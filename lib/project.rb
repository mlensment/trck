require 'model'
require 'organization'

class Project < Model
  attr_accessor :organization_name

  def organization=(organization)
    self.organization_name = organization.name
  end

  def organization
    Organization.find_by_name(organization_name)
  end

end