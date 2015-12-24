module Views.Requests where


import Models.Request as Request exposing (Request, decodeRequest)
import Models.Helper as Helper exposing (MiniHelper)
import Html exposing (..)
import Signal exposing (Address)
import Effects exposing (Effects)
import Task
import Http
import Json.Decode as Json exposing ((:=))
import Html.Attributes exposing (class, href)
import String exposing (toUpper, toLower)
import Components.PageButton as PB
import Components.PageButtons as PageButtons
import Components.Selector as Selector
import Debug exposing (log)
import Config exposing (apiUrl, appUrl)


-- Model

type alias Model =
  { requests : Requests
  , totalRequests : Int
  , offset : Int
  , selectedStatus : Request.Status
  }

type alias Requests =
  List Request


limit = 48


requestUrl = apiUrl ++ "jobs/"


appRequestUrl = appUrl ++ "#/request/"


createUrl : Int -> String -> String
createUrl offset status =
  Http.url
    requestUrl
    [ ("offset", toString offset)
    , ("limit", toString limit)
    , ("status", status)
    ]


empty : Model
empty =
  { requests = []
  , totalRequests = 0
  , offset = 0
  , selectedStatus = Request.Open
  }


init : (Model, Effects Action)
init =
  (empty, initView (createUrl 0 (toLower "open")))


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
  | Prev
  | Next
  | UpdateStatus Request.Status
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

    Next ->
      if model.offset + limit < model.totalRequests then
        let
          offset = model.offset + limit
          status = Request.statusToString model.selectedStatus

          (model', effects') =
            ( { model | offset = offset + limit }
            , initView (createUrl offset (toLower status))
            )
        in
          ( model', effects' )
      else
        ( model, Effects.none )

    Prev ->
      if model.offset - limit >= 0 then
        let
          offset = model.offset - limit
          status = Request.statusToString model.selectedStatus

          (model', effects') =
            ( { model | offset = offset }
            , initView (createUrl offset (toLower status)))
        in
          ( model', effects' )
      else
        ( model, Effects.none )

    NoOp ->
      (model, Effects.none)

    UpdateStatus status ->
      let
        stringStatus = toLower <| Request.statusToString status
      in
        ( { model | selectedStatus = status }
        , initView (createUrl model.offset stringStatus)
        )


-- View

type Element
  = Text String
  | Markdown Html

view : Address Action -> Model -> Html
view address model =
  let
    buttons =
      PageButtons.pair
        (PB.button address Prev "Prev")
        (PB.button address Next "Next")
    listings =
      List.map renderRequest model.requests
    selector =
      Selector.selector
        address
        selectActionCreator
        [ "--", "PENDING", "OPEN", "CONNECTED", "COMPLETED", "CLOSED" ]

  in
    div []
      [ selector
      , buttons
      , div [] listings
      ]


selectActionCreator : String -> Action
selectActionCreator string =
  if string == "OPEN" then
    UpdateStatus Request.Open
  else if string == "PENDING" then
    UpdateStatus Request.Pending
  else if string == "CONNECTED" then
    UpdateStatus Request.Connected
  else if string == "COMPLETED" then
    UpdateStatus Request.Completed
  else if string == "CLOSED" then
    UpdateStatus Request.Closed
  else
    let a = log "Status" string
    in NoOp


fullName : String -> String -> String
fullName first last =
  first ++ " " ++ last


renderRequest : Request -> Html
renderRequest { id, title, location, owner, reward, status, employed } =
  div
    [ class "RequestCard" ]
    [ itemBlock
      "ID"
      (Markdown (a [ href (appRequestUrl ++ id) ] [ text id ]))
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
    , itemBlock
      "Helper"
      (helperBlock employed)
    , a
        [ href ("#/request/" ++ id ++ "/edit") ]
        [ text "Edit" ]
    ]


helperBlock : Maybe MiniHelper -> Element
helperBlock maybeHelper =
  case maybeHelper of
    Just { id, firstName, lastName } ->
      Markdown
        <|
          a
            [ href ("#/helper/" ++ id) ]
            [ text <| fullName firstName lastName ]

    Nothing ->
      Text "N/A"


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
