require 'trck'

describe Trck do
  before(:each) do
    s = Storage.load
    s.reset
    @o1 = Organization.add_organization('deskrock')

    @o1.save
    @o2 = Organization.new('friendlyfinance')
    @o2.save
  end

  it 'returns all organizations' do
    Trck.org.should eq("deskrock\nfriendlyfinance")
    Organization.find_by_name('deskrock').mark_active
    Trck.org.should eq("=> deskrock\nfriendlyfinance")
    Organization.find_by_name('friendlyfinance').mark_active
    Trck.org.should eq("deskrock\n=> friendlyfinance")
  end

  it 'switches organization' do
    Trck.org('deskrock').should eq('Organization deskrock was marked as default')
    Organization.find_by_name('deskrock').active?.should be_true
    Trck.org('friendlyfinance').should eq('Organization friendlyfinance was marked as default')
    Organization.find_by_name('deskrock').active?.should be_false
    Organization.find_by_name('friendlyfinance').active?.should be_true

    Trck.org('skype').should eq('Organization skype was not found')
  end

  it 'adds organization' do
    Trck.org('add', 'skype').should eq('Organization skype added')
    Organization.all.length.should eq(3)
    Trck.org('add', 'skype').should eq('Cannot create two organizations with same name')
  end

  it 'removes organization' do
    Trck.org('remove', '-R', 'deskrock').should eq('Organization deskrock with projects and tasks removed')
    Organization.all.length.should eq(1)

    Trck.org('remove', '-R', 'deskrock').should eq('Organization deskrock was not found')
  end

  it 'adds project'
end