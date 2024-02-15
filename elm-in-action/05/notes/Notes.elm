module Notes exposing (..)

-- 5.1.1 -----------------------------------------------------------------------

-- Json.Encode --
--
-- We're not using this to encode JSON, but rather encode a JavaScript `Value`
-- for the `Html.Attributes.property` function. This will set a `JavaScript
-- _property_ on this `<range-slider>` node, so that our custom element can
-- read it later. The property will be named `val` and it will be set to our
-- `magnitude` value.

Html.Attributes.property "val" (Json.Encode.int magnitude)

-- `Json.Encode.int` function specifies what the property's type will be on the
-- JS side. You could've used `Json.Encode.string (String.fromInt m)) instead,
-- which would set to a JS string instead of a number.


-- Don't be ambiguous!! --------------------------------------------------------
--
-- Two names from different modules can cause an error:
--
-- `max` (the number function)
-- `Html.Attributes.max`

import Html.Attributes as Attr exposing (class, classList, ...)

-- Now you can call `Attr.max` instead!
