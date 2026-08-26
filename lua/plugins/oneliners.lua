return {
    { -- This helps with ssh tunneling and copying to clipboard
        'ojroques/vim-oscyank',
    },
    { -- Git plugin
        'tpope/vim-fugitive',
    },
    { -- Show CSS Colors
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require('nvim-highlight-colors').setup({})
        end
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            vim.cmd("colorscheme rose-pine")
        end
    },
    {
        "3rd/image.nvim",
        build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
        opts = {
            processor = "magick_cli",
        }
    },
    {
        "folke/zen-mode.nvim",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },
    { 'wakatime/vim-wakatime', lazy = false },
    {
        "fredrikaverpil/godoc.nvim",
        version = "*",
        dependencies = {
            { "nvim-telescope/telescope.nvim" },                           -- optional
            { "folke/snacks.nvim" },                                       -- optional
            { "echasnovski/mini.pick" },                                   -- optional
            { "ibhagwan/fzf-lua" },                                        -- optional
        },
        build = "go install github.com/lotusirous/gostdsym/stdsym@latest", -- optional
    }
}
