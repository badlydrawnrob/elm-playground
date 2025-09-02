# README

> You can also see `elm-watch` in action in `/06-build-larger-apps`

The book has you downloading "Create Elm App" (or Vite) and setting up the PicShare app again, but I've decided to keep things simple and use [`elm-watch`](https://lydell.github.io/elm-watch/) instead. It comes with it's own server (in beta) that we can also use to serve static files.

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
