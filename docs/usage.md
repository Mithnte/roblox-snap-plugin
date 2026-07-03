# Usage

## Tools
- Select (1) — Click to select, Shift to multi-select
- Box Select (B) — Drag region on XZ
- Move (2/M) — Drag; lock axis with X/Y/Z; grid snap
- Rotate (3/R) — Q/E rotate around Y (snap)
- Align — Press J/L/I/K/U/O to align to first selected

## Snapping
- Grid: toggle G, step [ / ] (0.25/0.5/1); per-axis overrides in the panel
- Rotate: toggle F; steps 15/45
- Vertex/Edge Snap: toggle V (or the panel toggle) — while moving, snaps to nearby part corners first, then edges, within a configurable threshold
- Surface Snap: enable in panel; Align-to-Normal optional

## Quick actions
- Toggle Anchor (panel button)
- Smart Duplicate: Ctrl+Shift+D (uses last move offset)
- Undo/Redo (panel buttons)

## Align & Array
- Align: Center to First, Match Rotation to First, Match Size to First (needs 2+ selected)
- Array: Linear, Radial, Grid — configure count/spacing in the panel, uses current selection

## Blueprints
- Select one or more Parts, type a name, and click "Save Selected as Blueprint" to store it locally
- Pick a saved blueprint from the dropdown, then "Spawn Blueprint" to place a copy at your mouse position (raycast to the closest surface/workspace point)
- "Delete Blueprint" removes the selected saved preset
- Blueprints persist across Studio restarts and support Parts only (position, rotation, size, shape, color, material, transparency, collision, anchored)

## Command Palette
- Ctrl+P opens a searchable list of available actions

## Rojo workflow (optional)
If you prefer editing in an external code editor, see docs/rojo-workflow.md for syncing this repo into Studio with Rojo.
