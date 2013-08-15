require 'trck'

def trck args
  Trck.execute(args)
end

describe Trck do
  before(:each) do
    s = Storage.load
    s.reset
  end

  after(:all) do
      s = Storage.load
      s.reset
  end


it 'handles basic task commands' do

    trck('start 100').should eq('Created and tracking task 100')
    trck('start 100').should eq('Already tracking task 100')

    trck('status').should eq("Currently tracking tasks:\n100 - 0h 0m 0s\n")

    trck('stop').should eq('Finished tracking task 100')
    trck('stop').should eq('No tasks are being tracked')

    trck('status').should eq("Last tracked tasks:\n100 - 0h 0m 0s\n")

    trck('tasks').should eq("100 - 0h 0m 0s")

    trck('remove 100').should eq('Removed task 100')

    trck('tasks').should eq("No tasks found")

    trck('status').should eq("")

    trck('start 100').should eq('Tracking task 100')
end

it 'ends previous tracking task and starts new' do

    trck('start 100').should eq('Created and tracking task 100')

    trck('start 200').should eq('Finished tracking task 100, created and tracking task 200')

    trck('status').should eq("Currently tracking tasks:\n200 - 0h 0m 0s\nLast tracked tasks:\n100 - 0h 0m 0s\n")

    trck('stop').should eq('Finished tracking task 200')

    trck('status').should eq("Last tracked tasks:\n100 - 0h 0m 0s\n200 - 0h 0m 0s\n")
end

it 'handles projects' do

    trck('projects').should eq("No projects found")

    trck('add project chatroom').should eq('Added project chatroom')

    trck('add project chatroom').should eq('Cannot create two projects with the same name')

    trck('projects').should eq("chatroom")

    trck('tasks abahn').should eq('Project abahn was not found')

    trck('add project abahn').should eq('Added project abahn')

    trck('tasks abahn').should eq('No tasks found')

    trck('projects').should eq("chatroom\nabahn")
end

it 'handles tasks in projects' do

    trck('add project abahn').should eq('Added project abahn')

    trck('start abahn calendar').should eq('Created and tracking task calendar in project abahn')

    trck('status abahn').should eq("Currently tracking tasks:\ncalendar - 0h 0m 0s\n")

    trck('stop').should eq('Finished tracking task 100 in project abahn')
    trck('stop').should eq('No tasks are being tracked')

    trck('status abahn').should eq("Last tracked tasks:\ncalendar - 0h 0m 0s\n")

    trck('tasks abahn').should eq('calendar - 0h 0m 0s')

    trck('remove abahn calendar').should eq('Removed task calendar from project abahn')

    trck('tasks abahn').should eq('No tasks found')

    trck('status abahn').should eq('')

    trck('start abahn calendar').should eq('Created and tracking task calendar in project abahn')
end

it 'removes projects with all its tasks' do

    trck('add project abahn').should eq('Added project abahn')

    trck('start abahn layout').should eq('Created and tracking task layout in project abahn')
    trck('stop').should eq('Finished tracking task layout in project abahn')

    trck('remove project abahn').should eq('Removed project abahn with all its tasks') #no functionality

    trck('remove project abahn').should eq('Project abahn was not found')

    trck('projects').should eq('No projects found')

    trck('start abahn layout').should eq('Project abahn was not found')
end


it 'shows status about multiple projects' do #no functionality

    trck('add project myproject').should eq('Added project myproject')
    trck('add project second_project').should eq('Added project second_project')

    trck('start myproject eatlunch').should eq('Created and tracking task eatlunch in project myproject')
    trck('stop').should eq('Finished tracking task eatlunch')

    trck('start second_project eatdinner').should eq('Created and tracking task eatdinner in project second_project')

    trck('status').should eq("Currently tracking tasks:\nsecond_project\n\teatdinner - 0h 0m 0s\nLast tracked tasks:\nmyproject\n\teatlunch - 0h 0m 0s")
end

it 'handles selecting projects' do

    trck('add project myproject').should eq('Added project myproject')
    trck('add project other_project').should eq('Added project other_project')

    trck('select project myproject').should eq('Now tracking in project myproject')

    trck('projects').should eq("=> myproject\nother_project")

    trck('start 100').should eq('Created and tracking task 100 in myproject')

    trck('select project other_project').should eq('Now tracking in project other_project')

    trck('start 200').should eq('Created and tracking task 200 in other_project')

    trck('projects').should eq("myproject\n=> other_project")

    trck('exit project').should eq('Now tracking without a project')

    trck('exit project').should eq('Already tracking without a project')

    trck('projects').should eq("myproject\nother_project")

end

end