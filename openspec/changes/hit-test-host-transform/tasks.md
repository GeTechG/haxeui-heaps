## 1. Implement
- [ ] 1.1 `ComponentImpl.inBounds`: map the point through the inverse of the host's absolute matrix when it has rotation, scale or skew
- [ ] 1.2 `ComponentImpl.hitTest`: override, map the point to the host's local space when the host's matrix is not the identity

## 2. Verify
- [ ] 2.1 Build check passes
- [ ] 2.2 `tests/HitTestTransformTest.hx`: under a host rotated by 90° and scaled by 2, `inBounds`/`hitTest` are true where the component is drawn and false where it would be without the transform; a scroll view's clip under the same host; an identity host gives the results of before
