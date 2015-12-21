module Components.PageButtons where


import Html exposing (..)
import Html.Attributes exposing (class)
import Components.PageButton as PB


pair : PB.PageButton -> PB.PageButton -> Html
pair (PB.PageButton first) (PB.PageButton second) =
  div
    [ class "PageButtons" ]
    [ first, second ]
