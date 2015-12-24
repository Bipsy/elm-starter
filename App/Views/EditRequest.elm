module Views.EditRequest where


import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (targetValue, on)
import Signal exposing (Address, message)
import Models.Request exposing (Request, emptyRequest)
import Components.InputPair as InputPair
import Components.Selector as Selector
import Components.PageButton as PageButton


-- Model

type alias Model =
  { request : Request }


empty : Model
empty =
  { request = emptyRequest }


-- Update

type Action
  = NoOp
  | UpdateTitle String
  | UpdateReward String
  | UpdateHelper String
  | SelectStatus String
  | SubmitStatus


-- View

view : Address Action -> Model -> Html
view address model =
  div
    []
    [ InputPair.pair address UpdateTitle "Title"
    , InputPair.pair address UpdateReward "Reward"
    , statusComponent address
    ]


statusComponent : Address Action -> Html
statusComponent address =
  let
    label =
      div
        []
        [ text "Status" ]
    input' =
      input
        [ on
            "input"
            targetValue
            (\str -> message address (UpdateHelper str))
        ]
        []
    selector =
      Selector.selector
        address
        SelectStatus
        [ "--", "PENDING", "OPEN", "CONNECTED", "COMPLETED", "CLOSED" ]
    (PageButton.PageButton button') =
      PageButton.button
        address
        SubmitStatus
        "Submit"
  in
    div
      [ class "StatusComponent" ]
      [ label
      , selector
      , button'
      ]
