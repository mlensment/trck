require 'model'
require 'organization'

class Organization < Model
  attr_accessor :active

  def initialize args = {}
    self.active = false
    super
  end

  def mark_active
    Organization.all.each do |x|
      x.active = (x.name == self.name) ? true : false
      x.save
    end
    self.active = true
  end

  def active?
    active
  end

  class << self
    def find_active
      Organization.all.select(&:active).first
    end
  end
end
