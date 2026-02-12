local M = {}
local api = vim.api
local ns = api.nvim_create_namespace 'GitLens'
local current_line = nil -- track the line we've already blamed

function M.blameVirtText()
  local ft = vim.fn.expand '%:h:t'
  if ft == '' or ft == 'bin' then
    return
  end

  local line = api.nvim_win_get_cursor(0)[1]

  -- already showing blame for this line, do nothing
  if line == current_line then
    return
  end

  api.nvim_buf_clear_namespace(0, ns, 0, -1)
  current_line = line

  local currFile = vim.fn.expand '%'
  local blame = vim.fn.system(string.format('git blame -c -L %d,%d %s', line, line, currFile))
  local hash = vim.split(blame, '%s')[1]
  local text

  if hash == '00000000' then
    text = 'Not Committed Yet'
  else
    local cmd = string.format("git show %s --no-patch --format='%%an | %%ar | %%s'", hash)
    text = vim.fn.system(cmd)
    text = vim.split(text, '\n')[1]
    if text:find 'fatal' then
      text = 'Not Committed Yet'
    end
  end

  api.nvim_buf_set_extmark(0, ns, line - 1, 0, {
    virt_text = { { text, 'GitLens' } },
    virt_text_pos = 'eol',
  })
end

function M.clearBlameVirtText()
  local line = api.nvim_win_get_cursor(0)[1]

  -- only clear when we move to a different line
  if line ~= current_line then
    api.nvim_buf_clear_namespace(0, ns, 0, -1)
    current_line = nil
  end
end

return M
