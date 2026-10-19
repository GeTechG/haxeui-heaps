## Why
When a text style asks for a size other than the bitmap font's own, `TextDisplayImpl` calls `h2d.Font.resizeTo(-size)`. The pinned heaps reads the negative size as a mirrored scale (`-size/size`): `font.size` becomes negative, `lineHeight` negative, glyph widths negative.

## What Changes
- `TextDisplayImpl.resizeFont` resizes a bitmap font to the positive requested size, as it already does for SDF fonts.

## Capabilities
### New Capabilities
- `text-font-size`: a text display renders its font at the size its style asks for.

## Impact
- `haxe/ui/backend/TextDisplayImpl.hx`. `TextInputImpl` overrides `resizeFont` with the same call; it is a separate task.
