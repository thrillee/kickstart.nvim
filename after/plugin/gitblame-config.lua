local blame = require 'thrillee.git-blame'

local group = vim.api.nvim_create_augroup('GitLensBlame', { clear = true })

vim.api.nvim_create_autocmd('CursorHold', {
  group = group,
  callback = blame.blameVirtText,
})

vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  group = group,
  callback = blame.clearBlameVirtText,
})

vim.api.nvim_set_hl(0, 'GitLens', { link = 'Comment' })
