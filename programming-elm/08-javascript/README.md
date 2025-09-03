# README

> It might be wise to read a book like [Eloquent Javascript](https://eloquentjavascript.net), but I've been avoiding learning as it's so nasty to look at!

Remember that using anything javascript is going to come with a heavy dose of pain ...

1. Massive dependencies
2. 124 vulnerabilities (20 critical)
3. Outdated at the speed of light
4. And of course, shitty js syntax

Again I'm using Elm Watch for live reloading and `http-server` here:

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
