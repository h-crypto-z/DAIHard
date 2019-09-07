module Create.Types exposing (CurrencyType(..), Errors, Inputs, Mode(..), Model, Msg(..), UpdateResult, currencySymbol, justModelUpdate, noErrors)

import BigInt exposing (BigInt)
import ChainCmd exposing (ChainCmd)
import CmdUp exposing (CmdUp)
import CommonTypes exposing (..)
import Currencies
import Http
import TokenValue exposing (TokenValue)
import Wallet


type alias Model =
    { wallet : Wallet.State
    , mode : Mode
    , inputs : Inputs
    , errors : Errors
    , margin : Float
    , showInTypeDropdown : Bool
    , showOutTypeDropdown : Bool
    , userAllowance : Maybe TokenValue
    }


type Msg
    = Refresh
    | AllowanceFetched TokenFactoryType (Result Http.Error BigInt)
    | AmountInChanged String
    | InTypeClicked
    | InTypeSelected CurrencyType
    | AmountOutChanged String
    | OutTypeClicked
    | OutTypeSelected CurrencyType
    | SearchInputChanged String
    | SwapClicked
    | CloseModals
    | NoOp
    | CmdUp (CmdUp Msg)


type alias Inputs =
    { amountIn : String
    , inType : CurrencyType
    , amountOut : String
    , outType : CurrencyType
    , currencySearch : String
    }


type alias Errors =
    { amountIn : Maybe String
    , amountOut : Maybe String
    }


type Mode
    = CryptoSwap BuyerOrSeller
    | OnRamp
    | OffRamp


type CurrencyType
    = DHToken FactoryType
    | External Currencies.Symbol


currencySymbol : CurrencyType -> String
currencySymbol currencyType =
    case currencyType of
        DHToken tokenType ->
            tokenUnitName tokenType

        External symbol ->
            symbol


noErrors : Errors
noErrors =
    Errors Nothing Nothing


type alias UpdateResult =
    { model : Model
    , cmd : Cmd Msg
    , chainCmd : ChainCmd Msg
    , cmdUps : List (CmdUp Msg)
    }


justModelUpdate : Model -> UpdateResult
justModelUpdate model =
    { model = model
    , cmd = Cmd.none
    , chainCmd = ChainCmd.none
    , cmdUps = []
    }
