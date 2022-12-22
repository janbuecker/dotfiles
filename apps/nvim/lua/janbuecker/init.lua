require('janbuecker.defaults')
require('janbuecker.keymaps')

require('janbuecker.plugins')
require('janbuecker.lsp')
require('janbuecker.null-ls')
require('janbuecker.telescope')
require('janbuecker.lualine')
require('janbuecker.gitsigns')
require('janbuecker.illuminate')
require('janbuecker.treesitter')
require('janbuecker.cmp')
require('janbuecker.comment')
require('janbuecker.indent')
require('janbuecker.vimtest')
require('janbuecker.nvimtree')
require('janbuecker.autopairs')
require('janbuecker.project')
require('janbuecker.lazygit')
require('janbuecker.disable_builtin')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.cmd [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]]

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', 'gl', vim.diagnostic.open_float)
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
