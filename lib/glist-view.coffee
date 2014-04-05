{EditorView, View} = require 'atom'
Clipboard = require 'clipboard'
path = require 'path'
https = require 'https'
fs = require 'fs-plus'
mkdirp = require 'mkdirp'
url = require 'url'
_ = require 'underscore'
octonode = require 'octonode'

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
          @div outlet: 'signupForm', =>
            @subview 'descriptionEditor', new EditorView(mini:true, placeholderText: 'Description')
            @div class: 'pull-right', =>
              @button outlet: 'gistButton', class: 'btn btn-primary', "Gist It"
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'
          @div outlet: 'urlDisplay', =>
            @span "All Done! the Gist's URL has been copied to your clipboard."

  initialize: (serializeState) ->
    @handleEvents()
    @isPublic = atom.config.get('glist.ispublic')
    @gistsPath = atom.config.get('glist.gistLocation')
    atom.workspaceView.command "glist:saveGist", => @saveGist()
    @token = atom.config.get("glist.userToken")
    @user = atom.config.get("glist.userName")
    @previousPath = atom.project.getPath();
    atom.project.setPath(@gistsPath);
    @ghgist = octonode.client(atom.config.get("glist.userToken")).gist()
    @updateList()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    console.log("off")
    atom.project.setPath(@previousPath)
    @previousPath=null
    @detach()

  updateList: ->
    @showProgressIndicator()
    @ghgist.list(@writefiles.bind(this))

  writefiles: (error, res) ->
    return if error?
    fetch = @fetch
    @gists = res
    gistsPath = path.join(__dirname, "../gists")
    res.forEach (gist) ->
      gistPath = path.join(gistsPath, gist.id)
      mkdirp.sync(gistPath)
      Object.keys(gist.files).forEach (filename) ->
          fetch gist.files[filename].raw_url, "get", null, (raw) ->
            console.log "writing gist", filename
            fs.writeFileSync path.join(gistPath, filename), raw

  fetch: (address, method, contentType, callback) ->
    urlobj = url.parse address
    options =
      hostname: urlobj.host
      path: urlobj.pathname
      method: method
      headers:
        'User-Agent':"Atom"

    options.headers["Authorization"] = "token #{@token}" if @token?

    https.get options, (res) ->
      res.setEncoding "utf8"
      body = ''
      res.on "data", (chunk) ->
        body += chunk
      res.on "end", ->
        if contentType is 'json'
          response = JSON.parse(body)
        else
          response = body
        callback(response)

  handleEvents: ->
    @gistButton.on 'click', => @createGist()
    @publicButton.on 'click', => @makePublic()
    @privateButton.on 'click', => @makePrivate()
    @descriptionEditor.on 'core:confirm', => @createGist()
    @descriptionEditor.on 'core:cancel', => @detach()

  saveGist: ->
    editor = atom.workspace.getActiveEditor()
    editor.save()

    title = editor.getLongTitle()
    gistid = title.split('-')[1]?.trim()
    gist = _(@gists).find (gist)->
      return gist.id == gistid

    if gist
      gist = _(gist).pick 'description', 'files'

      gist.files[editor.getTitle()].content = editor.getBuffer().getText()
      @ghgist.edit gistid, gist, (error, res)->
        console.log error, res
    else
      @showGistForm()
      atom.workspaceView.append(this)
      @descriptionEditor.focus()

  showForm: ->
    @showGistForm()
    atom.workspaceView.append(this)

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
      console.log "created", error, res
      Clipboard.writeText res.html_url
      self.showUrlDisplay()

  makePublic: ->
    @publicButton.addClass('selected')
    @privateButton.removeClass('selected')
    @isPublic = true

  makePrivate: ->
    @privateButton.addClass('selected')
    @publicButton.removeClass('selected')
    @isPublic = false

  showGistForm: ->
    if @isPublic then @makePublic() else @makePrivate()

    @toolbar.show()
    @signupForm.show()
    @urlDisplay.hide()
    @progressIndicator.hide()

  showProgressIndicator: ->
    @toolbar.hide()
    @signupForm.hide()
    @urlDisplay.hide()
    @progressIndicator.show()

  showUrlDisplay: ->
    @toolbar.hide()
    @signupForm.hide()
    @urlDisplay.show()
    @progressIndicator.hide()
