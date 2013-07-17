require 'model'
require 'organization'
require 'project'

class Task < Model
  attr_accessor :organization_name, :project_name, :start_at, :end_at, :running, :duration

  MESSAGES = {
    task_added: 'Task %0 was added',
    task_started: 'Task %0 was started',
    task_stopped: 'Task %0 was stopped',
    task_not_running: 'Task %0 is not running',
    task_already_started: 'Task %0 already started'
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
    return message(:task_already_started, name) if running

    self.start_at = Time.now
    self.running = true
    save ? message(:task_started, name) :  messages.first
  end

  def stop
    return message(:task_not_running, name) unless running

    self.end_at = Time.now
    self.duration = (end_at - start_at).to_i
    self.running = false
    save ? message(:task_stopped, name) :  messages.first
  end

  def formatted_duration
    hours = duration / 3600.to_i
    minutes = (duration / 60 - hours * 60).to_i
    seconds = (duration - (minutes * 60 + hours * 3600))
    return "#{hours}h #{minutes}m #{seconds}s"
  end

  class << self
    def running
      Task.all.select(&:running)
    end

    def add args
      t = new args[0]
      (t.save) ? t.message(:task_added, t.name) : t.messages.first
    end

    def start args
      if args.length == 1
        t = Task.find_by_name args[0]
        t.start
      else
        #TODO
      end
    end

    def stop args
      if args.length == 1
        t = Task.find_by_name args[0]
        t.stop
      else
        #TODO
      end
    end
  end
end