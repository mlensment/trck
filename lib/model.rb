require 'digest/sha1'
require 'storage'
require 'pry'

class Model
  attr_accessor :primary_key ,:name, :persisted, :messages

  MESSAGES = {
    create_same_name_obj: "Cannot create two {class_name}s with the same name",
    create_without_name_obj: "Cannot create {class_name} without name",
    not_found: "%0 %1 was not found",
    you_havent_tracked_anything_yet: "You haven't tracked anything yet"
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

  def valid?
    s = Storage.load
    raise self.message(:create_without_name_obj) unless self.name
    true
  end

  def save
    if valid?
      s = Storage.load
      self.persisted = true
      s.data[(self.class.name.downcase + 's').to_sym].delete(self.primary_key)
      s.data[(self.class.name.downcase + 's').to_sym][self.primary_key] = self
      (s.save) ? self : false
    else
      false
    end
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

  def generate_primary_key
    if defined?(self.project) && self.project
      p = self.project.name
    end
    Digest::SHA1.hexdigest(p + '-' + self.name)
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

    def all
      s = Storage.load
      s.data[(self.name.downcase + 's').to_sym].collect{|k, v| v}
    end
  end
end