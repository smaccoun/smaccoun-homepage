module Pages.Welcome exposing (..)

import Bulma.Columns exposing (..)
import Bulma.Components exposing (card, cardContent, cardImage)
import Bulma.Elements as Elements exposing (TitleSize(..), title)
import Bulma.Layout exposing (..)
import Bulma.Modifiers exposing (Size(..), Width(..))
import Html exposing (Html, a, div, i, text)
import Html.Attributes exposing (class, href, style, target)
import RemoteData exposing (RemoteData(..), WebData)
import Server.Config as SC
import Server.RequestUtils exposing (getRequestString)


type alias Model =
    { context : SC.Context
    , response : WebData String
    }


init : SC.Context -> ( Model, Cmd Msg )
init context =
    ( { context = context, response = NotAsked }
    , Cmd.map ReceiveResponse
        (getRequestString context "health"
            |> RemoteData.sendRequest
        )
    )


type Msg
    = ReceiveResponse (WebData String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveResponse response ->
            { model | response = response } ! []


viewWelcomeScreen : Model -> Html msg
viewWelcomeScreen { context, response } =
    let
        swaggerEndpoint =
            context.apiBaseUrl ++ "/swagger-ui"
    in
    div []
        [ hero { heroModifiers | size = Small, color = Bulma.Modifiers.Primary }
            [ style [ ( "marginBottom", "12px" ) ] ]
            [ heroBody []
                [ fluidContainer [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ]
                    [ title H1 [] [ text "My Home Page" ]
                    ]
                ]
            ]
        , viewAllInfoCards
        ]


viewAllInfoCards : Html msg
viewAllInfoCards =
    columns infoColumnsModifiers
            [style []]
            [  column infoColumnModifiers [] [ viewInfoCard githubIcon ]
            ,  column infoColumnModifiers [] [ viewInfoCard blogIcon ]
            ,  column infoColumnModifiers [] [ viewInfoCard linkedinIcon ]
            ]


infoColumnsModifiers : ColumnsModifiers
infoColumnsModifiers =
    { multiline = True
    , gap = Gap2
    , display = MobileAndBeyond
    , centered = True
    }


infoColumnModifiers : ColumnModifiers
infoColumnModifiers =
    { offset = Auto
    , widths =
        { mobile = Just Width11
        , tablet = Just Width8
        , desktop = Just Width2
        , widescreen = Just Width2
        , fullHD = Just Width2
        }
    }


type alias IconConfig =
    { faIcon : String
    , title : String
    , iconSize : String
    , iconLink : String
    }


blogIcon : IconConfig
blogIcon =
    { faIcon = "fab fa-blogger"
    , title = "Blog"
    , iconSize = "120px"
    , iconLink = "/blogPost"
    }

githubIcon : IconConfig
githubIcon =
    { faIcon = "fab fa-github"
    , title = "Github"
    , iconSize = "120px"
    , iconLink = "https://github.com/smaccoun"
    }


linkedinIcon : IconConfig
linkedinIcon =
    { faIcon = "fab fa-linkedin-in"
    , title = "LinkedIn"
    , iconSize = "120px"
    , iconLink = "https://www.linkedin.com/in/steven-maccoun-b4448b38/"
    }


viewInfoCard : IconConfig -> Html msg
viewInfoCard iconConfig =
    a [ href iconConfig.iconLink ]
        [ card [style [("padding-top", "20px")]]
            [ cardImage [] [ viewInfoLink iconConfig ]
            , cardContent [] [ text iconConfig.title ]
            ]
        ]


viewInfoLink : IconConfig -> Html msg
viewInfoLink { faIcon, iconSize, iconLink } =
    a [ href iconLink ]
        [ i [ class faIcon, style [ ( "fontSize", iconSize ) ] ] []
        ]
