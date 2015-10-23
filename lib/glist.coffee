GlistView = require './glist-view'
{TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
octonode = require 'octonode'
_ = require('lodash-fp')

module.exports = Glist =
  ghgist: null
  glistView: null
  modalPanel: null
  subscriptions: null
  state: {}
  config:
    githubToken:
      type: 'string'
      default: 'github auth token here'
    gistDir:
      type: 'string'
      default: atom.packages.getPackageDirPaths() + '/glist/gists'
    fileSuffix:
      type: 'string'
      default: '.md'
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
      @glistView = new GlistView(@ghgist, @state)
    @glistView.toggle()

  saveGist: ->
    @ghgist ?= octonode.client(atom.config.get('glist.githubToken')).gist()
    currentItem = atom.workspace.getActivePaneItem()
    gistDir = atom.config.get('glist.gistDir')
    gist = currentItem.getPath().match(/([^/]*)\/([^/]*)$/)
    files = {}
    files[gist[2]] = {filename:gist[2], content:currentItem.getText()}
    @ghgist.edit gist[1], {files: files}, (error, body) =>
      if error.statusCode == 404
        @ghgist.create {description: @state.filterQuery, files: files}, (error)->
          if error
            atom.notifications.addError error.toString()
          else
            currentItem.destroy()
      else
        currentItem.save()
