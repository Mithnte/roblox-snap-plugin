-- Default, rebindable single-key hotkeys. Stored as Enum.KeyCode *names*
-- (strings) so they can be saved via plugin:SetSetting, then resolved back
-- to Enum.KeyCode when read. Contextual/tool-specific keys (Q/E rotate,
-- +/- scale, J/L/I/K/U/O align, X/Y/Z axis lock, Ctrl+Shift+D duplicate,
-- Ctrl+P palette) are intentionally left fixed to avoid conflicts with
-- modifier combos.
return {
	switch_select = "One",
	switch_move = "Two",
	switch_rotate = "Three",
	switch_scale = "Four",
	switch_box = "B",
	toggle_grid_snap = "G",
	toggle_rotate_snap = "F",
	toggle_vertex_snap = "V",
}
