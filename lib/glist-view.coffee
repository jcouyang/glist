{EditorView, View} = require 'atom'
Clipboard = require 'clipboard'
path = require 'path'
fs = require 'fs-plus'
_ = require 'underscore'
octonode = require 'octonode'
shell = require 'shell'
exec = require('child_process').exec

splashStatus = (status) ->
  statusBar = atom.workspaceView.statusBar
  statusBar.find("#glist-logs").remove()
  statusBar.appendRight("<span id=glist-logs>#{status}</span>")
  setTimeout (=>
    statusBar.find("#glist-logs").remove()
  ), 7000

printer = (error, stdout, stderr) ->
  splashStatus("#{stdout} !! #{stderr}")
  console.log("#{stdout} !! #{stderr}")
  console.log('exec error: ' + error) if error?

module.exports =
class GlistView extends View
  @content: ->
    @div class: "gist overlay from-top padded", =>
      @div class: "inset-panel", =>
        @div class: "panel-heading", =>
          @span outlet: "title"
          @div class: "btn-toolbar pull-right", outlet: 'toolbar', =>
            @div class: "btn-group", =>
              @button outlet: "privateButton", class: "btn", "Private"
              @button outlet: "publicButton", class: "btn", "Public"
        @div class: "panel-body padded", =>
          @div outlet: 'filenameForm', =>
            @subview 'filenameEditor', new EditorView(mini:true, placeholderText: 'File name')
          @div outlet: 'descriptionForm', =>
            @subview 'descriptionEditor', new EditorView(mini:true, placeholderText: 'Description')
            @div class: 'pull-right', =>
              @button outlet: 'gistButton', class: 'btn btn-primary', "Gist"
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'


  initialize: (serializeState) ->
    @handleEvents()
    atom.workspaceView.command "glist:saveGist", => @saveGist()
    atom.workspaceView.command "glist:update", => @updateList()
    atom.workspaceView.command "glist:delete", => @deleteCurrentFile()
    @isPublic = atom.config.get('glist.ispublic')
    @gistsPath = atom.config.get('glist.gistLocation')
    @token = atom.config.get("glist.userToken")
    @user = atom.config.get("glist.userName")
    @ghgist = octonode.client(@token).gist()
    exec('git init', cwd: @gistsPath, printer) unless fs.existsSync(path.join(@gistsPath), "git")
    @updateList()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    atom.workspaceView.off "glist:saveGist"
    atom.workspaceView.off "glist:update"
    atom.workspaceView.off "glist:delete"
    @detach()

  updateList: ->
    @showProgressIndicator()
    @ghgist.list(@writefiles.bind(this))

  writefiles: (error, res) ->
    return if error?
    gistsPath = @gistsPath
    @gists = res

    res.forEach (gist) ->
      gistPath = path.join(gistsPath, gist.id)
      unless fs.existsSync(gistPath)
        exec "git submodule add #{gist.git_pull_url}",
          cwd: gistsPath
          , printer

    exec 'git submodule update --remote --merge',
      cwd: gistsPath
      , printer
    @detach()
    atom.workspaceView.trigger 'tree-view:toggle-focus'

  handleEvents: ->
    @gistButton.on 'click', => @createGist()
    @publicButton.on 'click', => @makePublic()
    @privateButton.on 'click', => @makePrivate()
    @descriptionEditor.on 'core:confirm', => @createGist()
    @descriptionEditor.on 'core:cancel', => @detach()
    @filenameEditor.on 'core:confirm', => @newfile()
    @filenameEditor.on 'core:cancel', => @detach()

  saveGist: ->
    editor = atom.workspace.getActiveEditor()
    gistPath = path.dirname(editor.getBuffer().getPath())
    if gistPath? and fs.existsSync(path.join(gistPath, ".git"))
      editor.save()
    else
      @showFilenameForm()
      @filenameEditor.focus()
      return

    @showProgressIndicator()
    self = @
    exec 'git commit -am "edit"',
      cwd: gistPath
      , (error, stdout, stderror) ->
        printer(error, stdout, stderror)
        self.detach()
        exec 'git push origin master',
          cwd: gistPath
          , (error, stdout, stderror) ->
            printer(error, stdout, stderror)
            self.detach()

  newfile: ->
    editor = atom.workspace.getActiveEditor()
    editor.saveAs(path.join(@gistsPath, ".tmp/#{@filenameEditor.getText()||'untitled'}"))
    @detach()
    @showGistForm()
    @descriptionEditor.focus()

  createGist: ->
    @showProgressIndicator()
    editor = atom.workspace.getActiveEditor()
    gist = {}
    gist.description = @descriptionEditor.getText()
    filename = editor.getTitle()
    gist.files={}
    gist.files[filename] =
      content: editor.getBuffer().getText()
    gist.public = @isPublic
    self = @
    @ghgist.create gist, (error, res)->
      if error
        self.showErrorMsg(error.message)
        setTimeout (=>
          self.detach()
        ), 2000
      else
        Clipboard.writeText res.html_url
        exec "git submodule add #{res.git_pull_url}",
          cwd: self.gistsPath
          , (error, stdout,stderr) ->
            atom.workspaceView.trigger "core:save"
            atom.workspaceView.trigger "core:close"
            shell.moveItemToTrash(path.join(self.gistsPath, ".tmp"))
            atom.workspaceView.open path.join(self.gistsPath, "#{res.id}/#{filename}")
            printer(error,stdout,stderr)

        self.detach()

  deleteCurrentFile: ->
    editor = atom.workspace.getActiveEditor()
    title = editor.getLongTitle()
    gistid = title.split(' - ')[1]?.trim()
    gist = _(@gists).find (gist)->
      return gist.id == gistid
    if gist
      @showProgressIndicator()
      gist = _(gist).pick 'description', 'files'
      gist.files[editor.getTitle()] = null
      self = @
      @ghgist.edit gistid, gist, (error, res)->
        if error
          self.showErrorMsg(error.message)
          setTimeout (=>
            self.detach()
          ), 2000
        else
          shell.moveItemToTrash(editor.getBuffer().getPath())
          if Object.keys(res.files).length is 0
            shell.moveItemToTrash(path.dirname(editor.getBuffer().getPath()))
            self.ghgist.delete(gistid);
            exec "git rm #{gistid} && git submodule sync", cwd: self.gistsPath, printer
          self.detach()
    else
      shell.moveItemToTrash(editor.getBuffer().getPath())

  delete: ->
    console.log "delete from tree view"
  makePublic: ->
    @publicButton.addClass('selected')
    @privateButton.removeClass('selected')
    @isPublic = true

  makePrivate: ->
    @privateButton.addClass('selected')
    @publicButton.removeClass('selected')
    @isPublic = false

  showGistForm: ->
    atom.workspaceView.append(this)
    if @isPublic then @makePublic() else @makePrivate()
    @title.text "New Gist"
    @toolbar.show()
    @filenameForm.hide()
    @descriptionForm.show()
    @progressIndicator.hide()

  showFilenameForm: ->
    atom.workspaceView.append(this)
    @title.text "Name the file"
    @toolbar.hide()
    @descriptionForm.hide()
    @filenameForm.show()
    @progressIndicator.hide()

  showProgressIndicator: ->
    atom.workspaceView.append(this)
    @title.text "glisting..."
    @toolbar.hide()
    @filenameForm.hide()
    @descriptionForm.hide()
    @progressIndicator.show()

  showErrorMsg: (msg) ->
    atom.workspaceView.append(this)
    @title.text "ERROR..#{msg}"
    @toolbar.hide()
    @filenameForm.hide()
    @descriptionForm.hide()
    @progressIndicator.hide()
