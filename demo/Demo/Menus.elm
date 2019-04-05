module Demo.Menus exposing (Model, Msg(..), defaultModel, update, view)

import Demo.CatalogPage exposing (CatalogPage)
import Demo.Helper.ResourceLink as ResourceLink
import Html exposing (Html, text)
import Html.Attributes
import Html.Events
import Json.Decode as Decode
import Material.Button exposing (button, buttonConfig)
import Material.List exposing (ListItemConfig, list, listConfig, listItem, listItemConfig, listItemDivider, listItemDividerConfig)
import Material.Menu exposing (menu, menuConfig, menuSurfaceAnchor)
import Material.Typography as Typography


type alias Model =
    { open : Bool }


defaultModel : Model
defaultModel =
    { open = False }


type Msg
    = NoOp
    | Open
    | Close


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update lift msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Open ->
            ( { model | open = True }, Cmd.none )

        Close ->
            ( { model | open = False }, Cmd.none )


view : Model -> CatalogPage Msg
view model =
    { title = "Menu"
    , prelude = "Menus display a list of choices on a transient sheet of material."
    , resources =
        { materialDesignGuidelines = Just "https://material.io/go/design-menus"
        , documentation = Just "https://material.io/components/web/catalog/menus/"
        , sourceCode = Just "https://github.com/material-components/material-components-web/tree/master/packages/mdc-menu"
        }
    , hero = [ heroMenu model ]
    , content =
        [ Html.h3 [ Typography.subtitle1 ] [ text "Anchored menu" ]
        , Html.div [ menuSurfaceAnchor ]
            [ button { buttonConfig | onClick = Just Open } "Open menu"
            , menu { menuConfig | open = model.open, onClose = Just Close }
                [ list listConfig
                    [ listItem menuItemConfig [ text "Passionfruit" ]
                    , listItem menuItemConfig [ text "Orange" ]
                    , listItem menuItemConfig [ text "Guava" ]
                    , listItem menuItemConfig [ text "Pitaya" ]
                    , listItemDivider listItemDividerConfig
                    , listItem menuItemConfig [ text "Pineapple" ]
                    , listItem menuItemConfig [ text "Mango" ]
                    , listItem menuItemConfig [ text "Papaya" ]
                    , listItem menuItemConfig [ text "Lychee" ]
                    ]
                ]
            ]
        ]
    }


menuItemConfig : ListItemConfig Msg
menuItemConfig =
    { listItemConfig
        | onClick = Just Close
        , additionalAttributes =
            [ Html.Events.on "keydown"
                (Html.Events.keyCode
                    |> Decode.andThen
                        (\keyCode ->
                            if keyCode == 32 || keyCode == 13 then
                                Decode.succeed Close

                            else
                                Decode.fail ""
                        )
                )
            ]
    }


heroMenu : Model -> Html msg
heroMenu model =
    menu
        { menuConfig
            | open = True
            , quickOpen = True
            , additionalAttributes = [ Html.Attributes.style "position" "relative" ]
        }
        [ list listConfig
            [ listItem listItemConfig [ text "A Menu Item" ]
            , listItem listItemConfig [ text "Another Menu Item" ]
            ]
        ]
