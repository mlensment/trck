require 'organization'

describe Organization do
  before(:each) do
    s = Storage.load
    s.reset
  end

  it 'creates and return organization' do
    Organization.find_by_name('deskrock').should eq(nil)

    o = Organization.new('deskrock')
    o.save.should eq(true)

    o = Organization.find_by_name 'deskrock'
    o.name.should eq('deskrock')
  end

  it 'does not create two organizations with same name' do
    o = Organization.new('deskrock')
    o.save.should be_true

    o.name = nil
    o.save.should be_false
    o.errors.include?('Cannot create organization without name')

    o = Organization.new('deskrock')
    o.save.should be_false
    o.errors.include?('Cannot create two organizations with same name')
  end

  it 'adds project' do
    o = Organization.new('deskrock')
    o.add_project('ccs').should eq(false)
    o.errors.include?('Cannot add project - organization is not saved')

    o.save
    o.add_project('ccs').kind_of?(Project).should be_true
    o.add_project('cofi')

    o.projects.length.should eq(2)

    o.projects.first.name.should eq('ccs')
    o.projects.last.name.should eq('cofi')

    o2 = Organization.new('friendlyfinance')
    o2.save
    o2.add_project('foo')

    o2.projects.length.should eq(1)

    o2.add_project('bar')
    o2.projects.length.should eq(2)
  end

  it 'finds project by name' do
    o = Organization.new('deskrock')
    o.save

    o.add_project('ccs')
    p = o.find_project 'ccs'
    p.name.should eq('ccs')
  end

  context 'when multiple organizations' do
    before(:each) do
      @o1 = Organization.new('deskrock')
      @o1.save
      @o2 = Organization.new('friendlyfinance')
      @o2.save
    end

    it 'returns all organizations' do
      all = Organization.all
      all.length.should eq(2)

      all.first.name.should eq('deskrock')
      all.last.name.should eq('friendlyfinance')
    end

    it 'finds active organization' do
      dr = Organization.find_by_name('deskrock')
      dr.mark_active
      dr.active?.should be_true

      ac = Organization.find_active
      ac.kind_of?(Organization).should be_true
      ac.active?.should be_true
      ac.name.should eq('deskrock')

      ff = Organization.find_by_name('friendlyfinance')
      ff.active?.should be_false

      ff.mark_active

      dr.reload!

      dr.active?.should be_false
      ff.active?.should be_true

      ac = Organization.find_active
      ac.active.should be_true
      ac.name.should eq('friendlyfinance')
    end

    it 'deletes project' do
      #with delete method
      p = @o1.add_project('ccs')
      @o1.projects.length.should eq(1)

      p.delete
      @o1.projects.length.should eq(0)

      #with remove method
      @o1.add_project('ccs')
      @o1.add_project('cofi')
      @o1.projects.length.should eq(2)

      @o2.add_project('foo')
      @o2.add_project('bar')
      @o2.projects.length.should eq(2)

      @o1.remove_project('ccs')
      @o1.projects.length.should eq(1)
      @o2.projects.length.should eq(2)

      @o1.remove_project('cofi')
      @o1.projects.length.should eq(0)
      @o2.projects.length.should eq(2)

      @o2.remove_project('foo')
      @o2.remove_project('bar')
      @o2.projects.length.should eq(0)
    end

    it 'deletes organization and projects' do
      @o1.add_project('ccs')
      @o1.add_project('cofi')
      @o2.add_project('foo')
      @o2.add_project('bar')

      Organization.all.length.should eq(2)
      Project.all.length.should eq(4)

      @o1.destroy

      Organization.all.length.should eq(1)
      Project.all.length.should eq(2)

      @o2.destroy

      Organization.all.length.should eq(0)
      Project.all.length.should eq(0)
    end
  end
end