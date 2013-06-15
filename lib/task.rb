require 'model'
require 'organization'
require 'project'

class Task < Model
  attr_accessor :organization_name, :project_name

  def organization=(organization)
    self.organization_name = organization.name
  end

  def organization
    Organization.find_by_name(organization_name)
  end

  def project=(project)
    self.project_name = project.name
  end

  def project
    Project.find_by_name(project_name)
  end

end