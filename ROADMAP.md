# Roadmap (Premium / Best Features)

This plugin is intended to feel Studio-native while delivering "premium" builder productivity.

## V1 (MVP) — core transform + snapping
- Select (click, shift add/remove)
- Move tool (drag workflow via plugin mouse)
- Rotate tool (drag workflow)
- Grid snap: 0.25 / 0.5 / 1 studs
- Rotate snap: 15° / 45°
- Undo/redo waypoints per operation
- DockWidget UI for snap toggles + step selection

## V2 (Premium) — high-value builder features
### Placement & snapping
- Surface snap (raycast to face) + align to normal
- Smart grid: adaptive grid per zoom level + per-axis snap
- Vertex snap / point-to-point snap (optional)
- Collision / overlap preview with red/green ghost

### Productivity
- Box select + lasso select
- Align / distribute / mirror
- Replace selection with another asset while preserving transforms
- Quick properties: anchor, collide, transparency, material, color eyedropper
- Grouping helpers: create model, set pivot, pivot to selection

### Prefabs / blueprints
- Palette browser (favorites)
- Save selection as blueprint (serialize) + insert later
- Import/export blueprint as JSON

### UX polish
- Studio-theme aware UI
- Status bar with hints
- Customizable shortcuts
- Safe-mode for locked objects

## V3 (Pro)
- Multi-edit handles (scale for Model via bounding box)
- Constraint-aware transforms
- Snapping rules per folder / per tag
- Optional telemetry hooks (disabled by default)
