return {
    {
        "williamboman/mason.nvim",
        config = true, -- Runs require("mason").setup() automatically
    },
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            -- List the servers you want Mason to automatically download
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "clangd",
                "cssls",
                "jsonls",
                "html",
                "tailwindcss"
            },
        },
    },
}
