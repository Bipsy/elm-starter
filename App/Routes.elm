-- Routes

module Routes where


import RouteParser exposing (..)
import Debug exposing (log)


type Route
    = NotFound
    | Home
    | Name String
    | Helpers
    | Helper String
    | Requests


routes : Parsers Route
routes =
    [ static Home "#/home"
    , dyn1 Helper "#/helper/" string ""
    , dyn1 Name "#/name/" string ""
    , static Helpers "#/helpers"
    , static Requests "#/requests"
    ]

getRoute : String -> Route
getRoute url =
    let
        maybeRoute = match routes url
    in
        case maybeRoute of
            Just r -> log "Route" r
            Nothing -> NotFound
