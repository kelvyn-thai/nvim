local vim = require('vim')
local ls = require("luasnip")
require("custom.snippets.greeting")
local set = vim.keymap.set
function luaSnipFn()
set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})
set({"i", "s"}, "<C-E>", function()
if ls.choice_active() then
	ls.change_choice(1)
end
end, {silent = true})
end

