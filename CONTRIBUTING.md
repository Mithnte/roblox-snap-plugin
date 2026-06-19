# Contributing

Thanks for considering contributing! This repo uses:
- Conventional commits (feat:, fix:, docs:, chore:, refactor:, perf:, test:)
- Small, focused PRs
- Update CHANGELOG.md in each PR

## Dev setup
1. Open Roblox Studio and create a Plugin container.
2. Copy `src/Plugin` into the container.
3. Enable from Plugins tab.

## Coding guidelines
- Luau, module-per-responsibility under `src/Plugin/`
- Keep tools and services decoupled via `ctx`
- Wrap mutating ops in ChangeHistoryService waypoints

## Testing
- Manual testing in Studio (play solo + edit)
- Test transform with/without snap, axis lock, surface snap

## Releases
- Tag versions as `vX.Y.Z`
- Update README and CHANGELOG
