-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Save undo history
vim.o.undofile = true

-- Show cursor line
vim.o.cursorline = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd [[colorscheme kanagawa]]

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Use system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Use less space for tabstops
vim.opt.tabstop = 4 -- Insert 4 spaces for a tab
vim.opt.shiftwidth = 4 -- Change the number of space characters inserted for indentation
vim.opt.expandtab = true -- Converts tabs to spaces

-- Visually mark at 120 chars
vim.opt.colorcolumn = "120"

-- set term gui colors
vim.opt.termguicolors = true

-- Getting splits right
vim.opt.splitbelow = true -- force all horizontal splits to go below current window
vim.opt.splitright = true -- force all vertical splits to go to the right of current window

vim.opt.scrolloff = 8 -- minimal number of screen lines to keep above and below the cursor.
vim.opt.sidescrolloff = 8 -- minimal number of screen lines to keep left and right of the cursor.

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.spelllang:append "cjk" -- disable spellchecking for asian characters (VIM algorithm does not support it)
vim.opt.shortmess:append "c" -- don't show redundant messages from ins-completion-menu
vim.opt.shortmess:append "I" -- don't show the default intro message
vim.opt.whichwrap:append "<,>,[,],h,l"
