## 1. Implement
- [x] 1.1 `TextInputImpl`: the `h2d.Interactive` of the text input cancels pointer events, without handling them, while `parentComponent` has its interactivity disabled
- [x] 1.2 `ComponentImpl.handleDisabled(true)` ends a selection drag the text input already started (found by cross-review)

## 2. Verify
- [x] 2.1 Build check passes
- [x] 2.2 `tests/TextInputDisabledPointerTest.hx`: a click on a field with interactivity disabled gives no focus, after enabling it does; focus by code still works; disabling mid-drag ends the drag
