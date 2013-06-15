require 'task'

describe Task do
  before(:each) do
    s = Storage.load
    s.reset
  end

  context 'without project' do
    it 'creates and returns task' do
      t = Task.new({})
      t.save.should be_false
      t.errors.include?('Cannot create task without name').should be_true

      Task.new({
        name: '100'
      }).save.should be_true

      Task.find_by_name('100').name.should eq('100')
    end

    it 'does not save two tasks with same name' do
      t1 = Task.new({
        name: '200'
      })
      t1.save.should be_true

      t2 = Task.new({
        name: '200'
      })
      t2.save.should be_false
      t2.errors.include?('Cannot create two tasks with same name').should be_true
    end
  end

  context 'with project' do
    before(:each) do
      @o = Organization.new('deskrock')
      @o.save
      @p1 = @o.add_project('ccs')
      @p2 = @o.add_project('cofi')
    end

    it 'creates and returns project' do
      Task.new({
        name: 'ccs-100',
        project: @p1
      }).save.should be_true

      t = Task.find_by_name('ccs-100')
      t.name.should eq('ccs-100')
      t.project.name.should eq('ccs')

      Task.new({
        name: 'cofi-100',
        project: @p2
      }).save.should be_true

      Task.new({
        name: 'deskrock-100',
        organization: @o
      }).save.should be_true

      t = Task.find_by_name('deskrock-100')
      t.name.should eq('deskrock-100')
      t.organization.name.should eq('deskrock')
    end

  end

end