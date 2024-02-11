# README

> [Fetching json with `Html.get` tutorial](https://elmprogramming.com/decoding-json-part-1.html)[^1][^2] (part 1)

```terminal
# terminal window 1
npx json-server --watch server/old-school.json -p 5019

# terminal window 2
elm reactor
```

## 01a

### How it all works

We need to go through three steps to retrieve data from a server:

1. Specify where to retrieve data from using `Http.get` when a button is clicked;
2. This creates a `Cmd` to retrieve data. This data is added to a `Msg` type variant as payload.
3. We can `case` on the `Msg` variant in `update`. It's either successful (`Ok`) or unsuccessful (`Err`or).
4. `Update` changes the model depending on our `Msg`.
5. We also `case` within `view`, rendering a different state for a success or failure.

Now we have our data, what will we do with it? `Msg -> Update -> View`.

1. We need to check if our data is valid. We'll `case` again with our decoder function.
2. If valid `json`, `Ok` updates the model with our data, in turn updating our `view`.
3. If not, we update our `error` in `model` and render that in `view`.


## 01b

We can simplify our process (01) quite a bit by using `Http.expectJson` function insted of `Http.expectString`.

1. `Cmd` with `Http.get` using `url`. We let the Elm Runtime know we're expecting JSON response.
2. The runtime runs the command.
3. The runtime sends `DataReceived` message to `update`
    - Include decoded nicknames as a payload if the request to _retrieve JSON_ and _decoding_ both succed.
    - Include an error of type `Http.Error` as a payload if either the request to _retrieve JSON_ or the _decoding_ fails.
4. No need for any more steps!!

The retrieving and decoding of JSON happen in one go. The `Http.get` call includes the decoder in it's type signature.


## Our REST API (url)

With `http-server` the url is `/old-school.txt`, but with `json-server` it's using the `key` `"nicknames"` as the url `/nicknames` (not the filename.)

The process for retrieving JSON from a server isn't any different from retrieving a string. It's still a _raw string_. So how does Elm interpret it? The server uses a `Content-Type` header `application/json` value (for a string it uses `text/plain`).

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


[^2]: Unlike `http-server`, `json-server` automatically enables [Cross-Origin Resource Sharing](https://elmprogramming.com/fetching-data-using-get.html#allowing-cross-origin-resource-sharing) (CORS). That’s why we didn’t get the `No 'Access-Control-Allow-Origin' header is present on the requested resource.` error when fetching the nicknames.
