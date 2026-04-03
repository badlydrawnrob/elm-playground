# README

> Deviated from the book: just use Elm!

The purpose of this chapter in the book is to integrate Elm with Javascript. This involves a ton of boilerplate and a difficult build process. The javascript code isn't particularly difficult, but it's not an easy read (compared to Elm). I managed to use [`esbuild`](https://esbuild.github.io) and `.jsx` files to compile the script, but javascript build tools are a drag to learn. For beginners it feels harder than it should be.

At it's essence it's only:

1. A simple form
2. An image upload

Which could be posted to a server someplace.


-----

> It might be wise to read a book like [Eloquent Javascript](https://eloquentjavascript.net), but I've been avoiding learning as it's so nasty to look at!

Remember that using anything javascript is going to come with a heavy dose of pain ...

1. Massive dependencies
2. 124 vulnerabilities (20 critical)
3. Outdated at the speed of light
4. And of course, shitty js syntax

## Elm Watch and esbuild (instead of webpack)

Again I'm using Elm Watch for live reloading and `http-server` here. I've also made a few changes by adding `.less` files to `/src/style` and renaming `.js` files to `.jsx` and compile the lot with `npm run build`. You can see the full issue at [the book's repo](https://github.com/jfairbank/programming-elm.com/issues/17). For the purposes of this tutorial, I'm not interested in learning javascript, or spending ages learning how to wrestle with Parcel or Vite ... they're not very beginner friendly.

```terminal
npm install elm-watch@beta
npx elm-watch init

npm install react@16.5.2 react-dom@16.5.2

npm install --save-dev esbuild

# Rename your `.js` files to `.jsx`
npx esbuild src/index.jsx --bundle --outfile=public/app.js

# Add the `"serve": "./public/"` to the `elm.json` file underneath `"targets"`
npx elm-watch hot
```

When we eventually want to release our app, we can optimize the build and copy over the files to the server. Optimisation won't work unless `Debug` code is removed!

```terminal
npx elm-watch make --optimize
```

## Embedding the Elm App

> I looked through it and I can't be bothered to implement `ImageUpload` in the javascript way. Instead I'll just use the Elm `File` method, and populate `localStorage`.

Perhaps only add ONE image to show it can be done. First add your form text ... then add this hacky update with ports.

```javascript
// Retrieve the note
const note = localStorage.getItem('note')

// Add or update a value
note.field = { "url": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAB9AA..."}

// Reset the note object
localStorage.setItem('note', JSON.stringify(note));
```


