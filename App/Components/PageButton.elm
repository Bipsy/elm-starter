module Components.PageButton where


import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Signal exposing (Address)


type PageButton
  = PageButton Html


button : Address a -> a -> String -> PageButton
button address action inner =
  PageButton
    <|
    div
      [ class "PageButton"
      , onClick address action
      ]
      [ text inner ]
