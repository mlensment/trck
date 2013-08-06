require 'model'
require 'project'

class Organization < Model
  attr_accessor :active

  MESSAGES = {
    org_not_saved: 'Cannot add project - organization is not saved',
    org_added: 'Organization %0 was added',
    no_organizations_found: 'No organizations found',
    org_not_found: 'Organization %0 was not found',
    org_selected: 'Organization %0 was selected',
    projects_not_found_in_org: 'No projects found in organization %0',
    project_added_to_org: 'Project %0 was added to organization %1',
    projects_in_org: 'Projects in organization %0:'
  }

  def initialize args = {}
    self.active = false
    super
  end

  def add_project name
    unless persisted
      add_message(:org_not_saved)
      return false
    end

    p = Project.new({
      name: name,
      organization: self
    })

    p.save
  end

  def remove_project name
    find_project(name).delete
  end

  def projects
    Project.all.select{|x| x.organization_name == self.name}
  end

  def find_project name
    projects.select{|x| x.name == name}.first
  end

  def destroy
    projects.each(&:delete);delete
  end

  def mark_active
    Organization.all.each do |x|
      x.active = (x.name == self.name) ? true : false
      x.save
    end
    self.active = true
  end

  def active?
    active
  end

  class << self
    def list
      os = Organization.all
      return message(:no_organizations_found) unless os.any?
      os.collect{|x|
        x.active? ? "=> #{x.name}" : "#{x.name}"
      }.join("\n")
    end

    def list_projects
      o = Organization.find_active
      return message(:projects_not_found_in_org, o.name) unless o.projects.any?
      msg = message(:projects_in_org, o.name) + "\n"
      msg += o.projects.collect(&:name).join("\n")
    end

    def select args
      o = Organization.find(args[0])
      return message(:org_not_found, args[0]) unless o
      o.mark_active ? message(:org_selected, args[0]) : o.messages.first
    end

    def add args
      o = new(args[0])
      o.save ? message(:org_added, args[0]) : o.messages.first
    end

    def add_project args
      o = Organization.find_active
      o.add_project(args[0]) ? message(:project_added_to_org, args[0], o.name) : o.messages.first
    end

    def find_active
      Organization.all.select(&:active).first
    end
  end
end
