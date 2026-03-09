-- Include configuration changes
require("set")
require("remap")

-- Set colorscheme
vim.o.background = "dark"
vim.cmd([[colorscheme habamax]])

-- Enable lsp
vim.lsp.enable({"clangd"})
vim.lsp.enable({"pylsp"})
vim.lsp.enable({"cmake"})

-- Set desired completion options
vim.cmd('set completeopt=fuzzy,menuone,popup,noselect')
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

local augroup = vim.api.nvim_create_augroup
local Defaultgp = augroup('Defaultgp', {})
local autocmd = vim.api.nvim_create_autocmd

-- Set up LSP autocomplete and autoquery
autocmd('LspAttach', {
    group = Defaultgp,
    callback = function(e)
        local client = assert(vim.lsp.get_client_by_id(e.data.client_id))
        local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
        -- Query lsp on each keypress
        -- Ctrl -Y to confirm selection
        client.server_capabilities.completionProvider.triggerCharacters = chars
        vim.lsp.completion.enable(true, client.id, e.buf, {
          autotrigger = true,
          convert = function(item)
            return { abbr = item.label:gsub('%b()', '') }
          end,
        })

        local opts = { buffer = e.buf }
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts) -- Fully view diagnostic
    end
})
