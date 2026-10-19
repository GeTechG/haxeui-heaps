## 1. Implement
- [x] 1.1 `AssetsImpl`: hooks `decodeImage`, `loadFont` and `defaultFont()` under `haxeui_heaps_no_image_decode`
- [x] 1.2 `FontData` is `h2d.Font` under the define; `TextDisplayImpl` uses it as is
- [x] 1.3 `TextDisplayImpl`/`TextInputImpl` take the default font from `AssetsImpl.defaultFont()`

## 2. Verify
- [x] 2.1 Build check passes (with and without the define)
- [x] 2.2 JS app with the define and `-dce full`: no `hxd_res_Image`, `format_png`, `NanoJpeg`; without the define they are there
- [x] 2.3 A host hook that throws loads its asset as `null` (found by cross-review)
