module Components.Selector where


import Html exposing (..)
import Html.Attributes exposing (value, class)
import Html.Events exposing (on, targetValue)
import Signal exposing (Address, message)

selector : Address a -> (String -> a) -> List String -> Html
selector address actionCreator values =
  div []
    [ select
      [ class "Selector"
      , on
        "change"
        targetValue
        (\val -> message address (actionCreator val))
      ]
      (List.map renderOption values) ]


renderOption : String -> Html
renderOption val =
  option
    [ value val
    , class "SelectorOption"
    ]
    [ text val ]
