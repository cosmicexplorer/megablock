port = chrome.runtime.connect name: 'contextmenu-initiate'

console.log 'hi'

document.addEventListener 'contextmenu', (e) ->
  {focusNode, type} = document.getSelection()
  console.assert type in ['Caret', 'Range']
  articleParent = focusNode.parentElement
  while articleParent.tagName isnt 'ARTICLE'
    articleParent = articleParent.parentElement
  console.log articleParent

  mentioned = []
  tweeter = null
  statusNumber = null
  for anchor in articleParent.querySelectorAll 'a'
    href = anchor.getAttribute 'href'

    # Filter out the twitter help link, which is absolute.
    continue unless href.startsWith '/'
    # Otherwise, look for relative hrefs.
    components = href.split('/')[1..]
    console.log components

    # There are multiple types here, but the only ones with novel information are the mentions
    # and the status number. We can generate the rest of the necessary links from that
    # info alone.
    switch components.length
      when 1 then mentioned.push components[0]
      when 3
        # There should be exactly one of these.
        console.assert not tweeter?
        [tweeter, inner, statusNumber] = components
        console.assert inner is 'status'
        console.assert statusNumber.match /^[0-9]+$/

  console.assert tweeter? and statusNumber?

  # We'll see multiple of the tweeter's name here; remove them all.
  # FIXME: why doesn't "console.assert tweeter in mentioned" work?
  console.assert mentioned.includes tweeter
  mentioned = mentioned.filter (m) -> m isnt tweeter

  # statusPage = "/#{tweeter}/status/#{statusNumber}"
  # rtsPage = "#{statusPage}/retweets"
  # qtsPage = "#{rtsPage}/with_comments"
  # likesPage = "#{statusPage}/likes"

  ret = {tweeter, statusNumber, mentioned}
  port.postMessage ret
  console.log ret
  console.log 'ok'
