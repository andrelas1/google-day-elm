module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onSubmit)
import Http
import Json.Decode exposing (Decoder, field, map4, string)



-- Model


type RemoteData
    = CompanyData CompanyModel
    | DevelopersList DevelopersListModel


type Model
    = Failure
    | Loading
    | StepOne CompanyModel
    | StepTwo DevelopersListModel
    | ThankYou


type alias CompanyModel =
    { manager : String
    , location : String
    , department : String
    , project : String
    }


type alias DevelopersListModel =
    List
        { name : String
        , rating : Int
        }


type alias FormModel =
    { developersFeedback : DevelopersListModel }


type Msg
    = FetchCompanyDetails (Result Http.Error CompanyModel)
    | SendCompanyDetails CompanyModel
    | FetchDevelopersList (Result Http.Error DevelopersListModel)
    | SendDevelopersFeedbackForm FormModel


lietest fields =
    fields



-- View


view : Model -> Html Msg
view model =
    case model of
        Failure ->
            div [] [ p [] [ text "Error" ] ]

        Loading ->
            div [ class "spinner-layer spinner-blue" ]
                [ div [ class "circle-clipper left" ]
                    [ div [ class "circle" ]
                        []
                    ]
                , div [ class "gap-patch" ]
                    [ div [ class "circle" ]
                        []
                    ]
                , div [ class "circle-clipper right" ]
                    [ div [ class "circle" ]
                        []
                    ]
                ]

        StepOne companyData ->
            div [ class "container" ]
                [ div [ class "row card-panel" ]
                    [ Html.form [ class "col s12" ]
                        [ h2 []
                            [ text "Company Name" ]
                        , div [ class "row" ]
                            [ div [ class "input-field col s12" ]
                                [ input [ class "validate", id "manager_name", type_ "text" ]
                                    []
                                , label [ for "manager_name" ]
                                    [ text "Manager Name" ]
                                ]
                            ]
                        , div [ class "row" ]
                            [ div [ class "input-field col s12" ]
                                [ input [ class "validate", id "location", type_ "text" ]
                                    []
                                , label [ for "location" ]
                                    [ text "Location" ]
                                ]
                            ]
                        , button
                            [ class "btn waves-effect waves-light", name "action", type_ "submit" ]
                            [ text "Submit    "
                            , i [ class "material-icons right" ]
                                [ text "send" ]
                            ]
                        ]
                    ]
                ]

        StepTwo developersList ->
            div [] [ p [] [ text "developers list" ] ]

        ThankYou ->
            div [] [ h1 [] [ text "OBRIGADO" ] ]


users : List String -> Html msg
users list =
    list
        |> List.map (\user -> li [] [ text user ])
        |> ul []



-- Initialization


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , fetchCompanyData "rabobank"
    )



-- Commands


fetchCompanyData : String -> Cmd Msg
fetchCompanyData companyName =
    Http.get
        { url = "http://localhost:8001/" ++ companyName
        , expect = Http.expectJson FetchCompanyDetails companyDecoder
        }


companyDecoder : Decoder CompanyModel
companyDecoder =
    map4 CompanyModel
        (field "name" string)
        (field "location" string)
        (field "department" string)
        (field "project" string)



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchCompanyDetails result ->
            case result of
                Ok data ->
                    ( StepOne data, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        FetchDevelopersList result ->
            case result of
                Ok data ->
                    ( StepTwo data, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        SendCompanyDetails form ->
            ( model, Cmd.none )

        SendDevelopersFeedbackForm form ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
