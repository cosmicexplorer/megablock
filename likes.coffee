# Globals:
port = chrome.runtime.connect name: 'traverse-likes'

chrome.storage.local.get ['tweetContext'], ({tweetContext}) ->
  if tweetContext?
    observer = new MutationObserver observeMutation(port, 'div[aria-label="Timeline: Liked by"]')
    observer.observe document,
      childList: yes
      subtree: yes

port.onMessage.addListener ({next}) ->
  console.log "next: #{next}"
  document.location.pathname = next
