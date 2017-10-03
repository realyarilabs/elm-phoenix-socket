# elm-phoenix-socket

---

**NOTE: I no longer have time to maintain this project. If you would like to take ownership of this project, please email me and I will gladly add you as a contributor.**

If you're looking for an alternative project that uses Effects Managers, checkout the excellent [`elm-phoenix`](https://github.com/saschatimme/elm-phoenix) package. The API is almost identical with the key difference being that it manages it's own state internerally, so you don't need to keep a `Socket` instance in your model.

---

This library is a pure Elm interpretation of the Phoenix.Socket library
that comes bundled with the Phoenix web framework. It aims to abstract away
the more tedious bits of communicating with Phoenix, such as joining channels,
leaving channels, registering event handlers, and handling errors.

## Setup

Phoenix connections are stateful. The Socket module will manage all of this for you,
but you need to add some boilerplate to your project to wire everything up.

1. Import all three `Phoenix` modules

    ```elm
    import Phoenix.Socket
    import Phoenix.Channel
    import Phoenix.Push
    ```

2. Add a socket to your model

    ```elm
    type alias Model =
      { phxSocket : Phoenix.Socket.Socket Msg
      }
    ```

3. Initialize the socket. The default path for Phoenix in development is `"ws://localhost:4000/socket/websocket"`.

    ```elm
    init =
      { phxSocket = Phoenix.Socket.init "PATH_TO_SERVER"
      }
    ```

4. Add a PhoenixMsg tag to your Msg type

    ```elm
    type Msg
      = UpdateSomething
      | DoSomethingElse
      | PhoenixMsg (Phoenix.Socket.Msg Msg)

    ```

5. Add the following to your update function

    ```elm
    PhoenixMsg msg ->
      let
        ( phxSocket, phxCmd ) = Phoenix.Socket.update msg model.phxSocket
      in
        ( { model | phxSocket = phxSocket }
        , Cmd.map PhoenixMsg phxCmd
        )
    ```

6. Listen for messages

    ```elm
    subscriptions : Model -> Sub Msg
    subscriptions model =
      Phoenix.Socket.listen model.phxSocket PhoenixMsg
    ```

7. Auto reconnect configuration

    ```elm
    phxSocket =
        |> Phoenix.Socket.init server
        |> Phoenix.Socket.withAutoReconnection
        |> Phoenix.Socket.config_reconnection 2 300
        -- set config_reconnection {first 2 channels (ex Lobby, user) mandatory for reconnection state by order } {300 seconds}
        -- reconnect this 2 channels and the change only last one for example {current conversation channel }
        -- the module check in intervals of 5 seconds until comming to 300 seconds if dectect activity from user this time is cleared and count again
    ```

8. Force reconnection after device sleep

    ```js
      // interop
      var myWorker = new Worker("/interop/DetectWakeup.js");

      myWorker.onmessage = function (ev) {
        if (ev && ev.data === 'wakeup') {
           // send signal to wake up
          app.ports.reJoinAllpreviousChannels.send("wakeup");
        }
      }

      // file DectectWakeup.js

        var lastTime = (new Date()).getTime();
        var checkInterval = 5000;

        setInterval(function () {
          var currentTime = (new Date()).getTime();

          if (currentTime > (lastTime + checkInterval * 2)) {  // ignore small delays errors
              postMessage("wakeup");
          }
          lastTime = currentTime;
        }, checkInterval);
    ```

    ```elm
    {-
      ports to wakeup connection on phoenix
    -}
    port reJoinAllpreviousChannels : (String -> msg) -> Sub msg

      ReJoinPrev str ->
            if String.contains str "wakeup" then
                let
                    ( phxSocket_, phxCmd ) =
                        Phoenix.Socket.reJoinAllpreviousChannels model.phxSocket
                in
                    ( { model | phxSocket = phxSocket_ }, Cmd.map PhoenixMsg phxCmd )
            else
                ( model, Cmd.none )


    -- subscriptions
    -- add
          PhxHelpers.reJoinAllpreviousChannels ReJoinPrev
    ```


Take a look at examples/Chat.elm if you want to see an example.

## Contributing

Pull requests and issues are greatly appreciated! If you think there's a better way
to implement this library, I'd love to hear your feedback. I basically tried to model
this library after the official javascript one, but that may not be the best approach.

## Change log

### v2.0.2

- Combine Heatbeat with auto reconnection for life time on client  
- Force previus connection sequence by wakeup script JS via ports using a  difer from date time and interval old date time.
- fix erros for buffering heatbeat pushes, and remove from buffer all "ref" on payloads sended to server and received.

## To do:

- Change script wakeup via port to Elm
- Change timeout code for auto reconnect to Task
- If a channel errors out, automatically reconnect with an exponential backoff strategy
- Write tests
