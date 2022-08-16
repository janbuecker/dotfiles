-- colorscheme
vim.g.tokyonight_style = "night"

-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "tokyonight"
lvim.colorscheme = "onedarker"

vim.o.tabstop = 4 -- Insert 4 spaces for a tab
vim.o.shiftwidth = 4 -- Change the number of space characters inserted for indentation
vim.o.expandtab = true -- Converts tabs to spaces

lvim.leader = "space"

lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
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
lvim.builtin.which_key.mappings["gR"] = { "<cmd>TroubleToggle lsp_references<cr>", "LSP references [Trouble]" }

lvim.builtin.which_key.mappings["t"] = {
    name = "+Test",
    t = { "<cmd>TestNearest<cr>", "Nearest" },
    T = { "<cmd>TestFile<cr>", "File" },
    a = { "<cmd>TestSuite<cr>", "Suite" },
    l = { "<cmd>TestLast<cr>", "Last" },
    g = { "<cmd>TestVisit<cr>", "Visit" },
}

-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.actions.open_file.resize_window = true

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
    "bash",
    "c",
    "javascript",
    "json",
    "lua",
    "python",
    "typescript",
    "tsx",
    "css",
    "rust",
    "java",
    "yaml",
    "php",
    "go",
    "hcl",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()
parser_configs.hcl = {
    filetype = { "hcl", "terraform", "tf" },
}

-- ---@usage disable automatic installation of servers
lvim.lsp.automatic_servers_installation = true

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
require("lvim.lsp.manager").setup("terraformls", {
    filetype = { "terraform", "tf" },
})

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    { command = "terraform_fmt" },
}

-- -- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    -- go
    -- { name = "golangci_lint" },

    -- php
    { name = "php" },
    { name = "phpstan" },
}

-- Additional Plugins
lvim.plugins = {
    { "folke/tokyonight.nvim" },
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
    { "lunarvim/colorschemes" },
    {
        "ray-x/lsp_signature.nvim",
        config = function() require "lsp_signature".on_attach({ toggle_key = '<C-x>' }) end,
        event = "BufRead"
    },
}

-- Go: auto-import on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.go" },
    callback = function()
        vim.lsp.buf.formatting_sync(nil, 3000)
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

-- fix for <cr>
-- see https://github.com/LunarVim/LunarVim/issues/2543
local cmp = require("cmp")
lvim.builtin.cmp.mapping['<CR>'] = cmp.mapping.preset.insert(cmp.mapping.confirm({ select = true }))
