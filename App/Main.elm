module Main where

import StartApp
import Signal exposing (Address)
import Task
import Model exposing (init, update, Model)
import Actions exposing (Action)
import Router exposing (view)
import Routes
import Effects exposing (Never)
import History

pathChanges : Signal Action
pathChanges =
    Signal.map Actions.UpdatePath History.hash

-- # Main

app =
    StartApp.start
        { init = init initialPath
        , view = view
        , update = update
        , inputs = [ pathChanges ]
        }

main = app.html

port tasks : Signal (Task.Task Never ())
port tasks =
    app.tasks

port initialPath : String
port token : String

port saveToken : Signal String
port saveToken =
  app.model
    |> Signal.map (.token)
    |> Signal.dropRepeats
