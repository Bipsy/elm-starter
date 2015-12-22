module Views.Helpers where

import Debug exposing (log)
import Models.Helper exposing (Helper, decodeHelper)
import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, on, targetValue)
import Http
import Json.Decode as Json exposing ((:=))
import Task
import String
import Components.PageButtons as PageButtons
import Components.PageButton as PB
import Config exposing (apiUrl)


helperUrl =
  apiUrl ++ "users/"


defaultOffset : Int
defaultOffset =
  0


defaultLimit : Int
defaultLimit =
  48


-- MODEL


type alias Model =
  { helpers : List Helper
  , offset : Int
  , limit : Int
  , viewedHelpers : List Helper
  , totalHelpers : Int
  }


createUrl : String -> Int -> Int -> String
createUrl base offset limit =
  Http.url
    base
    [ ( "offset", toString offset )
    , ( "limit", toString limit )
    ]


init : ( Model, Effects Action )
init =
  let
    url = createUrl helperUrl defaultOffset defaultLimit

    initialModel = empty
  in
    ( initialModel, getHelpers url )


getHelpers : String -> Effects Action
getHelpers url =
  Http.get helpersDecode url
    |> Task.toMaybe
    |> Task.map Fetch
    |> Effects.task


helpersDecode : Json.Decoder (Int, List Helper)
helpersDecode =
    Json.object2 (,)
        ("entityCount" := Json.int)
        ("entities" := Json.list decodeHelper)


empty : Model
empty =
    Model [] defaultOffset defaultLimit [] 0


-- UPDATE


search : String -> Helper -> Bool
search query helper =
  let
    predicate = String.contains <| String.toLower query
  in
    predicate (String.toLower helper.firstName)
      || predicate (String.toLower helper.lastName)
      || predicate (String.toLower helper.background)
      || predicate (String.toLower helper.id)


type Action
  = Fetch (Maybe (Int, List Helper))
  | Next
  | Prev
  | Search String


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Fetch maybeHelpers ->
      let
        (totalHelpers, newHelpers) =
          Maybe.withDefault
            ( model.totalHelpers, model.helpers )
            maybeHelpers

        newModel =
          { model
            | helpers = newHelpers
            , viewedHelpers = newHelpers
            , totalHelpers = totalHelpers
          }
      in
        ( newModel, Effects.none )

    Next ->
      if model.offset + model.limit < model.totalHelpers then
        let
          newModel =
            { model | offset = model.offset + model.limit }

          newUrl = createUrl helperUrl newModel.offset model.limit

          effects = getHelpers newUrl
        in
          ( newModel, effects )
      else
        ( model, Effects.none )

    Prev ->
      if model.offset - model.limit >= 0 then
        let
          newModel =
            { model | offset = model.offset - model.limit }

          newUrl = createUrl helperUrl newModel.offset model.limit

          effects = getHelpers newUrl
        in
          ( newModel, effects )
      else
        ( model, Effects.none )

    Search query ->
      let
        newHelpers = List.filter (search query) model.helpers

        newModel = { model | viewedHelpers = newHelpers }
      in
        ( newModel, Effects.none )



-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  let
    header = h1 [] [ text "Helpers" ]

    buttons =
      PageButtons.pair
        (PB.button address Prev "Prev")
        (PB.button address Next "Next")

    helpers =
      div [ helpersStyle ]
        <| List.map helperBlock model.viewedHelpers
  in
    div
        [ mainStyle ]
        [ header
        , searchPair address
        , buttons
        , helpers
        , buttons
        ]


searchPair : Signal.Address Action -> Html
searchPair address =
    let
        searchLabel =
            div
                [ class "Label" ]
                [ h3 [] [ text "Search" ] ]

        searchInput =
            div
                []
                [ input
                    [ on
                      "input"
                      targetValue
                      (\str -> Signal.message address (Search str))
                    , class "Input"
                    ]
                    []
                ]

    in
        div
            [ class "SearchBlock" ]
            [ searchLabel, searchInput ]


itemBlock : (String, String) -> Html
itemBlock (key, value) =

    let blockStyle = style
            [ ("display", "flex")
            , ("flex-direction", "column")
            , ("margin", "5px")
            ]

        keyStyle = style
            [ ("white-space", "nowrap")
            , ("margin", "5px 0px")
            , ("font-weight", "bold")
            ]

        block = div [ blockStyle ]
            [ div [ keyStyle ] [ text key ]
            , div [] [ text value ]
            ]

    in  block

linkBlock : (String, String) -> Html
linkBlock (key, value) =

    let blockStyle = style
            [ ("display", "flex")
            , ("flex-direction", "column")
            , ("margin", "5px")
            ]

        keyStyle = style
            [ ("white-space", "nowrap")
            , ("margin", "5px 0px")
            , ("font-weight", "bold")
            ]

        block = div [ blockStyle ]
            [ div [ keyStyle ] [ text key ]
            , div [] [ a [ href <| "http://localhost:8000/#/helper/" ++ value ] [ text value ] ]
            ]

    in  block

helperBlock : Helper -> Html
helperBlock helper =
    let blockStyle = style
            [ ("display", "flex")
            , ("flex-direction", "row")
            , ("margin", "10px 0px")
            ]

    in
        div [ blockStyle, class "card blue-grey lighten-5" ]
            [ linkBlock ("ID", helper.id)
            , itemBlock ("First Name", helper.firstName)
            , itemBlock ("Last Name", helper.lastName)
            , itemBlock ("Background", helper.background)
            ]


searchStyle : Attribute
searchStyle =
  style
    [ ( "display", "flex" )
    , ( "flex-direction", "row" )
    , ( "align-items", "center" )
    ]


mainStyle : Attribute
mainStyle =
  style
    [ ( "background", "#f9fbe7" )
    , ( "border-style", "solid" )
    , ( "border-width", "5px" )
    , ( "border-color", "black" )
    ]


helpersStyle : Attribute
helpersStyle =
  style
    [ ( "display", "flex" )
    , ( "flex-direction", "column" )
    ]
