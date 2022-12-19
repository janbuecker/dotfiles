-- Enable Comment.nvim
require('Comment').setup()

-- comment code
vim.keymap.set('v', '<leader>/', "<Plug>(comment_toggle_linewise_visual)", { desc = '[/] Comment current selection]' })
vim.keymap.set('n', '<leader>/', "<Plug>(comment_toggle_linewise_current)", { desc = '[/] Comment current line]' })

