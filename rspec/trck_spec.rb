require 'trck'

def trck args
  Trck.execute(args)
end

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
    trck('add task 100').should eq('Task 100 was added')
    trck('add task 100').should eq('Cannot create two tasks with same name')

    trck('start 100').should eq('Task 100 was started')
    trck('start 100').should eq('Task 100 already started')

    trck('status').should eq("Currently running tasks:\n100 - 0h 0m 0s\n")

    trck('stop 100').should eq('Task 100 was stopped')
    trck('stop 100').should eq('Task 100 is not running')

    trck('status').should eq("Last tracked tasks:\n100 - 0h 0m 0s\n")

    trck('tasks').should eq("100 - 0h 0m 0s")

    trck('remove task 100').should eq('Task 100 was removed')

    trck('tasks').should eq("No tasks found")

    trck('status').should eq("")

    trck('start 100').should eq('Task 100 was not found')

    trck('add task 100').should eq('Task 100 was added')
    trck('add task 200').should eq('Task 200 was added')

    trck('start 100').should eq('Task 100 was started')
    trck('start 200').should eq('Task 200 was started')

    trck('status').should eq("Currently running tasks:\n100 - 0h 0m 0s\n200 - 0h 0m 0s\n")
    trck('stop 100').should eq('Task 100 was stopped')

    trck('status').should eq("Currently running tasks:\n200 - 0h 0m 0s\nLast tracked tasks:\n100 - 0h 0m 0s\n")

    trck('stop 200').should eq('Task 200 was stopped')

    trck('status').should eq("Last tracked tasks:\n100 - 0h 0m 0s\n200 - 0h 0m 0s\n")

    trck('projects').should eq("No projects found")

    trck('add project chatroom').should eq('Project chatroom was added')
    trck('add project chatroom').should eq('Cannot create two projects with same name')

    trck('projects').should eq("chatroom")

    trck('add task chatroom 100').should eq('Task 100 was added to project chatroom')
    trck('add task chatroom 100').should eq('Cannot create two tasks with same name')

    trck('tasks abahn').should eq('Project abahn was not found')

    trck('tasks chatroom').should eq('100 - 0h 0m 0s')

    trck('add task chatroom 200').should eq('Task 200 was added to project chatroom')

    trck('tasks chatroom').should eq("100 - 0h 0m 0s\n200 - 0h 0m 0s")

    trck('add project abahn').should eq('Project abahn was added')

    trck('projects').should eq("chatroom\nabahn")

    trck('tasks abahn').should eq('No tasks found')

    trck('remove task chatroom 100').should eq('Task 100 was removed from project chatroom')

    trck('remove task chatroom 100').should eq('Task 100 was not found in project chatroom')

    trck('tasks chatroom').should eq("200 - 0h 0m 0s")

    trck('remove project abahn').should eq('Project abahn with all tasks was removed')

    trck('remove project abahn').should eq('Project abahn was not found')

    trck('remove project chatroom').should eq('Project chatroom with all tasks was removed')

    trck('projects').should eq("No projects found")

    trck('add project abahn').should eq('Project abahn was added')

    trck('organizations').should eq('No organizations found')

    trck('add organization deskrock').should eq('Organization deskrock was added')

    trck('organizations').should eq('deskrock')

    trck('add organization friendlyfinance').should eq('Organization friendlyfinance was added')
    trck('add organization friendlyfinance').should eq('Cannot create two organizations with same name')

    trck('organizations').should eq("deskrock\nfriendlyfinance")

    trck('select organization deskrock').should eq('Organization deskrock was selected')

    trck('organizations').should eq("=> deskrock\nfriendlyfinance")

    trck('projects').should eq('No projects found in organization deskrock')

    trck('add project ccs').should eq('Project ccs was added to organization deskrock')

    trck('projects').should eq("Projects in organization deskrock:\nccs")

    trck('add project abahn').should eq('Project abahn was added to organization deskrock')

    trck('tasks abahn').should eq('No tasks found')

    trck('add task abahn refactoring').should eq('Task refactoring was added to project abahn')

    trck('tasks abahn').should eq('refactoring - 0h 0m 0s')

    trck('add task abahn algorithm').should eq('Task algorithm was added to project abahn')
    trck('add task abahn algorithm').should eq('Cannot create two tasks with same name')

    trck('tasks abahn').should eq("refactoring - 0h 0m 0s\nalgorithm - 0h 0m 0s")

    trck('start abahn refactoring').should eq('Task refactoring was started')
  end
end