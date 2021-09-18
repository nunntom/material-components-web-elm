module Material.Dialog exposing
    ( Config, config
    , setOnClose
    , setOpen
    , setAttributes
    , alert
    , simple
    , confirmation
    )

{-| Dialogs inform users about a task and can contain critical information,
require decisions, or involve multiple tasks.


# Table of Contents

  - [Resources](#resources)
  - [Basic Usage](#basic-usage)
  - [Configuration](#configuration)
      - [Configuration Options](#configuration-options)
  - [Alert Dialog](#alert-dialog)
  - [Simple Dialog](#simple-dialog)
  - [Confirmation Dialog](#confirmation-dialog)


# Resources

  - [Demo: Dialogs](https://aforemny.github.io/material-components-web-elm/#dialog)
  - [Material Design Guidelines: Dialogs](https://material.io/go/design-dialogs)
  - [MDC Web: Dialog](https://github.com/material-components/material-components-web/tree/master/packages/mdc-dialog)
  - [Sass Mixins (MDC Web)](https://github.com/material-components/material-components-web/tree/master/packages/mdc-dialog#sass-mixins)


# Basic Usage

    import Material.Button as Button
    import Material.Dialog as Dialog

    type Msg
        = Closed

    main =
        Dialog.alert
            (Dialog.config
                |> Dialog.setOpen True
                |> Dialog.setOnClose Closed
            )
            { title = Nothing
            , content = [ text "Discard draft?" ]
            , actions =
                [ Button.text
                    (Button.config |> Button.setOnClick Closed)
                    "Cancel"
                , Button.text
                    (Button.config |> Button.setOnClick Closed)
                    "Discard"
                ]
            }


# Configuration

@docs Config, config


## Configuration Options

@docs setOnClose
@docs setOpen
@docs setAttributes


# Alert Dialog

@docs alert


# Simple Dialog

@docs simple


# Confirmation Dialog

@docs confirmation

-}

import Html exposing (Html, text)
import Html.Attributes exposing (class, style)
import Html.Events
import Json.Decode as Decode
import Json.Encode as Encode
import Material.IconButton as IconButton


{-| Configuration of a dialog
-}
type Config msg
    = Config
        { open : Bool
        , additionalAttributes : List (Html.Attribute msg)
        , onClose : Maybe msg
        }


{-| Default configuration of a dialog
-}
config : Config msg
config =
    Config
        { open = False
        , additionalAttributes = []
        , onClose = Nothing
        }


{-| Specify whether a dialog is open
-}
setOpen : Bool -> Config msg -> Config msg
setOpen open (Config config_) =
    Config { config_ | open = open }


{-| Specify additional attributes
-}
setAttributes : List (Html.Attribute msg) -> Config msg -> Config msg
setAttributes additionalAttributes (Config config_) =
    Config { config_ | additionalAttributes = additionalAttributes }


{-| Specify a message when the user closes the dialog
-}
setOnClose : msg -> Config msg -> Config msg
setOnClose onClose (Config config_) =
    Config { config_ | onClose = Just onClose }


{-| Alert dialog view function
-}
alert :
    Config msg
    ->
        { content : List (Html msg)
        , actions : List (Html msg)
        }
    -> Html msg
alert config_ { content, actions } =
    generic config_ { title = Nothing, content = content, actions = actions }


{-| Simple dialog view function
-}
simple :
    Config msg
    ->
        { title : String
        , content : List (Html msg)
        }
    -> Html msg
simple ((Config { additionalAttributes }) as config_) { title, content } =
    generic config_ { title = Just title, content = content, actions = [] }


{-| Confirmation dialog view function
-}
confirmation :
    Config msg
    ->
        { title : String
        , content : List (Html msg)
        , actions : List (Html msg)
        }
    -> Html msg
confirmation config_ { title, content, actions } =
    generic config_ { title = Just title, content = content, actions = actions }


type alias Content msg =
    { title : Maybe String
    , content : List (Html msg)
    , actions : List (Html msg)
    }


generic :
    Config msg
    -> Content msg
    -> Html msg
generic ((Config { additionalAttributes }) as config_) content =
    Html.node "mdc-dialog"
        (List.filterMap identity
            [ rootCs
            , openProp config_
            , closeHandler config_
            ]
            ++ additionalAttributes
        )
        [ containerElt content
        , scrimElt
        ]


rootCs : Maybe (Html.Attribute msg)
rootCs =
    Just (class "mdc-dialog")


openProp : Config msg -> Maybe (Html.Attribute msg)
openProp (Config { open }) =
    Just (Html.Attributes.property "open" (Encode.bool open))


closeHandler : Config msg -> Maybe (Html.Attribute msg)
closeHandler (Config { onClose }) =
    Maybe.map (Html.Events.on "MDCDialog:close" << Decode.succeed) onClose


containerElt : Content msg -> Html msg
containerElt content =
    Html.div [ class "mdc-dialog__container" ] [ surfaceElt content ]


surfaceElt : Content msg -> Html msg
surfaceElt content =
    Html.div
        [ dialogSurfaceCs
        , alertDialogRoleAttr
        , ariaModalAttr
        ]
        (List.filterMap identity
            [ titleElt content
            , contentElt content
            , actionsElt content
            ]
        )


dialogSurfaceCs : Html.Attribute msg
dialogSurfaceCs =
    class "mdc-dialog__surface"


alertDialogRoleAttr : Html.Attribute msg
alertDialogRoleAttr =
    Html.Attributes.attribute "role" "alertdialog"


ariaModalAttr : Html.Attribute msg
ariaModalAttr =
    Html.Attributes.attribute "aria-modal" "true"


titleElt : Content msg -> Maybe (Html msg)
titleElt { title } =
    case title of
        Just title_ ->
            Just (Html.div [ class "mdc-dialog__title" ] [ text title_ ])

        Nothing ->
            Nothing


contentElt : Content msg -> Maybe (Html msg)
contentElt { content } =
    Just (Html.div [ class "mdc-dialog__content" ] content)


actionsElt : Content msg -> Maybe (Html msg)
actionsElt { actions } =
    if List.isEmpty actions then
        Nothing

    else
        Just (Html.div [ class "mdc-dialog__actions" ] actions)


scrimElt : Html msg
scrimElt =
    Html.div [ class "mdc-dialog__scrim" ] []
