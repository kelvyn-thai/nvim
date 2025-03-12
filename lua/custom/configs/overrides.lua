local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "markdown",
    "markdown_inline",
    "json",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}

M.mason = {
  ensure_installed = {
    "html-lsp",
    "css-lsp",
    "typescript-language-server",
    "prettier",
    "tailwindcss-language-server",
    "eslint-lsp",
    "vtsls",
    "dockerfile-language-server",
  },
  PATH = "prepend",
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },
  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
  filters = {
    dotfiles = false,
  },
  view = {
    width = 50,
  },
  trash = {
    cmd = "trash",
  },
}

return M
