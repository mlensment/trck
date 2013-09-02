require 'digest/sha1'
require 'model'
require 'project'

class Task < Model
  attr_accessor :project_name, :start_at, :end_at, :running, :duration

  MESSAGES = {
    no_tasks_are_being_tracked: 'No tasks are being tracked',
    finished_tracking_task: 'Finished tracking task %0',
    removed_task: 'Removed task %0',
    finished_tracking_task_created_and_tracking_task: 'Finished tracking task %0, created and tracking task %1',
    finished_tracking_task_created_and_tracking_task_in_project: 'Finished tracking task %0, created and tracking task %1 in project %2',
    project_was_not_found: 'Project %0 was not found',
    finished_tracking_task_in_project: 'Finished tracking task %0 in project %1',
    created_and_tracking_task_in_project: 'Created and tracking task %0 in project %1',

    task_removed: 'Removed task %0',
    task_started: 'Tracking task %0',
    task_stopped: 'Finished tracking task %0',
    already_tracking_task: 'Already tracking task %0',
    no_tasks_found: 'No tasks found',
    task_not_running: 'No tasks are being tracked',
    created_and_tracking_task: 'Created and tracking task %0',
    task_stopped_created_and_started: 'Finished tracking task %0, created and tracking task %1',
    task_stopped_in_project: 'Finished tracking task %0 in project %1'
  }

  def initialize args = {}
    self.duration = 0

    if args[:project_name]
      p = Project.find_by_name(args[:project_name])
      raise message(:project_was_not_found, project_name) unless p
    end

    self.primary_key = Task.generate_primary_key(args[:name], args[:project_name])
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

  def valid?
    if Task.find_by_name_and_project_name(name, project_name) && !persisted
      raise self.class.message(:create_same_name_obj)
    end
    super
  end

  def running?
    self.running
  end

  class << self
    def list_tasks
      tasks = Task.without_project.collect{|x| x.name + " - " + x.formatted_duration}
      return message(:no_tasks_found) unless tasks.any?
      return tasks.join("\n")
    end

    def remove_task args
      t = Task.find_by_name_and_project_name(args[0])
      t.delete
      return message(:removed_task, t.name)
    end

    def start_task args
      t = Task.find_by_name_and_project_name(args[0])

      if t
        return message(:already_tracking_task, args[0]) if t.running?
      else
        return Task.stop_and_create_and_start(args[0]) if Task.running.any? && !t
        return Task.create_and_start(args[0]) unless t
      end
    end

    def stop_task
      t = running.first
      return message(:no_tasks_are_being_tracked) unless t
      t.stop
      return message(:finished_tracking_task, t.name) unless t.project_name
      message(:finished_tracking_task_in_project, t.name, t.project_name)
    end

    def create_and_start name, project_name = nil
      project_name = project_name || Project.get_selected_project_name
      new({name: name, project_name: project_name}).save.start
      return message(:created_and_tracking_task, name) unless project_name
      message(:created_and_tracking_task_in_project, name, project_name)
    end

    def stop_and_create_and_start name, project_name = nil
      project_name = project_name || Project.get_selected_project_name
      t = Task.running.first.stop
      new({name: name, project_name: project_name}).save.start
      return message(:finished_tracking_task_created_and_tracking_task, t.name, name) unless project_name
      message(:finished_tracking_task_created_and_tracking_task_in_project, t.name, name, project_name)
    end

    ### SCOPES ###
    def without_project
      Task.all.select{|x| !x.project_name}
    end

    def running
      Task.all.select(&:running)
    end

    def tracked
      Task.all.select(&:end_at)
    end

    def find_by_name_and_project_name name, project_name = nil
      s = Storage.load
      pk = generate_primary_key(name, project_name)
      s.data[:tasks][pk]
    end

    def generate_primary_key name, project_name = nil
      p = (project_name) ? project_name + '-' : ''
      Digest::SHA1.hexdigest(p + name)
    end
  end
end