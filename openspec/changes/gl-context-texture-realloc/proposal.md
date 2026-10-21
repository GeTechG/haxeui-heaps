## Why
When the GL context is replaced (heaps' context-lost path, `Engine.onCreate(true)`, as on Android after the app returns from the background), heaps disposes every texture and refills on its next use only a texture that has `realloc`. The backend creates three kinds of textures without it — gradient backgrounds (`TileCache.getGradient`), images (`ImageDisplayImpl`, background images in `StyleHelper`) and `ComponentGraphics.setPixels` — so after the reset they draw empty.

## What Changes
- `TileCache.tileFromBitmap(bmp)`: a tile over a new texture of `bmp` whose `realloc` uploads `bmp` again. Gradients, images and background images are created through it.
- `ComponentGraphicsImpl` keeps the last `Pixels` it uploaded; its texture's `realloc` uploads them again.

## Capabilities
### New Capabilities
- `gl-context-reset`: textures the backend creates are refilled after the GL context is replaced.

## Impact
- `haxe/ui/backend/heaps/TileCache.hx`, `heaps/StyleHelper.hx`, `ImageDisplayImpl.hx`, `ComponentGraphicsImpl.hx`.
- New `tests/GlContextResetTest.hx` (HashLink/SDL, needs a display).
- These textures now also count as reallocatable for heaps' automatic texture cleanup (`MemoryManager.cleanTextures`): it may dispose them under memory pressure, and they are refilled on their next use.
