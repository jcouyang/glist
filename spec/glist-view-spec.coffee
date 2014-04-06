GlistView = require '../lib/glist-view'
{WorkspaceView} = require 'atom'

fdescribe "GlistView", ->
  glistView = null
  beforeEach ->
    atom.workspaceView = new WorkspaceView
    glistView = new GlistView

  describe "When initialize", ->
    it "will get fetch gists", ->
      updatelist = spyOn(glistView, "updateList")
      glistView.initialize()
      expect(updatelist).toHaveBeenCalled()

  describe "when update gist", ->
    it "will show indicator and fetch via octonode", ->
      indicator = spyOn(glistView, "showProgressIndicator")
      list = spyOn(glistView.ghgist, "list")
      glistView.updateList()
      expect(indicator).toHaveBeenCalled()
      expect(list).toHaveBeenCalled()

    it "will write files into gist folder", ->
      fetch = spyOn(glistView, "fetch")
      detach = spyOn(glistView, "detach")
      gists = [
        {'id':'1', 'files': {'blah':{'raw_url': 'a url'}}}
        {'id':'2', 'files': {'blah':{'raw_url': 'another url'}}}
      ]
      glistView.writefiles(null, gists)
      expect(fetch.calls[0].args[0]).toBe('a url')
      expect(fetch.calls[1].args[0]).toBe('another url')
      expect(detach).toHaveBeenCalled()

  # describe "when save gist", ->
