vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)
-- Toggle comment for the current line
vim.keymap.set("n", "<C-_>", "gcc", { remap = true })
vim.keymap.set("i", "<C-_>", "<esc>gcci", { remap = true })

-- Toggle comment for the selected block (Visual Mode)
vim.keymap.set("v", "<C-_>", "gc", { remap = true })

-- Save using leader keymap
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")
-- For Git control
vim.keymap.set("n", "<leader>gg", vim.cmd.Git, { desc = "Open Fugitive" })
