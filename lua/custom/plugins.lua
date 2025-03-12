local overrides = require "custom.configs.overrides"
---@type NvPluginSpec[]
local plugins = {
  -- nvim-spl-installer
  {
    "williamboman/nvim-lsp-installer",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    -- Override plugin definition options
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
        "css",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "svelte",
      },
    },
    lazy = true,
  },
  -- To make a plugin not be loaded
  {
    "NvChad/nvim-colorizer.lua",
    enabled = true,
  },

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
    lazy = false,
  },
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
      require "custom.snippets.greeting"
      local ls = require "luasnip"
      local set = vim.keymap.set
      set({ "i" }, "<C-K>", function()
        ls.expand()
      end, { silent = true })
      set({ "i", "s" }, "<C-L>", function()
        ls.jump(1)
      end, { silent = true })
      set({ "i", "s" }, "<C-J>", function()
        ls.jump(-1)
      end, { silent = true })
      set({ "i", "s" }, "<C-E>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true })
    end,
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
      local cmp = require "cmp"
      local defaults = require "cmp.config.default"()
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
          ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<S-CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,
        },
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
            local icons = require "custom.icons.index"
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
    lazy = false,
    enabled = true,
    opts = {
      enable_aptocmd = false,
    },
    after = "nvim-treesitter",
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

        -- Autocommand to toggle line blame on cursor move
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = buffer,
          callback = function()
            -- Toggle the current line blame
            gs.toggle_current_line_blame()
          end,
        })
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
    keys = {
      {
        "<leader>s]",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next todo comment",
      },
      {
        "<leader>s[",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous todo comment",
      },
      { "<leader>sa", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
      { "<leader>sb", "<cmd>TodoTrouble keywords=TODO<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>sc", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sd", "<cmd>TodoTelescope keywords=TODO<cr>", desc = "Todo/Fix/Fixme" },
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
      -- * keyword: highlights of the keywordconform
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
        test = { "Identifier", "#FF00FF" },
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
    },
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
          "html",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "tsx",
          "jsx",
          "rescript",
          "xml",
          "php",
          "markdown",
          "astro",
          "glimmer",
          "handlebars",
          "hbs",
        },
        skip_tags = {
          "area",
          "base",
          "br",
          "col",
          "command",
          "embed",
          "hr",
          "img",
          "slot",
          "input",
          "keygen",
          "link",
          "meta",
          "param",
          "source",
          "track",
          "wbr",
          "menuitem",
        },
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    enabled = true,
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    enabled = true,
    lazy = false,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
    },
    enabled = true,
    lazy = true,
    keys = {
      {
        "<leader>tl",
        "<cmd>lua require('neotest').run.run_last()<cr>",
        desc = "Run Last Test",
        mode = "n",
      },
      -- {
      --   "<leader>tL",
      --   function()
      --     require("neotest").run.run_last { strategy = "dap" }
      --   end,
      --   desc = "Debug Last Test",
      --   mode = "n",
      -- },
      {
        "<leader>tw",
        "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<cr>",
        desc = "Run Watch",
        mode = "n",
      },
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.expand "%")
        end,
        desc = "Run File",
      },
      {
        "<leader>tT",
        function()
          require("neotest").run.run(vim.loop.cwd())
        end,
        desc = "Run All Test Files",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle Summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open { enter = true, auto_close = true }
        end,
        desc = "Show Output",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle Output Panel",
      },
      {
        "<leader>tS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop",
      },
    },
    opts = function(_, opts)
      opts.adapters = {
        require "neotest-jest" {
          jestCommand = "npm test --",
          jestConfigFile = "custom.jest.config.ts",
          env = { CI = true },
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        },
      }
    end,
  },
  {
    "MunifTanjim/prettier.nvim",
    enabled = true,
    lazy = false,
    opts = {
      bin = "prettierd", -- or `'prettierd'` (v0.23.3+)
      filetypes = {
        "css",
        -- "graphql",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "less",
        "markdown",
        "scss",
        "typescript",
        "typescriptreact",
        "yaml",
        "lua",
      },
      cli_options = {
        arrow_parens = "always",
        bracket_spacing = true,
        bracket_same_line = false,
        embedded_language_formatting = "auto",
        end_of_line = "lf",
        html_whitespace_sensitivity = "css",
        -- jsx_bracket_same_line = false,
        jsx_single_quote = true,
        print_width = 80,
        prose_wrap = "preserve",
        quote_props = "as-needed",
        semi = true,
        single_attribute_per_line = false,
        single_quote = true,
        tab_width = 2,
        trailing_comma = "es5",
        use_tabs = false,
        vue_indent_script_and_style = false,
      },
    },
  },
  { "folke/neodev.nvim", opts = {} },
  {
    "nvim-lua/plenary.nvim",
  },
  {
    "antoinemadec/FixCursorHold.nvim",
  },
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      require "custom.configs.nvim-lint"
    end,
  },
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    enabled = true,
  },
  {
    "vim-airline/vim-airline",
  },
  {
    "vim-airline/vim-airline-themes",
  },
  {
    "Galooshi/vim-import-js",
    enabled = true,
    lazy = false,
  },
  {
    "MunifTanjim/eslint.nvim",
    enabled = true,
    lazy = false,
    config = function(_, opts)
      require "custom.configs.eslint"
    end,
  },
  {
    "MattesGroeger/vim-bookmarks",
    enabled = true,
    lazy = true,
    keys = {
      {
        "<leader>mm",
        "<cmd>BookmarkToggle<cr>",
        mode = "n",
        desc = "Bookmark Toggle",
      },
      {
        "<leader>ml",
        "<cmd>BookmarkShowAll<cr>",
        mode = "n",
        desc = "Bookmark ShowAll",
      },
      {
        "<leader>mn",
        "<cmd>BookmarkShowNext<cr>",
        mode = "n",
        desc = "Bookmark ShowNext",
      },
      {
        "<leader>mp",
        "<cmd>BookmarkShowBack<cr>",
        mode = "n",
        desc = "Bookmark ShowBack",
      },
    },
  },
  -- {
  --   "robitx/gp.nvim",
  --   enabled = true,
  --   lazy = false,
  --   config = function(_, opts)
  --     local config = require "custom.configs.gp"
  --     require("gp").setup(config)
  --     -- require "custom.configs.gp"
  --
  --     -- or setup with your own config (see Install > Configuration in Readme)
  --     -- require("gp").setup(config)
  --
  --     -- shortcuts might be setup here (see Usage > Shortcuts in Readme)
  --   end,
  -- },
  -- {
  --   "folke/which-key.nvim",
  --   event = "VeryLazy",
  --   init = function()
  --     vim.o.timeout = true
  --     vim.o.timeoutlen = 300
  --   end,
  --   opts = {
  --     -- your configuration comes here
  --     -- or leave it empty to use the default settings
  --     -- refer to the configuration section below
  --   },
  -- },
  {
    "jackMort/ChatGPT.nvim",
    config = function()
      require("chatgpt").setup {
        api_key_cmd = os.getenv "OPENAI_API_KEY",
      }
    end,
    enabled = true,
    lazy = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim", -- optional
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      -- Core ChatGPT commands
      { "<leader>ci", "<cmd>ChatGPT<CR>", desc = "Open ChatGPT", mode = "n" },
      { "<leader>ce", "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with ChatGPT", mode = { "n", "v" } },

      -- Code enhancements
      { "<leader>cg", "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction", mode = { "n", "v" } },
      { "<leader>ct", "<cmd>ChatGPTRun translate<CR>", desc = "Translate Text", mode = { "n", "v" } },
      { "<leader>ck", "<cmd>ChatGPTRun keywords<CR>", desc = "Extract Keywords", mode = { "n", "v" } },
      { "<leader>cd", "<cmd>ChatGPTRun docstring<CR>", desc = "Generate Docstring", mode = { "n", "v" } },
      { "<leader>ca", "<cmd>ChatGPTRun add_tests<CR>", desc = "Add Tests", mode = { "n", "v" } },
      { "<leader>co", "<cmd>ChatGPTRun optimize_code<CR>", desc = "Optimize Code", mode = { "n", "v" } },
      { "<leader>cf", "<cmd>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs", mode = { "n", "v" } },
      { "<leader>cx", "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain Code", mode = { "n", "v" } },
      { "<leader>cs", "<cmd>ChatGPTRun summarize<CR>", desc = "Summarize Content", mode = { "n", "v" } },
      { "<leader>cr", "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit (R Code)", mode = { "n", "v" } },
      {
        "<leader>cl",
        "<cmd>ChatGPTRun code_readability_analysis<CR>",
        desc = "Analyze Code Readability",
        mode = { "n", "v" },
      },
    },
  },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
    enabled = true,
    lazy = false,
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    enabled = true,
    lazy = true,
    keys = {
      { "<leader>se", '<cmd>lua require("spectre").toggle()<CR>', desc = "Toggle Spectre" },
      {
        "<leader>sf",
        '<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
        desc = "Search current word (normal)",
      },
      {
        "<leader>sg",
        '<esc><cmd>lua require("spectre").open_visual()<CR>',
        desc = "Search current word (visual)",
        mode = "v",
      },
      {
        "<leader>sh",
        '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>',
        desc = "Search on current file",
      },
    },
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
    enabled = true,
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = true,
    lazy = true,
    enabled = true,
    keys = {
      {
        "<leader>go",
        ":GitConflictChooseOurs<CR>",
        mode = "n",
        desc = "Git conflict choose ours",
      },
      {
        "<leader>gt",
        ":GitConflictChooseTheirs<CR>",
        mode = "n",
        desc = "Git conflict choose theirs",
      },
      {
        "<leader>gb",
        ":GitConflictChooseBoth<CR>",
        mode = "n",
        desc = "Git conflict choose both",
      },
      {
        "<leader>gn",
        ":GitConflictNextConflict<CR>",
        mode = "n",
        desc = "Git conflict choose next conflict",
      },
      {
        "<leader>gp",
        ":GitConflictPrevConflict<CR>",
        mode = "n",
        desc = "Git conflict choose prev conflict",
      },
      {
        "<leader>gr",
        ":GitConflictRefresh<CR>",
        mode = "n",
        desc = "Git conflict refresh",
      },
      {
        "<leader>gq",
        ":GitConflictListQf<CR>",
        mode = "n",
        desc = "Git conflict quick fix list",
      },
    },
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    enabled = true,
    lazy = false,
    config = function()
      require "custom.configs.null-ls"
    end,
  },
  {
    "kamykn/spelunker.vim",
    enabled = true,
    lazy = false,
  },
  {
    "numToStr/Comment.nvim",
    lazy = false,
    enabled = true,
    config = function()
      require("Comment").setup {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },

  -- Only load whichkey after all the gui
  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    init = function()
      require("core.utils").load_mappings "whichkey"
    end,
    cmd = "WhichKey",
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "whichkey")
      require("which-key").setup(opts)
    end,
  }, -- Auto-close and rename HTML/JSX tags
  { "windwp/nvim-ts-autotag", lazy = false, enable = true, config = true },

  -- Emmet for fast HTML generation
  {
    "mattn/emmet-vim",
    lazy = false,
    enabled = true,
    config = function()
      vim.g.user_emmet_leader_key = "<C-Y>"

      -- Manually remap Emmet expansion
      vim.api.nvim_set_keymap("i", "<C-Y>,", "<Plug>(emmet-expand-abbr)", { noremap = true, silent = true })
    end,
    ft = { "html", "css", "javascriptreact", "typescriptreact" },
  },
  -- Auto-close tags
  {
    "alvan/vim-closetag",
    lazy = false,
    enable = true,
    ft = { "html", "javascriptreact", "typescriptreact" },
    config = function()
      vim.g.closetag_filenames = "*.html,*.js,*.jsx,*.ts,*.tsx"
      vim.g.closetag_xhtml_filenames = "*.jsx,*.tsx"
      vim.g.closetag_enable_react_fragment = 1
    end,
  },
}

return plugins
