local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.completion.spell,

        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.formatting.phpcsfixer,
        null_ls.builtins.formatting.buf,
        null_ls.builtins.formatting.sqlfluff,
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.gofumpt,

        null_ls.builtins.code_actions.gomodifytags,
        null_ls.builtins.code_actions.refactoring,

        null_ls.builtins.diagnostics.buf,
        null_ls.builtins.diagnostics.golangci_lint,
        null_ls.builtins.diagnostics.phpstan,
        null_ls.builtins.diagnostics.sqlfluff.with({
            extra_args = { "--dialect", "postgres", "--exclude-rules", "L016" },
        })
    },
})
