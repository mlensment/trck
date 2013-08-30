require 'model'
require 'task'

class Project < Model
  attr_accessor :tasks
  MESSAGES = {
    project_added: 'Added project %0',
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

  class << self
    def list
      projects = Project.all.collect(&:name)
      return message(:no_projects_found) unless projects.any?
      projects.join("\n")
    end

    def list_tasks name
      p = Project.find_by_name(name)
      return message(:no_tasks_found) unless p.tasks.any?
      p.tasks.collect do |k, v|
       "#{v.name} - #{v.formatted_duration}"
      end.join("\n")
    end

    def add args
      p = new args[0]
      p.save
      message(:project_added, p.name)
    end

    def add_task args
      p = Project.find_by_name(args[0])
      p.add_task(args[1])
      message(:task_added_to_project, args[1], args[0])
    end

    def remove args
      p = Project.find_by_name(args[0])
      return message(:project_was_not_found, args[0]) unless p
      p.destroy
      message(:project_with_tasks_removed, args[0])
    end

    def remove_task args
      p = Project.find_by_name(args[0])
      p.remove_task(args[1])
      message(:task_removed_from_project, args[1], args[0])
    end

    def create_start args
      p = Project.find_by_name(args[0])
      t = p.add_task(args[1])
      t.start
      message(:task_created_and_started, args[1], p.name)
    end

    def start_task args
      p = Project.find_by_name(args[0])
      t = p.find_task(args[1])
      return create_start args unless t
      t.start
      message(:task_started, args[1])
    end

    def stop_task args
      p = Project.find_by_name(args[0])
      t = p.find_task(args[1])
      t.stop
      message(:task_stopped, args[1])
    end
  end

end