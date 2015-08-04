CalculateView = require './calculate-view'
{CompositeDisposable} = require 'atom'

module.exports = Calculate =
  calculateView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @calculateView = new CalculateView(state.calculateViewState)
    @modalPanel = atom.workspace.addModalPanel(
      item: @calculateView.getElement(), visible: false
    )

    # Events subscribed to in atom's system can be easily cleaned up with a
    CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'calculate:sum':
      => @sum()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @calculateView.destroy()

  serialize: ->
    calculateViewState: @calculateView.serialize()

  getSelectedText: ->
    if @editor = atom.workspace.getActiveTextEditor()
      @editor.getSelectedText()
    else
      false

  sum: ->
    if text = @getSelectedText()
      lines = text?.split('\n') || 0
      sum = 0
      for line in lines
        if figure = parseFloat line
          sum += figure
      @editor.insertText text + '\nSum: ' + sum
    else
      console.log 'No text selected'
