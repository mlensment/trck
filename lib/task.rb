require 'model'
require 'project'

class Task < Model
  attr_accessor :project_name, :start_at, :end_at, :running, :duration

  MESSAGES = {
    task_removed: 'Removed task %0',
    task_started: 'Tracking task %0',
    task_stopped: 'Finished tracking task %0',
    task_already_started: 'Already tracking task %0',
    no_tasks_found: 'No tasks found',
    task_not_running: 'No tasks are being tracked',
    task_created_and_started: 'Created and tracking task %0',
    task_stopped_created_and_started: 'Finished tracking task %0, created and tracking task %1',
    task_stopped_in_project: 'Finished tracking task %0 in project %1'
  }

  def initialize args = {}
    self.duration = 0
    super
  end

  def project=(project)
    self.project_name = project.name
  end

  def project
    Project.find_by_name(project_name)
  end

  def start
    raise message(:task_already_started, name) if running
    self.start_at = Time.now
    self.running = true

    save
  end

  def stop
    raise message(:task_not_running, name) unless running

    self.end_at = Time.now
    self.duration = (end_at - start_at).to_i
    self.running = false

    save
  end

  def formatted_duration
    hours = duration / 3600.to_i
    minutes = (duration / 60 - hours * 60).to_i
    seconds = (duration - (minutes * 60 + hours * 3600))
    return "#{hours}h #{minutes}m #{seconds}s"
  end

  def save
    if project
      project.save
    else
      save
    end
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
      t.save
      message(:task_added, t.name)
    end

    def remove_task args
      t = Task.find_by_name(args[0])
      t.delete
      message(:task_removed, t.name)
    end

    def remove args
      args.one? ? remove_task(args) : Project.remove_task(args)
    end

    def start args
      args.one? ? start_task(args) : Project.start_task(args)
    end

    def stop
      t = Task.all.select(&:running).first
      return message(:task_not_running) unless t
      t.stop
      return message(:task_stopped_in_project, t.name, t.project.name) if t.project
      message(:task_stopped, t.name)
    end

    def stop_create_start(args)
      t_stop = Task.all.select(&:running).first.stop
      t_start = new(args[0]).save
      t_start.start
      message(:task_stopped_created_and_started, t_stop.name, t_start.name)
    end

    def start_task args
      t = Task.find_by_name(args[0])
      return stop_create_start(args) if running.any? && !t

      if t
        t.start
        message(:task_started, t.name)
      else
        t = new(args[0]).save
        t.start
        message(:task_created_and_started, args[0])
      end
    end

    def stop_task args
      t = Task.find_by_name(args[0])
      return message(:task_was_not_found, args[0]) unless t
      t.stop
      message(:task_stopped, args[0])
    end

    def all
      s = Storage.load
      s.data[(self.name.downcase + 's').to_sym].collect{|k, v| v}
      s.data[:project]
    end
  end
end