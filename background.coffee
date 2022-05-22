chrome.action.onClicked.addListener ({id}) ->
  chrome.scripting.executeScript
    target:
      tabId: id
    function: ->
      alert 'hello'
