-- Helper View

module Views.Helper where

import Debug exposing (log)
import Effects exposing (Effects)
import Task
import Models.Helper as Helper exposing
    (emptyHelper, Helper, decodeHelper)
import Http
import Html exposing (..)
import Html.Attributes exposing (src, class, href, target)
import Signal exposing (Address)
import Components.TitledCard as Card


empty : Model
empty =
    { id = ""
    , helper  = emptyHelper
    }


init : String -> (Model, Effects Action)
init id =
    let
        model =
            { id = log "ID" id
            , helper = emptyHelper
            }
        effects =
            fetchHelper id
    in
        (model, effects)


type alias Model =
    { id : String
    , helper : Helper
    }


fetchHelper : String -> Effects Action
fetchHelper id =
    Http.get decodeHelper (urlHelper id)
        |> Task.toMaybe
        |> Effects.task
        |> Effects.map Fetch


urlHelper : String -> String
urlHelper id =
    "https://api-staging.ancestorcloud.com/users/" ++ id


type Action
    = Fetch (Maybe Helper)


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        Fetch maybeHelper ->
            let
                helper = Maybe.withDefault emptyHelper maybeHelper
            in
                ( { model | helper = helper }
                , Effects.none
                )


view : Address Action -> Model -> Html
view address { id, helper } =
    let
        { firstName
        , lastName
        , background
        , avatar
        , experience
        , location
        } = helper

        idHeader =
            Card.view
                "ID"
                (span [] [ text id ])
        name =
            Card.view
              "Name"
              (span [] [ text <| fullName firstName lastName ])
        bio =
            Card.view
                "Background"
                (span [] [ text background ])
        specialties =
            Card.view
                "Experience"
                (span [] [ text experience ])
        location' =
            Card.view
                "Location"
                (span [] [ text location.name ])
        link = divWrapper []
            <| a
                [ href <| linkBuilder id
                , target "_blank"
                ]
                [ text "Profile" ]

    in
        div [ class "UserCard" ]
            [ profilePicture avatar.normal
            , div []
                [ idHeader
                , name
                , bio
                , specialties
                , location'
                , link
                ]
            ]


linkBuilder : String -> String
linkBuilder id =
    "https://app.ancestorcloud.com/#/profile/" ++ id

profilePicture : String -> Html
profilePicture source =
    div [ class "card-image" ] [ img [ src source ] [] ]


divWrapper : List Attribute -> Html -> Html
divWrapper attributes element =
    div attributes [ element ]

fullName : String -> String -> String
fullName first last =
    first ++ " " ++ last
