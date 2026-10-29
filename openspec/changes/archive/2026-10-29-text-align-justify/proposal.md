## Why
A text display maps the style's `text-align` to `h2d.Text.Align`, but only `left`, `right` and `center`: `justify` falls back to `Left`. Since `validateStyle` sets `sprite.textAlign` again on every style check, a consumer cannot set the alignment itself either. `h2d.Text` now has `Align.Justify` (GeTechG/heaps `b568f01d`), which stretches each line the word wrap broke to `maxWidth`.

## What Changes
- `TextDisplayImpl.getAlign` maps `text-align: justify` to `h2d.Text.Align.Justify`.
- Positioning is unchanged: a justified display is placed as a left-aligned one (x = the display's left). With a fixed width the sprite has `maxWidth`, so wrapped lines are stretched to it; with an auto width there is no `maxWidth` and Heaps lays the text out as `Left`.
- `tools/libs.pin` pins heaps at `778687a0`, the first pinned commit of the fork to have `Align.Justify`.

## Capabilities
### New Capabilities
- `text-align`: how a text display maps the style's `text-align` to the alignment of its `h2d.Text`.

## Impact
- `haxe/ui/backend/TextDisplayImpl.hx` (`getAlign`).
- `tools/libs.pin` (heaps).
- New `tests/TextAlignJustifyTest.hx` (HashLink/SDL, needs a display).
