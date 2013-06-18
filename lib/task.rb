require 'model'
require 'organization'
require 'project'

class Task < Model
  attr_accessor :organization_name, :project_name, :start_at, :end_at, :running, :duration

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

  def start
    self.start_at = Time.now
    self.running = true
    save
  end

  def stop
    self.end_at = Time.now
    self.duration = (end_at - start_at).to_i
    self.running = false
    save
  end

end