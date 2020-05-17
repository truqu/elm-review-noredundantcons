module NoRedundantConsTest exposing (..)

import NoRedundantCons
import Review.Test
import Test exposing (Test, describe, test)


tests : Test
tests =
    describe "NoRedundantCons"
        [ test "Simple one" <|
            \_ ->
                """module A exposing (..)

a = x :: [ y ]
"""
                    |> Review.Test.run NoRedundantCons.rule
                    |> Review.Test.expectErrors
                        [ addToListError
                            """x :: [ y ]"""
                            |> Review.Test.whenFixed
                                """module A exposing (..)

a = [x, y]
"""
                        ]
        , test "To multiple items" <|
            \_ ->
                """module A exposing (..)

a = x :: [ y, z ]
"""
                    |> Review.Test.run NoRedundantCons.rule
                    |> Review.Test.expectErrors
                        [ addToListError
                            """x :: [ y, z ]"""
                            |> Review.Test.whenFixed
                                """module A exposing (..)

a = [x, y, z]
"""
                        ]
        ]


addToListError : String -> Review.Test.ExpectedError
addToListError under =
    Review.Test.error
        { message = "Consing an item to a List literal is redundant"
        , details =
            [ "Expressions like `foo :: [ b ]` can be written as `[ foo, b ]`."
            ]
        , under = under
        }
