require('telescope').load_extension('projects')

require('project_nvim').setup {
  -- lsp detection will get annoying with multiple langs in one project
  detection_methods = { "pattern" },
}

vim.keymap.set('n', '<leader>P', require('telescope').extensions.projects.projects, { desc = '[P]rojects' })
