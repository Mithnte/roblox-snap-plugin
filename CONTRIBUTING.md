# Contributing

Thanks for considering contributing! This repo uses:
- Conventional commits (feat:, fix:, docs:, chore:, refactor:, perf:, test:)
- Small, focused PRs
- Update CHANGELOG.md in each PR

## Dev setup
1. Open Roblox Studio and create a Plugin container.
2. Copy `src/Plugin` into the container (or use Rojo — see `docs/rojo-workflow.md`).
3. Enable from Plugins tab.

## Toolchain
Tools are pinned in `rokit.toml`. Install [Rokit](https://github.com/rojo-rbx/rokit)
and run `rokit install` to get the same Rojo/StyLua/selene versions CI uses.

## Coding guidelines
- Luau, module-per-responsibility under `src/Plugin/`
- Keep tools and services decoupled via `ctx`
- Wrap mutating ops in ChangeHistoryService waypoints
- Format with StyLua and keep selene clean before opening a PR

## Testing / checks
- Manual testing in Studio (play solo + edit) — see `TESTING.md`
- Test transform with/without snap, axis lock, surface snap
- Run `stylua --check src/`, `selene src/`, and a Luau compile check locally; CI runs all three

## Releases
- Tag versions as `vX.Y.Z`
- Update README and CHANGELOG
