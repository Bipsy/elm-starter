module Components.InputPair where


import Html exposing (..)
import Html.Events exposing (on, targetValue)
import Html.Attributes exposing (class)
import Signal exposing (Address, message)
import Debug exposing (log)


pair : Address a -> (String -> a) -> String -> Html
pair address actionCreator label =
  let
    label' = span [] [ text label ]
    input' =
      input
        [ on
            "input"
            targetValue
            (\str -> message address (actionCreator str))
        ]
        []
  in
    div
      [ class "InputPair" ]
      [ label', input' ]
