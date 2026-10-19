# host-image-decode Specification

## Purpose
TBD - created by archiving change host-image-decode. Update Purpose after archive.

## Requirements

### Requirement: Without the define the backend decodes assets itself
Without `-D haxeui_heaps_no_image_decode` the backend SHALL load images, fonts and the default font with heaps' own decoders, as before.

#### Scenario: Upstream build
- **WHEN** a game is built without the define
- **THEN** images load through `hxd.res.Image`, fonts through `hxd.res.BitmapFont`, and the default font is `hxd.res.DefaultFont.get()`

### Requirement: Under the define the host decodes images
With `-D haxeui_heaps_no_image_decode` the backend SHALL pass the bytes of every image it loads (a resource of `hxd.Res.loader`, a Haxe resource, or bytes) to `AssetsImpl.decodeImage` and report the `ImageInfo` that hook returns; with no hook set, the image SHALL load as missing (`null`).

#### Scenario: Image resource with a hook
- **WHEN** the host has set `AssetsImpl.decodeImage` and a component loads an image resource
- **THEN** the hook receives the resource's bytes and the component gets the `ImageInfo` the hook passed back

#### Scenario: No hook
- **WHEN** no `AssetsImpl.decodeImage` is set and a component loads an image
- **THEN** the image loads as `null`

### Requirement: Under the define the host supplies fonts
With `-D haxeui_heaps_no_image_decode` `FontData` SHALL be `h2d.Font`, fonts SHALL load through `AssetsImpl.loadFont(resourceId, callback)` (no hook: `null`), and the default font SHALL be the font in the `hxd.res.DefaultFont` slot of the current engine's resource cache; when that slot is empty, creating a text SHALL fail with an error that names the slot.

#### Scenario: Default font from the cache slot
- **WHEN** the host stored its font with `engine.resCache.set(hxd.res.DefaultFont, font)` and a label is created
- **THEN** the label renders with that font

### Requirement: Under the define no Haxe image decoder is linked
A JS build with `-D haxeui_heaps_no_image_decode` and `-dce full` SHALL contain none of `hxd_res_Image`, `format_png`, `NanoJpeg`.

#### Scenario: Web build
- **WHEN** a JS app that starts HaxeUI and shows a label, a text field and an image is built with the define and `-dce full`
- **THEN** the output contains none of `hxd_res_Image`, `format_png`, `NanoJpeg`
