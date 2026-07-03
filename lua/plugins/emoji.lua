return {
    "allaman/emoji.nvim",
    -- 1. Remove version = "1.0.0" so lazy grabs the latest stable v6+ release
    dependencies = {
        "hrsh7th/nvim-cmp",
        "nvim-telescope/telescope.nvim",
        "ibhagwan/fzf-lua",
    },
    opts = {
        enable_cmp_integration = true,
        -- If you don't manually clone plugins to a custom directory,
        -- you can completely comment out or remove 'plugin_path'
        -- plugin_path = vim.fn.expand("$HOME/plugins/"),
    },
    config = function(_, opts)
        require("emoji").setup(opts)

        -- 2. Safely load the telescope extension
        require('telescope').load_extension('emoji')

        -- 3. Use the updated v6+ Telescope extension API call
        vim.keymap.set('n', '<leader>se', function()
            require('telescope').extensions.emoji.emoji()
        end, { desc = '[S]earch [E]moji' })
    end,
}
