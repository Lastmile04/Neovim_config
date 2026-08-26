-- At the VERY TOP of lsp.lua, add:
vim.g.autoformat_enabled = true

-- Register the command globally right at the start so it's always accessible
vim.api.nvim_create_user_command("ToggleFormat", function()
    vim.g.autoformat_enabled = not vim.g.autoformat_enabled
    print("Autoformat on save: " .. (vim.g.autoformat_enabled and "ENABLED" or "DISABLED"))
end, {})

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        -- Dropdown Menu & Autocomplete Suggestion Logic
        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(), -- Force pop-up suggestions
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp', priority = 1000 },
                { name = 'luasnip',  priority = 750 },
                { name = 'path',     priority = 500 },
                { name = 'buffer',   priority = 250 },
            }),
            window = {
                completion = cmp.config.window.bordered({ border = 'rounded' }),
                documentation = cmp.config.window.bordered({ border = 'rounded' }),
            },
        })

        vim.lsp.config('*', {
            root_markers = { '.git' },
        })

        vim.diagnostic.config({
            virtual_text  = true,
            severity_sort = true,
            float         = { style = 'minimal', border = 'rounded' },
            signs         = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '✘',
                    [vim.diagnostic.severity.WARN]  = '▲',
                    [vim.diagnostic.severity.HINT]  = '⚑',
                    [vim.diagnostic.severity.INFO]  = '»',
                },
            },
        })

        -- Custom Rounded Floating Window Previews for Man Pages/Documentation Documentation
        local orig = vim.lsp.util.open_floating_preview
        ---@diagnostic disable-next-line: duplicate-set-field
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts            = opts or {}
            opts.border     = opts.border or 'rounded'
            opts.max_width  = opts.max_width or 80
            opts.max_height = opts.max_height or 24
            opts.wrap       = opts.wrap ~= false
            return orig(contents, syntax, opts, ...)
        end

        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('my.lsp', {}),
            callback = function(args)
                local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                local buf    = args.buf
                local map    = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = buf }) end

                -- 'K' displays complete inline documentation manuals for functions/modules under cursor
                map('n', 'K', vim.lsp.buf.hover)
                map('n', 'gd', vim.lsp.buf.definition)
                map('n', 'gD', vim.lsp.buf.declaration)
                map('n', 'gi', vim.lsp.buf.implementation)
                map('n', 'gr', vim.lsp.buf.references)
                map('n', 'gl', vim.diagnostic.open_float)
                map('n', '<F2>', vim.lsp.buf.rename)
                map({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end)
                map('n', '<F4>', vim.lsp.buf.code_action)
                map('n', '<leader>t', '<cmd>ToggleFormat<CR>')

                if client:supports_method('textDocument/documentHighlight') then
                    local highlight_augroup = vim.api.nvim_create_augroup('my.lsp.highlight', { clear = false })
                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        buffer = buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })
                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        buffer = buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })
                end

                if not client:supports_method('textDocument/willSaveWaitUntil')
                    and client:supports_method('textDocument/formatting')
                then
                    vim.api.nvim_create_autocmd('BufWritePre', {
                        group = vim.api.nvim_create_augroup('my.lsp.format', { clear = false }),
                        buffer = buf,
                        callback = function()
                            if vim.g.autoformat_enabled then
                                vim.lsp.buf.format({ bufnr = buf, id = client.id, timeout_ms = 1000 })
                            end
                        end,
                    })
                end
            end,
        })

        local caps = vim.lsp.protocol.make_client_capabilities()
        local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        if has_cmp then caps = cmp_nvim_lsp.default_capabilities(caps) end

        -- --- Target Languages Active Environments Matrix ---

        -- Go Configuration
        vim.lsp.config['gopls'] = {
            cmd = { 'gopls' },
            filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
            root_markers = { 'go.mod', 'go.work', '.git' },
            capabilities = caps,
            settings = { gopls = { staticcheck = true, hoverKind = "FullDocumentation" } },
        }

        -- JavaScript / TypeScript Configuration (Node.js/Frontend ecosystem)
        vim.lsp.config['ts_ls'] = {
            cmd = { 'typescript-language-server', '--stdio' },
            filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
            root_markers = { 'package.json', 'tsconfig.json', '.git' },
            capabilities = caps,
        }

        -- Python Configuration
        vim.lsp.config['pyright'] = {
            cmd = { 'pyright-langserver', '--stdio' },
            filetypes = { 'python' },
            root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
            capabilities = caps,
        }

        -- C / C++ Configuration
        vim.lsp.config['clangd'] = {
            cmd = { 'clangd', '--background-index', '--clang-tidy', '--header-insertion=never' },
            filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
            root_markers = { 'compile_commands.json', 'Makefile', '.git' },
            capabilities = caps,
        }

        -- Tailwind CSS Configuration
        vim.lsp.config['tailwindcss'] = {
            cmd = { 'tailwindcss-language-server', '--stdio' },
            filetypes = { 'html', 'css', 'javascriptreact', 'typescriptreact' },
            root_markers = { 'tailwind.config.js', 'tailwind.config.ts', '.git' },
            capabilities = caps,
        }

        -- Markdown Configuration
        vim.lsp.config['marksman'] = {
            cmd = { 'marksman', 'server' },
            filetypes = { 'markdown', 'md' },
            root_markers = { '.marksman.toml', '.git' },
            capabilities = caps,
        }

        -- Lua Configuration
        vim.lsp.config['lua_ls'] = {
            cmd = { 'lua-language-server' },
            filetypes = { 'lua' },
            root_markers = { '.luarc.json', '.git' },
            capabilities = caps,
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    diagnostics = { globals = { 'vim' } },
                    workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file('', true) },
                },
            },
        }

        -- Future Setup: Rust Analyzer (Uncomment when you switch to Rust)
        -- vim.lsp.config['rust_analyzer'] = {
        --     cmd = { 'rust-analyzer' },
        --     filetypes = { 'rust' },
        --     root_markers = { 'Cargo.toml', '.git' },
        --     capabilities = caps,
        -- }

        vim.filetype.add({ extension = { h = 'c', md = 'markdown' } })

        ---@diagnostic disable-next-line: invisible
        for name, _ in pairs(vim.lsp.config._configs) do
            if name ~= '*' then vim.lsp.enable(name) end
        end
    end
}
