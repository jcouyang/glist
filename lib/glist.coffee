GlistView = require './glist-view'
shell = require 'shell'
AddDialog = require './add-dialog'
CSON = require 'season'
{TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable, File} = require 'atom'
octonode = require 'octonode'
_ = require('lodash-fp')
PASSWORD_MARK = '**********'
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
    tokenPath:
      type: 'string'
      default: atom.packages.getPackageDirPaths() + '/glist/.config.cson'
    gistDir:
      type: 'string'
      default: atom.packages.getPackageDirPaths() + '/glist/gists'
    fileSuffix:
      type: 'string'
      default: '.md'
    gistLocation:
      type: 'string'
      default: 'https://gist.github.com'
  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    atom.config.observe 'glist.githubToken', (newToken) ->
      if newToken == PASSWORD_MARK
        return
      CSON.writeFileSync atom.config.get('glist.tokenPath'),
        token: newToken
      @githubToken = newToken
      @ghgist = octonode.client(@githubToken).gist()
      @glistView = new GlistView(@ghgist, @state)
      # for security, when submit issue, atom submit all config inclue token
      atom.config.set 'glist.githubToken', PASSWORD_MARK
    @githubToken = CSON.readFileSync(atom.config.get('glist.tokenPath'))?.token
    @subscriptions.add atom.commands.add 'atom-workspace', 'glist:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'glist:saveGist': => @saveGist()
    @subscriptions.add atom.commands.add 'atom-workspace', 'glist:delete': => @deleteGist()
    @subscriptions.add atom.commands.add 'atom-workspace', 'glist:deleteGist': => @deleteGistFoler()
    @subscriptions.add atom.commands.add 'atom-workspace', 'glist:copyGistUrl': => @copyGistUrl()
    @subscriptions.add atom.commands.add 'atom-workspace', 'glist:openGistWeb': => @openGistWeb()
  deactivate: ->
    @subscriptions.dispose()
    @glistView.destroy()

  toggle: ->
    unless @glistView?
      @ghgist ?= octonode.client(@githubToken).gist()
      @glistView = new GlistView(@ghgist, @state)
    @glistView.toggle()

  deleteGist: ->

  getMeta: ->
    currentItem = atom.workspace.getActivePaneItem()
    gistDir = atom.config.get('glist.gistDir')
    metafile = new File(currentItem.getURI()).getParent().path + '/.gist.meta.cson'
    try
      meta = CSON.readFileSync metafile
    catch e
      meta = null
    @state.meta = meta
    {meta, metafile, currentItem: currentItem, filename: currentItem.getTitle(), content: currentItem.getText()}
  deleteGist: ->
    {meta, metafile, currentItem, filename, content} = @getMeta()
    files = {}
    files[filename] = null
    atom.confirm
      message: 'Are you sure?'
      buttons:
        Cancel: =>
        Delete: =>
          @ghgist ?= octonode.client(@githubToken).gist()
          if meta
            @ghgist.edit meta.id, files:files, (error, body) =>
              if error
                atom.notifications.addError error.toString()
              else
                atom.notifications.addInfo "file [#{filename}] deleted."
                shell.moveItemToTrash(currentItem.getURI())
                currentItem.destroy()
  saveGist: ->
    {meta, metafile, currentItem, filename, content} = @getMeta()
    files = {}
    files[filename] = {filename: filename, content: content}
    @addDialog = new AddDialog(@state)
    @addDialog.onConfirm = (description, publicOrPrivate) =>
      atom.notifications.addInfo 'uploading gist...'
      @ghgist ?= octonode.client(@githubToken).gist()
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

  copyGistUrl: ->
    if @getMeta().meta?.id
      location = atom.config.get('glist.gistLocation') + '/' + @getMeta().meta.id
      atom.clipboard.write(location)
      atom.notifications.addInfo 'gist url copied!'
      location
    else
      atom.notifications.addError 'not a gist, please ctrl-x ctrl-s save first!'
  openGistWeb: ->
    url = @copyGistUrl()
    shell.openExternal(url) if url
  deleteGistFoler: ->
    {meta, metafile, currentItem, filename, content} = @getMeta()
    files = {}
    files[filename] = null
    if !meta?.id
      atom.notifications.addWarning "it's not a gist, you cannot delete it!"
      return
    atom.confirm
      message: "This will delete #{meta.id} and its folder, are you sure?"
      buttons:
        Cancel: =>
        Delete: =>
          @ghgist ?= octonode.client(@githubToken).gist()
          @ghgist.delete meta.id, (error) ->
            if error
              atom.notifications.addError error.toString()
            else
              atom.notifications.addInfo "gist [#{meta.id}] deleted."
              shell.moveItemToTrash(new File(currentItem.getURI()).getParent().path)
              currentItem.destroy()
