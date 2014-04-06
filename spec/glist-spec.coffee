{WorkspaceView} = require 'atom'
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Glist", ->
  activationPromise = null
  Glist = null
  beforeEach ->
    atom.project = jasmine.createSpyObj("project", ["getRepo", "getPath", "setPath"])
    atom.project.getRepo = ->
      {
        getConfigValue: (name)->
          "jcouyang"
      }

    Glist = require '../lib/glist'
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('glist')

  describe "when the glist:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'glist:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.project.getPath()).toBe(atom.config.get('glist.gistLocation'))
