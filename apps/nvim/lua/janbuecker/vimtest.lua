-- test setup
vim.g["test#go#gotest#options"] = "-v -coverprofile coverage.out"
vim.g["test#strategy"] = "neovim"

-- Test mappings
vim.keymap.set("n", "<leader>tt", ":TestNearest<CR>", { desc = "[T]est nearest" })
vim.keymap.set("n", "<leader>tl", ":TestLast<CR>", { desc = "[T]est [L]ast" })
vim.keymap.set("n", "<leader>tf", ":TestFile<CR>", { desc = "[T]est [F]ile" })
vim.keymap.set("n", "<leader>ta", ":TestSuite<CR>", { desc = "[T]est [A]ll" })

-- Test coverage
require("coverage").setup() 

-- Test coverage mappings
vim.keymap.set("n", "<leader>tcl", ":Coverage<CR>", { desc = "[T]est [C]overage [L]oad" })
vim.keymap.set("n", "<leader>tcc", ":CoverageClear<CR>", { desc = "[T]est [C]overage [C]lear" })
vim.keymap.set("n", "<leader>tct", ":CoverageToggle<CR>", { desc = "[T]est [C]overage [T]oggle" })
vim.keymap.set("n", "<leader>tcs", ":CoverageSummary<CR>", { desc = "[T]est [C]overage [S]ummary" })
