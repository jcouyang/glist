GlistView = require './glist-view'
{CompositeDisposable} = require 'atom'
octonode = require 'octonode'
_ = require('lodash-fp')

module.exports = Glist =
  ghgist: null
  glistView: null
  modalPanel: null
  subscriptions: null
  config:
    githubToken:
      type: 'string'
      default: 'github auth token here'
    gistDir:
      type: 'string'
      default: atom.packages.getPackageDirPaths() + '/glist/gists'

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'glist:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'glist:saveGist': => @saveGist()

  deactivate: ->
    @subscriptions.dispose()
    @glistView.destroy()

  toggle: ->
    unless glistView?
      @ghgist = octonode.client(atom.config.get('glist.githubToken')).gist()
      @glistView = new GlistView(@ghgist)
    @glistView.toggle()

  saveGist: ->
    @ghgist ?= octonode.client(atom.config.get('glist.githubToken')).gist()
    currentItem = atom.workspace.getActivePaneItem()
    gistDir = atom.config.get('glist.gistDir')
    gist = currentItem.getPath().match(/([^/]*)\/([^/]*)$/)
    newGist = {files: {}}
    newGist.files[gist[2]] = {content:currentItem.getText()}
    debugger
    @ghgist.edit gist[1], newGist, (error, body)->
      if error.statusCode == 404
        @ghgist.create {description: "heheda", newGist}
