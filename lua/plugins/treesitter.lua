return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        ensure_installed = {
            "lua", "tsx", "typescript", "javascript",
            "python", "json", "html", "css", "markdown",
            "markdown_inline", "vim", "gitignore", "vimdoc",
            "bash", "sql", "c", "jsx", "yaml", "toml", "regex",
            "query", "go", "gomod", "gowork" },
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
    },
}
