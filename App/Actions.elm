-- App Actions

module Actions where


import Views.Helpers as H
import Views.Helper as Helper
import Views.Requests as Requests

type Action
    = UpdatePath String
    | Helpers H.Action
    | Helper Helper.Action
    | Requests Requests.Action
