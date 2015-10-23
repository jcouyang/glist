{File, Directory} = require 'atom'
{SelectListView} = require 'atom-space-pen-views'
octonode = require 'octonode'
_ = require('lodash-fp')
gistCache = null
github = null;

github = octonode.client(atom.config.get('glist.githubToken'))
ghgist = github.gist()
module.exports =
class GlistView extends SelectListView
  initialize: ->
    super
    @addClass('overlay from-top')
    @setItems gistCache if gistCache

  attach: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    ghgist.list (error, gists) =>
      indexedGists = _(gists).map (gist) ->
        gist.key = gist.description + " " + _.values(gist.files)
          .map (file)->
            file.filename
          .join ' '
        gist
      gistCache = indexedGists.value()
      gistCache.push {description: 'create new gist', key: 'create new add', files: {}}
      @setItems(gistCache) unless error
    @focusFilterEditor()

  viewForItem: (gist) ->
    "<li>
    <div>#{gist.description}</div>
<div class='text-subtle'>#{_(gist.files).values().first()?.filename}</div>
<span class='inline-block highlight-#{if gist.public then "info" else "success"} right'></span>
</li>"

  getFilterKey: ->
    console.log @items
    "key"

  confirmed: (item) ->
    if item
      gistPath = atom.config.get('glist.gistDir') + '/gists/' + item.id + '/'
      console.log gistPath
      ghgist.get item.id, (error, gist) ->
        console.log gist
        return if error
        _.forEach (file, filename) ->
          console.log 'saving', gistPath + filename
          gistfile = new File(gistPath + filename)
          gistfile.create().then ->
            gistfile.write file.content
          ,(e)->
            console.log e
        , gist.files
      atom.project.addPath(gistPath)
      console.log("#{item.id} was selected")
    @cancel()

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
