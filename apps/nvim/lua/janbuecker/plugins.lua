-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	is_bootstrap = true
	vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
	vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
	-- Package manager
	use 'wbthomason/packer.nvim'

	use { -- LSP Configuration & Plugins
		'neovim/nvim-lspconfig',
		requires = {
			-- Automatically install LSPs to stdpath for neovim
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',

			'j-hui/fidget.nvim', -- useful status updates for LSP
			'jose-elias-alvarez/null-ls.nvim', -- linters and formatters
		},
	}

	use { -- Autocompletion
		'hrsh7th/nvim-cmp',
		requires = {
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-path',
			'L3MON4D3/LuaSnip',
			'saadparwaiz1/cmp_luasnip',
		},
	}

	use { -- Highlight, edit, and navigate code
		'nvim-treesitter/nvim-treesitter',
		run = function()
			pcall(require('nvim-treesitter.install').update { with_sync = true })
		end,
		requires = {
			"nvim-treesitter/nvim-treesitter-context", -- see func context on top
			'nvim-treesitter/nvim-treesitter-textobjects', -- additional text objects
			{ 'JoosepAlviste/nvim-ts-context-commentstring', event = "BufReadPost", }, -- better commenting

		}
	}

	-- Git related plugins
	use 'lewis6991/gitsigns.nvim'
	use 'kdheepak/lazygit.nvim' -- shortcut to open lazygit
	use "f-person/git-blame.nvim" -- inline blame

	use 'nvim-lualine/lualine.nvim' -- Fancier statusline
	use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
	use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
	use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically


	use { -- Fuzzy Finder (files, lsp, etc)
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		requires = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }
		}
	}

	use { -- testing
		'vim-test/vim-test',
		requires = {
			"nvim-lua/plenary.nvim", -- required dependency
			"andythigpen/nvim-coverage", -- viewing test coverage in signcolumn
		}
	}

	-- remember cursor position in files
	use "farmergreg/vim-lastplace"

	-- case-preserving search/replace
	use "tpope/vim-abolish"

	-- twig file support
	use "nelsyeung/twig.vim"

	-- Colorscheme
	use "rebelot/kanagawa.nvim"

	-- project manager
	use 'ahmedkhalf/project.nvim'

	-- well known JSON schema files for auto completion
	use "b0o/schemastore.nvim"

	-- highlight word under cursor
	use 'RRethy/vim-illuminate'

	-- file tree
	use 'nvim-tree/nvim-tree.lua'

	-- auto parenthesis, brackets
	use 'windwp/nvim-autopairs'


	if is_bootstrap then
		require('packer').sync()
	end
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
	print '=================================='
	print '    Plugins are being installed'
	print '    Wait until Packer completes,'
	print '       then restart nvim'
	print '=================================='
	return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
	command = 'source <afile> | PackerCompile',
	group = packer_group,
	pattern = vim.fn.expand '$MYVIMRC',
})
