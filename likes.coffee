# Globals:
port = chrome.runtime.connect name: 'traverse-likes'

foundSection = null
scrollIncrement = null

allLikers = []

# Functions:

currentlyVisibleLinks = (container) -> for innerSpan in container.querySelectorAll?('a span') or []
  # Vaguely match the text against regex to see if it's a username.
  profileName = innerSpan.textContent.match(///^@([a-zA-Z0-9_]+)$///)?[1]
  continue unless profileName?
  # We're looking for anchor tags pointing to the same person identified in the span.
  outerAnchor = innerSpan.closest 'a'
  continue unless outerAnchor.getAttribute('href').match(///^/([^/]+)$///)?[1] == profileName
  # Return a list of the parsed href locations (usernames).
  profileName

deduplicate = (list) -> list.filter (value, index, self) ->
  self.indexOf(value) is index

# Script:

tryCompleteScroll = (scrollable, increment, observer) -> ->
  prevScroll = scrollable.scrollTop
  scrollable.scrollBy 0, increment
  complete = ->
    # If no vertical scrolling was performed.
    if scrollable.scrollTop is prevScroll
      # Disconnect the observer after we've finished our work.
      observer.disconnect()
      # Return the likers to the background script.
      port.postMessage deduplicate allLikers
      # Scroll back to the top of the list.
      foundSection.scrollTo 0, 0
  setTimeout complete, 2000

observeMutation = (mutations, observer) ->
  for m in mutations
    console.assert m.type is 'childList'
    if not foundSection?
      for node in m.addedNodes
        if node.tagName is 'SECTION'
          labelDiv = node.querySelector 'div[aria-label="Timeline: Liked by"]'
          likesModal = labelDiv.closest 'div[aria-modal="true"]'
          # Get the wrapper div with the scrollbar.
          foundSection = likesModal.querySelector('section').parentElement
          console.assert getComputedStyle(foundSection).overflow == 'auto'
          initialScrollHeight = foundSection.scrollHeight
          scrollIncrement = initialScrollHeight / 20
          console.log "scrollIncrement: #{scrollIncrement}"
          break
      if not foundSection?
        continue
    console.assert foundSection? and scrollIncrement?

    if not foundSection.contains m.target
      continue
    console.log m.target
    curLinks = currentlyVisibleLinks foundSection
    if curLinks.length is 0
      continue
    console.log curLinks
    allLikers.push ...curLinks

    setTimeout tryCompleteScroll(foundSection, scrollIncrement, observer), 2000


(new MutationObserver observeMutation).observe document,
  childList: yes
  subtree: yes

# history.back()
