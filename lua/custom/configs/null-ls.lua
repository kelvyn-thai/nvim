local null_ls = require "null-ls"
-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local b = null_ls.builtins
local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre" -- or "BufWritePost"
local async = event == "BufWritePost"

local sources = {
  -- webdev stuff
  b.formatting.deno_fmt, -- choosed deno for ts/js files cuz its very fast!
  b.formatting.prettier.with { filetypes = { "html", "markdown", "css" } }, -- so prettier works only on these filetype
  b.formatting.prettier,
  -- Lua
  b.formatting.stylua,
  -- cpp
  b.formatting.clang_format,
}

null_ls.setup {
  debug = true,
  sources = sources,
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.keymap.set("n", "<Leader>fm", function()
        vim.lsp.buf.format { bufnr = vim.api.nvim_get_current_buf() }
      end, { buffer = bufnr, desc = "[lsp] format" })
      -- format on save
      vim.api.nvim_clear_autocmds { buffer = bufnr, group = group }
      vim.api.nvim_create_autocmd(event, {
        buffer = bufnr,
        group = group,
        callback = function()
          vim.lsp.buf.format { bufnr = bufnr, async = async }
        end,
        desc = "[lsp] format on save",
      })
    end

    if client.supports_method "textDocument/rangeFormatting" then
      vim.keymap.set("x", "<Leader>fm", function()
        vim.lsp.buf.format { bufnr = vim.api.nvim_get_current_buf() }
      end, { buffer = bufnr, desc = "[lsp] format" })
    end
  end,
}
