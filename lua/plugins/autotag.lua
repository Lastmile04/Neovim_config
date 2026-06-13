return {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    -- As noted in the plugin's README, lazy loading isn't strictly necessary,
    -- but if you want to, these events work best:
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("nvim-ts-autotag").setup({
            opts = {
                -- Defaults
                enable_close = true,           -- Auto close tags
                enable_rename = true,          -- Auto rename pairs of tags
                enable_close_on_slash = false, -- Auto close on trailing </
            },
        })
    end,
}
