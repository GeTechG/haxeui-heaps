# text-font-size Specification

## Purpose
TBD - created by archiving change bitmap-font-resize. Update Purpose after archive.

## Requirements

### Requirement: Text is resized to the style's font size
When a text display's style asks for a font size other than the font's current size, the display SHALL resize a clone of its font to that size with a positive scale, for bitmap and SDF fonts alike.

#### Scenario: Bitmap font at another size
- **WHEN** a label uses a 12px bitmap font and its style sets `font-size: 16px`
- **THEN** the display's font has size 16, a positive line height and positive glyph widths
