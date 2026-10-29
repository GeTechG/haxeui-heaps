## 1. Implement
- [ ] 1.1 `tools/libs.pin`: pin heaps at a commit with `h2d.Text.Align.Justify`
- [ ] 1.2 `TextDisplayImpl.getAlign`: `justify` → `h2d.Text.Align.Justify`

## 2. Verify
- [ ] 2.1 Build check passes
- [ ] 2.2 `tests/TextAlignJustifyTest.hx`: a wrapped label with a fixed width and `text-align: justify` has a `Justify` sprite whose first line is as wide as the label; with an auto width it matches `left`
