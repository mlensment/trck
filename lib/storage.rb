require "pstore"

class Storage
  attr_accessor :pstore, :data

  def self.load
    s = self.new
    s.pstore = PStore.new("trck.pstore")
    s.data = s.get('data')
    unless s.data
      s.setup
      s.data = s.get('data')
    end
    s
  end

  def save
    @pstore.transaction do
      @pstore['data'] = data
    end

    true
  end

  def get key
    @pstore.transaction(true) do
      return @pstore[key]
    end
  end

  def setup input = nil
    self.data = get('data')

    if self.data
      self.data[:api_key] = input
    else
      self.data = {
        api_url: 'http://localhost:3000',
        api_key: input,
        organizations: {},
        projects: {},
        tasks: {}
      }
    end

    save
  end

  def reset
    self.data = {
        api_url: 'http://localhost:3000',
        api_key: nil,
        organizations: {},
        projects: {},
        tasks: {}
      }

    save
  end
end