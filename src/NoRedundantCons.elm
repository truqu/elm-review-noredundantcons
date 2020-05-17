module NoRedundantCons exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Infix as Infix
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Review.Fix as Fix
import Review.Rule as Rule exposing (Error, Rule)
import Util


{-| Forbids consing to a literal list.

Expressions like `foo :: [ bar ]` can be rewritten more simply as
`[ foo, bar ]`.

To use this rule, add it to your `elm-review` config like so:

    module ReviewConfig exposing (config)

    import NoRedundantCons
    import Review.Rule exposing (Rule)

    config : List Rule
    config =
        [ NoRedundantCons.rule
        ]

-}
rule : Rule
rule =
    Rule.newModuleRuleSchema "NoRedundantCons" ()
        |> Rule.withSimpleExpressionVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


expressionVisitor : Node Expression -> List (Error {})
expressionVisitor (Node.Node range expression) =
    case expression of
        Expression.OperatorApplication "::" _ item (Node.Node _ (Expression.ListExpr items)) ->
            [ Rule.errorWithFix
                { message = "Consing an item to a List literal is redundant"
                , details =
                    [ "Expressions like `foo :: [ b ]` can be written as `[ foo, b ]`."
                    ]
                }
                range
                [ addToList range item items ]
            ]

        _ ->
            []


addToList : Range -> Node Expression -> List (Node Expression) -> Fix.Fix
addToList range item items =
    (item :: items)
        |> Expression.ListExpr
        |> Util.expressionToString range
        |> Fix.replaceRangeBy range
