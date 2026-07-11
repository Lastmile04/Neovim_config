-- At the VERY TOP of lsp.lua, add:
vim.g.autoformat_enabled = true

-- Register the command globally right at the start so it's always accessible
vim.api.nvim_create_user_command("ToggleFormat", function()
    vim.g.autoformat_enabled = not vim.g.autoformat_enabled
    print("Autoformat on save: " .. (vim.g.autoformat_enabled and "ENABLED" or "DISABLED"))
end, {})

return {
    -- Core Neovim LSP Client Configurations
    "neovim/nvim-lspconfig",
    dependencies = {
        -- Autocompletion Engine Core Framework
        "hrsh7th/nvim-cmp",
        -- LSP Source Provider for nvim-cmp
        "hrsh7th/cmp-nvim-lsp",
        -- Buffer word completions provider
        "hrsh7th/cmp-buffer",
        -- Filesystem paths autocomplete provider
        "hrsh7th/cmp-path",
        -- Snippet Engine configuration
        "L3MON4D3/LuaSnip",
        -- Snippet expansion bridge for nvim-cmp
        "saadparwaiz1/cmp_luasnip",
    },
    config = function()
        -- 1. NEOCMP COMPLETE ENGINE CONFIGURATION (Dropdowns & Manual Pages/Docs Display)
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),            -- Force pop up completion menu manually
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm selected item
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
                completion = cmp.config.window.bordered({
                    border = 'rounded',
                    winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
                }),
                documentation = cmp.config.window.bordered({
                    border = 'rounded',
                    winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,Search:None',
                }),
            },
            experimental = {
                ghost_text = true, -- Shows inline predictive hints matching selection
            }
        })

        -- 2. LSP GLOBAL HOOKS & DIAGNOSTICS CONFIGURATION
        vim.lsp.config('*', {
            root_markers = { '.git' },
        })

        vim.diagnostic.config({
            virtual_text  = true,
            severity_sort = true,
            float         = {
                style  = 'minimal',
                border = 'rounded',
                source = 'if_many',
                header = '',
                prefix = '',
            },
            signs         = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '✘',
                    [vim.diagnostic.severity.WARN]  = '▲',
                    [vim.diagnostic.severity.HINT]  = '⚑',
                    [vim.diagnostic.severity.INFO]  = '»',
                },
            },
        })

        -- Floating windows documentation formatting overrider
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

        -- 3. INTERACTIVE ATTACH EXTENSION MAPPINGS
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('my.lsp', {}),
            callback = function(args)
                local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                local buf    = args.buf
                local map    = function(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = buf }) end

                -- Trigger Built-in Man-page definitions/hover references via 'K'
                map('n', 'K', vim.lsp.buf.hover)
                map('n', 'gd', vim.lsp.buf.definition)
                map('n', 'gD', vim.lsp.buf.declaration)
                map('n', 'gi', vim.lsp.buf.implementation)
                map('n', 'go', vim.lsp.buf.type_definition)
                map('n', 'gr', vim.lsp.buf.references)
                map('n', 'gs', vim.lsp.buf.signature_help)
                map('n', 'gl', vim.diagnostic.open_float)
                map('n', '<F2>', vim.lsp.buf.rename)
                map({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end)
                map('n', '<F4>', vim.lsp.buf.code_action)
                map('n', '<leader>t', '<cmd>ToggleFormat<CR>')

                -- Buffer references highlight loop
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

                -- Autoformat Pipeline Execution Control (excluding heavy formatters if needed)
                local excluded_filetypes = { php = true }
                if not client:supports_method('textDocument/willSaveWaitUntil')
                    and client:supports_method('textDocument/formatting')
                    and not excluded_filetypes[vim.bo[buf].filetype]
                then
                    vim.api.nvim_create_autocmd('BufWritePre', {
                        group = vim.api.nvim_create_augroup('my.lsp.format', { clear = false }),
                        buffer = buf,
                        callback = function()
                            if vim.g.autoformat_enabled then
                                vim.lsp.buf.format({ bufnr = buf, id = client.id, timeout_ms = 2000 })
                            end
                        end,
                    })
                end
            end,
        })

        -- Extract capabilities matching cmp engine defaults
        local caps = vim.lsp.protocol.make_client_capabilities()
        local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        if has_cmp then
            caps = cmp_nvim_lsp.default_capabilities(caps)
        end

        -- 4. LANGUAGE SERVER DECLARATIONS MATRIX

        -- Go Server
        vim.lsp.config['gopls'] = {
            cmd = { 'gopls' },
            filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
            root_markers = { 'go.mod', 'go.work', '.git' },
            capabilities = caps,
            settings = {
                gopls = {
                    analyses = { unusedparams = false, ST1003 = false, ST1000 = false },
                    staticcheck = true,
                    hoverKind = "FullDocumentation", -- Returns detailed markdown manuals on hover
                },
            },
        }

        -- JavaScript / TypeScript Server
        vim.lsp.config['ts_ls'] = {
            cmd = { 'typescript-language-server', '--stdio' },
            filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
            root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
            capabilities = caps,
            settings = { completions = { completeFunctionCalls = true } },
        }

        -- Rust Analyzer
        vim.lsp.config['rust_analyzer'] = {
            cmd = { 'rust-analyzer' },
            filetypes = { 'rust' },
            root_markers = { 'Cargo.toml', '.git' },
            capabilities = caps,
            settings = {
                ['rust-analyzer'] = {
                    cargo = { allFeatures = true },
                    checkOnSave = { command = "clippy" },
                    hover = { documentation = { enable = true } }
                },
            },
        }

        -- C / C++ via Clangd
        vim.lsp.config['clangd'] = {
            cmd = {
                'clangd',
                '--background-index',
                '--clang-tidy',
                '--header-insertion=never',
                '--completion-style=detailed',
            },
            filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
            root_markers = { 'compile_commands.json', '.clangd', 'Makefile', '.git' },
            capabilities = caps,
        }

        -- Tailwind CSS Server
        vim.lsp.config['tailwindcss'] = {
            cmd = { 'tailwindcss-language-server', '--stdio' },
            filetypes = { 'html', 'css', 'javascriptreact', 'typescriptreact', 'vue', 'svelte' },
            root_markers = { 'tailwind.config.js', 'tailwind.config.ts', 'postcss.config.js', '.git' },
            capabilities = caps,
        }

        -- Lua Server
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

        -- Markdown / Marksman Configuration (Deep Reference Mapping Engine)
        vim.lsp.config['marksman'] = {
            cmd = { 'marksman', 'server' },
            filetypes = { 'markdown', 'md' },
            root_markers = { '.marksman.toml', '.git' },
            capabilities = caps,
        }

        -- Java Configuration Engine
        vim.lsp.config['jdtls'] = {
            cmd = { 'jdtls' },
            filetypes = { 'java' },
            root_markers = { 'pom.xml', 'gradle.build', '.git' },
            capabilities = caps,
        }

        -- JSON Language Server
        vim.lsp.config['jsonls'] = {
            cmd = { 'vscode-json-languageserver', '--stdio' },
            filetypes = { 'json', 'jsonc' },
            root_markers = { 'package.json', '.git' },
            capabilities = caps,
        }

        -- Zig Compiler Server
        vim.lsp.config['zls'] = {
            cmd = { 'zls' },
            filetypes = { 'zig', 'zir' },
            root_markers = { 'build.zig', 'zls.json', '.git' },
            capabilities = caps,
        }

        -- Add structural mappings matching extended targets
        vim.filetype.add({
            extension = {
                h = 'c',
                templ = 'templ',
                md = 'markdown'
            },
        })

        -- Dynamically boot all active configurations loop
        ---@diagnostic disable-next-line: invisible
        for name, _ in pairs(vim.lsp.config._configs) do
            if name ~= '*' then
                vim.lsp.enable(name)
            end
        end
    end
}
