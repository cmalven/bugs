Template.bug_details.helpers

  bugSelected: ->
    return Session.get('selected_bug')

  bug: ->
    return Bugs.findOne(Session.get('selected_bug'))