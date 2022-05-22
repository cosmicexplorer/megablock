chrome.contextMenus.onClicked.addListener (info, tab) ->
  {id: tabId} = tab
  chrome.scripting.executeScript
    target: {tabId}
    func: ->
      {anchorNode, focusNode, type} = document.getSelection()
      console.assert anchorNode == focusNode
      console.assert type in ['Caret', 'Range']
      curParent = anchorNode.parentNode
      while curParent.nodeName isnt 'ARTICLE'
        console.log curParent.nodeName
        curParent = curParent.parentNode
      console.log curParent
  console.log info
  console.log tab

chrome.runtime.onInstalled.addListener ->
  chrome.contextMenus.create
    contexts: ['all']
    # documentUrlPatterns: ['https://*.twitter.com/*']
    id: 'this-should-be-unique'
    title: 'do a block'
    type: 'normal'
    visible: yes
