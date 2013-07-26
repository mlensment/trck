require 'model'
require 'organization'
require 'task'

class Project < Model
  attr_accessor :organization_name

  MESSAGES = {
    project_added: 'Project %0 was added',
    no_projects_found: 'No projects found',
    cannot_add_task_project_not_saved: 'Cannot add task - project is not saved',
    project_was_not_found: 'Project %0 was not found',
    no_tasks_found: 'No tasks found',
    task_added_to_project: 'Task %0 was added to project %1',
    task_removed_from_project: 'Task %0 was removed from project %1',
    task_not_found_in_project: 'Task %0 was not found in project %1',
    project_with_tasks_removed: 'Project %0 with all tasks was removed'
  }

  def organization=(organization)
    self.organization_name = organization.name
  end

  def organization
    Organization.find_by_name(organization_name)
  end

  def add_task name
    add_message(:cannot_add_task_project_not_saved) and return false unless persisted

    t = Task.new({
      name: self.name + '-' + name,
      project: self
    })

    if t.save
      return true
    else
      messages << t.messages.first
      false
    end
  end

  def tasks
    Task.all.select{|x| x.project_name == self.name}
  end

  def find_task name
    tasks.select{|x| x.name == self.name + '-' + name}.first
  end

  def remove_task name
    t = find_task(name)
    add_message(:task_not_found_in_project, name, self.name) and return false unless t
    t.delete
  end

  def destroy
    tasks.each(&:delete)
    delete
  end

  class << self
    def list
      Organization.find_active ? Organization.list_projects : list_projects
    end

    def list_projects
      projects = Project.all.collect(&:name)
      return message(:no_projects_found) unless projects.any?
      projects.join("\n")
    end

    def list_tasks name
      p = Project.find_by_name(name)
      return message(:project_was_not_found, name) unless p
      return message(:no_tasks_found) unless p.tasks.any?

      p.tasks.collect do |x|
       "#{x.name.sub(name + '-', '')} - #{x.formatted_duration}"
      end.join("\n")
    end

    def add args
      Organization.find_active ? Organization.add_project(args) : add_project(args)
    end

    def add_project args
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
      # t.start ?
    end
  end

end