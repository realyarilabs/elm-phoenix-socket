module Phoenix.ConnectionHelper exposing (..)




type alias Messagex =
     { event : String
     , topic : String
     , ref : Maybe Int
     }

cfg : Bool
cfg =
   True


{-| -}
reset_timer : { c | autoReconnectAfterSec : a, autoReconnectTimer : b } -> { c | autoReconnectAfterSec : a, autoReconnectTimer : a }
reset_timer socket =
    ({ socket | autoReconnectTimer = (socket.autoReconnectAfterSec) })
