## Why
A tree of components can be added under any `h2d.Object` (the host of its root component). Heaps draws it through the host's absolute matrix: translation, rotation, scale and skew. The pointer hit test of the backend ignores all but the translation: `inBounds` compares the point with a rectangle made of the `left`/`top` of the components plus the `x`/`y` of the host and its ancestors, and `hitTest` (haxeui-core, through `screenBounds`) ignores the host altogether. Under a rotated or scaled host a component is drawn in one place and takes the pointer in another.

## What Changes
- `ComponentImpl.inBounds` maps the point through the inverse of the host's absolute matrix before comparing it with the component's rectangle and its clip rectangle, both of which are in the host's space. When the host's matrix has no rotation, scale or skew the computation is the one of before.
- `ComponentImpl` overrides `hitTest`: the point (stage coordinates, as haxeui-core expects) is mapped to the host's local space by the inverse of its absolute matrix, then tested by haxeui-core as before. With an identity host matrix nothing changes. Under a translated host `hitTest` now takes the translation into account, as `inBounds` already did.
- `screenX`/`screenY`, `screenLeft`/`screenTop`/`screenBounds` are unchanged.

## Capabilities
### New Capabilities
- `pointer-hit-test`: how the backend decides whether a point is over a component when its root is under a transformed `h2d.Object`.

## Impact
- `haxe/ui/backend/ComponentImpl.hx` (`inBounds`, new `hitTest` override).
- New `tests/HitTestTransformTest.hx` (HashLink/SDL, needs a display).
