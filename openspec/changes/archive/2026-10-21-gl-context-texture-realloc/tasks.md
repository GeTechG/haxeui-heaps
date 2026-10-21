## 1. Implement
- [x] 1.1 `TileCache.tileFromBitmap`: a tile whose texture's `realloc` uploads the bitmap again
- [x] 1.2 Gradients (`TileCache.getGradient`), images (`ImageDisplayImpl`) and background images (`StyleHelper`) are created through it
- [x] 1.3 `ComponentGraphicsImpl.setPixels`: the texture's `realloc` uploads a copy of the last pixels (the caller may reuse its buffer; found by cross-review)

## 2. Verify
- [x] 2.1 Build check passes
- [x] 2.2 `tests/GlContextResetTest.hx`: a gradient, an image and `setPixels` draw the same pixels after `onCreate(true)` as before it
