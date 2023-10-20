module List.Focus exposing
    ( Focus, singleton, append, prepend
    , focused, toList
    , next, previous, first, last
    , map, mapParts
    )

{-| A list with a focus.


## Constructing

@docs Focus, singleton, append, prepend


## Deconstructing

@docs focused, toList


## Moving

@docs next, previous, first, last


## Transforming

@docs map, mapParts

-}


{-| A list with a focus.
-}
type Focus a
    = Focus (List a) a (List a)


{-| Create a Focus with a single element.

    singleton 1
      |> focused --> 1

-}
singleton : a -> Focus a
singleton a =
    Focus [] a []


{-| Append an element to the end of a Focus.

    singleton 1
      |> append [2, 3]
      |> toList --> [1, 2, 3]

    singleton 1
      |> append [2, 3]
      |> focused --> 1

-}
append : List a -> Focus a -> Focus a
append newXs (Focus ls a rs) =
    Focus ls a (rs ++ newXs)


{-| Prepend an element to the beginning of a Focus.

    singleton 1
      |> prepend [2, 3]
      |> toList --> [2, 3, 1]

    singleton 1
      |> prepend [2, 3]
      |> focused --> 1

-}
prepend : List a -> Focus a -> Focus a
prepend newXs (Focus ls a rs) =
    Focus (List.reverse newXs ++ ls) a rs


{-| Get the focused element of a Focus.

    singleton 1
      |> focused --> 1

-}
focused : Focus a -> a
focused (Focus _ a _) =
    a


{-| Get the elements of a Focus as a list.

    singleton 1
      |> toList --> [1]

-}
toList : Focus a -> List a
toList (Focus ls a rs) =
    List.reverse ls ++ [ a ] ++ rs


{-| Move the focus to the next element in a Focus.

    singleton 1
      |> append [2, 3]
      |> next
      |> Maybe.map focused --> Just 2

    singleton 1
      |> next
      |> Maybe.map focused --> Nothing

    singleton 1
      |> append [2, 3]
      |> next
      |> Maybe.map focused --> Just 2

-}
next : Focus a -> Maybe (Focus a)
next focus =
    case focus of
        Focus _ _ [] ->
            Nothing

        Focus ls a (r :: rs) ->
            Just (Focus (a :: ls) r rs)


{-| Move the focus to the previous element in a Focus.

    singleton 1
      |> append [2, 3]
      |> next
      |> Maybe.andThen next
      |> Maybe.andThen previous
      |> Maybe.map focused --> Just 2


    singleton 1
      |> previous
      --> Nothing

-}
previous : Focus a -> Maybe (Focus a)
previous focus =
    case focus of
        Focus [] a rs ->
            Nothing

        Focus (l :: ls) a rs ->
            Just (Focus ls l (a :: rs))


{-| Focus first element if list is empty

    singleton 1
        |> append [2, 3]
        |> next
        |> Maybe.andThen next
        |> Maybe.map first
        |> Maybe.map focused --> Just 1

    singleton 1
        |> append [2, 3, 4]
        |> next
        |> Maybe.andThen next
        |> Maybe.map first
        |> Maybe.map toList --> Just [1, 2, 3, 4]

-}
first : Focus a -> Focus a
first focus =
    case focus of
        Focus [] a rs ->
            Focus [] a rs

        Focus ls a rs ->
            case List.reverse ls of
                [] ->
                    Focus [] a rs

                l :: rest ->
                    Focus [] l (rest ++ a :: rs)


{-| Focus last element if list is empty

    singleton 1
        |> append [2, 3]
        |> last
        |> focused --> 3

    singleton 1
        |> append [2, 3, 4]
        |> last
        |> toList --> [1, 2, 3, 4]

-}
last : Focus a -> Focus a
last focus =
    case focus of
        Focus ls a [] ->
            Focus ls a []

        Focus ls a rs ->
            case List.reverse rs of
                [] ->
                    Focus ls a []

                r :: rest ->
                    Focus (rest ++ a :: ls) r []


{-| Map over a Focus, with information about the focus.

    singleton 1
      |> append [2, 3]
      |> map (\x -> x+1)
      |> toList --> [2, 3, 4]

-}
map : (a -> b) -> Focus a -> Focus b
map f focus =
    mapParts
        { before = \_ x -> f x
        , focus = \_ x -> f x
        , after = \_ x -> f x
        }
        focus


{-| Information about the focus.

    singleton 1
      |> append [2, 3, 4, 5]
      |> prepend [0]
      |> next
      |> Maybe.map (mapParts
        { before = \i x -> (i, x, "before")
        , focus = \i x -> (i, x, "focus")
        , after = \i x -> (i, x, "after")
        })
       |> Maybe.map toList
    --> Just
    -->   [ (0, 0, "before")
    -->   , (1, 1, "before")
    -->   , (2, 2, "focus")
    -->   , (3, 3, "after")
    -->   , (4, 4, "after")
    -->   , (5, 5, "after")
    -->   ]

-}
mapParts :
    { before : Int -> a -> b
    , focus : Int -> a -> b
    , after : Int -> a -> b
    }
    -> Focus a
    -> Focus b
mapParts { before, focus, after } (Focus ls a rs) =
    Focus
        (List.reverse ls
            |> List.indexedMap before
            |> List.reverse
        )
        (focus (List.length ls) a)
        (List.indexedMap (\i x -> after (List.length ls + i + 1) x) rs)
