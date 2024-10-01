require("nvim-lsp-installer").setup {}
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup {
  -- add any options here, or leave empty to use the default settings
  library = { plugins = { "neotest" }, types = true },
}
local lsp_config = require "lspconfig"
-- if you just want default config for the servers then put them in a table
local servers = {
  "html",
  "cssls",
  "ts_ls",
  "clangd",
  "jsonls",
  "eslint",
  "tailwindcss",
  "dockerls",
  "docker_compose_language_service",
}

for _, lsp in ipairs(servers) do
  lsp_config[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
