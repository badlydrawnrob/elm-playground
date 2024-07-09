# README


## Useful features

1. Boolean for [`disabled`](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#disabled) ([examples](https://www.w3schools.com/tags/att_fieldset_disabled.asp)) on form elements.
2. [Default `value`](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#value) for form elements (automatically updates the model element passed to it. It's an opaque type so you can't "get" the value)
3. [`onInput`](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onInput) Html event (pass to a `Update String` message)


## Things for Anki

1. `onInput : (String -> msg) -> Attribute msg` within a form, takes a function that returns a `msg` typr variable. So `UpdateComment String` is a function and also a `Msg` type. The DOM event handler will pass the `event.target.value` as a `String` argument. Every time the value changes in the input field. See (3) in the `viewComments` function.
2. When to validate forms and if you can rely on only HTML5 field form validators, such as regex and disable.
3. A picture of decoders. See pg.69 and earlier pages. How is `succeed` decoder passed into another decoder?
    - You need to write this whole section in language that's easier to understand with imagery.
    - [Order matters](https://discourse.elm-lang.org/t/should-decoder-and-record-be-fields-order-independant/3295/4) in the decoder (it'll populate in the order of the curried function variables), but key/values can be in any order in the json string. It maps in the order of the decoder.
    - The string in `required "name" string` decoder is the `key` in the json string.
    - Possibly a good idea to show a _basic_ decoder in the original `Json.Decode` and a more _complex_ decoder with `Json.Decode.Pipeline` as it does seem a little easier to grasp — things like []`hardcoded`](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest/Json-Decode-Pipeline#hardcoded) are handy.
    - When showing the `photoDecoder` you should've by now shown that calling the `Photo` type alias is basically the same as creating a record. It's called a `constructor` function.
    - **Order matters** if you switched the order of the `id` and `url` fields you'd get a compiler error. It follows the order of the arguments for the function (in this case a record) you're passing to the decoder.
4. Add an example of loading the json from a localhost server (see pg.74)
5. pg. 75 (and check [Beginning Elm](https://elmprogramming.com/who-this-book-is-for.html) also) for a diagram of how different functional programming is from javascript — it's pure with no [side-effects](https://elmprogramming.com/side-effects.html).
4. Validating data: Is HTML5 form validation enough? If you're using json encoder (to post) it might well be.
    - Client-side form validation is a good way for enhancing user experience, it also provides some styling that can help to communicate that an input is required.
    - But you will allways still have to validate any data submitted on the server, making sure is clean and safe data. The required attribute can be manipulated by a malicious user.


## Renaming files, folders, script

**Be careful of naming conventions and refactoring the model names.** Currently I'm using the chapter names for filenames, and storing each chapter's files in it's own `src/ChapterName/..` folder.

```elm
// So this ...
module FileName exposing (main)
// Becomes this ...
module FolderName.FileName exposing (main) element
```

You'll also need to rename the script calling the Elm module in the `index.html` file. Something like this:

```html
<script>
// The name of the module
Elm.FolderName.FileName.init({
    node: document.getElementById('selector') // the HTML element
});
<!/script>
```
