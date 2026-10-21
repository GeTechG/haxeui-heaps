## 1. Implement
- [ ] 1.1 `TileCache.tileFromBitmap`: a tile whose texture's `realloc` uploads the bitmap again
- [ ] 1.2 Gradients (`TileCache.getGradient`), images (`ImageDisplayImpl`) and background images (`StyleHelper`) are created through it
- [ ] 1.3 `ComponentGraphicsImpl.setPixels`: the texture's `realloc` uploads the last `Pixels`

## 2. Verify
- [ ] 2.1 Build check passes
- [ ] 2.2 `tests/GlContextResetTest.hx`: a gradient, an image and `setPixels` draw the same pixels after `onCreate(true)` as before it
