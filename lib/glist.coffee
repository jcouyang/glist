GlistView = require './glist-view'
AddDialog = require './add-dialog'
CSON = require 'season'
{TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable, File} = require 'atom'
octonode = require 'octonode'
_ = require('lodash-fp')

module.exports = Glist =
  ghgist: null
  glistView: null
  addDialog: null
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
    unless @glistView?
      @ghgist = octonode.client(atom.config.get('glist.githubToken')).gist()
      @glistView = new GlistView(@ghgist, @state)
    @glistView.toggle()

  saveGist: ->
    currentItem = atom.workspace.getActivePaneItem()
    gistDir = atom.config.get('glist.gistDir')
    metafile = new File(currentItem.getURI()).getParent().path + '/.gist.meta.cson'
    try
      meta = CSON.readFileSync metafile
    catch e
      meta = null
    @state.meta = meta
    gist = currentItem.getPath().match(/([^/]*)\/([^/]*)$/)
    files = {}
    files[gist[2]] = {filename: gist[2], content:currentItem.getText()}
    @addDialog = new AddDialog(@state)
    @addDialog.onConfirm = (description, publicOrPrivate) =>
      atom.notifications.addInfo 'uploading gist...'
      @ghgist ?= octonode.client(atom.config.get('glist.githubToken')).gist()
      if meta
        @ghgist.edit meta.id, {files: files, public: publicOrPrivate, description: description}, (error, body) =>
          if error
            atom.notifications.addError error.toString()
          else
            atom.notifications.addInfo "gist [#{description}] saved."
            meta.public = publicOrPrivate
            meta.description = description
            CSON.writeFile metafile, meta, ->
              currentItem.save()
      else
        @ghgist.create {description: description, files: files, public: publicOrPrivate}, (error)->
          if error
            atom.notifications.addError error.toString()
          else
            atom.notifications.addInfo "gist [#{description}] saved."
            currentItem.destroy()
