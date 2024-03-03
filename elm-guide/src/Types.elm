module Types exposing (..)

{-| From the `Types` section of the guide -}
import Buttons exposing (Msg)


-- Type inferance --

-- This code would throw an error if the fieldnames were entered
-- incorrectly at some point. The compiler helps us check things!
-- A wrongly worded record name would be a type error.

toFullName person =
  person.firstName ++ " " ++ person.lastName

fullName =
  toFullName { firstName = "Hermann", lastName = "Hesse" }


-- Reading types ---------------------------------------------------------------

-- Functions and operators expect a certain type. You can also add
-- type annotations to get specific about what types are allowed
-- (and what types are output).

"hello"       -- "hello" : String
not True      -- False : Bool
round 3.1415  -- 3 : Int

["Alice", "Bob"]  -- : List String
[1.0, 8.6, 42.1]  -- : List Float

String.length  -- <function> : String -> Int
String.length "supercalifragi"  -- 14 : Int


half : Float -> Float
half n =
  n / 2

half 56   -- 128
half "3"  -- error!

hypotenuse : Float -> Float -> Float
hypotenuse a b =
  sqrt (a^2 + b^2)

hypotenuse 3 4   -- 5
hypotenuse 5 12  -- 13


checkPower : Int -> String
checkPower powerLevel =
  if powerLevel > 9000 then "It's over 9000!!!" else "Ok"

checkPower 9001  -- "It's over 9000!!!"
checkPower True  -- error!


-- Type Variables --------------------------------------------------------------

-- Such as `List a`, where `a` could stand for an
-- `Int` or `String` or whatever

List.length [1,2,3]         -- 3 : List Int
List.length ["one", "two"]  -- 2 : List String
List.length [True, False]   -- 2 : List Bool

List.reverse                  -- <function> : List a -> List a
List.reverse ["a", "b", "c"]  -- ["c", "b", "a"] : List String


-- Contstrained Type Variables -------------------------------------------------

-- For example `number`, `comparable`, `appendable` which are a certain type
-- of variable _constrained_ to a certain range of types, for instance `number`
-- is an `Int` or a `Float`. It constrains the possibilities.

negate  -- <function> : number -> number

negate 3.1415          -- -3.1415 : Float
negate (round 3.1415)  -- -3 : Int

(+)  -- <function> : number -> number -> number


-- Type Aliases ----------------------------------------------------------------

-- Type annotations can start to get long. For instance, records with
-- many fields. This is where Type Aliases can become useful.alias
--
-- Type annotations for records (and records only) will generate a
-- constructor function.

type alias User =
  { name : String
  , age : Int
  }

isOldEnoughToVote : User -> Bool
isOldEnoughToVote user =
  user.age >= 18

isOldEnoughToVote : Bool
isOldEnoughToVote { name = "Frank", age = 23 }  -- True

User  -- <function> : String -> Int -> User
User "Sue" 58  -- { name = "Sue", age = 58 } : User


-- Custom Types ----------------------------------------------------------------

-- Custom Types are the MOST IMPORTANT FEATURE of Elm. They have a lot of
-- depth, especially when trying to model scenarios precisely.alias
--
-- See also:
--
--    @ https://guide.elm-lang.org/appendix/types_as_sets
--    @ https://guide.elm-lang.org/appendix/types_as_bits
--
-- E.g: Every user needs a name but some don't have a permanent account,
-- so we can create a `UserStatus` with two different types.alias

type UserStatus = Regular | Visitor

type alias User =
  { status : UserStatus
  , name : String
  }

thomas = { status = Regular, name = "Thomas" }
kate95 = { status = Visitor, name = "Kate95" }

selectUser : User -> Bool
selectUser {status, name} =
  name == Regular

selectUser kate95  -- False


-- Alternatively, we could simple use Types to represent
-- this information:

type User
  = Regular String
  | Visitor String

thomas = Regular "Thomas"
kate95 = Visitor "Kate95"


-- You can assign different data to these type containers

type User
  = Regular String Int
  | Visitor String

Regular  -- <function> : String -> Int -> user
Visitor  -- <function> : String


-- Messages and Modeling -------------------------------------------------------

-- This comes in quite handy when dealing with `Msg` types,
-- where each `Msg` requires a different piece of data.alias
-- You can pretty much use any type of data here, even
-- recursive data!
--
-- This allows you to describe interactions in your application very precisely.

type Msg
  = PressedEnter
  | ChangedDraft String
  | RecievedMessage { user : User, message : String }
  | ClickedExit

-- Custom types beome extremely powerful when you start modeling
-- solutions very precisely. For example waiting for data to load:

type Profile
  = Failure
  | Loading
  | Success { name : String, description : String }

-- 1. Start on Loading state
-- 2. It's a Failure or a Success
-- 3. If Success, load data to work with.
--
-- Makes it simple to write a `view` function for different states.


-- Pattern Matching ------------------------------------------------------------

-- These also afford us guarantees, so we know if we make a typo, or try to
-- pass the wrong type to a function, the compiler will let us know!

type User
  = Regular String Int
  | Visitor String

toName : User -> String
toName user =
  case user of
      Regular name age ->  -- If `age` is unused, it's better to write it
        name               -- as a Wildcard, with `_` underscore.

      Visitor name ->
        name

-- toName (Regular "Thomas" 44) == "Thomas"
-- toName (Visitor "Kate95")    == "Kate95"


-- Elm treats errors as data. Remember, that withing a
-- function, the return values must be of the same type.
-- So if it's a Custom Union Type, this works nicely:
--
-- You need to make sure all branches are catered for!

type MaybeAge
  = Age Int
  | InvalidInput

toAge : String -> MaybeAge
toAge userInput =
  case (String.toInt userInput) of
      Just number ->
        Age number

      Nothing ->
        InvalidInput

-- toAge "24" == Age 24
-- toAge "99" == Age 99
-- toAge "ZZ" -- InvalidInput


-- This kind of thing comes up ALL THE TIME! For example, perhaps you want to
-- turn a bunch of user input into a `Post` to share with others.
-- What happens if they forget to add a title? Or no content in the `Post`?
--
-- We can validate a `Post` like so:

type MaybePost
  = Post { title : String, content : String }
  | NoTitle
  | NoContent

toPost : String -> String -> MaybePost
toPost title content =
  ...

-- toPost "hi" "sup?" == Post { title = "hi", content = "sup?" }
-- toPost "" ""       == NoTitle
-- toPost "hi" ""     == NoContent


-- Validation ------------------------------------------------------------------

-- Instead of just saying the input is invalid, we describe all the ways
-- that post could be invalid. If we have a `viewPreview : MaybePost -> Html msg`
-- function to preview valid posts, we can give a specific error message
-- in the preview area when something goes wrong!

-- These kind of situations are extremely common. Where the solution is
-- simple, you can use an off-the-shelf type. Where you want to get more
-- specific, create a custom type!
