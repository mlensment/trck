require 'model'
require 'project'

class Organization < Model
  attr_accessor :active

  MESSAGES = {
    org_not_saved: 'Cannot add project - organization is not saved',
    org_added: 'Organization {org_name} was added'
  }

  def initialize args = {}
    self.active = false
    super
  end

  def add_project name
    unless persisted
      message(:org_not_saved)
      return false
    end

    p = Project.new({
      name: name,
      organization: self
    })

    p.save ? p : false
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
    def add name
      o = new(name)
      (o.save) ? message(:org_added, name) : o.messages.first
    end

    def find_active
      Organization.all.select(&:active).first
    end
  end
end
