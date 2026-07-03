# Usage

## Tools
- Select (1) — Click to select, Shift to multi-select
- Box Select (B) — Drag region on XZ
- Move (2/M) — Drag; lock axis with X/Y/Z; grid snap
- Rotate (3/R) — Q/E rotate; defaults to Y, hold X/Y/Z to rotate about that axis (snap)
- Scale (4) — `=`/`-` grow/shrink the selection by one grid step; hold X/Y/Z to constrain to that axis. BaseParts resize about their centre; Models scale uniformly about their pivot.
- Align — Press J/L/I/K/U/O to align to first selected

Tool switching (1/2/3/4/B) works from any tool, not just Select.

## Snapping
- Grid: toggle G, step [ / ] (0.25/0.5/1); per-axis overrides in the panel
- Rotate: toggle F; steps 15/45
- Vertex/Edge Snap: toggle V (or the panel toggle) — while moving, snaps to nearby part corners first, then edges, within a configurable threshold
- Surface Snap: enable in panel; Align-to-Normal optional

## Quick actions
- Toggle Anchor (panel button)
- Smart Duplicate: Ctrl+Shift+D (repeats your last Move offset; if you haven't moved yet it nudges one grid step on X, and the copies become the new selection so repeats build a row)
- Reset Settings to Defaults (panel button / command palette) — restores snapping, placement and hotkeys to defaults; your saved blueprints are kept
- Undo/Redo (panel buttons)

## Paint (color / material)
- Pick a material in the "Paint" section and click **Apply Material** to set it on every selected part (and every part inside selected Models)
- Enter R/G/B (0–255) and click **Apply Color**
- **Match Appearance to First** copies color, material, transparency and reflectance from the first selected part onto the rest (needs 2+ selected)

## Status line
The top of the panel shows the active tool, how many objects are selected, the
current grid step, and whether grid/rotate/vertex snapping are on.

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
