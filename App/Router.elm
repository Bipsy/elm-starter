-- App Router

module Router where


import Debug exposing (log)
import Actions exposing (Action)
import Model exposing (Model)
import Html exposing (..)
import Routes
import Views.Helpers as Helpers
import Views.Helper as Helper
import Signal exposing (Address, forwardTo)
import Views.Requests as Requests


view : Address Action -> Model -> Html
view address model =
    case model.currentRoute of

        Routes.NotFound ->
            div [] [ text "Not Found" ]

        Routes.Home ->
            div [] [ text "Home" ]

        Routes.Name name ->
            div [] [ text name ]

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
