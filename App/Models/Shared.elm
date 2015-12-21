module Models.Shared where


import Json.Decode exposing
  ( Decoder, (:=), string, list, float, succeed, oneOf
  , object2
  )

type alias Location =
  { name : String
  , coordinates : List Float
  }


decodeLocation : Decoder Location
decodeLocation =
  object2 Location
      (oneOf ["name" := string, succeed "N/A"])
      (oneOf ["coordinates" := list float, succeed []])


emptyLocation : Location
emptyLocation =
  { name = "N/A"
  , coordinates = []
  }
