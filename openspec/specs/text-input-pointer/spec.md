# text-input-pointer Specification

## Purpose
A text input the backend creates does not take the pointer while the interactivity of its component is disabled.

## Requirements

### Requirement: A text input ignores the pointer while its component's interactivity is disabled
While the component that owns a text input has its interactivity disabled (`disableInteractivity(true)`, which `disabled = true` also does), the backend's `h2d.TextInput` SHALL NOT handle pointer events: a click SHALL NOT focus the component nor the heaps scene focus, SHALL NOT set the caret or a selection, hovering SHALL NOT show the text cursor, and the event SHALL go on to the interactives under the field. Keyboard events and focus set by code SHALL work as for an enabled field. After `disableInteractivity(false)` the pointer SHALL work as before.

#### Scenario: Click on a field with interactivity disabled
- **WHEN** the interactivity of a `TextField` is disabled and the user clicks on its text
- **THEN** neither the field nor the heaps scene takes the focus and no caret is placed

#### Scenario: Click after interactivity is enabled again
- **WHEN** the interactivity of that field is enabled again and the user clicks on its text
- **THEN** the field takes the focus as before

#### Scenario: Interactivity disabled during a selection drag
- **WHEN** the user has pressed on an enabled field and is dragging a selection, and its interactivity is disabled before the release
- **THEN** further pointer movement no longer changes the caret or the selection

#### Scenario: Focus by code
- **WHEN** the interactivity of a `TextField` is disabled and code sets `focus = true`
- **THEN** the field takes the focus and receives the keyboard
