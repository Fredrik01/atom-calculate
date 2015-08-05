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

  # Remove left and right whitespace
  trim: (str) ->
    str.replace /^\s+|\s+$/g, ""

  # Check if the string contains any whitespace chars
  hasWhitespace: (str) ->
    str.indexOf(' ') >= 0

  isNumeric: (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)

  prepareNumber: (n) ->
    n = n.replace(/,/,".")
    @trim n

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
      parseErrors = 0
      for selection in selections
        lines = selection?.split('\n') || 0
        for line in lines
          line = @prepareNumber line
          if line.length
            if @isNumeric line
              sum += parseFloat line
            else
              parseErrors++
      atom.notifications.addSuccess 'Sum: ' + sum
      if parseErrors > 0
        rowStr = if parseErrors == 1 then 'line' else 'lines'
        message = "Couldn't process " + parseErrors + ' ' + rowStr
        atom.notifications.addWarning(message)
    else
      atom.notifications.addInfo "Couldn't find anything"
