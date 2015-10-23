GlistView = require './glist-view'
{CompositeDisposable} = require 'atom'

module.exports = Glist =
  glistView: null
  modalPanel: null
  subscriptions: null
  config:
    githubToken:
      type: 'string'
      default: 'github auth token here'
  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'glist:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()
    @glistView.destroy()

  toggle: ->
    console.log 'Glist was toggled!'
    unless glistView?
      glistView = new GlistView()
    glistView.toggle()
