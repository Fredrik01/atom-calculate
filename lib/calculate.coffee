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

  # Get text from all selections
  getSelectedText: ->
    if @editor = atom.workspace.getActiveTextEditor()
      selection.getText() for selection in @editor.getSelections()
    else
      false

  sum: ->
    if selections = @getSelectedText()
      sum = 0
      for selection in selections
        lines = selection?.split('\n') || 0
        for line in lines
          if figure = parseFloat line
            sum += figure
      atom.clipboard.write sum.toString()
    else
      console.log 'No text selected'
