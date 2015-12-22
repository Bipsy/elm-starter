module Components.Nav where


import Html exposing (..)
import Html.Attributes exposing (href, class)

nav : Html
nav =
  div
    [ class "Nav" ]
    [ a [ href "#/helpers", class "NavLink" ] [ text "Helpers" ]
    , a [ href "#/requests", class "NavLink" ] [ text "Requests" ]
    ]
