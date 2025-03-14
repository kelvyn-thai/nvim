---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  theme = "one_light",
  theme_toggle = { "one_light", "one_light" },
  -- transparency = true,
  hl_override = highlights.override,
  hl_add = highlights.add,
}

-- check core.mappings for table structure
M.mappings = require "custom.mappings"
M.plugins = "custom.plugins"

return M
