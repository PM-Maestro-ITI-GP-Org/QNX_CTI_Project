-- :Q acts like :q!
vim.api.nvim_create_user_command('Q', 'q!', {})
