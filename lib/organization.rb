require 'storage'
require 'pry'


class Organization
  attr_accessor :name, :errors, :persisted, :active

  def initialize args = {}
    self.errors = []
    self.persisted = false
    self.active = false

    if args.kind_of?(String)
      self.name = args
      return
    end

    args.each do |k, v|
      instance_variable_set("@#{k}", v)
    end

  end

  def mark_active
    Organization.all.each do |x|
      x.active = (x.name == self.name) ? true : false
      x.save
    end
    self.active = true
  end

  def reload!
    o = Organization.find_by_name(self.name)
    instance_variables.each do |k|
      instance_variable_set(k, o.instance_variable_get(k))
    end
  end

  def save
    s = Storage.load
    if valid?
      self.persisted = true
      s.data[:organizations][name] = to_hash
      s.save
    else
      false
    end
  end

  def valid?
    s = Storage.load
    self.errors = []
    if s.data[:organizations][name] && !persisted
      self.errors << 'Cannot create two organizations with same name'
    end

    self.errors << 'Cannot create organization without name' unless name

    return false if errors.any?
    true
  end

  def active?
    active
  end

  def to_hash
    instance_variables.inject({}) { |hash, var|
      hash[var[1..-1].to_sym] = instance_variable_get(var);hash
    }
  end

  class << self
    def all
      s = Storage.load
      s.data[:organizations].collect{|k, v| Organization.new(v)}
    end

    def find_by_name name
      s = Storage.load
      if s.data[:organizations][name]
        Organization.new(s.data[:organizations][name])
      end
    end

    def find_active
      Organization.all.select(&:active).first
    end

  end
end
