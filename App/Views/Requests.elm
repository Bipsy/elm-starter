module Views.Requests where


import Models.Request as Request exposing (Request)
import Html exposing (..)
import Signal exposing (Address)
import Effects exposing (Effects)
import Task
import Http
import Json.Decode as Json exposing ((:=))
import Models.Request exposing (Request, decodeRequest)
import Html.Attributes exposing (class, href)
import String exposing (toUpper)
import Components.PageButton as PB
import Components.PageButtons as PageButtons


-- Model

type alias Model =
  { requests : Requests
  , totalRequests : Int
  }

type alias Requests =
  List Request


requestUrl = "https://staging.ancestorcloud.com/#/request/"

offset = 0


limit = 48


createUrl : String
createUrl =
  Http.url
    "https://api-staging.ancestorcloud.com/jobs"
    [ ("offset", toString offset)
    , ("limit", toString limit)
    ]


empty : Model
empty =
  { requests = []
  , totalRequests = 0
  }


init : (Model, Effects Action)
init =
  (empty, initView createUrl)


decodeHelpers : Json.Decoder (Int, Requests)
decodeHelpers =
    Json.object2 (,)
        ("entityCount" := Json.int)
        ("entities" := Json.list decodeRequest)


-- Update

initView : String -> Effects Action
initView url =
  Http.get decodeHelpers url
    |> Task.toMaybe
    |> Task.map Fetch
    |> Effects.task

type Action
  = Fetch (Maybe (Int, Requests))
  | NoOp


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Fetch maybeRequests ->
      let
        (totalRequests, newRequests) =
          Maybe.withDefault
            ( model.totalRequests, model.requests )
            maybeRequests

        newModel =
          { model
            | requests = newRequests
            , totalRequests = totalRequests
          }
      in
        ( newModel, Effects.none )

    NoOp -> (model, Effects.none)


-- View

type Element
  = Text String
  | Markdown Html

view : Address Action -> Model -> Html
view address model =
  let
    prev = PB.button address NoOp "Prev"
    next = PB.button address NoOp "Next"
  in
    div []
      <|
        [ PageButtons.pair prev next ]
        ++
        (List.map renderRequest model.requests)

fullName : String -> String -> String
fullName first last =
  first ++ " " ++ last


renderRequest : Request -> Html
renderRequest { id, title, location, owner, reward, status } =
  div
    [ class "RequestCard" ]
    [ itemBlock
      "ID"
      (Markdown (a [ href (requestUrl ++ id) ] [ text id ]))
    , itemBlock
      "Title"
      (Text title)
    , itemBlock
      "Location"
      (Text location.name)
    , itemBlock
      "Reward"
      (Text (toString reward))
    , itemBlock
      "Status"
      (Text <| toUpper status)
    , itemBlock
      "Owner"
      (Markdown (a
        [ href ("#/helper/" ++ owner.id)]
        [ text <| fullName owner.firstName owner.lastName ]))
    ]


itemBlock : String -> Element -> Html
itemBlock header base =
  let
    bottom = case base of
      Text string ->
        span [] [ text string ]

      Markdown html ->
        html
  in
    div
      [ class "RequestItemBlock" ]
      [ span [ class "RequestItemBlockHeader" ] [ text header ]
      , bottom
      ]
