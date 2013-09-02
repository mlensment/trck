require 'digest/sha1'
require 'model'
require 'task'

class Project < Model
  MESSAGES = {
    added_project: 'Added project %0',
    created_and_tracking_task_in_project: 'Created and tracking task %0 in project %1',
    removed_task_from_project: 'Removed task %0 from project %1',

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
    self.primary_key = Project.generate_primary_key(args[:name])
    super
  end

  def add_task name
    raise message(:cannot_add_task_project_not_saved) unless persisted

    t = Task.new({
      name: name,
      project: self
    })

    save
    t
  end

  def tasks
    Task.all.select{|x| x.project_name == self.name}
  end

  def find_task name
    Task.find_by_name_and_project_name(name, self.name)
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
    def list_projects
      projects = Project.all.collect(&:name)
      return message(:no_projects_found) unless projects.any?
      projects.join("\n")
    end

    def list_tasks args
      p = Project.find_by_name(args[0])
      return message(:project_was_not_found, args[0]) unless p
      tasks = p.tasks.collect{|x| x.name + " - " + x.formatted_duration}
      return message(:no_tasks_found) unless tasks.any?
      tasks.join("\n")
    end

    def add args
      new({name: args[0]}).save
      return message(:added_project, args[0])
    end

    def start_task args
      p = Project.find_by_name(args[0])
      return message(:project_was_not_found, args[0]) unless p
      t = p.find_task(args[1])
      return Project.create_and_start_task(args) unless t
    end

    def create_and_start_task args
      Task.new({name: args[1], project_name: args[0]}).save.start
      message(:created_and_tracking_task_in_project, args[1], args[0])
    end

    def remove_task args
      t = Task.find_by_name_and_project_name(args[1], args[0])
      t.delete
      message(:removed_task_from_project, args[1], args[0])
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