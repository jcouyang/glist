{TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class AddDialog extends View
  public: false
  @content: (state) ->
    @div class: 'tree-view-dialog', =>
      @label 'enter gist discription', class: 'icon', outlet: 'promptText'
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'btn-toolbar', =>
        @div class: 'btn-group', =>
          @button 'private', class: "btn #{"selected" unless state?.meta?.public}", outlet: 'privateButton'
          @button 'public', class: "btn #{"selected" if state?.meta?.public}", outlet: 'publicButton'
        @div class: 'btn-group', =>
          @button 'Save', class: 'btn btn-primary', outlet: 'saveButton'
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: (state) ->
    atom.commands.add @element,
      'core:confirm': =>
        @onConfirm(@miniEditor.getText(),@public)
        @cancel()
      'core:cancel': => @cancel()
    @miniEditor.getModel().setText(state.meta.description) if state?.meta?.description
    @saveButton.on 'click', =>
      @onConfirm(@miniEditor.getText(),@public)
      @cancel()
    @miniEditor.getModel().onDidChange => @showError()
    @privateButton.on 'click', =>
      @public = false
      @privateButton.addClass('selected')
      @publicButton.removeClass('selected')
    @publicButton.on 'click', =>
      @public = true
      @publicButton.addClass('selected')
      @privateButton.removeClass('selected')
    @attach()
  attach: ->
    @panel = atom.workspace.addModalPanel(item: this.element)
    @miniEditor.focus()
    @miniEditor.getModel().scrollToCursorPosition()

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    atom.workspace.getActivePane().activate()

  cancel: ->
    @close()

  showError: (message='') ->
    @errorMessage.text(message)
    @flashError() if message
