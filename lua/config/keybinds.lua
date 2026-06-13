vim.g.mapleader = " "

vim.keymap.set("n", "<leader>cd", function()
    require("neo-tree.command").execute({
        toggle = true,
        dir = vim.loop.cwd(),
    })
end, { desc = "Open Neo-tree in cwd" })

-- Toggle comment for the current line
vim.keymap.set("n", "<C-_>", "gcc", { remap = true })
vim.keymap.set("i", "<C-_>", "<esc>gcci", { remap = true })

-- Toggle comment for the selected block (Visual Mode)
vim.keymap.set("v", "<C-_>", "gc", { remap = true })

-- Save using leader keymap
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")
-- For Git control
vim.keymap.set("n", "<leader>gg", vim.cmd.Git, { desc = "Open Fugitive" })

vim.keymap.set("n", "<leader>cr", function()
    require("neo-tree.command").execute({ reveal = true })
end)

vim.keymap.set("n", "<leader>i", "mzgg=G`z", { desc = "Auto indent file (keep cursor)" })

vim.keymap.set({ "n", "v" }, "p", '"+p', { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "P", '"+P', { noremap = true, silent = true })

vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })
