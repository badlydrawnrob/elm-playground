# Custom Types

## Don't use a custom type unless it's ...

a) More explicit and better described data
b) Easier to work with (make impossible states impossible)
c) Better shaped than simple data (easier to reason about)


## Always ask:

1. Have I scoped the problem and sketched it out?
2. What problems have I discovered? What routes?
3. Do we _really_ need this feature?
4. Is this as simple as it can be? ('5 steps to reduce code')
    - We need to convert `Album` to a list ...
    - So we're not differentiating a single `Song` in our view
    - We _might_ want to enforce a singleton if saving to json
    - It's likely this could've been simplified to a `List Song`
6. Have I accounted for ALL POSSIBLE STATES of my data?
    - An `Album Song []` for example.
    - We MUST make sure at least an empty list is provided there
    - A `SongTime` uses a `Tuple` ONLY when form is saved. This makes our inputs a bit easier to deal with.


## A humble list (for example)

Take a list for example:

```elm
-- A list can be one of
[]
["singleton"]
["many", "items"]
```

In general we only care if it's empty or contains something. But perhaps we want
to assure a non-empty list. What would we do then?

```elm
type Songs
    = NoSongs
    | Songs (List Song)
```

This doesn't bring much to the table that a `Maybe (List Song)` doesn't. And with a `Maybe` we get all the extra functions like `Maybe.map` for free. We'd have to create some helper functions with this type.

```elm
type Songs
    = NoSongs
    | Songs Song (List Song)
```

This caters for a `[]` and a single `Song`, as well as the rest of the list. You'd have to think carefully if it's an improvement on a `Maybe (List Song)`.

### Pulling from json

We often have to cater for a list that may not exist, perhaps a json file. Here we
could use a `Maybe List`, a `NoSongs`, or maybe we want to use a `Collection`
instead, whereby we could search for it with an ID:

```elm
{
    "album" : "Name"
    "id"    : 256340
    "songs" : ["Afraid", "Heathen", ".."]
}
```

If that ID can't be found we'd return `Nothing`, or perhaps an `Err`. If the ID _can_ be found, we'd expect a list and render it with view. When saving to `json` we could _enforce_ at least one entry in that list.


### A few rules to follow

> First it's best to really think about the type of data you actually need, and the best way to represent this. Only action what you REALLY need, right now (YAGNI)

1. Don't store default data or `null` in json
    - Simply handle it with `Maybe` in your application
    - Default data hides potential issues and mute errors
2. `Maybe`s are just fine to use, but ...
    - Sometimes your own custom descriptive type is better
    - ONLY if it improves on simple data ..
    - Or makes impossible states (impossible)
3. Reach for `Maybe.withDefault` LATE (at the very end)
    - For example, at the last moment in your `view`.
4. For other custom types, you can reach for a codec ...
    - Codecs are fine for _transmitting_ the data. But you probably don't want to store it as is ...
    - Your custom types and `json` data can get out of sync VERY quickly, if you store them directly.
    - You'd have to version your custom types if you saved them as json.


### Climbing the wall

The problem with our `Maybe` or `Songs` type is that before we can deal with our list, we have to "climb the wall" so to speak, to "lift" or unpack the list. Only then can we check for empty, single, or a full list and start working with the data. `Maybe` gives us some ready made functions for this purpose. If we use a custom type, we have to write our own functions.

Either way, all that lifting adds up and creates quite a bit of work for ourselves. I feel the best way is to unpack it in ONE place where possible.




