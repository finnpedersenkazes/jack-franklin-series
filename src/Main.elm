module Main exposing (..)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation exposing (Key)
import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Url exposing (Url)



---- MODEL ----


type alias Flags =
    {}


type Token
    = Token String


type alias Model =
    { token : Maybe Token
    , navigationKey : Key
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        _ =
            Debug.log "url" url

        parts : List String
        parts =
            Debug.log "parts" (String.split "/" url.path)

        firstPart : Maybe String
        firstPart =
            List.reverse parts |> List.head

        token : Maybe Token
        token =
            case firstPart of
                Nothing ->
                    Nothing

                Just tokenString ->
                    Just (Token tokenString)

        tokenAlternative1 : Maybe Token
        tokenAlternative1 =
            Maybe.map Token firstPart

        tokenAlternative2 : Maybe Token
        tokenAlternative2 =
            url.path
                |> String.split "/"
                |> List.reverse
                |> List.head
                |> Maybe.map Token

        _ =
            Debug.log "token" token

        newModel : Model
        newModel =
            { token = tokenAlternative2
            , navigationKey = key
            }
    in
    ( newModel, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


onUrlRequest : UrlRequest -> Msg
onUrlRequest urlRequest =
    NoOp


onUrlChange : Url -> Msg
onUrlChange url =
    NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Document Msg
view model =
    { title =
        "Distinctly Average"
    , body =
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        ]
    }



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }
