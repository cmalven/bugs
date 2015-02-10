Meteor.methods

  fetchProjects: ->
    return Meteor.call 'makeRequest', 'projects/active.json'

  fetchBugs: (projectId) ->
    return Meteor.call 'makeRequest', "projects/#{projectId}/tasks.json"

  makeRequest: (urlPath) ->
    url = "https://www.bugherd.com/api_v2/#{urlPath}"

    result = Meteor.http.get url, { auth: process.env.BUGHERD_API_KEY + ':x' }
    if result.statusCode is 200
      return JSON.parse result.content
    else
      errorJson = JSON.parse(result.content)
      throw new Meteor.Error(result.statusCode, errorJson.error)
