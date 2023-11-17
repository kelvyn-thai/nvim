local overrides = require("custom.configs.overrides")
---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
    enabled = true,
    lazy = true,
  },

  {
"nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
    dependencies =  {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },
 {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        tailwind = true,
      },
      filetypes = {
        'css',
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'svelte',
      },
    },
    lazy = true,
  },
  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },

  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  -- }
  {
    "majutsushi/tagbar",
    enabled = true,
    version = "*",
    keys = {
      { "<C-T>", "<cmd>TagbarToggle<cr>", desc = "Toggle Tagbar" },
      { "<C-X>", "<cmd>TagbarClose<cr>", desc = "Toggle Close" },
    },
    lazy = true,
  },
   {
    "tpope/vim-surround",
    enabled = true,
    version = "*",
    lazy = false,
  },
  -- {
  --  "lewis6991/gitsigns.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim"
  --   },
  --   enabled = true,
  --   lazy = false,
  --   version = "*"
  -- },
  {
	"L3MON4D3/LuaSnip",
    enabled = true,
    lazy = true,
    dependencies = "rafamadriz/friendly-snippets",
	-- follow latest release.
	version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	-- install jsregexp (optional!).
	build = "make install_jsregexp",
    config = function()
     require("custom.snippets.greeting")
     local ls = require("luasnip")
     local set = vim.keymap.set
       set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
       set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
       set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})
       set({"i", "s"}, "<C-E>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, {silent = true})
    end
    -- config = luaSnipFn
},
  {
  "rafamadriz/friendly-snippets",
    enabled = true,
    lazy = true,
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
},
  {
  "hrsh7th/nvim-cmp",
  version = "*", -- last release is way too old
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
    { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
  },
  opts = function()
    vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    local cmp = require("cmp")
    local defaults = require("cmp.config.default")()
    return {
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<S-CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<C-CR>"] = function(fallback)
          cmp.abort()
          fallback()
        end,
           ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
           ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
      }, {
        { name = "buffer" },
      }),
       formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
            require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
            local icons = require("custom.icons.index")
            local kinds = icons.kinds
     -- Kind icons
      vim_item.kind = string.format("%s", kinds[vim_item.kind])
      -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
      })[entry.source.name]
      return vim_item
    end,
  },
      experimental = {
        ghost_text = {
          hl_group = "CmpGhostText",
        },
      },
      sorting = defaults.sorting,
    }
  end,
  ---@param opts cmp.ConfigSchema
  config = function(_, opts)
    for _, source in ipairs(opts.sources) do
      source.group_index = source.group_index or 1
    end
    require("cmp").setup(opts)
  end,
},
  {
  "JoosepAlviste/nvim-ts-context-commentstring",
  lazy = true,
    enabled =  true,
  opts = {
    enable_aptocmd = false,
  },
},
  {
  "lewis6991/gitsigns.nvim",
    enabled = true,
    lazy = true,
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      -- stylua: ignore start
      map("n", "]h", gs.next_hunk, "Next Hunk")
      map("n", "[h", gs.prev_hunk, "Prev Hunk")
      map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
      map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
      map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
      map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
      map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
      map("n", "<leader>ghd", gs.diffthis, "Diff This")
      map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
    end,
  },
},
 {
  "RRethy/vim-illuminate",
    enabled = true,
    lazy = true,
  -- event = "LazyFile",
  opts = {
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = {
      providers = { "lsp" },
    },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)

    local function map(key, dir, buffer)
      vim.keymap.set("n", key, function()
        require("illuminate")["goto_" .. dir .. "_reference"](false)
      end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
    end

    map("]]", "next")
    map("[[", "prev")

    -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        local buffer = vim.api.nvim_get_current_buf()
        map("]]", "next", buffer)
        map("[[", "prev", buffer)
      end,
    })
  end,
  keys = {
    { "]]", desc = "Next Reference" },
    { "[[", desc = "Prev Reference" },
  },
},
  {
    "folke/todo-comments.nvim",
      cmd = { "TodoTrouble", "TodoTelescope" },
    enabled = true,
    lazy = true,
    version = "*",
     config = true,
     keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
    { "<leader>xT", "<cmd>TodoTrouble keywords=TODO<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
    { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
    { "<leader>sT", "<cmd>TodoTelescope keywords=TODO<cr>", desc = "Todo/Fix/Fixme" },
  },
    opts = {
  signs = true, -- show icons in the signs column
  sign_priority = 8, -- sign priority
  -- keywords recognized as todo comments
  keywords = {
    FIX = {
      icon = " ", -- icon used for the sign, and in search results
      color = "error", -- can be a hex color, or a named color (see below)
      alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
      -- signs = false, -- configure signs for some keywords individually
    },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
  },
  gui_style = {
    fg = "NONE", -- The gui style to use for the fg highlight group.
    bg = "BOLD", -- The gui style to use for the bg highlight group.
  },
  merge_keywords = true, -- when true, custom keywords will be merged with the defaults
  -- highlighting of the line containing the todo comment
  -- * before: highlights before the keyword (typically comment characters)
  -- * keyword: highlights of the keyword
  -- * after: highlights after the keyword (todo text)
  highlight = {
    multiline = true, -- enable multine todo comments
    multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
    multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
    before = "", -- "fg" or "bg" or empty
    keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
    after = "fg", -- "fg" or "bg" or empty
    pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
    comments_only = true, -- uses treesitter to match keywords in comments only
    max_line_len = 400, -- ignore lines longer than this
    exclude = {}, -- list of file types to exclude highlighting
  },
  -- list of named colors where we try to extract the guifg from the
  -- list of highlight groups or use the hex color if hl not found as a fallback
  colors = {
    error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
    warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
    info = { "DiagnosticInfo", "#2563EB" },
    hint = { "DiagnosticHint", "#10B981" },
    default = { "Identifier", "#7C3AED" },
    test = { "Identifier", "#FF00FF" }
  },
  search = {
    command = "rg",
    args = {
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
    },
    -- regex that will be used to match keywords.
    -- don't replace the (KEYWORDS) placeholder
    pattern = [[\b(KEYWORDS):]], -- ripgrep regex
    -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
  },
}

  },
  {
  "windwp/nvim-ts-autotag",
    cmd = "AutoTag",
  lazy = false,
    enabled = true,
    version = "*",
  opts = {
       autotag = {
    enable = true,
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
filetypes = {
    'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'tsx', 'jsx', 'rescript',
    'xml',
    'php',
    'markdown',
    'astro', 'glimmer', 'handlebars', 'hbs'
},
    skip_tags = {
  'area', 'base', 'br', 'col', 'command', 'embed', 'hr', 'img', 'slot',
  'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr','menuitem'
    }
  }
    }
},
    {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
  enabled = true,
    lazy = false,
     dependencies = { 'nvim-lua/plenary.nvim' }
    }


--   {
--   "mfussenegger/nvim-lint",
--   lazy = false,
--   enabled = true,
--    opts = {
--     -- Event to trigger linters
--     events = { "BufWritePost", "BufReadPost", "InsertLeave" },
--     linters_by_ft = {
--       fish = { "fish" },
--       -- Use the "*" filetype to run linters on all filetypes.
--       -- ['*'] = { 'global linter' },
--       -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
--       -- ['_'] = { 'fallback linter' },
--     },
--     -- LazyVim extension to easily override linter options
--     -- or add custom linters.
--     ---@type table<string,table>
--     linters = {
--       -- -- Example of using selene only when a selene.toml file is present
--       -- selene = {
--       --   -- `condition` is another LazyVim extension that allows you to
--       --   -- dynamically enable/disable linters based on the context.
--       --   condition = function(ctx)
--       --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
--       --   end,
--       -- },
--     },
--   },
--   config = function(_, opts)
--     local Util = require("lazyvim.util")
--
--     local M = {}
--
--     local lint = require("lint")
--     for name, linter in pairs(opts.linters) do
--       if type(linter) == "table" and type(lint.linters[name]) == "table" then
--         lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
--       else
--         lint.linters[name] = linter
--       end
--     end
--     lint.linters_by_ft = opts.linters_by_ft
--
--     function M.debounce(ms, fn)
--       local timer = vim.loop.new_timer()
--       return function(...)
--         local argv = { ... }
--         timer:start(ms, 0, function()
--           timer:stop()
--           vim.schedule_wrap(fn)(table.unpack(argv))
--         end)
--       end
--     end
--
--     function M.lint()
--       -- Use nvim-lint's logic first:
--       -- * checks if linters exist for the full filetype first
--       -- * otherwise will split filetype by "." and add all those linters
--       -- * this differs from conform.nvim which only uses the first filetype that has a formatter
--       local names = lint._resolve_linter_by_ft(vim.bo.filetype)
--
--       -- Add fallback linters.
--       if #names == 0 then
--         vim.list_extend(names, lint.linters_by_ft["_"] or {})
--       end
--
--       -- Add global linters.
--       vim.list_extend(names, lint.linters_by_ft["*"] or {})
--
--       -- Filter out linters that don't exist or don't match the condition.
--       local ctx = { filename = vim.api.nvim_buf_get_name(0) }
--       ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
--       names = vim.tbl_filter(function(name)
--         local linter = lint.linters[name]
--         if not linter then
--           Util.warn("Linter not found: " .. name, { title = "nvim-lint" })
--         end
--         return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
--       end, names)
--
--       -- Run linters.
--       if #names > 0 then
--         lint.try_lint(names)
--       end
--     end
--
--     vim.api.nvim_create_autocmd(opts.events, {
--       group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
--       callback = M.debounce(100, M.lint),
--     })
--   end,
-- }
-- {
--   "nvim-telescope/telescope.nvim",
--   enabled = true,
--     lazy = false,
--   cmd = "Telescope",
--   version = '*', -- telescope did only one release, so use HEAD for now
--   dependencies = {
--     {
--       "nvim-telescope/telescope-fzf-native.nvim",
--       build = "make",
--       enabled = vim.fn.executable("make") == 1,
--       config = function()
--         Util.on_load("telescope.nvim", function()
--           require("telescope").load_extension("fzf")
--         end)
--       end,
--     },
--   },
--   keys = {
--     {
--       "<leader>,",
--       "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
--       desc = "Switch Buffer",
--     },
--     { "<leader>/", Util.telescope("live_grep"), desc = "Grep (root dir)" },
--     { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
--     { "<leader><space>", Util.telescope("files"), desc = "Find Files (root dir)" },
--     -- find
--     { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
--     { "<leader>fc", Util.telescope.config_files(), desc = "Find Config File" },
--     { "<leader>ff", Util.telescope("files"), desc = "Find Files (root dir)" },
--     { "<leader>fF", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
--     { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
--     { "<leader>fR", Util.telescope("oldfiles", { cwd = vim.loop.cwd() }), desc = "Recent (cwd)" },
--     -- git
--     { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
--     { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
--     -- search
--     { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
--     { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
--     { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
--     { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
--     { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
--     { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
--     { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
--     { "<leader>sg", Util.telescope("live_grep"), desc = "Grep (root dir)" },
--     { "<leader>sG", Util.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
--     { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
--     { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
--     { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
--     { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
--     { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
--     { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
--     { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
--     { "<leader>sw", Util.telescope("grep_string", { word_match = "-w" }), desc = "Word (root dir)" },
--     { "<leader>sW", Util.telescope("grep_string", { cwd = false, word_match = "-w" }), desc = "Word (cwd)" },
--     { "<leader>sw", Util.telescope("grep_string"), mode = "v", desc = "Selection (root dir)" },
--     { "<leader>sW", Util.telescope("grep_string", { cwd = false }), mode = "v", desc = "Selection (cwd)" },
--     { "<leader>uC", Util.telescope("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
--     {
--       "<leader>ss",
--       function()
--         require("telescope.builtin").lsp_document_symbols({
--           symbols = require("lazyvim.config").get_kind_filter(),
--         })
--       end,
--       desc = "Goto Symbol",
--     },
--     {
--       "<leader>sS",
--       function()
--         require("telescope.builtin").lsp_dynamic_workspace_symbols({
--           symbols = require("lazyvim.config").get_kind_filter(),
--         })
--       end,
--       desc = "Goto Symbol (Workspace)",
--     },
--   },
--   opts = function()
--     local actions = require("telescope.actions")
--
--     local open_with_trouble = function(...)
--       return require("trouble.providers.telescope").open_with_trouble(...)
--     end
--     local open_selected_with_trouble = function(...)
--       return require("trouble.providers.telescope").open_selected_with_trouble(...)
--     end
--     local find_files_no_ignore = function()
--       local action_state = require("telescope.actions.state")
--       local line = action_state.get_current_line()
--       Util.telescope("find_files", { no_ignore = true, default_text = line })()
--     end
--     local find_files_with_hidden = function()
--       local action_state = require("telescope.actions.state")
--       local line = action_state.get_current_line()
--       Util.telescope("find_files", { hidden = true, default_text = line })()
--     end
--
--     return {
--       defaults = {
--         prompt_prefix = " ",
--         selection_caret = " ",
--         -- open files in the first window that is an actual file.
--         -- use the current window if no other window is available.
--         get_selection_window = function()
--           local wins = vim.api.nvim_list_wins()
--           table.insert(wins, 1, vim.api.nvim_get_current_win())
--           for _, win in ipairs(wins) do
--             local buf = vim.api.nvim_win_get_buf(win)
--             if vim.bo[buf].buftype == "" then
--               return win
--             end
--           end
--           return 0
--         end,
--         mappings = {
--           i = {
--             ["<c-t>"] = open_with_trouble,
--             ["<a-t>"] = open_selected_with_trouble,
--             ["<a-i>"] = find_files_no_ignore,
--             ["<a-h>"] = find_files_with_hidden,
--             ["<C-Down>"] = actions.cycle_history_next,
--             ["<C-Up>"] = actions.cycle_history_prev,
--             ["<C-f>"] = actions.preview_scrolling_down,
--             ["<C-b>"] = actions.preview_scrolling_up,
--           },
--           n = {
--             ["q"] = actions.close,
--           },
--         },
--       },
--     }
--   end,
-- }
,
  {
  "roobert/tailwindcss-colorizer-cmp.nvim",
    enabled = true,
    lazy = false,
  -- optionally, override the default options:
}
   }


return plugins
