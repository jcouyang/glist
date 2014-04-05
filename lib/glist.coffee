path = require 'path'
GlistView = require './glist-view'

module.exports =
  activate: (state) ->
    atom.workspaceView.command "glist:toggle", => @toggle()

  deactivate: ->
    console.log("destroy")
    @glistView.destroy()

  toggle: ->
    console.log("toggle")
    if @previousPath?
      console.log("off")
      atom.project.setPath(@previousPath)
      @previousPath=null
      @deactivate()
    else
      console.log("on")
      @previousPath = atom.project.getPath();
      @glistView = new GlistView()
      atom.project.setPath(atom.config.get('glist.gistLocation'));

  configDefaults:
    userToken: atom.getGitHubAuthToken()
    userName:atom.project.getRepo().getConfigValue("github.user")
    gistLocation: path.join(__dirname, "../gists")
    ispublic: true
