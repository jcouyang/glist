CSON = require 'season'
Glist = require '../lib/glist'
octonode = require 'octonode'
shell = require 'shell'
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Glist", ->
  [workspaceElement, activationPromise] = []
  currentItem = null
  beforeEach ->
    currentItem =
      getURI: ->
        '/tmp/gistid/gist-file-name.rb'
      getTitle: ->
        'gist-file-name.rb'
      getText: ->
        'gist content blah blah'
      destroy: jasmine.createSpy()
      save: jasmine.createSpy()
    spyOn(octonode, 'client').andReturn
        gist: ->
          create: (option, cb)->
            cb()
          edit: (id, option, cb) ->
            cb()
          list: (cb) ->
            cb()
          delete: (id, cb) ->
            cb()

    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('glist')

  describe "when the glist:toggle event is triggered", ->
    beforeEach ->
      spyOn(atom.config, 'get').andReturn('/tmp/.gist.meta.cson');
      spyOn(atom.config, 'set')
      atom.commands.dispatch workspaceElement, 'glist:toggle'
      waitsForPromise ->
        activationPromise

    it "hides and shows the modal panel", ->
      expect(workspaceElement.querySelector('.glist-listview')).toExist()
    it 'write config into a file', ->
      expect(CSON.readFileSync('/tmp/.gist.meta.cson').token).toBe('/tmp/.gist.meta.cson')
    it 'safely mask github token in atom config', ->
      expect(atom.config.set).toHaveBeenCalledWith('glist.githubToken', '**********')
  describe 'delete Gist file', ->
    afterEach ->
      shell.moveItemToTrash '/tmp/gistid/.gist.meta.cson'

    beforeEach ->
      spyOn(atom.config, 'get').andReturn('/tmp/.gist.meta.cson');
      spyOn(atom.config, 'set')
      spyOn atom.notifications, 'addInfo'

    describe 'confirm', ->
      beforeEach ->
        spyOn(atom.workspace, 'getActivePaneItem').andReturn currentItem
        spyOn atom, 'confirm'
        CSON.writeFileSync '/tmp/gistid/.gist.meta.cson',
          id: 'gist-id'
          description: 'gist description'
        atom.commands.dispatch workspaceElement, 'glist:toggle'
        atom.commands.dispatch workspaceElement, 'glist:delete'
        waitsForPromise ->
          activationPromise
      it 'delete gist file', ->
        atom.confirm.calls[0].args[0].buttons.Delete()
        expect(atom.notifications.addInfo).toHaveBeenCalledWith('file [gist-file-name.rb] deleted.')

  describe 'saveGist', ->
    beforeEach ->
      spyOn(atom.config, 'get').andReturn('/tmp/.gist.meta.cson');
      spyOn(atom.config, 'set')
      spyOn atom.notifications, 'addInfo'

    describe 'without meta file', ->
      beforeEach ->
        spyOn(atom.workspace, 'getActivePaneItem').andReturn currentItem
        atom.commands.dispatch workspaceElement, 'glist:toggle'
        atom.commands.dispatch workspaceElement, 'glist:saveGist'
        waitsForPromise ->
          activationPromise

      it 'create a new gist', ->
        dialogElement = workspaceElement.querySelector('.tree-view-dialog')
        dialogElement.querySelector('.btn-primary').click()
        expect(atom.notifications.addInfo).toHaveBeenCalledWith('gist [] saved.')
        expect(currentItem.destroy).toHaveBeenCalled()
    describe 'with meta file', ->
      afterEach ->
        shell.moveItemToTrash '/tmp/gistid/.gist.meta.cson'
      beforeEach ->
        CSON.writeFileSync '/tmp/gistid/.gist.meta.cson',
          id: 'gist-id'
          description: 'gist description'
        spyOn(CSON, 'writeFile').andCallFake (dir,content, cb)->
          cb()
        spyOn(atom.workspace, 'getActivePaneItem').andReturn currentItem
        atom.commands.dispatch workspaceElement, 'glist:toggle'
        atom.commands.dispatch workspaceElement, 'glist:saveGist'
        waitsForPromise ->
          activationPromise

      it 'edit the current gist', ->
        dialogElement = workspaceElement.querySelector('.tree-view-dialog')
        dialogElement.querySelector('.btn-primary').click()
        expect(atom.notifications.addInfo).toHaveBeenCalledWith('gist [gist description] saved.')
        expect(CSON.writeFile.calls[0].args[1]).toEqual
          id: 'gist-id'
          description: 'gist description'
          public: false
        expect(currentItem.save).toHaveBeenCalled()

  describe 'delete Gist folder', ->
    afterEach ->
      shell.moveItemToTrash '/tmp/gistid/.gist.meta.cson'

    beforeEach ->
      spyOn(atom.config, 'get').andReturn('/tmp/.gist.meta.cson');
      spyOn(atom.config, 'set')
      spyOn atom.notifications, 'addInfo'
      spyOn(shell, 'moveItemToTrash').andCallThrough()

    describe 'confirm', ->
      beforeEach ->
        spyOn(atom.workspace, 'getActivePaneItem').andReturn currentItem
        spyOn atom, 'confirm'
        CSON.writeFileSync '/tmp/gistid/.gist.meta.cson',
          id: 'gist-id'
          description: 'gist description'
        atom.commands.dispatch workspaceElement, 'glist:toggle'
        atom.commands.dispatch workspaceElement, 'glist:deleteGist'
        waitsForPromise ->
          activationPromise
      it 'delete gist folder', ->
        atom.confirm.calls[0].args[0].buttons.Delete()
        expect(atom.notifications.addInfo).toHaveBeenCalledWith('gist [gist-id] deleted.')
        expect(shell.moveItemToTrash).toHaveBeenCalledWith('/tmp/gistid')

  describe "intergration test", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
    beforeEach ->
      jasmine.attachToDOM(workspaceElement)
      spyOn(atom.config, 'get').andReturn('/tmp/.gist.meta.cson');
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
