module Components.TitledCard where


import Html exposing (..)
import Html.Attributes exposing (class)


view : String -> Html -> Html
view title body =
    let
        header = div [] [ text title ]
        body = div [ class "TitleCardBody" ] [ body ]
    in
        div
            [ class "TitledCard" ]
            [ header, body ]
