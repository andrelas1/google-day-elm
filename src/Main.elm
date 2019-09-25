module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
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
    | StepOne CompanyInformationForm
    | StepTwo DeveloperFeedbackForm
    | ThankYou


type Msg
    = FetchCompanyDetails (Result Http.Error CompanyInformation)
    | SendCompanyDetails (Result Http.Error ())
    | FetchDevelopersList (Result Http.Error (List Developer))
    | SendDevelopersFeedbackForm (Result Http.Error ())
    | SupervisorNameChange String
    | LocationNameChange String
    | DeveloperRatingChange String String
    | SubmitForm



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
            stepOneView companyData

        StepTwo developersList ->
            developersListView developersList

        ThankYou ->
            div [] [ h1 [] [ text "OBRIGADO" ] ]


stepOneView : CompanyInformationForm -> Html Msg
stepOneView model =
    div
        [ class "container" ]
        [ div
            [ class "row card-panel" ]
            [ Html.form
                [ class "col s12", onSubmit SubmitForm ]
                [ h2
                    []
                    [ text model.name ]
                , div
                    [ class "row" ]
                    [ div
                        [ class "input-field col s12" ]
                        [ input
                            [ name "manager", class "validate", id "manager_name", type_ "text", onInput SupervisorNameChange ]
                            []
                        , label
                            [ for "manager_name" ]
                            [ text "Supervisor" ]
                        ]
                    ]
                , div
                    [ class "row" ]
                    [ div
                        [ class "input-field col s12" ]
                        [ input
                            [ class "validate", name "location", id "location", type_ "text", onInput LocationNameChange ]
                            []
                        , label
                            [ for "location" ]
                            [ text "Location" ]
                        ]
                    ]
                , button
                    [ class "btn waves-effect waves-light", name "action", type_ "submit" ]
                    [ text "Submit    "
                    , i
                        [ class "material-icons right" ]
                        [ text "send" ]
                    ]
                ]
            ]
        ]


renderDeveloper : DeveloperFeedback -> Html Msg
renderDeveloper model =
    div [ class "row" ]
        [ div
            [ class "row" ]
            [ h2
                []
                [ text model.name ]
            ]
        , div
            [ class "row" ]
            [ div
                [ class "input-field col s12" ]
                [ input
                    [ class "validate", id "rating", type_ "number", value <| String.fromInt model.rating ]
                    []
                ]
            , div
                [ class "input-field col s12" ]
                [ textarea
                    [ class "validate", id "comments", name "comments", value model.comments ]
                    []
                ]
            ]
        ]


developerToDeveloperFeedback : String -> DeveloperFeedback
developerToDeveloperFeedback model =
    { name = model, comments = "", rating = 0 }


developersListToDeveloperFeedbackForm : List String -> DeveloperFeedbackForm
developersListToDeveloperFeedbackForm model =
    List.map developerToDeveloperFeedback model


developersListView : DeveloperFeedbackForm -> Html Msg
developersListView model =
    div
        [ class "container" ]
        [ Html.form
            [ onSubmit SubmitForm ]
            [ div
                []
                (List.map renderDeveloper model)
            , button
                [ class "btn waves-effect waves-light", name "action", type_ "submit" ]
                [ text "Submit    "
                , i
                    [ class "material-icons right" ]
                    [ text "send" ]
                ]
            ]
        ]



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
        { url = "http://localhost:8001/developers"
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
                    , ( "name", Json.Encode.string form.name )
                    ]
        , expect = Http.expectWhatever SendCompanyDetails
        , url = "http://localhost:8001/" ++ "testing"
        }


sendDevelopersFeedbackData : DeveloperFeedbackForm -> Cmd Msg
sendDevelopersFeedbackData form =
    let
        x =
            Debug.log "DEVELOPER FEEWDBACK" form
    in
    Http.post
        { body =
            Http.jsonBody <|
                Json.Encode.object
                    [ ( "developers"
                      , Json.Encode.list
                            (\developer ->
                                Json.Encode.object
                                    [ ( "name", Json.Encode.string developer.name )
                                    , ( "comments", Json.Encode.string developer.comments )
                                    , ( "rating", Json.Encode.int developer.rating )
                                    ]
                            )
                            form
                      )
                    ]
        , expect = Http.expectWhatever SendDevelopersFeedbackForm
        , url = "http://localhost:8001/post-developers"
        }



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchCompanyDetails result ->
            case result of
                Ok data ->
                    ( StepOne { name = data.name, location = data.location, supervisor = "Supervisor" }, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        FetchDevelopersList result ->
            case result of
                Ok data ->
                    ( StepTwo (developersListToDeveloperFeedbackForm data), Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        SendCompanyDetails formModel ->
            ( StepTwo [], fetchDevelopersListData "rabobank" )

        SendDevelopersFeedbackForm result ->
            case result of
                Ok data ->
                    ( ThankYou, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        SupervisorNameChange inputValue ->
            case model of
                StepOne form ->
                    let
                        x =
                            Debug.log "Input Supervisor" inputValue
                    in
                    ( StepOne { form | supervisor = inputValue }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        LocationNameChange inputValue ->
            case model of
                StepOne form ->
                    let
                        x =
                            Debug.log "Input Location" inputValue
                    in
                    ( StepOne { form | location = inputValue }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SubmitForm ->
            case model of
                StepOne form ->
                    let
                        a =
                            Debug.log "SUBMITTTT" form
                    in
                    ( model, sendCompanyData form )

                StepTwo form ->
                    ( model, sendDevelopersFeedbackData form )

                _ ->
                    ( model, Cmd.none )

        DeveloperRatingChange name inputValue ->
            let
                x =
                    Debug.log "DEVELOPER" (inputValue ++ name)
            in
            case model of
                StepTwo form ->
                    ( StepTwo <| updateDevelopersRating form name inputValue, Cmd.none )

                _ ->
                    ( model, Cmd.none )


updateDevelopersRating : DeveloperFeedbackForm -> String -> String -> DeveloperFeedbackForm
updateDevelopersRating list name rating =
    List.map
        (\developer ->
            if developer.name == name then
                { developer | rating = Maybe.withDefault 0 (String.toInt rating) }

            else
                developer
        )
        list



-- Subscriptions


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
