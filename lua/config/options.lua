-- lua/config/options.lua

local opt = vim.opt

-- --- UI / Visuals ---
opt.number = true
opt.relativenumber = true -- FIX: Removed the underscore
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 10


-- --- Tabs & Indentation ---
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = false
opt.autoindent = true

-- --- Search ---
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false

-- --- General Behavior ---
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.updatetime = 250
opt.splitright = true
opt.splitbelow = true


-- Add this to your options.lua or an autocmd file
vim.api.nvim_create_autocmd("FocusLost", {
    pattern = "*",
    command = "silent! wa"
})
