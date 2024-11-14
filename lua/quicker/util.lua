local M = {}

---@param bufnr integer
---@return nil|integer
function M.buf_find_win(bufnr)
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == bufnr then
      return winid
    end
  end
end

---@param winid nil|integer
---@return nil|"c"|"l"
M.get_win_type = function(winid)
  if not winid or winid == 0 then
    winid = vim.api.nvim_get_current_win()
  end
  local info = vim.fn.getwininfo(winid)[1]
  if info.quickfix == 0 then
    return nil
  elseif info.loclist == 0 then
    return "c"
  else
    return "l"
  end
end

---@param item QuickFixItem
---@return QuickFixUserData
M.get_user_data = function(item)
  if type(item.user_data) == "table" then
    return item.user_data
  else
    return {}
  end
end

---Get valid location extmarks for a line in the quickfix
---@param bufnr integer
---@param lnum integer
---@param line_len? integer how long this particular line is
---@param ns? integer namespace of extmarks
---@return table[] extmarks
M.get_lnum_extmarks = function(bufnr, lnum, line_len, ns)
  if not ns then
    ns = vim.api.nvim_create_namespace("quicker_locations")
  end
  if not line_len then
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]
    line_len = line:len()
  end
  local extmarks = vim.api.nvim_buf_get_extmarks(
    bufnr,
    ns,
    { lnum - 1, 0 },
    { lnum - 1, line_len },
    { details = true }
  )
  return vim.tbl_filter(function(mark)
    return not mark[4].invalid
  end, extmarks)
end

return M
