require 'storage'
require 'organization'

class Trck
  class << self
    def setup input
      @storage = Storage.load
      @storage.setup(input)
    end

    def execute args
      begin
        args =  args.split(' ') if args.kind_of?(String)
        action = args.shift

        return status if action == 'status'
        return Task.start(args) if action == 'start'
        return Task.stop if action == 'stop'
        return Task.remove(args) if action == 'remove'
        return Task.list(args) if action == 'tasks'
        return Project.list if action == 'projects'

        model = args.shift
        model = Module.const_get(model.capitalize)
        options = args
        model.send(action, options)
      rescue Exception => e
        e.message
      end
    end

    def status
      msg = ''
      msg += running_tasks
      msg += last_tracked_tasks
      msg
    end

    def running_tasks
      running = Task.running
      return '' unless running.any?
      msg = "Currently tracking tasks:\n"
      running.each do |x|
        msg += "#{x.name} - #{x.formatted_duration}\n"
      end
      msg
    end

    def last_tracked_tasks
      tracked = Task.tracked
      return '' unless tracked.any?
      msg = "Last tracked tasks:\n"
      tracked.each do |x|
        msg += "#{x.name} - #{x.formatted_duration}\n"
      end
      msg
    end

    def self.sync

    end

    def get_arg args, arg
      if args.index('-R')
        args.delete_at(args.index('-R'))
        args
      end
    end

  end
end