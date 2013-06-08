require 'storage'

class Trck
  def self.setup input
    @storage = Storage.load
    @storage.setup(input)
  end

  def self.org org

  end

  def self.sync

  end
end