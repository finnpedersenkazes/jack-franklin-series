module UserAPI exposing (..)

import Http exposing (..)


type alias UserRequestInfo msg =
    { token : String
    , method : String
    , url : String
    , body : Maybe Body
    , expect : Expect msg
    }


userRequest : UserRequestInfo msg -> Cmd msg
userRequest requestInfo =
    Http.request
        { method = requestInfo.method
        , headers = [ header "Authorization" ("Bearer " ++ requestInfo.token) ]
        , url = "http://localhost:3000" ++ requestInfo.url
        , body = Maybe.withDefault emptyBody requestInfo.body
        , expect = requestInfo.expect
        , timeout = Nothing
        , tracker = Nothing
        }
