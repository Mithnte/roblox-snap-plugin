# Roblox Builder Toolkit (Studio‑native)

Premium builder productivity plugin for Roblox Studio.

<p align="left">
  <img alt="ci" src="https://github.com/Mithnte/roblox-snap-plugin/actions/workflows/ci.yml/badge.svg" />
  <img alt="status" src="https://img.shields.io/badge/status-in_progress-blue" />
  <img alt="license" src="https://img.shields.io/badge/license-MIT-green" />
</p>

## Features (snapshot)
- Move drag + grid snap + axis lock + undo waypoints
- Vertex/edge snap for precise placement (toggle V)
- Rotate (Q/E) around X/Y/Z with snap steps
- Scale/resize (=/- by grid step, X/Y/Z to constrain)
- Surface snap (raycast) + optional align‑to‑normal
- Collision preview (green/red SelectionBox), geometry‑accurate
- Select + Box Select
- Align to first (J/L/I/K/U/O) + center/match rotation/match size
- Array tools: linear, radial, grid
- Paint: set color/material, or match appearance to the first selection
- Blueprints: save/spawn/delete reusable Part presets
- Rebindable hotkeys (Hotkeys panel); tool switching works from any tool
- Smart duplicate (Ctrl+Shift+D) — repeats your last move offset
- Command palette (Ctrl+P)
- DockWidget panel with a live status line, plus reset‑to‑defaults
- Local settings persistence (survives Studio restarts) — see docs/usage.md

## Docs
- docs/getting-started.md
- docs/usage.md
- docs/hotkeys.md
- docs/rojo-workflow.md — build/sync with a code editor via Rojo
- docs/icons.md — how to add real toolbar icons
- ROADMAP.md
- TESTING.md — manual QA checklist

## Development
Tooling is pinned with [Rokit](https://github.com/rojo-rbx/rokit) in `rokit.toml`
(Rojo, StyLua, selene). CI runs StyLua (`--check`), selene, and a Luau
compile check on every push/PR — see `.github/workflows/ci.yml`. Run the same
checks locally with `stylua --check src/`, `selene src/`, and Rojo/Luau.

## Contributing
See CONTRIBUTING.md and CODE_OF_CONDUCT.md.

## License
MIT — free to use, modify, and distribute. See LICENSE.
