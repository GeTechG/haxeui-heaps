# text-align Specification

## Purpose
How a text display maps the style's `text-align` to the alignment of its `h2d.Text`.

## Requirements

### Requirement: A text display maps text-align to the alignment of its text
A text display SHALL set the alignment of its `h2d.Text` from the style's `text-align`: `left` to `Left`, `right` to `Right`, `center` to `Center`, `justify` to `Justify`; any other value or no value to `Left`. A justified display SHALL be positioned as a left-aligned one.

#### Scenario: Justified text with a fixed width
- **WHEN** a word-wrapped label with a fixed width shows text that wraps onto several lines and its style sets `text-align: justify`
- **THEN** its text has the alignment `Justify` and its first wrapped line is as wide as the label

#### Scenario: Justified text with an auto width
- **WHEN** a label with an auto width has `text-align: justify`
- **THEN** its text is laid out and positioned as with `text-align: left`
