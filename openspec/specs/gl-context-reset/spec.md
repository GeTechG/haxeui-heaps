# gl-context-reset Specification

## Purpose
Textures the backend creates are refilled after heaps disposes them on a replaced GL context (`Engine.onCreate(true)`).

## Requirements

### Requirement: Backend textures survive a GL context reset
Every texture the backend fills from data it holds — gradient backgrounds, images, background images and the pixels of `ComponentGraphics.setPixels` — SHALL have a `realloc` that uploads that data again, so that after heaps' context-lost path (`Engine.onCreate(true)`) disposes the texture, it draws the same content on its next use.

#### Scenario: Gradient background after a reset
- **WHEN** a component with a gradient background has been drawn and the engine runs `onCreate(true)`
- **THEN** on the next frames the background draws the gradient again

#### Scenario: Image after a reset
- **WHEN** an `Image` (or a component with a background image) has been drawn and the engine runs `onCreate(true)`
- **THEN** on the next frames it draws the image again

#### Scenario: ComponentGraphics pixels after a reset
- **WHEN** a component's `ComponentGraphics.setPixels` has been drawn and the engine runs `onCreate(true)`
- **THEN** on the next frames it draws the last pixels passed to `setPixels`
