# elm-review-noredundantcons

Helps with preventing redundant usage of the cons operator, namely consing to a literal list.

This will flag expressions like these:

```elm
foo :: [ bar ]
```

And propose rewriting it like so:

```elm
[ foo, bar ]
```

## Configuration

```elm
module ReviewConfig exposing (config)

import NoRedundantCons
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ NoRedundantCons.rule
    ]
```
