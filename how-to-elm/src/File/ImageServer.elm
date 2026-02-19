module File.ImageServer exposing (..)

{-| ----------------------------------------------------------------------------
    A reliable image server (https://ImgBB.com)
    ============================================================================
    > ⚠️ ImgBB is fine for testing, but find a better server for live.
    > ⚠️ If you're operating in one area a CDN is overkill!!

    Who's viewing? Who's uploading? From which country?

    ImgBB has very little customer service, so a better server is needed.
    Escape Json if sending in it's raw format (e.g: moustache files).

    There's a lot of image CDNs/hosting to choose from @ https://bunny.net,
    @ https://tinify.com/cdn, @ https://www.file.io/, @ https://www.cloudinary.com/,
    and so on. Other services like @ https://uploadcare.com/pricing/ and
    @ https://www.cloudimage.io/which provide (Ai) transforms and optimizations.

    Things get pricey however at scale for some (£40-£100/month), so it mightn't
    be a bad idea to optimize offline with an app or LLM.


    Some example SDKs for Python:
    -----------------------------

        @ https://tinify.com/developers/reference/python (paid)
        @ https://pypi.org/project/pillow/ (free)


    Issues
    ------
    1. API sometimes creates unique url, othertimes uses the filename.
    2. See @ issue #43 for notes on `Base64`, CURL e.g, and CORS errors.


    CURL
    ----
    > Must be sent as a form

    ```
    curl --location \
         --request POST "https://api.imgbb.com/1/upload?expiration=600&key=[YOUR-API-KEY]" \
         --form "image=[DATA-STRING|HTTP-IMAGE-URL]"
    ```

    Examples
    --------
    > Any image will do

        @ https://cdn.sstatic.net/Sites/stackoverflow/company/img/logos/so/so-logo.png (low def)
        @ https://commons.wikimedia.org/wiki/Category:Girl_with_a_Pearl_Earring_(Koorosh_Orooj) (high def)

    Example API HTTP request with `Html.track`

        @ https://github.com/passiomatic/elm-designer/blob/master/src/Imgbb.elm
        @ https://tinyurl.com/elm-http-request-with-form (configure multipart `--form`)

-}


type ApiKey
    = ApiKey String

exampleResponse : String
exampleResponse =
    """
    {
        "data": {
            "id": "GcrbjRd",
            "title": "602e5c7474580-dipqm35gir161-700",
            "url_viewer": "https://ibb.co/GcrbjRd",
            "url": "https://i.ibb.co/2gpfBdF/602e5c7474580-dipqm35gir161-700.jpg",
            "display_url": "https://i.ibb.co/5BJfVL1/602e5c7474580-dipqm35gir161-700.jpg",
            "width": 700,
            "height": 698,
            "size": 98898,
            "time": 1729271123,
            "expiration": 800,
            "image": {
            "filename": "602e5c7474580-dipqm35gir161-700.jpg",
            "name": "602e5c7474580-dipqm35gir161-700",
            "mime": "image/jpeg",
            "extension": "jpg",
            "url": "https://i.ibb.co/2gpfBdF/602e5c7474580-dipqm35gir161-700.jpg"
            },
            "thumb": {
            "filename": "602e5c7474580-dipqm35gir161-700.jpg",
            "name": "602e5c7474580-dipqm35gir161-700",
            "mime": "image/jpeg",
            "extension": "jpg",
            "url": "https://i.ibb.co/GcrbjRd/602e5c7474580-dipqm35gir161-700.jpg"
            },
            "medium": {
            "filename": "602e5c7474580-dipqm35gir161-700.jpg",
            "name": "602e5c7474580-dipqm35gir161-700",
            "mime": "image/jpeg",
            "extension": "jpg",
            "url": "https://i.ibb.co/5BJfVL1/602e5c7474580-dipqm35gir161-700.jpg"
            },
            "delete_url": "https://ibb.co/GcrbjRd/9556d9e20d20bfe8ed532b961646f631"
        },
        "success": true,
        "status": 200
    }
    """
