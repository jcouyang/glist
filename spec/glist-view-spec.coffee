GlistView = require '../lib/glist-view'
{WorkspaceView} = require 'atom'
fs = require 'fs-plus'
path = require 'path'
shell = require 'shell'
mkdirp = require 'mkdirp'
describe "GlistView", ->
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

  describe "when delete gist file", ->
    it "will remove bot local and remote file",->
      gists = [
        {'id':'123456', 'files': {'tobeDeleted.txt':{'raw_url': 'a url'}}}
        {'id':'2', 'files': {'blah':{'raw_url': 'another url'}}}
      ]
      edit = spyOn(glistView.ghgist, "edit")
      detach = spyOn(glistView, "detach")
      filePath = path.join(__dirname, '/123456/tobeDeleted.txt')
      fs.writeFileSync(filePath)
      atom.workspaceView.openSync(filePath)
      glistView.gists = gists

      glistView.deleteCurrentFile()
      expect(edit.calls[0].args[0]).toBe('123456')
      expect(edit.calls[0].args[1]).toEqual({'files': {'tobeDeleted.txt':null}})

    it "will delete gist file if not in remote", ->
      shellspy = spyOn(shell, "moveItemToTrash")
      mkdirp.sync(path.join(__dirname, "/123456/"))
      filePath = path.join(__dirname, '/123456/tobeDeleted.txt')
      fs.writeFileSync(filePath)
      atom.workspaceView.openSync(filePath)

      glistView.deleteCurrentFile()
      expect(shellspy).toHaveBeenCalled()
