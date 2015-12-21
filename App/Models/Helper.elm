-- Module for working with Helpers

module Models.Helper where


import Json.Decode as Json exposing
    ( Decoder, (:=), string, object7, object2, oneOf, succeed
    , list, object3, float, object5
    )
import Models.Shared as SharedModels exposing
  (Location, decodeLocation, emptyLocation)


type alias MiniHelper =
  { id : String
  , firstName : String
  , lastName : String
  , background : String
  , avatar : Avatar
  }


type alias Helper =
    { id : String
    , firstName : String
    , lastName : String
    , background : String
    , experience : String
    , location : Location
    , avatar : Avatar
    }


type alias Avatar =
  { normal : String
  , thumb : String
  }


decodeMiniHelper : Decoder MiniHelper
decodeMiniHelper =
  object5 MiniHelper
    ("_id" := string)
    ("firstName" := string)
    ("lastName" := string)
    (oneOf ["bio" := string, succeed "N/A"])
    ("avatar" := decodeAvatar)

decodeAvatar : Decoder Avatar
decodeAvatar =
  object2 Avatar
      (oneOf ["normal" := string, succeed "N/A"])
      (oneOf ["thumb" := string, succeed "N/A"])

decodeHelper : Decoder Helper
decodeHelper =
  object7 Helper
      ("_id" := string)
      ("firstName" := string)
      ("lastName" := string)
      (oneOf ["bio" := string, succeed "N/A"])
      (oneOf ["specialties" := string, succeed "N/A"])
      (oneOf ["location" := decodeLocation, succeed emptyLocation])
      (oneOf ["avatar" := decodeAvatar, succeed emptyAvatar])




emptyAvatar : Avatar
emptyAvatar =
  { normal = "N/A"
  , thumb = "N/A"
  }


emptyHelper : Helper
emptyHelper =
    { id = "N/A"
    , firstName = "N/A"
    , lastName = "N/A"
    , background = "N/A"
    , experience = "N/A"
    , location = emptyLocation
    , avatar = emptyAvatar
    }


emptyMiniHelper : MiniHelper
emptyMiniHelper =
    { id = "N/A"
    , firstName = "N/A"
    , lastName = "N/A"
    , background = "N/A"
    , avatar = emptyAvatar
    }
