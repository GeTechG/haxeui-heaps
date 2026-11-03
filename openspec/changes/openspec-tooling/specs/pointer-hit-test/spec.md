## MODIFIED Requirements

### Requirement: The pointer hit test follows the absolute transform of the root's host
The host of a component is the `h2d.Object` its root component is added to. `inBounds` and `hitTest` SHALL map the point they get through the inverse of the host's absolute matrix and SHALL test it in the host's local space, so that a point is over a component exactly where Heaps draws the component, whatever rotation, scale or skew the host and its ancestors have.

#### Scenario: Component under a rotated and scaled host
- **WHEN** a component's root is under an `h2d.Object` rotated by 90° and scaled by 2
- **THEN** `inBounds` and `hitTest` are true at a point where the component is drawn, and false at the point where it would be drawn without the transform

#### Scenario: Clip rectangle under a rotated and scaled host
- **WHEN** a scroll view whose content is larger than its viewport is under that host
- **THEN** `inBounds` of the content is true at a point drawn inside the viewport and false at a point of the content drawn outside it

#### Scenario: Identity host
- **WHEN** the host's absolute matrix is the identity
- **THEN** `inBounds` and `hitTest` give the results they gave before

## ADDED Requirements

### Requirement: Only `inBounds` honours the clip of the nearest clipping ancestor
In the host's local space `inBounds` SHALL test the point against the component's rectangle and the clip rectangle of its nearest clipping ancestor; `hitTest` SHALL test it against the component's rectangle only, as haxeui-core's `hitTest` does.

#### Scenario: Point of the content drawn outside the viewport
- **WHEN** a scroll view's content is larger than its viewport and a point of the content is drawn outside the viewport
- **THEN** `inBounds` of the content is false at that point and `hitTest` of the content is true

### Requirement: Hosts without rotation, scale or skew keep the previous results
When the host's absolute matrix is the identity, `inBounds` and `hitTest` SHALL give the same results as before the host's transform was taken into account; when the matrix has no rotation, scale or skew, `inBounds` SHALL.

#### Scenario: Translated host
- **WHEN** a component's root is under an `h2d.Object` that is only translated
- **THEN** `inBounds` gives, at every point, the result it gave before the host's transform was taken into account
