require 'storage'
require 'pry'

class Model
  attr_accessor :name, :errors, :persisted

  def initialize args = {}
    self.errors = []
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
    self.errors = []
    if s.data[(self.class.name.downcase + 's').to_sym][name] && !persisted
      self.errors << "Cannot create two #{(self.class.name.downcase) + 's'} with same name"
    end

    self.errors << "Cannot create #{self.class.name.downcase} without name" unless name

    return false if errors.any?
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

  class << self
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