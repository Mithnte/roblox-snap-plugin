# Developing with Rojo (optional, recommended)

Copy-pasting `src/Plugin` into Studio every time you change something gets old
fast. If you install [Rojo](https://rojo.space/), you can sync changes live.

## One-time setup

1. Install the Rojo CLI (`cargo install rojo`, or via the Rojo VS Code
   extension / aftman / foreman).
2. Install the **Rojo** plugin inside Roblox Studio itself (Plugins tab →
   search "Rojo" → install). This is the companion that receives the sync.

## Syncing this repo

1. From the project root, run:
   ```
   rojo serve
   ```
   This reads `default.project.json` and starts a local server (default port
   34872).
2. Open Roblox Studio, open any place (a throwaway one is fine), click the
   Rojo plugin button, and hit **Connect**.
3. Rojo will insert a `BuilderToolkitPlugin` folder into `ServerStorage`
   containing everything under `src/Plugin`, kept live in sync with your
   editor.
4. Right-click that folder → **Save as Local Plugin**. Studio copies it into
   your local Plugins folder and it now behaves like any installed plugin
   (shows up in the Plugins toolbar tab, persists across Studio restarts).
5. Whenever you edit files in this repo and want to test again, just repeat
   step 4 (Save as Local Plugin) — Rojo keeps the synced folder up to date
   automatically while `rojo serve` is running, so the re-save picks up your
   latest changes.

## Building a distributable file instead

If you'd rather hand someone a single file:

```
rojo build default.project.json --output BuilderToolkitPlugin.rbxm
```

Drop the resulting `.rbxm` straight into your local `Plugins` folder
(`%LOCALAPPDATA%/Roblox/Plugins` on Windows, `~/Documents/Roblox/Plugins` on
Mac) and restart Studio.

## Why `Main.plugin.lua`?

The `.plugin.lua` suffix is a Rojo convention: it becomes a `Script` with
`RunContext = Plugin`, meaning it only executes when running as an installed
plugin — safe to keep synced in the same tree without it trying to run as a
normal game script.
