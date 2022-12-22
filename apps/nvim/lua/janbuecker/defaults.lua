-- [[ Setting options ]]
-- See `:help vim.o`

vim.o.hlsearch = true -- Set highlight on search
vim.wo.number = true -- Make line numbers default
vim.o.mouse = 'a' -- Enable mouse mode
vim.o.undofile = true -- Save undo history
vim.o.cursorline = true -- Show cursor line
vim.o.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.o.smartcase = true -- Smart case
vim.o.updatetime = 100 -- Decrease update time
vim.wo.signcolumn = 'yes' -- Always display signcolumn
vim.opt.termguicolors = true -- set term gui colors (most terminals support this)
vim.cmd [[colorscheme kanagawa]] -- Set colorscheme
vim.o.completeopt = 'menuone,noselect' -- Set completeopt to have a better completion experience
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard
vim.opt.tabstop = 4 -- Insert 4 spaces for a tab
vim.opt.shiftwidth = 4 -- Change the number of space characters inserted for indentation
vim.opt.expandtab = true -- Converts tabs to spaces
vim.opt.colorcolumn = "120" -- Visually mark at 120 chars
vim.opt.splitbelow = true -- force all horizontal splits to go below current window
vim.opt.splitright = true -- force all vertical splits to go to the right of current window
vim.opt.scrolloff = 8 -- minimal number of screen lines to keep above and below the cursor.
vim.opt.sidescrolloff = 8 -- minimal number of screen lines to keep left and right of the cursor.
vim.opt.swapfile = false -- disable swap files
vim.opt.showmode = false -- we don't need to see things like -- INSERT -- anymore
vim.opt.laststatus = 3
vim.opt.wrap = false

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.spelllang:append "cjk" -- disable spellchecking for asian characters (VIM algorithm does not support it)
vim.opt.shortmess:append "c" -- don't show redundant messages from ins-completion-menu
vim.opt.shortmess:append "I" -- don't show the default intro message
vim.opt.whichwrap:append "<,>,[,],h,l"
