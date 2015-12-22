module Models.Request where


import Models.Helper exposing
  ( MiniHelper, decodeMiniHelper, emptyMiniHelper
  )
import Models.Shared exposing
  (Location, decodeLocation, emptyLocation)
import Json.Decode exposing
  ( Decoder, object8, string, oneOf, succeed, (:=)
  , float, maybe
  )
import Json.Decode.Extra exposing
  ( apply, (|:))

type alias Request =
  { id : String
  , title : String
  , background : String
  , description : String
  , location : Location
  , owner : MiniHelper
  , reward : Float
  , status : String
  , employed : Maybe MiniHelper
  }


type Status
  = Pending
  | Open
  | Connected
  | Completed
  | Closed


statusToString : Status -> String
statusToString status =
  case status of
    Pending -> "pending"
    Open -> "Open"
    Connected -> "Connected"
    Completed -> "Completed"
    Closed -> "Closed"


decodeRequest : Decoder Request
decodeRequest =
  oneOf
    [ succeed Request
      |: ("_id" := string)
      |: ("title" := string)
      |: (oneOf ["background" := string, succeed "N/A"])
      |: ("description" := string)
      |: (oneOf ["location" := decodeLocation, succeed emptyLocation])
      |: (oneOf ["owner" := decodeMiniHelper, succeed emptyMiniHelper])
      |: (oneOf ["reward" := float, succeed 0 ])
      |: (oneOf ["status" := string, succeed "N/A" ])
      |: (maybe ("employed" := decodeMiniHelper))
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
  , employed = Nothing
  }
