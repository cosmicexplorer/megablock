chrome.runtime.onInstalled.addListener ->
  chrome.contextMenus.create
    # FIXME: can we narrow this?
    contexts: ['all']
    documentUrlPatterns: ['https://*.twitter.com/*']
    id: 'this-should-be-unique'
    title: 'do a block'
    # TODO: any more complexity in this menu?
    type: 'normal'
    visible: yes

currentTweet = null

chrome.runtime.onConnect.addListener (port) ->
  switch port.name
    when 'contextmenu-initiate'
      port.onMessage.addListener (msg) ->
        console.log msg
        currentTweet = msg
    else throw new Error "unrecognized port name: #{port.name}"

chrome.contextMenus.onClicked.addListener (info, {id: tabId}) ->
  chrome.scripting.executeScript
    target: {tabId}
    func: (currentTweet) ->
      console.log currentTweet
    args: [currentTweet]
