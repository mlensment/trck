require 'model'
require 'organization'
require 'task'

class Project < Model
  attr_accessor :organization_name

  def organization=(organization)
    self.organization_name = organization.name
  end

  def organization
    Organization.find_by_name(organization_name)
  end

  def add_task name
    unless persisted
      messages << 'Cannot add task - project is not saved'
      return false
    end

    t = Task.new({
      name: self.name + '-' + name,
      project: self
    })

    (t.save) ? t : false
  end

  def tasks
    Task.all.select{|x| x.project_name == self.name}
  end

end