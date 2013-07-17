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
    p.messages.include?('Can not create two projects with same name')
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

  it 'adds and returns tasks' do
    p = Project.new({
      name: 'cofi'
    })

    p.add_task('100').should be_false
    p.messages.include?('Cannot add project - organization is not saved')
    p.save

    p.add_task('100').kind_of?(Task).should be_true
    p.tasks.length.should eq(1)
    p.add_task('100').kind_of?(Task).should be_false
    p.add_task('200').kind_of?(Task).should be_true
    p.tasks.length.should eq(2)


  end
end