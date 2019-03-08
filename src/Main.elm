module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, div, h1, li, p, text, ul)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onSubmit)
import Http
import Json.Decode exposing (Decoder, field, list, map2, string)
import Json.Encode



-- Model


type alias Developer =
    String


type alias CompanyInformation =
    { name : String
    , location : String
    }


type alias DeveloperFeedback =
    { name : Developer
    , comments : String
    , rating : Int
    }


type Form
    = StepTwoForm DeveloperFeedbackForm
    | StepOneorm CompanyInformationForm


type alias DeveloperFeedbackForm =
    List DeveloperFeedback


type alias CompanyInformationForm =
    { name : String
    , location : String
    , supervisor : String
    }


type Model
    = Failure
    | Loading
    | StepOne CompanyInformation
    | StepTwo (List Developer)
    | ThankYou


type alias DevelopersListModel =
    List
        { name : String
        , rating : Int
        }


type alias FormModel =
    { developersFeedback : DevelopersListModel }


type Msg
    = FetchCompanyDetails (Result Http.Error CompanyInformation)
    | SaveForm Form
    | SendCompanyDetails (Result Http.Error ())
    | FetchDevelopersList (Result Http.Error (List Developer))
    | SendDevelopersFeedbackForm DeveloperFeedbackForm



-- View


view : Model -> Html Msg
view model =
    case model of
        Failure ->
            div [] [ p [] [ text "Error" ] ]

        Loading ->
            div [] [ h1 [] [ text "Loading..." ] ]

        StepOne companyData ->
            div
                [ class "bla bla1" ]
                [ p [] [ text companyData.name ]
                ]

        StepTwo developersList ->
            div [] [ p [] [ text "developers list" ] ]

        ThankYou ->
            div [] [ h1 [] [ text "OBRIGADO" ] ]


developersListView : List String -> Html msg
developersListView list =
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
fetchCompanyData clientName =
    Http.get
        { url =
            "http://localhost:8001/" ++ clientName
        , expect = Http.expectJson FetchCompanyDetails companyDecoder
        }


companyDecoder : Decoder CompanyInformation
companyDecoder =
    map2 CompanyInformation
        (field "name" string)
        (field "location" string)


developerListDecoder : Decoder (List Developer)
developerListDecoder =
    field "developers" <| list string


fetchDevelopersListData : String -> Cmd Msg
fetchDevelopersListData clientName =
    Http.get
        { url = "http//localhost:8001/" ++ clientName ++ "/developers"
        , expect = Http.expectJson FetchDevelopersList developerListDecoder
        }


sendCompanyData : CompanyInformationForm -> Cmd Msg
sendCompanyData form =
    Http.post
        { body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "location", Json.Encode.string form.location )
                    , ( "supervisor", Json.Encode.string form.supervisor )
                    ]
        , expect = Http.expectWhatever SendCompanyDetails
        , url = "http://localhost:8001/" ++ form.name
        }



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

        SendCompanyDetails formModel ->
            ( Loading, Cmd.none )

        SendDevelopersFeedbackForm form ->
            ( model, Cmd.none )

        SaveForm form ->
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
