# Changelog

## [Unreleased]
### Added
- Scale/Resize tool (key `4`): `=`/`-` resize by grid step, hold `X`/`Y`/`Z` to constrain an axis; Models scale uniformly via `ScaleTo`
- Multi-axis Rotate: `Q`/`E` now rotate around `X`/`Y`/`Z` (hold the axis key), not just Y
- Paint tools: apply color (RGB) or material to the selection, and "Match Appearance to First" (color/material/transparency/reflectance)
- Live status line in the panel (active tool, selection count, grid step, snap states) and a "Reset Settings to Defaults" action
- Continuous integration: StyLua format check, selene lint (self-contained `roblox.yml` std), and a Luau compile check; pinned toolchain via `rokit.toml`

### Fixed
- Ctrl+P now actually opens the Command Palette (previously documented but unbound)
- Smart Duplicate (Ctrl+Shift+D) works after a move again — the last move offset is remembered on mouse-up instead of being discarded, and the copies are selected so repeats lay down a row
- Tool switching, snap toggles and grid-step cycling now work from **any** tool (moved to global shortcuts), not only the Select tool
- Collision preview uses geometry overlap (`GetPartsInPart`) so anchored, non-colliding builder parts are detected

### Changed
- Replaced deprecated APIs: `RaycastFilterType.Blacklist` → `Exclude`; Box Select now uses `GetPartBoundsInBox` + `OverlapParams` instead of `Region3`/`FindPartsInRegion3`
- Normalised formatting across the codebase with StyLua

### Previously staged
- Per-axis grid snap (UI + snapping)
- Array tools skeleton (linear, radial, grid)
- Align pack: center, match rotation/size
- Command palette skeleton + toolbar button
- Vertex/edge snap for Move tool (V to toggle, configurable threshold)
- Rebindable hotkeys (Hotkeys panel; click a row, press a key)
- Blueprints: save selected Parts as a named preset, spawn/delete later (persisted)
- First-run onboarding tip in the panel
- Rojo project (`default.project.json`) + `docs/rojo-workflow.md` for a code-editor workflow
- MIT License

## [0.1.0] - 2026-06-20
### Added
- Initial professional skeleton (Move/Rotate, snapping, Box Select, Align, surface snap scaffold, collision preview, smart duplicate)
