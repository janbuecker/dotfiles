-- nvim-cmp setup
local cmp = require("cmp")
local luasnip = require("luasnip")

local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
	completion = {
		---@usage The minimum length of a word to complete on.
		keyword_length = 1,
	},
	experimental = {
		ghost_text = false,
		native_menu = false,
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, item)
			local source_names = {
				nvim_lsp = "(LSP)",
				emoji = "(Emoji)",
				path = "(Path)",
				calc = "(Calc)",
				vsnip = "(Snippet)",
				luasnip = "(Snippet)",
				buffer = "(Buffer)",
				treesitter = "(TreeSitter)",
			}

			local duplicates = {
				buffer = 1,
				path = 1,
				nvim_lsp = 0,
				luasnip = 1,
			}

			item.menu = source_names[entry.source.name]
			item.dup = duplicates[entry.source.name] or 0

			return item
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				local confirm_opts = {
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				}
				local is_insert_mode = function()
					return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
				end
				if is_insert_mode() then -- prevent overwriting brackets
					confirm_opts.behavior = cmp.ConfirmBehavior.Insert
				end
				if cmp.confirm(confirm_opts) then
					return -- success, exit early
				end
			end
			fallback() -- if not exited early, always fallback
		end),

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{
			name = "nvim_lsp",
			entry_filter = function(entry, ctx)
				local kind = require("cmp.types").lsp.CompletionItemKind[entry:get_kind()]
				if kind == "Snippet" and ctx.prev_context.filetype == "java" then
					return false
				end
				if kind == "Text" then
					return false
				end
				return true
			end,
		},
		{ name = "path" },
		{ name = "luasnip" },
	},
})
