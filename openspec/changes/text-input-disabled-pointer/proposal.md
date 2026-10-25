## Why
`disableInteractivity(true)` (haxeui-core) removes the interactive events of a component, but a text field keeps its own `h2d.Interactive`: the `h2d.TextInput` the backend creates gets the pointer straight from `h2d.Scene`, past haxeui's events. A text field whose interactivity is disabled therefore still takes the focus on a click (haxeui's and the heaps scene's), sets the caret and selects text by dragging, and shows the text cursor on hover.

## What Changes
- While the component of a text input (`parentComponent`) has its interactivity disabled, the input's `h2d.Interactive` cancels pointer events (push, release, click, move, check, over) without handling them: no focus, no caret or selection, no cursor, and the event goes on to what is under the field.
- Keyboard events and focus set by code (`focus = true`, `FocusManager`) are unaffected; a field focused before keeps typing.
- `disableInteractivity(false)` restores the pointer. The state is read from the component on each event, so nothing has to be kept in sync.

## Capabilities
### New Capabilities
- `text-input-pointer`: a text input does not take the pointer while its component's interactivity is disabled.

## Impact
- `haxe/ui/backend/TextInputImpl.hx`.
- New `tests/TextInputDisabledPointerTest.hx` (HashLink/SDL, needs a display).
