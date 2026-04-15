module Http.Markdown exposing (..)

{-| ----------------------------------------------------------------------------
    A simple markdown app
    ============================================================================
    > Slightly better than Evan's markdown package, and simpler than others.

    Based on the latest CommonMark specification, with a few differences.
    What I'm looking to achieve here is:

    1. Sanitized markdown rendering (no XSS)
    2. Individal markdown blocks (could be form fields)


    Other Markdown packages
    -----------------------
    > In order of complexity ...

    @ https://package.elm-lang.org/packages/elm-explorations/markdown/latest/
    @ https://package.elm-lang.org/packages/dillonkearns/elm-markdown/latest/
    @ https://package.elm-lang.org/packages/jxxcarlson/elm-markdown/latest/


    Sanitize input
    --------------
    > HTML tags can be sanitized or unparsed.

    Generally speaking for user input you'd want unparsed HTML. If you're using
    Markdown for content then why would you allow raw HTML? I'm not sure how it
    sanitizes the input or how secure it is.


    Highlight JS
    ------------
    > The CLI converts the file lock stock and barrel.

    Will include even the `<pre><code>` tags which is a bit annoying.


    Learning points
    ---------------
    > Namespace clashes with two different Markdown packages.

    The namespaces are the same and I don't think there's a workaround. For the
    time being, you'll have to make sure ONLY ONE is installed at a time.


    ----------------------------------------------------------------------------
    WISHLIST
    ----------------------------------------------------------------------------
    1. ⚠️ Add support for attributes on markdown elements (e.g: {#id})
        - Programatically add attributes to `Markdown.Block` elements
        - Should the user be able to add these? (`DontParse` option)

-}

import Html exposing (..)
import Markdown
import Markdown.Block exposing (..)
import Markdown.Config exposing (HtmlOption(..), Options)
import Markdown.Inline exposing (..)

-- Markdown block --------------------------------------------------------------


{-| `String` -> `Markdown.Block`

> Each block can have it's own parsing options

- Allow raw HTML in the Markdown string.
- `Heading` is the raw text
- `Markdown.Block.Inline` gets rendered in view

You could've created this block from scratch. I'm sure it's not intended use,
but the raw text can be different from the rendered text. It's the inline stuff
that's rendered in the view.

```
[Heading ("Heading with *emphasis*")                        -- raw text (input)
    1                                                       -- heading level
    [Text ("Emphasis with "),Emphasis 1 [Text "heading"]]   -- rendered (inline elements)
]
```
-}
title : List (Block b i)
title =
    parse Nothing "# Markdown code renderer"

{-| Convert to `Html msg`

> See customisation on the package frontpage

This could be pointless but was trying to enable `clipboardjs`. Whereby each
block would have it's own clipboard copy button.

    @ https://clipboardjs.com/
-}
titleBlock =
    List.map Markdown.Block.toHtml title
    |> List.concat
    |> div []


-- Markdown regular ------------------------------------------------------------

inlineCode : String
inlineCode = "`function : List Int -> Int`"

subHeader : String
subHeader = "## Sub header {#id .class key=\"value\"}"

{-| Multiline string

> Must have no spaces or tabs in front of Markdown

If `String` has tabs it'll compile as plain text (like `<pre>`)
-}
body : String
body = """
This is a paragraph with **bold** and *italic* text,
as well as a [link](https://example.com){#id} and an image
![alt text](https://example.com/image.jpg). Here's a list:

- Item 1
- Item 2
"""

codeBlock : String
codeBlock = """
```php
module Main exposing (..)

{-| Here's a block of "documentation" code
That you can use to generate docs in Elm I think -}

import Browser as B exposing (..)

type Msg
  = ToMessage Int

onSlide : (Int -> msg) -> Attribute msg
onSlide toMsg =
  let
    detailUserSlidTo : Decode Int  -- A Json Decoder
    detailUserSlidTo =
      at [ "detail", "userSlidTo" ] int
    msgDecoder : Decoder msg  -- Maps to a Message
    msgDecoder =
      Json.Decode.map ToMsg detailUserSlidTo
  in
  on "slide" msgDecoder  -- Html.Event
at [ "detail", "userSlidTo" ] int  -- <internals> : Decoder Int
    |> Json.Decode.map ToMsg  -- <function> : Decoder Int -> Decoder Msg
    |> on "slide"  -- <function> : Decoder msg -> Html.Attribute ms


-- view --
view : Model -> Html Msg
view model =
  div [ id "choose-size" ]
    -- How can we clean up this section of the code?
    [ viewSizeChooser Small, viewSizeChooser Medium, viewSizeChooser Large ]

viewSizeChooser : ThumbnailSize -> Html Msg  -- #3
viewSizeChooser size =
  span [] [
    label []
    [ input [
        type_ "radio", name "size", onClick (ClickedSize size)  -- Handled by `Msg`
      ] []
    , text (sizeToString size)
    ]
  ]

-- case --
sizeToString : ThumbnailSize -> String
sizeToString size =
  case size of
      Small -> "small"
      Medium -> "med"
      Large -> "large"


-- model --
type ThumbnailSize
  = Small
  | Medium
  | Large
```
```
>> sizeToString Medium
"med"
```
```
<div><b>Disallow raw html</b></div>
```
"""


-- Options ---------------------------------------------------------------------

{-| Don't allow user input with HTML

- `DontParse` to remove ANY html
- `Sanitize options` to allow only safe html
-}
customOptions : Options
customOptions =
    { softAsHardLineBreak = False
    , rawHtml = Sanitize
        { allowedHtmlElements = []
        , allowedHtmlAttributes =
            [ "class", "id" ]
        }
    }


-- Main ------------------------------------------------------------------------

main =
  div []
    [ titleBlock -- Complicated way to render markdown blocks
    , div []
        --
        (List.concat
            <| List.map (Markdown.toHtml (Just customOptions))
                [ inlineCode, subHeader, body, codeBlock ]
        )
        --
    ]
