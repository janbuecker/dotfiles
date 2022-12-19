-- Gitsigns
-- See `:help gitsigns.txt`
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

vim.keymap.set("n", "<leader>gp", require('gitsigns').preview_hunk, { desc = '[G]it [P]review hunk' })
vim.keymap.set("n", "<leader>gr", require('gitsigns').reset_hunk, { desc = '[G]it [R]eset hunk' })
