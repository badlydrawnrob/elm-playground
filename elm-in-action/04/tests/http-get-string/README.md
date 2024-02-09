# README

> [Fetching data with `Html.get` tutorial](https://elmprogramming.com/fetching-data-using-get.html)[^1]
>
> ⚠️ Warning! Beware of [url errors](http://tinyurl.com/beginning-elm-origin-200-error)!![^2]]

```terminal
# terminal window 1
npx http-server server -a localhost -p 5016

# terminal window 2
elm reactor
```

## Other tutorials

- [Handling HTTP Errors](https://elmprogramming.com/fetching-data-using-get#handling-http-errors)


[^1]: Using [`npx`](https://stackoverflow.com/a/52018825) instead of installing server globally.


[^2]: In Console you can go to `Errors` and it will show any bugs that need attending to. **See [Allowing Cross-Origin Resource Sharing](https://elmprogramming.com/fetching-data-using-get.html#allowing-cross-origin-resource-sharing)** — this is very important for security reasons. The `http-server` package provides an option called `--cors` for enabling Cross-Origin Resource Sharing (CORS) via the `Access-Control-Allow-Origin` header.
