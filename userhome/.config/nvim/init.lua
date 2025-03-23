-- General vim config
vim.cmd([[
let g:clipboard = {
	    \   'name': 'WslClipboard',
	    \   'copy': {
	    \      '+': 'pbcopy',
	    \      '*': 'pbcopy',
	    \    },
	    \   'paste': {
	    \      '+': 'pbpaste',
	    \      '*': 'pbpaste',
	    \   },
	    \   'cache_enabled': 0,
	    \ }

" YAML
au FileType yaml setl shiftwidth=2
au FileType yaml setl tabstop=2

" GoLang
au FileType go set noexpandtab

filetype plugin indent on
]])

vim.opt.path:append("**")
vim.opt.wildmenu = true
vim.opt.swapfile = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.list = true
vim.opt.listchars = { tab = ">-", trail = "-"}
vim.opt.nu = true


-- Bootstrap Packer
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- My plugins here
  use "neovim/nvim-lspconfig"
  use "scrooloose/nerdcommenter"
  use "nvim-lua/plenary.nvim"
  use "ckipp01/nvim-jenkinsfile-linter"
  use "martinda/Jenkinsfile-vim-syntax"
  use "rebelot/kanagawa.nvim"
  use { 'mfussenegger/nvim-dap', requires = {"rcarriga/nvim-dap-ui"} }
  use 'leoluz/nvim-dap-go'
  use 'mfussenegger/nvim-dap-python'
  use 'nvim-neotest/nvim-nio'
  use 'preservim/nerdtree'
  use 'github/copilot.vim'
  use {
      'wincent/command-t',
      run = 'cd lua/wincent/commandt/lib && make',
      setup = function ()
        vim.g.CommandTPreferredImplementation = 'lua'
      end,
      config = function()
        require('wincent.commandt').setup({
          -- Customizations go here.
        })
      end,
  }
  use {
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)


vim.cmd("colorscheme kanagawa")


-- General LSP config
vim.lsp.set_log_level 'trace'
if vim.fn.has 'nvim-0.5.1' == 1 then
require('vim.lsp.log').set_format_func(vim.inspect)
end
local nvim_lsp = require 'lspconfig'
local on_attach = function(_, bufnr)
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

end

-- Mappings.
local opts = { buffer = bufnr, noremap = true, silent = true }
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, opts)
vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
vim.keymap.set('n', '<F2>', "<cmd>NERDTreeToggle<cr>", opts)
vim.keymap.set('n', '<F3>', '<Plug>(CommandT)')


local lspconfig = require('lspconfig')
local configs = require 'lspconfig.configs'

-- Golang language server
lspconfig.gopls.setup{
    on_attach = on_attach,
    settings = {
        gopls = {
            experimentalPostfixCompletions = true,
            analyses = {
                unusedparams = true,
                shadow = true,
            },
            staticcheck = true,
        },
    },
    init_options = {
        usePlaceholders = true,
    }
}

lspconfig.ruff.setup {
    on_attach = on_attach,
    init_options = {
        settings = {
            args = {},
        }
    }
}

-- Python language server
lspconfig.pylsp.setup{
    settings  = {
        pylsp = { plugins = { pyflakes = {enabled = false}, flake8 = {enabled = false}, pycodestyle = {enabled = false}, pylint = {enabled = true}}}

    }
}
lspconfig.pylsp.setup = {
    on_attach = on_attach
}

-- Rust analyzer
lspconfig.rust_analyzer.setup{
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false;
      }
    }
  }
}

-- Debugger (DAP) config
require("dap-python").setup("python")
require('dap-go').setup()
local dap, dapui =require("dap"),require("dapui")
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"]=function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"]=function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"]=function()
  dapui.close()
end

--vim.fn.sign_define('DapBreakpoint',{ text ='🟥', texthl ='', linehl ='', numhl =''})
--vim.fn.sign_define('DapStopped',{ text ='▶️', texthl ='', linehl ='', numhl =''})

vim.keymap.set('n', '<F5>', require 'dap'.continue)
vim.keymap.set('n', '<F10>', require 'dap'.step_over)
vim.keymap.set('n', '<F11>', require 'dap'.step_into)
vim.keymap.set('n', '<F12>', require 'dap'.step_out)
vim.keymap.set('n', '<leader>b', require 'dap'.toggle_breakpoint)
