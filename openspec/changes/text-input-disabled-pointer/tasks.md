## 1. Implement
- [ ] 1.1 `TextInputImpl`: the `h2d.Interactive` of the text input cancels pointer events, without handling them, while `parentComponent` has its interactivity disabled

## 2. Verify
- [ ] 2.1 Build check passes
- [ ] 2.2 `tests/TextInputDisabledPointerTest.hx`: a click on a field with interactivity disabled gives no focus, after enabling it does; focus by code still works
