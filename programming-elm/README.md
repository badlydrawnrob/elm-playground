# README


## Useful features

1. Boolean for [`disabled`](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#disabled) ([examples](https://www.w3schools.com/tags/att_fieldset_disabled.asp)) on form elements.
2. [Default `value`](https://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#value) for form elements (automatically updates the model element passed to it. It's an opaque type so you can't "get" the value)
3. [`onInput`](https://package.elm-lang.org/packages/elm/html/latest/Html-Events#onInput) Html event (pass to a `Update String` message)


## Things for Anki

1. `onInput : (String -> msg) -> Attribute msg` within a form, takes a function that returns a `msg` typr variable. So `UpdateComment String` is a function and also a `Msg` type. The DOM event handler will pass the `event.target.value` as a `String` argument. Every time the value changes in the input field. See (3) in the `viewComments` function.
2. When to validate forms and if you can rely on only HTML5 field form validators, such as regex and disable.


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
