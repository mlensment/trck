require 'trck'

def trck args
  Trck.execute(args)
end

describe Trck do
  before(:each) do
    s = Storage.load
    s.reset
  end

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
    trck('start abahn refactoring').should eq('Task refactoring already started')

    trck('status').should eq('Currently running tasks:\nrefactoring - 0h 0m 0s')
  end
end