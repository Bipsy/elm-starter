-- App Router

module Router where


import Debug exposing (log)
import Actions exposing (Action)
import Model exposing (Model)
import Html exposing (..)
import Routes
import Views.Helpers as Helpers
import Views.Helper as Helper
import Views.EditRequest as EditRequest
import Signal exposing (Address, forwardTo)
import Views.Requests as Requests
import Components.Nav as Nav


view : Address Action -> Model -> Html
view address model =
  let
    header =
      Nav.nav
    body =
      route address model
    footer =
      div [] [ text "Footer" ]
  in
    div
      []
      [ header
      , body
      , footer
      ]


route : Address Action -> Model -> Html
route address model =
    case model.currentRoute of

        Routes.NotFound ->
            div [] [ text "Not Found" ]

        Routes.Helpers ->
            Helpers.view
              (forwardTo address Actions.Helpers)
              model.helpersModel

        Routes.Helper id ->
          Helper.view
            (forwardTo address Actions.Helper)
            (log "Helper" model.activeHelper)

        Routes.Requests ->
          Requests.view
            (forwardTo address Actions.Requests)
            model.requestsModel

        Routes.EditRequest id ->
          EditRequest.view
            (forwardTo address Actions.EditRequest)
            model.activeRequest
