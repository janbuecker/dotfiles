-- general
lvim.colorscheme = "kanagawa"
lvim.leader = "space"
lvim.builtin.alpha.active = true
lvim.builtin.terminal.active = true
-- lvim.builtin.breadcrumbs.active = true
-- lvim.builtin.nvimtree.setup.view.side = "left"
-- lvim.builtin.nvimtree.setup.actions.open_file.resize_window = true

-- indentation
vim.o.tabstop = 4 -- Insert 4 spaces for a tab
vim.o.shiftwidth = 4 -- Change the number of space characters inserted for indentation
vim.o.expandtab = true -- Converts tabs to spaces
vim.opt.colorcolumn = "120"

-- treesitter
lvim.builtin.treesitter.ensure_installed = "all"
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- LSP
lvim.lsp.automatic_servers_installation = false
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright", "clangd", "intelephense" }, 1, 3)

-- Telescope
lvim.builtin.telescope.pickers.live_grep = {
    path_display = { "truncate" },
    layout_strategy = "horizontal",
    layout_config = {
        width = 0.9,
        height = 0.9,
        prompt_position = "bottom",
    },
}

lvim.builtin.telescope.pickers.find_files.path_display = { "truncate" }
lvim.builtin.telescope.pickers.git_files.path_display = { "truncate" }
lvim.builtin.which_key.mappings["r"] = { "<cmd>Telescope resume<CR>", "Telescope Resume", }
lvim.builtin.which_key.mappings["b"] = { "<cmd>Telescope buffers<CR>", "List Buffers", }

-- keybindings
lvim.keys.normal_mode["<C-e>"] = ":Telescope oldfiles<cr>"
lvim.keys.normal_mode["<leader>d"] = "\"_d"
lvim.keys.visual_mode["<leader>d"] = "\"_d"

-- theprimeagen <3
lvim.keys.normal_mode["<C-u>"] = "<C-u>zz"
lvim.keys.normal_mode["<C-d>"] = "<C-d>zz"
lvim.keys.normal_mode["n"] = "nzz"

-- test setup
vim.g["test#go#gotest#options"] = "-v -coverprofile coverage.out"
vim.g["test#strategy"] = "neovim"

lvim.builtin.which_key.mappings["sf"] = { "<cmd>Telescope find_files no_ignore=true<cr>", "Find File" }
lvim.builtin.which_key.mappings["gg"] = { "<cmd>LazyGit<CR>", "LazyGit" }
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["x"] = {
    name = "+Trouble",
    r = { "<cmd>Trouble lsp_references<cr>", "References" },
    f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
    d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
    q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
    l = { "<cmd>Trouble loclist<cr>", "LocationList" },
    w = { "<cmd>Trouble workspace_diagnostics<cr>", "Wordspace Diagnostics" },
    x = { "<cmd>TroubleToggle<cr>", "Toggle" },
}
lvim.builtin.which_key.mappings["lR"] = { "<cmd>TroubleToggle lsp_references<cr>", "LSP references [Trouble]" }

lvim.builtin.which_key.mappings["t"] = {
    name = "+Test",
    t = { "<cmd>TestNearest<cr>", "Nearest" },
    T = { "<cmd>TestFile<cr>", "File" },
    a = { "<cmd>TestSuite<cr>", "Suite" },
    l = { "<cmd>TestLast<cr>", "Last" },
    g = { "<cmd>TestVisit<cr>", "Visit" },
    c = {
        name = "+Coverage",
        l = {"<cmd>Coverage<cr>", "Load coverage"},
        c = {"<cmd>CoverageClear<cr>", "Clear"},
        t = {"<cmd>CoverageToggle<cr>", "Toggle"},
        s = {"<cmd>CoverageSummary<cr>", "Summary"},
    }
}

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
local lsp_manager = require "lvim.lsp.manager"
lsp_manager.setup("terraformls", { filetype = { "terraform", "tf" }, })
-- lsp_manager.setup("golangci_lint_ls", {
--     on_init = require("lvim.lsp").common_on_init,
--     capabilities = require("lvim.lsp").common_capabilities(),
-- })
lsp_manager.setup("gopls", {
    on_attach = function(client, bufnr)
        require("lvim.lsp").common_on_attach(client, bufnr)
        local _, _ = pcall(vim.lsp.codelens.refresh)
    end,
    on_init = require("lvim.lsp").common_on_init,
    capabilities = require("lvim.lsp").common_capabilities(),
    settings = {
        gopls = {
            completeUnimported = true,
            gofumpt = true,
            codelenses = {
                generate = false,
                gc_details = true,
                test = true,
                tidy = true,
            },
            analyses = {
                unusedparams = true,
            },
            experimentalPostfixCompletions = true,
            hints = {
                parameterNames = true,
                assignVariableTypes = true,
                constantValues = true,
                rangeVariableTypes = true,
                compositeLiteralTypes = true,
                compositeLiteralFields = true,
                functionTypeParameters = true,
            },
        },
    },
})

-- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    { command = "shfmt" },
    { command = "phpcsfixer" },
    { command = "buf" },
    { command = "sqlfluff", args = { "--dialect", "postgres" } },
    { command = "goimports", filetypes = { "go" } },
    { command = "gofumpt", filetypes = { "go" } },
}

-- -- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    -- go
    -- { name = "golangci_lint", args = { "--fast" } },

    -- php
    { name = "php" },
    { name = "phpstan" },

    -- proto
    { name = "buf" },
    { name = "sqlfluff", args = { "--dialect", "postgres", "--exclude-rules", "L016" } },
}

-- Additional Plugins
lvim.plugins = {
    { "vim-test/vim-test" },
    { "farmergreg/vim-lastplace" },
    { "tpope/vim-abolish" },
    { "nelsyeung/twig.vim" },
    {
        "folke/trouble.nvim",
        config = function()
            require("trouble").setup {}
        end,
    },
    { "kdheepak/lazygit.nvim" },
    {
        "ray-x/lsp_signature.nvim",
        config = function() require "lsp_signature".on_attach({ toggle_key = '<C-x>' }) end,
        event = "BufRead"
    },
    { "jacoborus/tender.vim" },
    { "folke/lsp-colors.nvim" },
    { "f-person/git-blame.nvim" },
    { "rebelot/kanagawa.nvim" },
    {
        "nvim-telescope/telescope-live-grep-args.nvim",
        config = function()
            require("telescope").load_extension("live_grep_args")
        end
    },
    {
        "phpactor/phpactor",
        run = "composer install --no-dev -o",
        config = function()
            require 'lspconfig'.phpactor.setup {
                init_options = {
                    ["language_server_phpstan.enabled"] = false,
                    ["language_server_psalm.enabled"] = false,
                    ["language_server_php_cs_fixer.enabled"] = true,
                }
            }
        end
    },
    {
        "andythigpen/nvim-coverage",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require("coverage").setup()
        end,
    },
}

-- Go: auto-import on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.go" },
    callback = function()
        vim.lsp.buf.format({ timeout_ms = 3000 })
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.go" },
    callback = function()
        local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
        params.context = { only = { "source.organizeImports" } }

        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
        for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding())
                else
                    vim.lsp.buf.execute_command(r.command)
                end
            end
        end
    end,
})

