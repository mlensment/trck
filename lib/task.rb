require 'model'
require 'organization'
require 'project'

class Task < Model
  attr_accessor :organization_name, :project_name, :start_at, :end_at, :running, :duration

  MESSAGES = {
    task_added: 'Task %0 was added',
    task_removed: 'Task %0 was removed',
    task_started: 'Task %0 was started',
    task_stopped: 'Task %0 was stopped',
    task_not_running: 'Task %0 is not running',
    task_already_started: 'Task %0 already started',
    no_tasks_found: 'No tasks found',
    task_was_not_found: 'Task %0 was not found'
  }

  def initialize args = {}
    self.duration = 0
    super
  end

  def organization=(organization)
    self.organization_name = organization.name
  end

  def organization
    Organization.find_by_name(organization_name)
  end

  def project=(project)
    self.project_name = project.name
  end

  def project
    Project.find_by_name(project_name)
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
    def list
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
      t = new args[0]
      t.save ? message(:task_added, t.name) : t.messages.first
    end

    def remove args
      t = Task.find_by_name(args[0])
      t.delete ? t.message(:task_removed, t.name) : t.messages.first
    end

    def start args
      if args.length == 1
        t = Task.find_by_name args[0]
        return message(:task_was_not_found, args[0]) unless t
        t.start ? message(:task_started, args[0]) : t.messages.first
      else
        #TODO
      end
    end

    def stop args
      if args.length == 1
        t = Task.find_by_name args[0]
        return message(:task_was_not_found, args[0]) unless t
        t.stop ? message(:task_stopped, args[0]) : t.messages.first
      else
        #TODO
      end
    end
  end
end