require("nvim-lsp-installer").setup {}
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local util = require "lspconfig.util"

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
  "yamlls",
  -- "vtsls",
}

-- Iterate and configure LSPs
for _, lsp in ipairs(servers) do
  if lsp == "vtsls" then
    lsp_config.vtsls.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      root_dir = util.root_pattern("tsconfig.json", "package.json", ".git"),
      single_file_support = false,
    }
  else
    if lsp_config[lsp] then
      lsp_config[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
      }
    else
      print("Warning: LSP server " .. lsp .. " is not available.")
    end
  end
end
