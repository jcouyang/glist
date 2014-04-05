path = require 'path'
https = require 'https'
fs = require 'fs-plus'
mkdirp = require 'mkdirp'
url = require 'url'
_ = require 'underscore'
octonode = require 'octonode'

module.exports =
  previousPath:null
  gistsPath:null
  token:null
  user:null
  gists:null
  ghgist:null

  activate: (state) ->
    atom.workspaceView.command "glist:toggle", => @toggle()
    atom.workspaceView.command "glist:update", => @update()
    @gistsPath = path.join(__dirname, "../gists")
    @ghgist = octonode.client(atom.config.get("glist.userToken")).gist()

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

  update: ->
    editor = atom.workspace.getActiveEditor()
    editor.save()
    debugger

    title = editor.getLongTitle()
    gistid = title.split('-')[1]?.trim()
    gist = _(@gists).find (gist)->
      return gist.id == gistid

    if gist
      gist = _(gist).pick 'description', 'files'

      gist.files[editor.getTitle()].content = editor.getBuffer().getText()
      @ghgist.edit gistid, gist, (error, res)->
        console.log error, res

  toggle: ->
    console.log("toggle")
    if @previousPath?
      console.log("off")
      atom.project.setPath(@previousPath)
      @previousPath=null
    else
      console.log("on")
      @token = atom.config.get("glist.userToken")
      @user = atom.config.get("glist.userName")
      @previousPath = atom.project.getPath();
      atom.project.setPath(@gistsPath);
      debugger
      @ghgist.list(@writefiles.bind(this))

  configDefaults:
    userToken: atom.getGitHubAuthToken()
    userName:atom.project.getRepo().getConfigValue("github.user")
    gistLocation: path.join(__dirname, "../gists")
