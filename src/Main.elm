module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, div, p, text)



-- Model


type alias Model =
    { users : List String
    , loading : Bool
    }


type Msg
    = FetchUsers
    | Nothing



-- View


view : Model -> Html Msg
view model =
    div []
        [ p
            []
            [ text "Hello Elm" ]
        ]



-- Initialization


init : Model
init =
    { users = [ "Andre" ]
    , loading = False
    }



-- Update


update : Msg -> Model -> Model
update msg model =
    case msg of
        FetchUsers ->
            model

        Nothing ->
            model


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }



-- Browser.application
--   { init = init
--   , view = view
--   , update = update
--   , subscriptions = subscriptions
--   , onUrlRequest = onUrlRequest
--   , onUrlChange = onUrlChange
--   }
