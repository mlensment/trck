require 'storage'
require 'task'

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

        if args.one?
          return Task.start_task(args) if action == 'start' # trck start 100
          return Task.remove_task(args) if action == 'remove' # trck remove 100
          return Project.list_tasks(args) if action == 'tasks' # trck tasks abahn
          return Project.exit if action == 'exit' # trck exit project
          return Project.select(args) if action == 'select' #trck select myproject
        else
          return Project.start_task(args) if action == 'start' # trck start abahn 100
          return Project.remove_project(args) if action == 'remove' && get_arg(args, 'project')
          return Project.remove_task(args) if action == 'remove' # trck remove abahn 100
          return Task.list_tasks if action == 'tasks' # trck tasks
          return Task.stop_task if action == 'stop' # trck stop
          return Project.list_projects if action == 'projects' #trck projects
        end

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
      msg = Model.message(:you_havent_tracked_anything_yet) unless msg.length > 0
      msg
    end

    def running_tasks
      running = Task.running
      return '' unless running.any?
      msg = "Currently tracking task "
      t = running.first
      if t.project_name
        msg += "#{t.project_name} #{t.name} - #{t.formatted_duration}\n\n"
      else
        msg += "#{t.name} - #{t.formatted_duration}\n"
      end
      msg
    end

    def last_tracked_tasks
      projects = Project.all
      msg = "Last tracked tasks:\n"
      msg_i = ""

      projects.each do |p|
        space = false
        p.tasks.each_with_index do |t, i|
          next unless t.end_at
          msg_i += p.name + "\n" if i == 0
          msg_i += "  #{t.name} - #{t.formatted_duration}\n"
          space = true
        end
        msg_i += "\n" if space
      end

      tasks = Task.without_project

      tasks.each_with_index do |t, i|
        next unless t.end_at
        msg_i += Model.message(:without_project) + "\n" if i == 0
        msg_i += "  #{t.name} - #{t.formatted_duration}\n"
      end

      if msg_i.length > 0
        msg + msg_i
      else
        ""
      end
    end

    def self.sync

    end

    def get_arg args, arg
      if args.index(arg)
        args.delete_at(args.index(arg))
        args
      end
    end

  end
end