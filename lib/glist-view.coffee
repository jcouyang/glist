{SelectListView} = require 'atom-space-pen-views'
GitHubApi = require("node-github")
_ = require('lodash-fp')
gistCache = null
github = null;
githubOptions =
    version: "3.0.0",
    headers:
      "user-agent": "Glist from Atom"

module.exports =
class GlistView extends SelectListView
  initialize: ->
    super
    @addClass('overlay from-top')
    @setItems gistCache if gistCache
    github = new GitHubApi(githubOptions)
    github.authenticate({type: "oauth",token: atom.config.get('glist.githubToken')})
    github.gists.getAll {}, (error, gists) =>
      indexedGists = _(gists).map (gist) ->
        gist.key = gist.description + " " + _.values(gist.files)
          .map (file)->
            file.filename
          .join ' '
        gist
      gistCache = indexedGists.value()
      @setItems(gistCache) unless error
  attach: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)

    @focusFilterEditor()

  viewForItem: (gist) ->
    "<li>
    <div>#{gist.description}</div>
<div class='text-subtle'>#{_(gist.files).values().first().filename}</div>
<span class='inline-block highlight-#{if gist.public then "info" else "success"} right'></span>
</li>"

  getFilterKey: ->
    console.log @items
    "key"
  confirmed: (item) ->
    console.log("#{item} was selected")

  cancelled: ->
    @panel?.destroy()
    @panel = null

  destroy: ->
    @cancel()

  toggle: ->
    if @panel?
      @cancel()
    else
      @attach()
