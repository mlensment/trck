require 'storage'
require 'pry'

class Model
  attr_accessor :name, :persisted, :messages
  # ACTIONS = ["ADD","REMOVE"]

  # def execute action, options
  #   result = self.send(action, options) if ACTIONS.includes?(action)
  #   echo "#{self.class.to_s} #{action} #{result ? ok : not_ok}"
  # end

  MESSAGES = {
    create_same_name_obj: "Cannot create two {class_name}s with same name",
    create_without_name_obj: "Cannot create {class_name} without name"
  }

  def initialize args = {}
    self.messages = []
    self.persisted = false

    if args.kind_of?(String)
      self.name = args
      return
    end

    args.each do |k, v|
      send(k.to_s + '=', v)
    end
  end

  def reload!
    m = Module.const_get(self.class.name).find_by_name(self.name)
    instance_variables.each do |k|
      instance_variable_set(k, m.instance_variable_get(k))
    end
  end

  def to_hash
    instance_variables.inject({}) { |hash, var|
      hash[var[1..-1].to_sym] = instance_variable_get(var);hash
    }
  end

  def valid?
    s = Storage.load
    self.messages = []
    if s.data[(self.class.name.downcase + 's').to_sym][name] && !persisted
      messages << self.class.message(:create_same_name_obj)
    end

    messages << self.message(:create_without_name_obj) unless name

    return false if messages.any?
    true
  end

  def save
    s = Storage.load
    if valid?
      self.persisted = true
      s.data[(self.class.name.downcase + 's').to_sym][name] = to_hash
      (s.save) ? self : false
    else
      false
    end
  end

  def delete
    s = Storage.load
    s.data[(self.class.name.downcase + 's').to_sym].delete(name)
    s.save
  end

  def message key, *args
    msgs = MESSAGES.merge(self.class::MESSAGES)
    m = msgs[key].gsub('{class_name}', self.class.name.downcase)
    args.flatten.each_with_index do |x, i|
      m.gsub!('%' + i.to_s, x)
    end

    m
  end

  def add_message key, *args
    messages << message(key, args)
  end

  class << self
    def message key, *args
      msgs = MESSAGES.merge(self::MESSAGES)
      m = msgs[key].gsub('{class_name}', self.name.downcase)

      args.each_with_index do |x, i|
        m.gsub!('%' + i.to_s, x)
      end

      m
    end

    def find_by_name name
      s = Storage.load
      if s.data[(self.name.downcase + 's').to_sym][name]
        Module.const_get(self.name).new(s.data[(self.name.downcase + 's').to_sym][name])
      end
    end

    def all
      s = Storage.load
      s.data[(self.name.downcase + 's').to_sym].collect{|k, v|
        Module.const_get(self.name).new(v)
      }
    end
  end
end