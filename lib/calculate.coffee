CalculateView = require './calculate-view'
{CompositeDisposable} = require 'atom'

module.exports = Calculate =
  calculateView: null
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'calculate:sum':
      => @sum()

  deactivate: ->
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

  # Get text from selections or from the current document
  getText: ->
    selections = @getSelectedText()
    if selections != null and selections.length == 0 and @editor
      return [@editor.getText()]
    selections

  sum: ->
    selections = @getText()
    if selections? and selections.length
      sum = 0
      allOk = true
      for selection in selections
        lines = selection?.split('\n') || 0
        for line in lines
          # Trim whitespace
          line = line.replace /^\s+|\s+$/g, ""
          if line.length
            figure = parseFloat line
            if !isNaN(figure)
              sum += figure
            else
              allOk = false
      atom.notifications.addSuccess 'Sum: ' + sum
      if not allOk
        atom.notifications.addWarning "Couldn't process all rows"
    else
      atom.notifications.addInfo "Couldn't find anything"
