CSON = require 'season'
Glist = require '../lib/glist'
octonode = require 'octonode'
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Glist", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    spyOn(octonode, 'client').andReturn
        gist: ->
          create: (option, cb)->
            cb()
          edit: (id, option, cb) ->
            cb()
          list: (cb) ->
            cb()
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('glist')

  describe "when the glist:toggle event is triggered", ->
    beforeEach ->
      spyOn(atom.config, 'get').andReturn('/tmp/glist-test.cson');
      spyOn(atom.config, 'set')
      atom.commands.dispatch workspaceElement, 'glist:toggle'
      waitsForPromise ->
        activationPromise

    it "hides and shows the modal panel", ->
      expect(workspaceElement.querySelector('.glist-listview')).toExist()
    it 'write config into a file', ->
      expect(CSON.readFileSync('/tmp/glist-test.cson').token).toBe('/tmp/glist-test.cson')
    it 'safely mask github token in atom config', ->
      expect(atom.config.set).toHaveBeenCalledWith('glist.githubToken', '**********')
  describe 'getMeta', ->
    beforeEach ->
      spyOn(atom.config, 'get').andReturn('/tmp/glist-test.cson');
      spyOn(atom.config, 'set')
      spyOn(atom.workspace, 'getActivePaneItem').andReturn
        getURI: ->
          '/tmp/gistid/gist-file-name.rb'
        getTitle: ->
          'gist-file-name.rb'
        getText: ->
          'gist content blah blah'
        destroy: jasmine.createSpy()
      # CSON.writeFileSync '/tmp/glist-test.cson',
      #   hehe: 'da'
      atom.commands.dispatch workspaceElement, 'glist:toggle'
      atom.commands.dispatch workspaceElement, 'glist:saveGist'
      waitsForPromise ->
        activationPromise
    it 'get all meta data from meta file', ->
      dialogElement = workspaceElement.querySelector('.tree-view-dialog')
      dialogElement.querySelector('.btn-primary').click()


  describe "intergration test", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
    beforeEach ->
      jasmine.attachToDOM(workspaceElement)
      spyOn(atom.config, 'get').andReturn('/tmp/glist-test.cson');
      spyOn(atom.config, 'set')
      atom.commands.dispatch workspaceElement, 'glist:toggle'
      waitsForPromise ->
        activationPromise

    it 'hide and show glist view', ->
        # Now we can test for view visibility
      glistElement = workspaceElement.querySelector('.glist-listview')
      expect(glistElement).toBeVisible()
      atom.commands.dispatch workspaceElement, 'glist:toggle'
      expect(glistElement).not.toBeVisible()
