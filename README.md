# A list with a focus

This is basically a zipper. I created a new library because I wanted the smalles API surface as possible.

```elm
import List.Focus exposing (Focus)

myFocusedList : Focus Int
myFocusedList =
    List.Focus.singleton 1
      |> List.Focus.append [2,3,4,5]
      |> List.Focus.prepend [0]

List.Focus.toList myFocusedList --> [0,1,2,3,4,5]


myFocusedList
  |> List.Focus.next
  |> Maybe.andThen List.Focus.next
  |> Maybe.map List.Focus.focused
  --> Just 3

myFocusedList
  |> List.Focus.mapParts
    { before = \i x -> (i, x, "before")
    , focus = \i x -> (i, x, "focus")
    , after = \i x -> (i, x, "after")
    }
  |> List.Focus.toList
--> [ (0, 0, "before")
--> , (1, 1, "focus")
--> , (2, 2, "after")
--> , (3, 3, "after")
--> , (4, 4, "after")
--> , (5, 5, "after")
--> ]
```

![test workflow](https://github.com/stoeffel/list-focus/actions/workflows/test.yml/badge.svg)
