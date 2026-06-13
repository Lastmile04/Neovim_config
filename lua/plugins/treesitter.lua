return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        -- The modern key for managing language parsers
        ensure_installed = {
            "lua", "tsx", "typescript", "javascript",
            "python", "json", "html", "css", "markdown",
            "markdown_inline", "vim", "gitignore", "vimdoc",
            "bash", "sql", "c", "jsx", "yaml", "toml", "regex",
            "query"
        },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
    },
}
