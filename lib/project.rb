require 'digest/sha1'
require 'model'
require 'task'

class Project < Model
  attr_accessor :selected
  MESSAGES = {
    added_project: 'Added project %0',
    created_and_tracking_task_in_project: 'Created and tracking task %0 in project %1',
    removed_task_from_project: 'Removed task %0 from project %1',
    removed_project_with_all_its_tasks: 'Removed project %0 with all its tasks',
    now_tracking_in_project: 'Now tracking in project %0',
    now_tracking_without_a_project: 'Now tracking without a project',
    already_tracking_without_a_project: 'Already tracking without a project',
    no_tasks_found: 'No tasks found',
    no_projects_found: 'No projects found',
    cannot_add_task_project_not_saved: 'Cannot add task - project is not saved',
    project_was_not_found: 'Project %0 was not found'
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

  def select
    p = Project.find_selected
    if p
      p.selected = false
      p.save
    end

    self.selected = true
    save
  end

  def destroy
    tasks.each do |x|
      x.delete
    end
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
      projects = Project.all.collect{|x| (x.selected) ? '=> ' + x.name : x.name}
      return message(:no_projects_found) unless projects.any?
      projects.join("\n")
    end

    def list_tasks args
      p = Project.find_project(args[0])
      tasks = p.tasks.collect{|x| x.name + " - " + x.formatted_duration}
      return message(:no_tasks_found) unless tasks.any?
      tasks.join("\n")
    end

    def add args
      new({name: args[0]}).save
      return message(:added_project, args[0])
    end

    def select args
      p = Project.find_project(args[0])
      p.select
      message(:now_tracking_in_project, args[0])
    end

    def find_selected
      Project.all.select(&:selected).first
    end

    def get_selected_project_name
      selected = Project.find_selected
      selected.name if selected
    end

    def exit
      s = Project.find_selected
      if s
        s.selected = false
        s.save
        return message(:now_tracking_without_a_project)
      end
      message(:already_tracking_without_a_project)
    end

    def start_task args
      p = Project.find_project(args[0])
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

    def remove_project args
      p = Project.find_project(args[0])
      p.destroy
      message(:removed_project_with_all_its_tasks, args[0])
    end

    def find_project name
      p = Project.find_by_name(name)
      raise message(:project_was_not_found, name) unless p
      p
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