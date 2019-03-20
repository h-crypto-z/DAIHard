module FiatValue exposing (FiatValue, compare, currencyTypes, decoder, encode, getFloatValueWithWarning, renderToString)

import BigInt exposing (BigInt)
import BigIntHelpers
import Dict exposing (Dict)
import Images exposing (Image)
import Json.Decode
import Json.Encode


type alias FiatValue =
    { fiatType : String
    , amount : BigInt
    }


currencyTypes : Dict String ( Char, Image )
currencyTypes =
    [ ( "USD", '$' )
    ]
        |> List.map
            (\( typeString, typeChar ) ->
                ( typeString
                , ( typeChar
                  , { src = "static/img/currencies/" ++ typeString ++ ".png"
                    , description = typeString
                    }
                  )
                )
            )
        |> Dict.fromList


getFloatValueWithWarning : FiatValue -> Float
getFloatValueWithWarning value =
    let
        toFloat =
            value.amount
                |> BigInt.toString
                |> String.toFloat
    in
    case toFloat of
        Just f ->
            f

        Nothing ->
            let
                _ =
                    Debug.log "Error converting FiatValue to float--string -> float failed!" value
            in
            0


renderToString : FiatValue -> String
renderToString fv =
    let
        currencyChar =
            Dict.get fv.fiatType currencyTypes
                |> Maybe.map Tuple.first
                |> Maybe.withDefault '?'
    in
    String.fromChar currencyChar ++ BigIntHelpers.toStringWithCommas fv.amount


compare : FiatValue -> FiatValue -> Order
compare f1 f2 =
    BigInt.compare f1.amount f2.amount


encode : FiatValue -> Json.Encode.Value
encode val =
    Json.Encode.list identity
        [ Json.Encode.string val.fiatType
        , BigIntHelpers.encode val.amount
        ]


decoder : Json.Decode.Decoder FiatValue
decoder =
    Json.Decode.map2
        FiatValue
        (Json.Decode.index 0 Json.Decode.string)
        (Json.Decode.index 1 BigIntHelpers.decoder)
