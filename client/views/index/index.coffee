Template.index.helpers

  bugs: ->
    return Bugs.find()

Template.index.created = ->
  # Create a new client-only collection to store bugs
  window.Bugs = new Meteor.Collection(null)

Template.index.rendered = ->
  projects = null

  Meteor.call 'fetchProjects', (err, result) ->
    return unless result
    projects = result.projects
    window.fetchProjectInterval = Meteor.setInterval(-> 
      project = projects[0]
      # Remove the first project in projects array
      projects.shift()
      # Stop listening for projects if array is empty
      Meteor.clearInterval(fetchProjectInterval) unless projects.length

      Meteor.call 'fetchBugs', project.id, (err, result) ->
        return unless result
        _.each result.tasks, (task) ->
          # Create a bug
          # Don't create bug if the status is Done (4) or Closed (5)
          return if task.status_id is 4 or task.status_id is 5
          Bugs.insert
            projectName: project.name
            description: task.description
            created_at: task.created_at
            assigned_to_id: task.assigned_to_id
            priority_id: task.priority_id
            status_id: task.status_id
            requester_email: task.requester_email
            tag_names: task.tag_names
    , 5000)

Template.index.destroyed = ->
  # console.log 'destroyed!'
  
Template.index.events
  # 'click .foo': (evt) ->
  #    Event Callback
