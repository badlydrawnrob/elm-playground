# README

> [Fetching json with `Html.get` tutorial](https://elmprogramming.com/decoding-json-part-1.html)[^1] (part 1)
>
> ⚠️ Warning! Beware of [url errors](http://tinyurl.com/beginning-elm-origin-200-error)!![^2]]

```terminal
# terminal window 1
npx json-server --watch server/old-school.json -p 5019

# terminal window 2
elm reactor
```

## How it all works

We need to go through three steps to retrieve data from a server:

1. Specify where to retrieve data from using `Http.get`
2. Retrieve data. Use the Elm Runtime by sending a `Cmd`
3. This `Cmd` will in turn generate a `Msg`. It's either successful `Ok` or an `Err`or.
4. `Update` handles the model change.
5. We case `view` for both error and success.

## The url

With `http-server` the url is `/old-school.txt`, but with `json-server` it's using the `key` `"nicknames"` as the url `/nicknames` (not the filename.)

### Resources

For instance, this JSON defines three different resources: `posts`, `comments`, and `profile`. Each resource has a unique location from where we can access it.

1. `posts` and `comments` are collections.
2. `profile` is a single entity.

So running `json-server` on the json below (named `db.json`) **will give us a REST API with 3 different urls**.

```json
{
  "posts": [
    {
      "id": 1,
      "title": "json-server",
      "author": "typicode"
    },
    {
      "id": 2,
      "title": "http-server",
      "author": "indexzero"
    }
  ],
  "comments": [
    {
      "id": 1,
      "body": "some comment",
      "postId": 1
    }
  ],
  "profile": {
    "name": "typicode"
  }
}
```

### Navigating a REST API

For instance, each `/posts/` entry has a unique ID, so we can call the REST API in the path, like so: `/posts/1` — this would return the following:

```json
{
    "id": 1,
    "title": "json-server",
    "author": "typicode"
}
```

## Other tutorials

- [Handling HTTP Errors](https://elmprogramming.com/fetching-data-using-get#handling-http-errors)


[^1]: Currently using a non-alpha version of `json-server` (otherwise getting errors). Using [`npx`](https://stackoverflow.com/a/52018825) instead of installing server globally.


[^2]: In Console you can go to `Errors` and it will show any bugs that need attending to. **See [Allowing Cross-Origin Resource Sharing](https://elmprogramming.com/fetching-data-using-get.html#allowing-cross-origin-resource-sharing)** — this is very important for security reasons. There should be an option for `--cors` for enabling Cross-Origin Resource Sharing (CORS) via the `Access-Control-Allow-Origin` header.
