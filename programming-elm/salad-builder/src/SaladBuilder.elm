module SaladBuilder exposing (main)

import Browser
import Html
    exposing
        ( Html
        , button
        , div
        , h1
        , h2
        , input
        , label
        , li
        , p
        , section
        , table
        , td
        , text
        , th
        , tr
        , ul
        )
import Html.Attributes exposing (checked, class, disabled, name, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Http
import Json.Encode exposing (Value, list, object, string)
import Regex
import Set exposing (Set)



---- MODEL ----

{- Previously this was:

    { building : Bool
    , sending : Bool
    , success : Bool
    , error : Maybe String
    ...
    }

An impossible state could be showing the `viewConfirmation`
when `building`, `sending` and `success` are all `False` -}
type Step
    = Building (Maybe Error)
    | Sending
    | confirmation


type Base
    = Lettuce
    | Spinach
    | SpringMix


baseToString : Base -> String
baseToString base =
    case base of
        Lettuce ->
            "Lettuce"

        Spinach ->
            "Spinach"

        SpringMix ->
            "Spring Mix"


type alias Error =
    String


type Topping
    = Tomatoes
    | Cucumbers
    | Onions


toppingToString : Topping -> String
toppingToString topping =
    case topping of
        Tomatoes ->
            "Tomatoes"

        Cucumbers ->
            "Cucumbers"

        Onions ->
            "Onions"


type Dressing
    = NoDressing
    | Italian
    | RaspberryVinaigrette
    | OilVinegar


dressingToString : Dressing -> String
dressingToString dressing =
    case dressing of
        NoDressing ->
            "No Dressing"

        Italian ->
            "Italian"

        RaspberryVinaigrette ->
            "Raspberry Vinaigrette"

        OilVinegar ->
            "Oil and Vinegar"


type alias Salad =
    { base : Base
    , toppings : Set String
    , dressing : Dressing
    }


{- Extensible record -}
type alias Contact c =
    { c
        | name : String
        , email : String
        , phone : String
    }


type alias Model =
    { step : Step
    , salad : Salad
    , name : String
    , email : String
    , phone : String
    }


initialModel : Model
initialModel =
    { step = Building Nothing
    , salad =
        { base = Lettuce
        , toppings = Set.empty
        , dressing = NoDressing
        }
    , name = ""
    , email = ""
    , phone = ""
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, Cmd.none )



---- VALIDATION ----


isRequired : String -> Bool
isRequired value =
    String.trim value /= ""


isValidEmail : String -> Bool
isValidEmail value =
    let
        options =
            { caseInsensitive = True
            , multiline = False
            }

        regexString =
            "^(([^<>()\\[\\]\\.,;:\\s@\"]+(\\.[^<>()\\[\\]\\.,;:\\s@\"]+)*)|(\".+\"))@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$"

        regex =
            Regex.fromStringWith options regexString
                |> Maybe.withDefault Regex.never
    in
    value
        |> String.trim
        |> Regex.contains regex


isValidPhone : String -> Bool
isValidPhone value =
    let
        regex =
            Regex.fromString "^\\d{10}$"
                |> Maybe.withDefault Regex.never
    in
    value
        |> String.trim
        |> Regex.contains regex


isValid : Model -> Bool
isValid model =
    [ isRequired model.name
    , isRequired model.email
    , isValidEmail model.email
    , isRequired model.phone
    , isValidPhone model.phone
    ]
        |> List.all identity



---- VIEW ----

viewSending : Html msg
viewSending =
    div [ class "sending" ] [ text "Sending Order ..." ]


viewError : Maybe Error -> Html msg
viewError error =
    case error of
        Just errorMessage ->
            div [ class "error" ] [ text errorMessage ]
        Nothing ->
            text ""


viewSection : String -> List (Html msg) -> Html msg
viewSection heading children =
    section [ class "salad-section" ]
        (h2 [] [text heading ] :: children)


{- #! I'm not a fan of lines `225`->`263`. I'm sure there's a better way -}
viewRadioOption : String -> value -> (value -> msg) -> String -> value -> Html msg
viewRadioOption radioName selectedValue tagger optionLabel value =
    label [ class "select-option" ]
        [ input
            [ type_ "radio"
            , name radioName
            , checked (value == selectedValue) -- #! These have switched places
            , onClick (tagger value)
            ]
            []
        , text optionLabel
        ]


viewSelectBase : Base -> Html Msg
viewSelectBase currentBase =
    let
        viewBaseOption =
            viewRadioOption "base" currentBase (SaladMsg << SetBase)
        in
        div []
            [ viewBaseOption "Lettuce" Lettuce
            , viewBaseOption "Spinach" Spinach
            , viewBaseOption "Spring Mix" SpringMix
            ]

viewSelectDressing : Dressing -> Html Msg
viewSelectDressing currentDressing =
    let
        viewDressingOption =
            viewRadioOption "dressing" currentDressing (SaladMsg << SetDressing)
    in
    div []
        [ viewDressingOption "None" NoDressing
        , viewDressingOption "Italian" Italian
        , viewDressingOption "Rasperry Vinaigrette" RaspberryVinaigrette
        , viewDressingOption "Oil and Vinegar" OilVinegar
        ]


{- #! I feel like you should be able to `List.map` this function rather than having
2 different functions:  `List.map toppings topping` where `toppings` has a
`type alias Topping = (Set String)` (sets must be comparable, not union types) -}
viewToppingOption : Topping -> Html Msg
viewToppingOption toppingLabel topping toppings =
    label [ class "select-option" ]
            [ input
                [ type_ "checkbox"
                , checked (Set.member (toppingToString topping) toppings)
                , onCheck (SaladMsg << ToggleTopping topping)
                ]
                []
            , text toppingLabel -- This could use the `toppingToString` function
            ]


viewSelectToppings : Set String -> Html Msg
viewSelectToppings toppings =
    div []
        [ viewToppingOption "Tomatoes" Tomatoes toppings
        , viewToppingOption "Cucumbers" Cucumbers toppings
        , viewToppingOption "Onions" Onions toppings
        ]


viewTextInput : String -> String -> (String -> msg) -> Html ContactMsg
viewTextInput inputLabel inputValue tagger =
    div [ class "text-input" ]
        [ label []
            [ div [] [ text (inputLabel ++ ":") ]
            , input
                [ type_ "text"
                , value inputValue
                , onInput tagger
                ]
                []
            ]
        ]

{- Here we use `ContactMsg` instead of our `Msg` -}
viewContact : Contact c -> Html ContactMsg
viewContact contact =
    div []
        -- You could've written it like `(ContactMsg << SetName)`
        [ viewTextInput "Name" model.name SetName
        , viewTextInput "Email" model.email SetEmail
        , viewTextInput "Phone" model.phone SetPhone
        ]


viewBuild : Maybe Error -> Model -> Html Msg
viewBuild error model =
    div []
        [ viewError error
        , viewSection "1. Select Base"
            [ viewSelectBase model.salad.base ]
        , viewSection "2. Select Toppings"
            [ viewSelectToppings model.salad.toppings ]
        , viewSection "3. Select Dressing"
            [ viewSelectDressing model.salad.dressing ]
        , viewSection "4. Enter Contact Info"
            -- But we use `Html.map` to create the correct `Msg`!
            -- Applies `ContactMsg` to the message values of Html
            [ Html.map ContactMsg (viewContact model)
            , button
                [ class "send-button"
                , disabled (not (isValid model))
                , onClick Send
                ]
                [ text "Send Order" ]
            ]
        ]


viewConfirmation : Model -> Html msg
viewConfirmation model =
    div [ class "confirmation" ]
        [ h2 [] [ text "Woo hoo!" ]
        , p [] [ text "Thanks for your order!" ]
        , table []
            [ tr []
                [ th [] [ text "Base:" ]
                , td [] [ text (baseToString model.salad.base) ]
                ]
            , tr []
                [ th [] [ text "Toppings:" ]
                , td []
                    [ ul []
                        (model.salad.toppings
                            |> Set.toList
                            |> List.map (\topping -> li [] [ text topping ])
                        )
                    ]
                ]
            , tr []
                [ th [] [ text "Dressing:" ]
                , td [] [ text (dressingToString model.salad.dressing) ]
                ]
            , tr []
                [ th [] [ text "Name:" ]
                , td [] [ text model.name ]
                ]
            , tr []
                [ th [] [ text "Email:" ]
                , td [] [ text model.email ]
                ]
            , tr []
                [ th [] [ text "Phone:" ]
                , td [] [ text model.phone ]
                ]
            ]
        ]


viewStep : Model -> Html Msg
viewStep model =
    case model.step of
        Building error ->
            viewBuild error model

        Sending ->
            viewSending

        Confirmation ->
            viewConfirmation model


view : Model -> Html Msg
view model =
    div []
        [ h1 [ class "header" ]
            [ text "Saladise - Build a Salad" ]
        , div [ class "content" ]
            [ viewStep model ]
        ]



---- UPDATE ----


type SaladMsg
    = SetBase Base
    | ToggleTopping Topping Bool
    | SetDressing Dressing


type ContactMsg
    = SetName String
    | SetEmail String
    | SetPhone String


type Msg
    = SaladMsg SaladMsg -- Constructor + SaladType
    | ContactMsg ContactMsg -- Extensible record
    | Send
    | SubmissionResult (Result Http.Error String)


sendUrl : String
sendUrl =
    "https://programming-elm.com/salad/send"


encodeOrder : Model -> Value
encodeOrder model =
    object
        [ ( "base", string (baseToString model.salad.base) )
        , ( "toppings", list string (Set.toList model.salad.toppings) )
        , ( "dressing", string (dressingToString model.salad.dressing) )
        , ( "name", string model.name )
        , ( "email", string model.email )
        , ( "phone", string model.phone )
        ]


send : Model -> Cmd Msg
send model =
    Http.post
        { url = sendUrl
        , body = Http.jsonBody (encodeOrder model)
        , expect = Http.expectString SubmissionResult
        }


updateSalad : SaladMsg -> Salad -> Salad
updateSalad msg salad =
    case msg of
        SetBase base ->
            { salad | base = base }

        ToggleTopping topping add ->
            let
                updater =
                    if add then
                        Set.insert
                    else
                        Set.remove
            in
            { salad | toppings = updater (toppingToString topping) salad.toppings }

        SetDressing dressing ->
            { salad | dressing = dressing }


updateContact : ContactMsg -> Contact c -> Contact c
updateContact msg contact =
    case msg of
        SetName name ->
            { contact | name = name }

        SetEmail email ->
            { contact | email = email }

        SetPhone phone ->
            { contact | phone = phone }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        {- Using nested record (not recommended) -}
        SaladMsg saladMsg ->
            ( { model | salad = updateSalad saladMsg model.salad }
            , Cmd.none
            )

        {- Using extensible record -}
        ContactMsg contactMsg ->
            ( updateContact contactMsg model
            , Cmd.none
            )

        Send ->
            let
                newModel =
                    { model | step = Sending }
            in
            ( newModel, send newModel )

        SubmissionResult (Ok _) ->
            ( { model | step = Confirmation }
            , Cmd.none
            )

        SubmissionResult (Err _) ->
            let
                errorMessage =
                    "There was a problem sending your order. Please try again."
            in
            ( { model | step = Building (Just errorMessage) }
            , Cmd.none
            )



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
