module Models.Request where


import Models.Helper exposing
  ( MiniHelper, decodeMiniHelper, emptyMiniHelper
  )
import Models.Shared exposing
  (Location, decodeLocation, emptyLocation)
import Json.Decode exposing
  ( Decoder, object8, string, oneOf, succeed, (:=)
  , float
  )

type alias Request =
  { id : String
  , title : String
  , background : String
  , description : String
  , location : Location
  , owner : MiniHelper
  , reward : Float
  , status : String
  }


decodeRequest : Decoder Request
decodeRequest =
  oneOf
    [ object8 Request
      ("_id" := string)
      ("title" := string)
      (oneOf ["background" := string, succeed "N/A"])
      ("description" := string)
      (oneOf ["location" := decodeLocation, succeed emptyLocation])
      (oneOf ["owner" := decodeMiniHelper, succeed emptyMiniHelper])
      (oneOf ["reward" := float, succeed 0 ])
      (oneOf ["status" := string, succeed "N/A" ])
    , succeed emptyRequest
    ]


emptyRequest : Request
emptyRequest =
  { id = "N/A"
  , title = "N/A"
  , background = "N/A"
  , description = "N/A"
  , location = emptyLocation
  , owner = emptyMiniHelper
  , reward = 0
  , status = "N/A"
  }
