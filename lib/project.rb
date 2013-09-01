require 'digest/sha1'
require 'model'
require 'task'

class Project < Model
  attr_accessor :tasks
  MESSAGES = {
    added_project: 'Added project %0',

    no_projects_found: 'No projects found',
    cannot_add_task_project_not_saved: 'Cannot add task - project is not saved',
    project_was_not_found: 'Project %0 was not found',
    no_tasks_found: 'No tasks found',
    task_added_to_project: 'Task %0 was added to project %1',
    task_removed_from_project: 'Removed task %0 from project %1',
    task_not_found_in_project: 'Task %0 was not found in project %1',
    project_with_tasks_removed: 'Removed project %1 with all its tasks',
    task_started: 'Created and tracking task %0 in project %1',
    task_stopped: 'Finished tracking task %0 in project %1',
    task_created_and_started: 'Created and tracking task %0 in project %1'
  }

  def initialize args = {}
    self.tasks = {}
    self.primary_key = Project.generate_primary_key(args[:name])
    super
  end

  def add_task name
    raise message(:cannot_add_task_project_not_saved) unless persisted

    t = Task.new({
      name: name,
      project: self
    })

    self.tasks[name] = t
    save
    t
  end

  def find_task name
    tasks[name]
  end

  def remove_task name
    raise message(:task_not_found_in_project, name, self.name) unless tasks[name]
    tasks.delete(name)

    save
  end

  def remove
    delete
  end

  def valid?
    if Project.find_by_name(name) && !persisted
      raise self.class.message(:create_same_name_obj)
    end
    super
  end

  class << self
    def list
      projects = Project.all.collect(&:name)
      return message(:no_projects_found) unless projects.any?
      projects.join("\n")
    end

    def add args
      new({name: args[0]}).save
      return message(:added_project, args[0])
    end

    def find_by_name name
      s = Storage.load
      pk = generate_primary_key(name)
      s.data[:projects][pk]
    end

    def generate_primary_key name
      Digest::SHA1.hexdigest(name)
    end
  end

end