# Manual Testing Checklist

Luau plugins run inside Studio, so behaviour must still be verified manually in
a throwaway baseplate place. CI does cover the mechanical checks, though —
StyLua formatting, selene lint and a Luau compile check run on every push/PR
(see `.github/workflows/ci.yml`). Run them locally before publishing:

```
stylua --check src/
selene src/
# compile-check every file (parse + bytecode, no execution):
find src -name '*.lua' -exec luau-compile --null {} \;
```

## Setup
- [ ] Plugin loads without errors in the Output window
- [ ] Toolbar shows all buttons (Toggle, Select, Box, Move, Rotate, Scale, Align, Palette) with no red/missing-icon warnings
- [ ] Clicking Toggle opens/closes the dock widget panel
- [ ] The panel's top status line shows the active tool, selection count, grid step and snap states, and updates live
- [ ] On first run, the onboarding tip appears in the panel; after reopening, it does not appear again

## Tools
- [ ] Select (1): click selects a part; Shift-click multi-selects
- [ ] Box Select (B): drag creates a selection box on the XZ plane and selects parts inside
- [ ] Move (2/M): drag moves the part; X/Y/Z locks to that axis
- [ ] Rotate (3/R): Q/E rotate the selection in configured steps; holding X/Y/Z rotates about that world axis
- [ ] Scale (4): `=`/`-` grow/shrink by one grid step; holding X/Y/Z constrains to that axis; a Model scales uniformly
- [ ] Tool switching (1/2/3/4/B) works while any tool is active (e.g. from Move press 3 to Rotate)
- [ ] Undo/Redo (panel buttons, or Ctrl+Z/Ctrl+Y) revert/reapply each tool's changes

## Snapping
- [ ] Grid Snap toggle (G or panel) enables/disables grid snapping while moving
- [ ] Grid step cycles with [ / ]; per-axis overrides (X/Y/Z) apply independently when set
- [ ] Rotate Snap toggle (F or panel) enables/disables rotate stepping
- [ ] Vertex/Edge Snap toggle (V or panel): moving a part near another part's corner snaps to that corner within threshold; near an edge (no corner in range) snaps to the closest point on that edge
- [ ] Vertex Threshold field updates the snap distance after clicking Apply
- [ ] Surface Snap + Align-to-Normal: placing near a surface snaps to it and orients to its normal when enabled

## Align & Array
- [ ] Center to First / Match Rotation to First / Match Size to First require 2+ selected parts and apply to all but the first
- [ ] Array Linear/Radial/Grid create the expected number of copies with correct spacing, using the current selection

## Blueprints
- [ ] Save Selected as Blueprint stores the current Part selection under the typed name
- [ ] Saved blueprint appears in the dropdown after saving (survives Studio restart)
- [ ] Spawn Blueprint places a copy of the saved parts at the mouse/cursor position, preserving size/rotation/color/material
- [ ] Delete Blueprint removes it from the dropdown and persisted storage

## Hotkeys
- [ ] Hotkeys section lists all rebindable actions with their current key
- [ ] Clicking a row and pressing a new key updates the binding and immediately takes effect (test the new key actually triggers the action)
- [ ] Rebound keys persist after closing and reopening Studio

## Paint
- [ ] Apply Material sets the chosen material on all selected parts (and parts inside selected Models)
- [ ] Apply Color sets the RGB color on the selection
- [ ] Match Appearance to First copies color/material/transparency/reflectance from the first selected part to the rest (needs 2+)

## Quick actions & misc
- [ ] Toggle Anchor flips Anchored on the selection (Parts and Models with descendants)
- [ ] Smart Duplicate (Ctrl+Shift+D) duplicates using the last move offset; with no prior move it nudges one grid step on X; the copies become selected so repeats build a row
- [ ] Reset Settings to Defaults restores snapping/placement/hotkeys to defaults and keeps saved blueprints
- [ ] Command Palette (Ctrl+P) opens via the keyboard shortcut (not just the toolbar button) and its listed actions execute correctly

## Persistence
- [ ] All settings (snap toggles/steps, keymap, blueprints, onboarding flag) survive closing and reopening Studio
- [ ] No errors are logged when settings fail to load (e.g. first run with no saved data)

## Rojo workflow (if used)
- [ ] `rojo serve` + Studio's Rojo plugin sync pulls in code changes without errors
- [ ] "Save as Local Plugin" produces a working `.rbxm`/`.rbxmx` that loads correctly
