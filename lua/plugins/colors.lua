return {
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000, -- Load this before everything else
        config = function()
            require("tokyonight").setup({
                style = "moon",     -- Choose: storm, moon, night, or day
                transparent = true, -- Native transparency handles it cleanly

                -- CRITICAL FIX: Disables LSP semantic tokens forcing the theme
                -- to look broken and mismatched like in your screenshot.
                disable_semantic_tokens = true,

                styles = {
                    sidebars = "transparent",
                    floats = "transparent",
                },
            })

            -- Apply the theme cleanly
            vim.cmd.colorscheme "tokyonight"
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            theme = 'tokyonight',
        }
    }
}
