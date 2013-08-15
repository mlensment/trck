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
    task_stopped: 'Finished tracking task %0 in project %1'
  }

  def add_task name
    add_message(:cannot_add_task_project_not_saved) and return false unless persisted

    t = Task.new({
      name: name,
      project: self
    })

    t.tasks << t
    if save
      add_message(:task_added_to_project, name)
      true
    end

    false
  end

  def find_task name
    tasks[name]
  end

  def remove_task name
    add_message(:task_not_found_in_project, name, self.name) and return false unless tasks[name]
    tasks.delete(name)

    if save
      add_message(:task_removed_from_project, name)
      true
    end

    false
  end

  def destroy
    if delete
      add_message(:project_with_tasks_removed, self.name)
      true
    end

    false
  end

  class << self
    def list
      projects = Project.all.collect(&:name)
      return message(:no_projects_found) unless projects.any?
      projects.join("\n")
    end

    def list_tasks name
      p = Project.find_by_name(name)
      return message(:project_was_not_found, name) unless p
      return message(:no_tasks_found) unless p.tasks.any?

      p.tasks.collect do |x|
       "#{x.name} - #{x.formatted_duration}"
      end.join("\n")
    end

    def add args
      p = new args[0]
      p.save ? message(:project_added, p.name) : p.messages.first
    end

    def add_task args
      p = Project.find_by_name(args[0])
      p.add_task(args[1]) ? message(:task_added_to_project, args[1], args[0]) : p.messages.first
    end

    def remove args
      p = Project.find_by_name(args[0])
      return message(:project_was_not_found, args[0]) unless p
      p.destroy ? message(:project_with_tasks_removed, args[0]) : p.messages.first
    end

    def remove_task args
      p = Project.find_by_name(args[0])
      p.remove_task(args[1]) ? message(:task_removed_from_project, args[1], args[0]) : p.messages.first
    end

    def start_task args
      p = Project.find_by_name(args[0])
      t = p.find_task(args[1])
      t.start ? message(:task_started, args[1]) : t.messages.first
    end

    def stop_task args
      p = Project.find_by_name(args[0])
      t = p.find_task(args[1])
      t.stop ? message(:task_stopped, args[1]) : t.messages.first
    end
  end

end