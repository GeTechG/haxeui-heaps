# pointer-hit-test Specification

## Purpose
The backend's pointer hit test matches where Heaps draws a component, whatever transform the `h2d.Object` its root is added to has.

## Requirements

### Requirement: The pointer hit test follows the absolute transform of the root's host
The host of a component is the `h2d.Object` its root component is added to. `inBounds` and `hitTest` SHALL map the point they get through the inverse of the host's absolute matrix and SHALL test it in the host's local space — `inBounds` against the component's rectangle and the clip rectangle of its nearest clipping ancestor, `hitTest` against the component's rectangle only, as haxeui-core's `hitTest` does — so that a point is over a component exactly where Heaps draws the component, whatever rotation, scale or skew the host and its ancestors have. When the host's absolute matrix is the identity, both SHALL give the same result as before this requirement. When it has no rotation, scale or skew, `inBounds` SHALL give the same result as before.

#### Scenario: Component under a rotated and scaled host
- **WHEN** a component's root is under an `h2d.Object` rotated by 90° and scaled by 2
- **THEN** `inBounds` and `hitTest` are true at a point where the component is drawn, and false at the point where it would be drawn without the transform

#### Scenario: Clip rectangle under a rotated and scaled host
- **WHEN** a scroll view whose content is larger than its viewport is under that host
- **THEN** `inBounds` of the content is true at a point drawn inside the viewport and false at a point of the content drawn outside it

#### Scenario: Identity host
- **WHEN** the host's absolute matrix is the identity
- **THEN** `inBounds` and `hitTest` give the results they gave before
