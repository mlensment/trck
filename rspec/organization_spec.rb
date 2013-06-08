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

  it 'returns projects'

  context 'when multiple organizations' do
    before(:each) do
      Organization.new('deskrock').save
      Organization.new('friendlyfinance').save
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
  end
end