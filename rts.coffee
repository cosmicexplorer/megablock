# Globals:
port = chrome.runtime.connect name: 'traverse-rts'

chrome.storage.local.get ['tweetContext'], ({tweetContext}) ->
  if tweetContext?
    observer = new MutationObserver observeMutation(port, 'div[aria-label="Timeline: Retweeted by"]')
    observer.observe document,
      childList: yes
      subtree: yes
