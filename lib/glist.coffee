path = require 'path'
GlistView = require './glist-view'
mkdirp = require 'mkdirp'

module.exports =
  activate: ->
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
      @previousPath = atom.project.getPath()
      @glistView = new GlistView()
      gistPath = atom.config.get('glist.gistLocation')
      mkdirp.sync(gistPath)
      atom.project.setPath(gistPath)

  configDefaults:
    userName: localStorage.getItem("glist.username") || atom.project.getRepo()?.getConfigValue("github.user")
    gistLocation: path.join(__dirname, "../gists")
    ispublic: true
