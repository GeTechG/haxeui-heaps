## Why
A web build of a game with HaxeUI links the Haxe image decoders (`hxd.res.Image`, `format.png`, inflate, `NanoJpeg`) through the backend, even when the host decodes every picture with the browser: `AssetsImpl` decodes images and bitmap fonts with `hxd.res.Image`, and `TextDisplayImpl`/`TextInputImpl` call `hxd.res.DefaultFont.get()`, which builds the default font from a PNG.

## What Changes
- New define `haxeui_heaps_no_image_decode` (after heaps' `heaps_no_sound_decode`). Without it nothing changes.
- With it the backend never references `hxd.res.Image`, `hxd.res.BitmapFont` or `hxd.res.DefaultFont.get()`:
  - images (resources and bytes) go through a host hook, `AssetsImpl.decodeImage(bytes, callback)`;
  - fonts go through a host hook, `AssetsImpl.loadFont(resourceId, callback)`, and `FontData` is `h2d.Font`;
  - the default font is the one the host put in the `hxd.res.DefaultFont` slot of the engine's resource cache.
  - no hook set: the asset loads as missing (`null`); no default font in the slot: an error naming the slot.

## Capabilities
### New Capabilities
- `host-image-decode`: under `haxeui_heaps_no_image_decode` the host decodes images and supplies fonts.

## Impact
- `haxe/ui/backend/AssetsImpl.hx`, `FontData.hx`, `TextDisplayImpl.hx`, `TextInputImpl.hx`.
