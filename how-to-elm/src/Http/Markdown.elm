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


    Learning points
    ---------------
    > Two or more `Markdown` packages will clash

    The namespaces are the same and I don't think there's a workaround. For the
    time being, you'll have to make sure ONLY ONE is installed at a time.

-}

import Html exposing (..)
import Markdown
-- import Markdown.Config exposing (Config)


-- Markdown --------------------------------------------------------------------

{-| Must be without spaces

If `String` has tabs it'll compile as plain text (like `<pre>`)
-}
markdown : String
markdown = """
# Heading 1

## Heading 2

### Heading 3

#### Heading 4

##### Heading 5

###### Heading 6

**Bold Text**

*Italic Text*

***Bold and Italic Text***

- Unordered List Item 1
- Unordered List Item 2
- Unordered List Item 3

1. Ordered List Item 1
2. Ordered List Item 2
3. Ordered List Item 3

[Link Text](https://www.example.com)

![Image Alt Text](https://www.example.com/image.jpg)

> Blockquote Text

`Inline Code`

```
Code Block
```
"""

main =
  div []
    <| Markdown.toHtml Nothing markdown
