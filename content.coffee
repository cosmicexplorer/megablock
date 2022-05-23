port = chrome.runtime.connect name: 'contextmenu-initiate'

# When a contextmenu is initiated with a right click, find the tweet containing the place that was
# clicked, and extract the tweet's id, author, and other metadata. Send that to the mothership.
#
# We have to coordinate this separately from the context menu registration because the location
# registered when the context menu is selected is going to be down and to the right of where the
# user actually clicked, since they then need to mouse over and click our menu item.
document.addEventListener 'contextmenu', (e) ->
  containingArticle = e.target.closest 'article'
  return unless containingArticle?

  mentioned = []
  tweeter = null
  statusNumber = null

  for anchor in containingArticle.querySelectorAll 'a'
    href = anchor.getAttribute 'href'

    # Filter out the twitter help link, which is absolute.
    continue unless href.startsWith '/'
    # Otherwise, look for relative hrefs.
    components = href.split('/')[1..]

    # There are multiple types here, but the only ones with novel information are the mentions
    # and the status number. We can generate the rest of the necessary links from that
    # info alone.
    switch components.length
      when 1 then mentioned.push components[0]
      when 3
        # There should be exactly one of these.
        console.assert not tweeter?
        [tweeter, inner, statusNumber] = components
        return unless inner is 'status'
        # NB: we do *not* convert the tweet id (status number) to a Number, since in the conversion
        # to double it loses precision and will change the number. We could use a BigInt, but those
        # aren't serializable with JSON.stringify, so we can't pass them back to the
        # background script.
        console.assert statusNumber.match /^[0-9]+$/
        break

  return unless tweeter? and statusNumber?

  # We'll see multiple of the tweeter's name here; remove them all.
  console.assert mentioned.includes tweeter
  mentioned = mentioned.filter (m) -> m isnt tweeter

  port.postMessage {tweeter, statusNumber, mentioned}
