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
      s.getText() for s in @editor.getSelections() when !s.isEmpty()
    else
      null

  sum: ->
    selections = @getSelectedText()
    if selections? and selections.length
      sum = 0
      for selection in selections
        lines = selection?.split('\n') || 0
        for line in lines
          if figure = parseFloat line
            sum += figure
      atom.clipboard.write 'Sum: ' + sum
      console.log 'Sum: ' + sum
    else
      message = "Couldn't find any selections"
      console.log message
      atom.clipboard.write message
