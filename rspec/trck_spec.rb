require 'trck'

def trck args
  Trck.execute(args)
end

describe Trck do
  before(:each) do
    s = Storage.load
    s.reset
  end

it 'handles basic task commands' do

    # tasks without projects, basic functionality

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

end

it 'handles two simultaneously running tasks' do

    trck('add task 100').should eq('Task 100 was added')

    trck('add task 200').should eq('Task 200 was added')

    trck('start 100').should eq('Task 100 was started')
    trck('start 200').should eq('Task 200 was started')

    trck('status').should eq("Currently running tasks:\n100 - 0h 0m 0s\n200 - 0h 0m 0s\n")
    trck('stop 100').should eq('Task 100 was stopped')

    trck('status').should eq("Currently running tasks:\n200 - 0h 0m 0s\nLast tracked tasks:\n100 - 0h 0m 0s\n")

    trck('stop 200').should eq('Task 200 was stopped')

    trck('status').should eq("Last tracked tasks:\n100 - 0h 0m 0s\n200 - 0h 0m 0s\n")

end


it 'handles projects' do

    trck('projects').should eq("No projects found")

    trck('add project chatroom').should eq('Project chatroom was added')
    trck('add project chatroom').should eq('Cannot create two projects with same name')

    trck('projects').should eq("chatroom")

    trck('tasks abahn').should eq('Project abahn was not found')

    trck('add project abahn').should eq('Project abahn was added')

    trck('tasks abahn').should eq('No tasks found')

    trck('projects').should eq("chatroom\nabahn")

end

it 'handles tasks in projects' do
    trck('add task chatroom 100').should eq('Task 100 was added to project chatroom')

    trck('add task chatroom 100').should eq('Cannot create two tasks with same name')

    trck('tasks chatroom').should eq('100 - not started')

    trck('add task chatroom 200').should eq('Task 200 was added to project chatroom')

    trck('tasks chatroom').should eq("100 - not started\n200 - not started")

    trck('remove task chatroom 100').should eq('Task 100 was removed from project chatroom')

    trck('remove task chatroom 100').should eq('Task 100 was not found in project chatroom')

    trck('tasks chatroom').should eq("200 - 0h 0m 0s")

    trck('add task abahn calendar').should eq('Task calendar was added to project abahn')

    trck('add task calendar').should eq('Cannot create two tasks with same name')

    trck('start abahn calendar').should eq('Task calendar was started')

    trck('start abahn calendar').should eq('Task calendar already started')

    trck('status abahn').should eq("Currently running tasks:\ncalendar - 0h 0m 0s\n") #no functionality?

    trck('stop abahn calendar').should eq('Task calendar was stopped')
    trck('stop abahn calendar').should eq('Task calendar is not running')

    trck('status abahn').should eq("Last tracked tasks in project:\calendar - 0h 0m 0s\n")

    trck('tasks abahn').should eq("calendar - 0h 0m 0s")

    trck('remove task abahn calendar').should eq('Task calendar was removed')

    trck('tasks abahn').should eq(" No tasks found")

    trck('status abahn').should eq("")

    trck('start calendar').should eq('Task calendar was not found')
end

it 'removes projects' do

    trck('remove project abahn').should eq('Project abahn with all tasks was removed') no functionality

    trck('remove project abahn').should eq('Project abahn was not found')

    trck('remove project chatroom').should eq('Project chatroom with all tasks was removed')

    trck('projects').should eq("No projects found")
end

end