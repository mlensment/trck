require 'trck'

describe Trck do
  before(:each) do
    s = Storage.load
    s.reset
    # @o1 = Organization.new('deskrock')

    # @o1.save
    # @o2 = Organization.new('friendlyfinance')
    # @o2.save

    # Trck.add('task', '100')
    # Trck.add('task', '200')
    # Trck.add('task', '300')
  end

  # it 'returns all organizations' do
  #   Trck.org.should eq("deskrock\nfriendlyfinance")
  #   Organization.find_by_name('deskrock').mark_active
  #   Trck.org.should eq("=> deskrock\nfriendlyfinance")
  #   Organization.find_by_name('friendlyfinance').mark_active
  #   Trck.org.should eq("deskrock\n=> friendlyfinance")
  # endff

  # it 'switches organization' do
  #   Trck.org('deskrock').should eq('Organization deskrock was marked as default')
  #   Organization.find_by_name('deskrock').active?.should be_true
  #   Trck.org('friendlyfinance').should eq('Organization friendlyfinance was marked as default')
  #   Organization.find_by_name('deskrock').active?.should be_false
  #   Organization.find_by_name('friendlyfinance').active?.should be_true

  #   Trck.org('skype').should eq('Organization skype was not found')
  # end

  # it 'adds organization' do
  #   Trck.add('organization', 'skype').should eq('Organization skype was added')
  #   Organization.all.length.should eq(3)
  #   Trck.add('organization', 'skype').should eq('Cannot create two organizations with same name')
  # end

  # it 'destroys organization' do
  #   Trck.remove('organization', '-R', 'deskrock').should eq('Organization deskrock with projects and tasks was removed')
  #   Organization.all.length.should eq(1)

  #   Trck.remove('organization', '-R', 'deskrock').should eq('Organization deskrock was not found')
  # end

  # it 'deletes organization' do
  #   Trck.remove('organization', 'deskrock').should eq('Organization deskrock was removed')
  #   Organization.all.length.should eq(1)
  # end

  # it 'adds task' do
  #   Trck.add('task', '400').should eq('Task 400 was added')
  #   Trck.add('task', '400').should eq('Cannot create two tasks with same name')
  # end

  # it 'lists tasks' do
  #   Trck.task.should eq("100\n200\n300")
  # end

  # it 'removes tasks' do
  #   Trck.task('remove', '400').should eq('Task 400 was not found')
  #   Trck.task('remove', '100').should eq('Task 100 was removed')
  #   Task.all.length.should eq(2)
  # end

  # it 'adds project' do
  #   Trck.add('project', 'ccs').should eq('Project ccs was added')
  #   Trck.add('project', 'ccs').should eq('Cannot create two projects with same name')
  # end

  # it 'adds project to organization' do
  #   @o1.mark_active
  #   Trck.add('project', 'ccs').should eq('Project ccs was added to organization deskrock')
  #   @o1.reload
  #   @o1.projects.length.should eq(1)
  #   Trck.add('project', 'ccs').should eq('Cannot create two projects with same name')
  # end


  it 'does everything' do
    #trck setup 389949494

    #trct add task 100
    Trck.add('task', '100').should eq('Task 100 was added')
    Trck.add('task', '100').should eq('Cannot create two tasks with same name')

    #trck start 100
    Trck.start('100').should eq('Task 100 was started')
    Trck.start('100').should eq('Task 100 already started')

    Trck.status.should eq("
      Currently running tasks:\n
      100 - 0h 0m 0s
    ")

    Trck.stop('100').should eq('Task 100 was stopped')
    Trck.stop('100').should eq('Task 100 is not running')

    Trck.status.should eq("
      Last tracked tasks:\n
      100 - 0h 0m 0s
    ")

    Trck.task.should eq("
      Tasks:\n
      100 - 0h 0m 0s
    ")

    Trck.task('remove', '100').should eq('Task 100 was removed')

    Trck.task.should eq("
      No tasks found
    ")

    Trck.status.should eq("
      Last tracked tasks:\n
      No tasks found
    ")

    Trck.start('100').should eq('Task 100 was not found')
    Trck.add('task', '100').should eq('Task 100 was added')
    Trck.add('task', '200').should eq('Task 200 was added')

    Trck.start('100').should eq('Task 100 was started')
    Trck.start('200').should eq('Task 200 was started')

    Trck.status.should eq("
      Currently running tasks:\n
      100 - 0h 0m 0s\n
      200 - 0h 0m 0s\n\n
    ")

    Trck.stop('100').should eq('Task 100 was stopped')

    Trck.status.should eq("
      Currently running tasks:\n
      200 - 0h 0m 0s\n\n
      Last tracked tasks:\n
      100 - 0h 0m 0s
    ")

    Trck.stop('200').should eq('Task 200 was stopped')

    Trck.status.should eq("
      Last tracked tasks:\n
      200 - 0h 0m 0s\n
      100 - 0h 0m 0s
    ")

    Trck.add('project', 'chatroom').should eq('Project chatroom was added')
    Trck.add('project', 'chatroom').should eq('Cannot create two projects with same name')

    Trck.project.should eq("
      Projects:\n
      chatroom
    ")

    Trck.add('task', 'chatroom', '100').should eq('Task 100 was added to project chatroom')
    Trck.add('task', 'chatroom', '100').should eq('Cannot create two tasks with same name')

    Trck.project('abahn', 'tasks').should eq('Project abahn was not found')

    Trck.project('chatroom', 'tasks').should eq("
      Project chatroom tasks:\n
      100 - 0h 0m 0s
    ")
  end
end