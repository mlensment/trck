Timetracker gem

trck status (shows the latest 3 tracks)
o = Organization.find_active


trck status ccs
trck status --all

trck start cofi 93
trck start ccs 85
trck stop

trck project (lists all projects)
o = Organization.find_active
o.projects

trck project add allkiri
o = Organization.find_active
o.add_project('cofi')

trck project remove allkiri
o = Organization.find_active
o.remove_project('cofi')

trck org (lists all organizations)
Organization.all

trck org deskrock (switches organization)
Organization.set_active('deskrock')

trck sync (sync manually)

Data format:

store: {
  api_url: '',
  api_key: '',
  organizations: [
    {
      name: 'deskrock',
      active: true,
      projects:
        ccs: {
          tasks: {
            85: {
              start: 03.06.2013 9:00,
              stop: 03.06.2013 10:00,
              time: 3600,
              running: false
            },
            93-bla: {
              start: 03.06.2013 15:00,
              stop: nil,
              time: 129,
              running: true
            }
          }
        },
        cofi: {

        }
      }
    ]
  }
}