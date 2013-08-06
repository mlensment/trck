require 'digest/sha1'
require 'storage'
require 'pry'

class Model
  attr_accessor :primary_key, :name, :persisted, :messages
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

    if find_from_db && !persisted
      messages << self.class.message(:create_same_name_obj)
    end

    messages << self.message(:create_without_name_obj) unless name

    return false if messages.any?
    true
  end

  def save
    generate_primary_key unless primary_key
    if valid?
      s = Storage.load
      self.persisted = true
      s.data[(self.class.name.downcase + 's').to_sym].delete(primary_key)
      s.data[(self.class.name.downcase + 's').to_sym][primary_key] = self
      (s.save) ? self : false
    else
      false
    end
  end


  def generate_primary_key
    p = project.name if defined?(project) && project
    o = organization.name if defined?(organization) && organization
    self.primary_key = Digest::SHA1.hexdigest("#{name}#{p}#{o}")
  end

  def delete
    s = Storage.load
    s.data[(self.class.name.downcase + 's').to_sym].delete(self.primary_key)
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
    s.data[(self.class.name.downcase + 's').to_sym][primary_key]
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

      all = s.data[(self.name.downcase + 's').to_sym]
      all.select{|x| x[:name] == name}.first
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