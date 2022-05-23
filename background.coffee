# Globals:

currentTweet = null

chrome.runtime.onInstalled.addListener ->
  chrome.contextMenus.create
    contexts: ['all']
    documentUrlPatterns: ['https://*.twitter.com/*']
    id: 'this-should-be-unique'
    title: 'do a block'
    # TODO: any more complexity in this menu?
    type: 'normal'
    visible: yes

chrome.runtime.onConnect.addListener (port) ->
  switch port.name
    when 'contextmenu-initiate' then port.onMessage.addListener (msg) ->
      console.log 'contextmenu:'
      console.log msg
      currentTweet = msg
    when 'traverse-likes' then port.onMessage.addListener (msg) ->
      console.log 'traverse-likes:'
      console.log msg
      if currentTweet?
        # Tell the content script to go back a page in history.
        port.postMessage 'back'
    else throw new Error "unrecognized port name: #{port.name}"

chrome.contextMenus.onClicked.addListener (info, {id: tabId}) ->
  chrome.scripting.executeScript
    target: {tabId}
    func: (context) ->
      {tweeter, statusNumber, mentioned} = context

      statusPage = "/#{tweeter}/status/#{statusNumber}"
      rtsPage = "#{statusPage}/retweets"
      qtsPage = "#{rtsPage}/with_comments"
      likesPage = "#{statusPage}/likes"

      pages = {statusPage, rtsPage, qtsPage, likesPage}

      console.log {context, pages}
      chrome.storage.local.set {tweetContext: JSON.stringify {context, pages}}

      # Redirect to the /likes page, activating 'likes.coffee'.
      document.location.pathname = likesPage
    args: [currentTweet]
