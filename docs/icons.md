# Toolbar Icons

Roblox Studio plugin toolbar buttons take an `rbxassetid://<id>` image. Asset
ids can only come from images uploaded to Roblox (Studio's Asset Manager or
create.roblox.com) — a local file path or an id invented ahead of time will
not resolve, and `rbxassetid://0` is not a valid asset (Studio may warn about
it). That's why `src/Plugin/Config/Icons.lua` currently ships with empty
strings, which Studio renders as clean text-only buttons.

## Adding real icons

1. Design or export a square PNG per button (Roblox recommends 24x24 or
   32x32 for toolbar icons; use a transparent background). Suggested set:
   - `toggle` — panel/toolkit icon (e.g. a wrench or grid)
   - `select` — cursor/arrow
   - `box` — dashed selection rectangle
   - `move` — 4-way arrows
   - `rotate` — circular arrow
   - `align` — alignment guides
   - `palette` — command palette / search icon
2. Upload each PNG:
   - In Studio: **Home → Toolbox → Asset Manager → Images → Upload**, or
   - On the web: create.roblox.com → Create → upload as a Decal/Image asset.
3. Copy the resulting asset id and set it in `src/Plugin/Config/Icons.lua`,
   e.g. `select = "rbxassetid://123456789"`.
4. Republish/resync the plugin (or re-run `Save as Local Plugin` /
   Rojo sync) and reload Studio to see the new icons.

Uploading images requires a Roblox account and is subject to Roblox's
moderation; simple monochrome icons are typically approved quickly.
