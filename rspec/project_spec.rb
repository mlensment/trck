require 'project'

describe Project do
  before(:each) do
    s = Storage.load
    s.reset
  end

  it 'creates project' do
    p = Project.new({
      name: 'cofi'
    })

    p.save.should be_true

    o = Organization.new('deskrock')
    p = Project.new({
      name: 'ccs',
      organization: o
    })

    p.save.should be_true

    p = Project.new({
      name: 'ccs',
      organization: o
    })

    p.save.should be_false
    p.errors.include?('Can not create two projects with same name')
  end

  it 'returns project' do
    o = Organization.new('deskrock')
    o.save
    p = Project.new({
      name: 'ccs',
      organization: o
    })
    p.save

    p = Project.find_by_name('ccs')
    p.name.should eq('ccs')
    p.organization.name.should eq('deskrock')
  end

  it 'deletes project' do
    p = Project.new({
      name: 'cofi'
    })

    p.save

    Project.all.length.should eq(1)

    p.delete

    Project.all.length.should eq(0)
  end
end