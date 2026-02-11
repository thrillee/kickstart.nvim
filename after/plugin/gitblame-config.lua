local blame = require 'thrillee.git-blame'

vim.api.nvim_create_autocmd('CursorHold', {
  callback = blame.blameVirtText,
})

vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  callback = blame.clearBlameVirtText,
})

vim.api.nvim_set_hl(0, 'GitLens', { link = 'Comment' })
