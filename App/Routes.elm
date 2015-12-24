-- Routes

module Routes where


import RouteParser exposing (..)
import Debug exposing (log)


type Route
    = NotFound
    | Helpers
    | Helper String
    | Requests
    | EditRequest String


routes : Parsers Route
routes =
    [ dyn1 Helper "#/helper/" string ""
    , static Helpers "#/helpers"
    , static Requests "#/requests"
    , dyn1 EditRequest "#/request/" string "/edit"
    ]

getRoute : String -> Route
getRoute url =
    let
        maybeRoute = match routes url
    in
        case maybeRoute of
            Just r -> log "Route" r
            Nothing -> NotFound
