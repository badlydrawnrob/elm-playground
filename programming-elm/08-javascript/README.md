# README

> 💩 Fuck javascript: just use Elm solo.

- I've deviated from the book to only use Elm Lang packages
- Add basic image preview and send our images anywhere ...

Elm [examples](https://elm-lang.org/examples) don't _do_ anything with images, they simply upload to the javascript API by (a) multiple uploads with [`["target","files"]`](https://developer.mozilla.org/en-US/docs/Web/API/File_API/Using_files_from_web_applications), or (b) drag and drop with [`["dataTransfer","files"]`](https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/files). One downside is that `files` clears it's cache if more images are added.[^1]

The book's example uses javascript to upload and store images in `localStorage`, then Elm's `port`s send them to `Model` as a `List Image` to preview. An uploaded image is simply a `base64` string! Unfortunately learning about the low-level detail of file formats and sending to the server is difficult (one of Elm's downfalls — no easy plugins!), but we can safely ignore sending to the server for now. Thankfully, you can view a `base64` string with `<img src="data:image/png;base64">`!

1. [Convert](https://www.base64-image.de/) image to `base64`
    - Or use the [example app code](https://github.com/badlydrawnrob/elm-playground/blob/1db43ce18833a6530e15cd12fe7b54852adcdf03/how-to-elm/build/file-upload-image-to-server.html) here
2. Copy `base64` to clipboard and in terminal type:
    - `pbpaste | base64 -d > image.jpg`

<figure>
    <figcaption>Beware of large file sizes, they'll be sluggish to upload and save!</figcaption>
    <img src"">
</figure>

This chapter focused on Elm with Javascript. It involved a lot of boilerplate to run the server which I personally find [javascript syntax](https://eloquentjavascript.net) hard to read, even if the code isn't all that complicated. Beginners will find the build process daunting. After a lot of work I found [`esbuild`](https://esbuild.github.io) and `.jsx` files the easiest to manage, but my [initial attempt](https://github.com/badlydrawnrob/elm-playground/tree/9198e8a77ca557318d49c5e7dac6d15fa2f5fba1/programming-elm/08-javascript) wasn't well integrated with the script.

In essence all we have is:

1. A simple form with 3 fields
2. An image upload (with preview)

The original also sent data to `localStorage` which we can do if we wish.


## Image upload

You've got a couple ways to display the images. In order of ease:

1. Upload to an image server with url (stores image)
2. Convert image to `base64` and [preview](https://stackoverflow.com/questions/20756042/how-to-display-an-image-stored-as-byte-array-in-html-javascript) (does not store image)
3. See Elm's other image versions:
    - @ https://elm-lang.org/examples/drag-and-drop
    - @ https://elm-lang.org/examples/image-previews

For (2) the code is:

```html
<img id="ItemPreview" src="">
```
```js
document.getElementById("ItemPreview").src = "data:image/png;base64," + yourByteArrayAsBase
```


## Why not javascript?

> I find it hard to read and uncomfortable to work with.

1. Massive dependencies
2. 124 vulnerabilities (20 critical)
3. Outdated at the speed of light
4. Syntax is not easy to read


## Setup

```terminal
npm install --save-dev elm-watch@beta
npx elm-watch --help

# Change `elm-watch.json` paths if needed
npx elm-watch init

npx elm-watch hot
```

When we eventually want to release our app, we can optimize the build and copy over the files to the server. Optimisation won't work unless `Debug` code in `Main.elm` is removed!

```terminal
npx elm-watch make --optimize
```



[^1]: [Tiny PNG](https://tinypng.com) automatically processes each image on drag. I'm not sure there's anyway around this behaviour.
