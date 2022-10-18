-- general
lvim.colorscheme = "tokyonight"
lvim.leader = "space"
lvim.builtin.alpha.active = true
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
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
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright", "clangd", "intelephense" })

-- keybindings
lvim.keys.normal_mode["<C-e>"] = ":Telescope oldfiles<cr>"

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
}
lvim.builtin.which_key.mappings["n"] = {
    name = "+Notes",
    n = { function() return require('arachne').new() end, "New" },
    r = { function() return require('arachne').rename() end, "Rename" },
    f = { function() require('telescope.builtin').find_files {
            prompt_title = '<notes::files>',
            cwd = '~/notes'
        }
    end, "Find notes" }
}

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
require("lvim.lsp.manager").setup("terraformls", {
    filetype = { "terraform", "tf" },
})

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    { command = "phpcsfixer" },
    { command = "buf" },
}

-- -- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    -- go
    { name = "golangci_lint" },

    -- php
    { name = "php" },
    { name = "phpstan" },

    -- proto
    { name = "buf" },
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
    { "Mofiqul/dracula.nvim" },
    { "folke/lsp-colors.nvim" },
    { "f-person/git-blame.nvim" },
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
        'oem/arachne.nvim',
        config = function()
            require('arachne').setup { notes_directory = "/Users/jbuecker/notes" }
        end
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
