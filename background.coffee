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

pagesFromTweet = ({tweeter, statusNumber, mentioned}) ->
  statusPage = "/#{tweeter}/status/#{statusNumber}"
  rtsPage = "#{statusPage}/retweets"
  qtsPage = "#{rtsPage}/with_comments"
  likesPage = "#{statusPage}/likes"
  {statusPage, rtsPage, qtsPage, likesPage}

chrome.runtime.onConnect.addListener (port) ->
  switch port.name
    when 'contextmenu-initiate' then port.onMessage.addListener (msg) ->
      console.log 'contextmenu:'
      console.log msg
      currentTweet = {context: msg, pages: pagesFromTweet msg}
    when 'traverse-likes' then port.onMessage.addListener (msg) ->
      console.log 'traverse-likes:'
      console.log msg
      chrome.storage.local.set {likes: JSON.stringify msg}
      # Redirect to the /retweets page, activating 'rts.coffee'.
      chrome.storage.local.get ['tweetContext'], ({tweetContext}) ->
        tweetContext = JSON.parse tweetContext
        console.log tweetContext
        {pages: {rtsPage}} = tweetContext
        port.postMessage {next: rtsPage}
    when 'traverse-rts' then port.onMessage.addListener (msg) ->
      console.log 'traverse-rts:'
      console.log msg
      chrome.storage.local.set {rts: JSON.stringify msg}
      # TODO: now generate a landing page with a confirmation on whether to megablock!
    else throw new Error "unrecognized port name: #{port.name}"

chrome.contextMenus.onClicked.addListener (info, {id: tabId}) ->
  chrome.scripting.executeScript
    target: {tabId}
    func: (tweetContext) ->
      chrome.storage.local.set {tweetContext: JSON.stringify tweetContext}
      {pages: {likesPage}} = tweetContext

      # Redirect to the /likes page, activating 'likes.coffee'.
      document.location.pathname = likesPage
    args: [currentTweet]
