vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('config.options')
require('config.keybinds')
require('config.lazy')

vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 10
vim.g.catppuccin_flavour = "mocha"
vim.cmd.colorscheme("catppuccin")
