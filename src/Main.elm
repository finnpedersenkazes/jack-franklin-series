port module Main exposing (..)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Html exposing (Html, a, br, button, div, h1, h2, img, text)
import Html.Attributes as Attr exposing (class, href, src, type_)
import Html.Events exposing (onClick)
import Http
import Json.Encode as Encode
import Url exposing (Url, toString)
import Url.Parser as Parser exposing ((</>))
import User exposing (LoggedInUser, UnverifiedUser, UserInfo, unverifiedToUserInfo, unverifiedUserEncoder, userInfoDecoder)
import UserAPI exposing (userRequest)
import UserAuth0 exposing (AuthStatus(..), auth0Endpoint, auth0LoginUrl, auth0Token)



-- PORTS


port saveAccessToken : String -> Cmd msg


port removeAccessToken : () -> Cmd msg



---- MODEL ----


type alias Flags =
    { maybeAccessToken : Maybe String }


type alias Model =
    { url : Url
    , key : Key
    , page : Page
    , auth : AuthStatus
    }


type Page
    = NotFound
    | About
    | LoggedIn



-- INIT


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        _ =
            Debug.log "url" url

        { maybeAccessToken } =
            flags

        _ =
            Debug.log "maybeAccessToken" maybeAccessToken
    in
    ( { url = url
      , key = key
      , page = About
      , auth =
            case maybeAccessToken of
                Just token ->
                    HasToken token

                Nothing ->
                    NotAuthed
      }
    , auth0GetUser auth0Token
    )



---- UPDATE ----


type Msg
    = NoOp
    | GotAuth0Profile String (Result Http.Error UnverifiedUser)
    | VerifiedUser String (Result Http.Error UserInfo)
    | LogOut


onUrlRequest : UrlRequest -> Msg
onUrlRequest urlRequest =
    NoOp


onUrlChange : Url -> Msg
onUrlChange url =
    NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotAuth0Profile token result ->
            case result of
                Ok profile ->
                    ( { model | auth = HasUnverifiedUser token profile }
                    , verifyUser token profile
                    )

                Err err ->
                    let
                        _ =
                            Debug.log "error" err
                    in
                    ( model, Cmd.none )

        VerifiedUser token result ->
            case result of
                Ok profile ->
                    ( { model | auth = Authenticated (LoggedInUser token profile) }
                    , Cmd.batch
                        [ Nav.pushUrl model.key "/feed"
                        , saveAccessToken token
                        ]
                    )

                Err err ->
                    let
                        _ =
                            Debug.log "error" err
                    in
                    ( model, Cmd.none )

        LogOut ->
            ( { model | auth = NotAuthed }, Cmd.batch [ Nav.pushUrl model.key "about", removeAccessToken () ] )

        NoOp ->
            ( model, Cmd.none )


auth0GetUser token =
    Http.request
        { method = "POST"
        , headers = []
        , url = auth0Endpoint ++ "/userinfo"
        , body =
            Http.jsonBody <|
                Encode.object [ ( "access_token", Encode.string token ) ]
        , expect =
            Http.expectJson (GotAuth0Profile token) User.decodeFromAuth0
        , timeout = Nothing
        , tracker = Nothing
        }



---- VIEW ----


verifyUser : String -> UnverifiedUser -> Cmd Msg
verifyUser token unVerifiedUser =
    userRequest
        { token = token
        , method = "POST"
        , url = "/user"
        , body = Just (Http.jsonBody (unverifiedUserEncoder unVerifiedUser))
        , expect = Http.expectJson (VerifiedUser token) userInfoDecoder
        }


view : Model -> Document Msg
view model =
    { title =
        "Jack Franklin"
    , body =
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        , text (model.url |> Url.toString)
        , br [] []
        , text ("AuthStatus: " ++ viewAuthStatus model.auth)
        , br [] []
        , text ("Page: " ++ viewPage model.page)
        , div []
            [ button
                [ type_ "button"
                , href "#"
                , onClick LogOut
                ]
                [ text "Logout" ]
            , button
                [ type_ "button"
                , href "#"
                , onClick LogOut
                ]
                [ text "Login" ]
            , h2 [] [ a [ Attr.href auth0LoginUrl ] [ text "login" ] ]
            ]
        ]
    }


viewPage : Page -> String
viewPage page =
    case page of
        NotFound ->
            "NotFound"

        About ->
            "About"

        LoggedIn ->
            "LoggedIn"


viewAuthStatus : AuthStatus -> String
viewAuthStatus authStatus =
    case authStatus of
        NotAuthed ->
            "NotAuthed"

        AuthError error ->
            "AuthError: " ++ error

        HasToken token ->
            "HasToken " ++ token

        HasUnverifiedUser token profile ->
            "HasUnverifiedUser"

        Authenticated _ ->
            "Authenticated"



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
