# Globals:
port = chrome.runtime.connect name: 'traverse-likes'

chrome.storage.local.get ['tweetContext'], ({tweetContext}) ->
  if tweetContext?
    (new MutationObserver observeMutation port).observe document,
      childList: yes
      subtree: yes

port.onMessage.addListener (msg) ->
  if msg is 'back'
    history.back()
  else throw new Error "unrecognized message: #{msg}"
