local M = {}
local api = vim.api

function M.blameVirtText()
  local ft = vim.fn.expand '%:h:t'
  if ft == '' or ft == 'bin' then
    return
  end

  api.nvim_buf_clear_namespace(0, 2, 0, -1)

  local currFile = vim.fn.expand '%'
  local line = api.nvim_win_get_cursor(0)
  local blame = vim.fn.system(string.format('git blame -c -L %d,%d %s', line[1], line[1], currFile))
  local hash = vim.split(blame, '%s')[1]
  local text

  if hash == '00000000' then
    text = 'Not Committed Yet'
  else
    local cmd = string.format("git show %s --format='%%an | %%ar | %%s'", hash)
    text = vim.fn.system(cmd)
    text = vim.split(text, '\n')[1]
    if text:find 'fatal' then
      text = 'Not Committed Yet'
    end
  end

  -- nvim_buf_set_virtual_text is deprecated; use nvim_buf_set_extmark
  api.nvim_buf_set_extmark(0, api.nvim_create_namespace 'GitLens', line[1] - 1, 0, {
    virt_text = { { text, 'GitLens' } },
    virt_text_pos = 'eol',
  })
end

function M.clearBlameVirtText()
  api.nvim_buf_clear_namespace(0, api.nvim_create_namespace 'GitLens', 0, -1)
end

return M
