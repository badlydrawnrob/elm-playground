module Anki.Lazy exposing (..)

{-| A test file for an Anki flashcard (delete anytime)

> The web obesity crisis (video)

Start with working code and improve where possible.

1. Lazy images (for data dark spots)
2. Lazy loading
3. Lazy evaluation
4. Lazy lists

@ https://www.youtube.com/watch?v=34zcWFLCDIc
@ https://codepen.io/m1y474/pen/bNbVBpQ
@ https://codepen.io/hexagoncircle/pen/yyBMGrL
(scroll snap and horizontal scrolling like the Telegraph website)

- How are people accessing your app. When? Which device?
- How real is the need for a zippy fast experience for all users?
- Printability (print a recipe) — get straight to the point, no fluff
- Low/no 4G available (load a simple view or plain HTML)
- RSS and feeds for slow connections

Are you trying to be able detect those slow connections or optimise web for slow network?
Either the way just do some testing with browser dev tools console where you can simply
simulate whatever network speed you need to see how your web/app is behaving.

“I want to find a meal in my current location” so heavy optimisation would be a safe bet.

I was actually considering both. Test the network and render a text only version of your
collection if slow network detected (with “load images” option), if fast network load only
a preview image (of different resolutions), and on reveal load full images.

I guess you could pass in isMobile? and loadSpeed flags on first load
@ https://accreditly.io/articles/detecting-a-slow-internet-connection-in-javascript
and subsequent `Loading | Loaded | SlowLoading` messages for http requests.

Images have certainly moved on quite a bit, and the browser handles a lot for image resolution
(1x, 2x, etc) — but you’d be surprised how slow loading (or no loading) things are in 4g/5g dead
spots (unreliable on Three network for instance).

Another example is Google Maps loads a list of restaurants, but many of the images don’t load
(or load slowly). I tested 4g today with a friends Virgin/02 network and even this brutalist
website wouldn’t load 2 times out of 3 @ https://brutalist-web.design and it’s ALL text.

So either it depends on your provider, busyness of the network, websites have become bloated,
or some other reasons. It’s quite surprising and annoying.

There’s now loading=“lazy” attribute for images, but it’s up to the individual browser how to
interpret that https://web.dev/articles/browser-level-image-lazy-loading#distance-from-viewport
— in Safari iOS it seems to load two viewport heights of images, then loads on scroll (just before
you reach the next image).

Example here https://mathiasbynens.be/demo/img-loading-lazy (scroll fast to see lazy loading)

-}
