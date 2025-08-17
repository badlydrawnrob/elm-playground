# Managing `json`

> There's something of personal taste in all this, or discover the downsides of a particular way of doing things through bugs. For example:
>
> - If you misspell the `"key"` does it fail?
>    - `field "misspelled" (nullable string)` does
>    - `optionalField` "misspelled" string` does not (`Json.Decode.Extra`)
> - If you have wrong data type does it fail?
> - What do we do about other `json` that gets ignored?

1. You have full control:
    - Encode and Decode to as nice a type as you can get
    - @SimonLydell says better to use `null` for Encode and Decode.[^1] Apparently it 
      leads to simpler code in the end. These are optional fields but we're being 
      explicit that they're missing.
    - @Sebastian says better to use `Maybe` rather than default data
    - Either way **never use `Json.Decode.maybe`**
2. External `json` you don't have control over:
    - Start by designing types as nice as you can.
    - Write decoders that decode into those nice types.
    - You can default a missing field to an empty type (or a `Maybe` where 
      appropriate)
    - You can fail on some impossible case that `json` allows but should never happen.


[^1]: I used to model things with lots of String and Maybe, until I forgot what all those strings and Nothings meant. I used to use `Json.Decode.maybe` until it lead to bugs in production.