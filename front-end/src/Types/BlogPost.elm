module Types.BlogPost exposing (..)

import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Types.MasterEntity exposing (MasterEntity)


type alias BlogPost =
    { title : String
    , content : String
    , submitStatus : String
    }


type alias BlogPostE =
    MasterEntity BlogPost


blogPostDecoder : Decoder BlogPost
blogPostDecoder =
    decode BlogPost
        |> required "title" string
        |> required "content" string
        |> required "submit_status" string


blogPostEncoder : BlogPost -> Json.Encode.Value
blogPostEncoder { title, content, submitStatus } =
    Json.Encode.object
        [ ( "title", Json.Encode.string title )
        , ( "content", Json.Encode.string content )
        , ( "submit_status", Json.Encode.string submitStatus )
        ]
