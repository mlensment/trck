require 'digest/sha1'
require 'storage'
require 'pry'

class Model
  attr_accessor :name, :persisted, :messages

  MESSAGES = {
    create_same_name_obj: "Cannot create two {class_name}s with the same name",
    create_without_name_obj: "Cannot create {class_name} without name",
    not_found: "%0 %1 was not found"
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

    if find_from_db && !persisted
      raise self.class.message(:create_same_name_obj)
    end

    raise self.message(:create_without_name_obj) unless name
    true
  end

  def save
    if valid?
      s = Storage.load
      self.persisted = true
      s.data[(self.class.name.downcase + 's').to_sym].delete(name)
      s.data[(self.class.name.downcase + 's').to_sym][name] = self
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

  def find_from_db
    s = Storage.load
    s.data[(self.class.name.downcase + 's').to_sym][name]
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
      ret = s.data[(self.name.downcase + 's').to_sym][name]
      raise message(:not_found, self.name, name) unless ret
      ret
    end

    def find k
      return nil unless k
      s = Storage.load
      k = Digest::SHA1.hexdigest(k)
      s.data[(self.name.downcase + 's').to_sym][k]
    end

    def all
      s = Storage.load
      s.data[(self.name.downcase + 's').to_sym].collect{|k, v| v}
    end
  end
end