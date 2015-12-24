-- App Model

module Model where

import Debug exposing (log)
import Routes exposing (Route)
import Effects exposing (Effects)
import Actions exposing (Action)
import Views.Helpers as H
import Views.Helper as Helper
import Views.Requests as Requests
import Views.EditRequest as EditRequest

type alias Model =
    { currentRoute : Route
    , helpersModel : H.Model
    , activeHelper : Helper.Model
    , activeRequest : EditRequest.Model
    , requestsModel : Requests.Model
    , token : String
    }


init : String -> (Model, Effects Action)
init url =
    let
        (model, effects) =
              viewInit
              { empty | currentRoute = Routes.getRoute url }

    in
        ( model
        , effects
        )


viewInit : Model -> (Model, Effects Action)
viewInit model =
    case model.currentRoute of

      Routes.NotFound ->
          ( model
          , Effects.none
          )

      Routes.Helpers ->
          let
              (model', effects') = H.init
              updatedModel = { model | helpersModel = model' }

          in
              ( updatedModel
              , Effects.map Actions.Helpers effects'
              )

      Routes.Helper id ->
          let
              (model', effects') = Helper.init id
              updatedModel = { model | activeHelper = model' }

          in
              ( updatedModel
              , Effects.map Actions.Helper effects'
              )

      Routes.Requests ->
        let
          (model', effects') = Requests.init
          updatedModel = { model | requestsModel = model' }

        in
          ( updatedModel
          , Effects.map Actions.Requests effects'
          )

      Routes.EditRequest id ->
        (model, Effects.none)


empty : Model
empty =
    { currentRoute = Routes.NotFound
    , helpersModel = H.empty
    , activeHelper = Helper.empty
    , requestsModel = Requests.empty
    , activeRequest = EditRequest.empty
    , token = ""
    }


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        Actions.UpdatePath url ->
            let
                model' = { model | currentRoute = Routes.getRoute url }
                ( model'', effects') = viewInit model'

            in
                ( model''
                , effects'
                )

        Actions.Helpers act ->
            let
                (helpersModel, helpersEffects) =
                    H.update act model.helpersModel
            in
                ( { model | helpersModel = helpersModel }
                , Effects.map Actions.Helpers helpersEffects
                )

        Actions.Helper act ->
            let
                (helperModel, helperEffects) =
                    Helper.update act model.activeHelper
            in
                ( { model | activeHelper = helperModel }
                , Effects.map Actions.Helper helperEffects
                )

        Actions.Requests act ->
          let
            (requestsModel, requestsEffects) =
              Requests.update act model.requestsModel
          in
            ( { model | requestsModel = requestsModel }
            , Effects.map Actions.Requests requestsEffects
            )

        Actions.EditRequest act ->
          (model, Effects.none)
