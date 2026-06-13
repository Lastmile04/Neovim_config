-- lua/plugins/harpoon.lua
return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2", -- REQUIRED for the harpoon:list() syntax you're using
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        -- --- Basic Keymaps ---
        -- Add current file to Harpoon list
        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
        -- Toggle the text UI menu
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        -- Quick navigation through your list
        vim.keymap.set("n", "<C-p>", function() harpoon:list():prev() end)
        vim.keymap.set("n", "<C-n>", function() harpoon:list():next() end)

        -- --- Telescope Integration ---
        -- This creates a fancy Ivy-style menu for your Harpoon files
        vim.keymap.set("n", "<leader>fl", function()
            local conf = require("telescope.config").values
            local themes = require("telescope.themes")
            local file_paths = {}

            for _, item in ipairs(harpoon:list().items) do
                table.insert(file_paths, item.value)
            end

            require("telescope.pickers").new(themes.get_ivy({ prompt_title = "Working List" }), {
                finder = require("telescope.finders").new_table({ results = file_paths }),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
            }):find()
        end)
    end,
}
