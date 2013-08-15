require 'model'
require 'project'

class Task < Model
  attr_accessor :project_name, :start_at, :end_at, :running, :duration

  MESSAGES = {
    task_removed: 'Removed task %0',
    task_started: 'Created and tracking task %0',
    task_stopped: 'Finished tracking task %0',
    task_already_started: 'Already tracking task %0',
    no_tasks_found: 'No tasks found',
    task_not_running: 'No tasks are being tracked'
  }

  def initialize args = {}
    self.duration = 0
    super
  end

  def project=(project)
    self.project_name = project.name
  end

  def project
    Project.find("#{project_name}")
  end

  def start
    add_message(:task_already_started, name) and return false if running

    self.start_at = Time.now
    self.running = true

    if save
      add_message(:task_started, name)
      return true
    end

    false
  end

  def stop
    add_message(:task_not_running, name) and return false unless running

    self.end_at = Time.now
    self.duration = (end_at - start_at).to_i
    self.running = false

    if save
      add_message(:task_stopped, name)
      return true
    end

    false
  end

  def formatted_duration
    hours = duration / 3600.to_i
    minutes = (duration / 60 - hours * 60).to_i
    seconds = (duration - (minutes * 60 + hours * 3600))
    return "#{hours}h #{minutes}m #{seconds}s"
  end

  class << self
    def list args
      args.empty? ? list_tasks : Project.list_tasks(args[0])
    end

    def list_tasks
      tasks = Task.all.collect{|x| "#{x.name} - #{x.formatted_duration}"}
      return message(:no_tasks_found) unless tasks.any?
      tasks.join("\n")
    end

    def running
      Task.all.select(&:running)
    end

    def tracked
      Task.all.select{|x| x.start_at && !x.running}
    end

    def add args
      args.one? ? add_task(args) : Project.add_task(args)
    end

    def add_task args
      t = new args[0]
      t.save ? message(:task_added, t.name) : t.messages.first
    end

    def remove_task args
      t = Task.find_by_name(args[0])
      t.delete ? t.message(:task_removed, t.name) : t.messages.first
    end

    def remove args
      args.one? ? remove_task(args) : Project.remove_task(args)
    end

    def start args
      args.one? ? start_task(args) : Project.start_task(args)
    end

    def stop args
      args.one? ? stop_task(args) : Project.stop_task(args)
    end

    def start_task args
      t = Task.find_by_name(args[0])
      return message(:task_was_not_found, args[0]) unless t
      t.start ? message(:task_started, args[0]) : t.messages.first
    end

    def stop_task args
      t = Task.find_by_name(args[0])
      return message(:task_was_not_found, args[0]) unless t
      t.stop ? message(:task_stopped, args[0]) : t.messages.first
    end
  end
end