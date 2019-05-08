module Trade.Types exposing
    ( ContractAction(..)
    , Model
    , Msg(..)
    , PhaseState(..)
    , TxChainStatus(..)
    )

import Array exposing (Array)
import BigInt exposing (BigInt)
import CommonTypes exposing (..)
import Contracts.Generated.DAIHardFactory as DHF
import Contracts.Generated.DAIHardTrade as DHT
import Contracts.Types as CTypes
import Eth.Sentry.Event as EventSentry exposing (EventSentry)
import Eth.Types exposing (Address, TxHash, TxReceipt)
import EthHelpers
import Http
import Json.Decode
import Time
import Trade.ChatHistory.SecureComm exposing (..)
import Trade.ChatHistory.Types as ChatHistory


type alias Model =
    { node : EthHelpers.EthNode
    , userInfo : Maybe UserInfo
    , trade : CTypes.Trade
    , expandedPhase : CTypes.Phase
    , chatHistoryModel : Maybe ChatHistory.Model
    , eventsWaitingForChatHistory : List ( Int, CTypes.DAIHardEvent )
    , showChatHistory : Bool
    , showStatsModal : Bool
    , secureCommInfo : SecureCommInfo
    , eventSentry : EventSentry Msg
    , allowance : Maybe BigInt
    , txChainStatus : Maybe TxChainStatus
    }


type Msg
    = CreationInfoFetched (Result Http.Error DHF.CreatedTrade)
    | StateFetched (Result Http.Error (Maybe CTypes.State))
    | ParametersFetched (Result Http.Error (Result String CTypes.TradeParameters))
    | PhaseInfoFetched (Result Http.Error (Maybe CTypes.PhaseStartInfo))
    | AllowanceFetched (Result Http.Error BigInt)
    | CommitClicked CTypes.FullTradeInfo UserInfo BigInt
    | AbortCommit
    | ConfirmCommit CTypes.FullTradeInfo UserInfo BigInt
    | CommitSigned (Result String TxHash)
    | CommitMined (Result String TxReceipt)
    | StartContractAction ContractAction
    | ActionMined ContractAction (Result String TxReceipt)
    | ActionSigned ContractAction (Result String TxHash)
    | ApproveSigned (Result String TxHash)
    | Refresh Time.Posix
    | ExpandPhase CTypes.Phase
    | ToggleChat
    | ToggleStatsModal
    | EventLogFetched Eth.Types.Log
    | EventSentryMsg EventSentry.Msg
    | ChatHistoryMsg ChatHistory.Msg
    | MessageSubmitMined (Result String TxReceipt)
    | EncryptionFinished Json.Decode.Value


type TxChainStatus
    = ConfirmingCommit CTypes.FullTradeInfo UserInfo BigInt
    | ApproveNeedsSig
    | ApproveMining TxHash
    | CommitNeedsSig
    | CommitMining TxHash
    | ActionNeedsSig ContractAction
    | ActionMining ContractAction TxHash


type ContractAction
    = Poke
    | Recall
    | Claim
    | Abort
    | Release
    | Burn


type PhaseState
    = NotStarted
    | Active
    | Finished
