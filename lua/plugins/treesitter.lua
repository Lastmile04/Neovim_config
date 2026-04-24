return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
    
    -- 1. Run the standard setup (highlighting, etc.)
    ts.setup({
      highlight = { enable = true },
      indent = { enable = true },
    })

    -- 2. Manually handle the "ensure_installed" logic
    local languages = {
      "lua", "tsx", "typescript", "javascript", 
      "python", "json", "html", "css", "markdown", "markdown_inline", "vim", "gitignore", "vimdoc"
    }
    
    -- This checks what is missing and installs it
    ts.install(languages)
  end,
}
