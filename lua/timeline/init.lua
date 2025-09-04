local M = {}

-- Timeline storage
M.timeline = {}
M.max_entries = 100

-- Check if devicons is available
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
if not has_devicons then
  devicons = nil
end

-- Track visited and edited files separately
local function add_entry(filepath, action_type)
  if not filepath or filepath == '' then
    return
  end

  -- Convert to absolute path
  local abs_path = vim.fn.fnamemodify(filepath, ':p')
  
  -- Don't track special buffers
  if abs_path:match('^%w+://') or abs_path == '' then
    return
  end

  -- Remove existing entries for this file to avoid duplicates
  for i = #M.timeline, 1, -1 do
    if M.timeline[i].file == abs_path then
      table.remove(M.timeline, i)
    end
  end

  -- Add new entry at the beginning (most recent first)
  table.insert(M.timeline, 1, {
    file = abs_path,
    action = action_type,
    timestamp = os.time(),
    display_name = vim.fn.fnamemodify(abs_path, ':~:.')
  })

  -- Keep only the most recent entries
  if #M.timeline > M.max_entries then
    for i = #M.timeline, M.max_entries + 1, -1 do
      table.remove(M.timeline, i)
    end
  end
end

-- Event handlers
local function on_buf_enter()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath and filepath ~= '' then
    add_entry(filepath, 'visited')
  end
end

local function on_buf_write_post()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath and filepath ~= '' then
    add_entry(filepath, 'edited')
  end
end

-- Timeline window management
M.timeline_buf = nil
M.timeline_win = nil

local function create_timeline_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'timeline')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  
  return buf
end

local function get_file_icon_data(filepath)
  if not has_devicons or not devicons then
    return "", ""
  end
  
  local filename = vim.fn.fnamemodify(filepath, ':t')
  local extension = vim.fn.fnamemodify(filepath, ':e')
  
  local icon, highlight = devicons.get_icon(filename, extension, { default = true })
  return icon and icon or "", highlight or ""
end

local function populate_timeline_buffer(buf)
  local lines = {}
  local highlights = {}
  
  if #M.timeline == 0 then
    table.insert(lines, "No files in timeline")
  else
    table.insert(lines, "Timeline (" .. #M.timeline .. " files)")
    table.insert(lines, string.rep("=", 50))
    table.insert(lines, "")
    
    for i, entry in ipairs(M.timeline) do
      local action_symbol = entry.action == 'edited' and '✏️ ' or '👁️ '
      local time_str = os.date("%H:%M:%S", entry.timestamp)
      local file_icon, icon_highlight = get_file_icon_data(entry.file)
      
      local line = string.format("%s[%s] %s%s%s", 
        action_symbol, 
        time_str, 
        file_icon, 
        file_icon ~= "" and " " or "",
        entry.display_name
      )
      table.insert(lines, line)
      
      -- Store highlight info for the icon if we have one
      if file_icon ~= "" and icon_highlight ~= "" then
        local line_num = #lines - 1  -- 0-indexed
        local icon_start = string.len(action_symbol .. "[" .. time_str .. "] ")
        table.insert(highlights, {
          line = line_num,
          col_start = icon_start,
          col_end = icon_start + vim.fn.strdisplaywidth(file_icon),
          highlight = icon_highlight
        })
      end
    end
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  
  -- Apply icon highlights
  local ns_id = vim.api.nvim_create_namespace('timeline_icons')
  vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
  
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns_id, hl.highlight, hl.line, hl.col_start, hl.col_end)
  end
end

local function setup_timeline_keymaps(buf)
  local opts = { buffer = buf, noremap = true, silent = true }
  
  -- Enter to open file
  vim.keymap.set('n', '<CR>', function()
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    local entry_index = line_num - 3  -- Account for header lines
    
    if entry_index > 0 and entry_index <= #M.timeline then
      local entry = M.timeline[entry_index]
      -- Close timeline window
      if M.timeline_win and vim.api.nvim_win_is_valid(M.timeline_win) then
        vim.api.nvim_win_close(M.timeline_win, false)
      end
      -- Open the file
      vim.cmd('edit ' .. vim.fn.fnameescape(entry.file))
    end
  end, opts)
  
  -- q to close
  vim.keymap.set('n', 'q', function()
    if M.timeline_win and vim.api.nvim_win_is_valid(M.timeline_win) then
      vim.api.nvim_win_close(M.timeline_win, false)
    end
  end, opts)
  
  -- r to refresh
  vim.keymap.set('n', 'r', function()
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    populate_timeline_buffer(buf)
  end, opts)
end

function M.show_timeline()
  -- Close existing timeline if open
  if M.timeline_win and vim.api.nvim_win_is_valid(M.timeline_win) then
    vim.api.nvim_win_close(M.timeline_win, false)
    return
  end

  -- Create buffer
  M.timeline_buf = create_timeline_buffer()
  populate_timeline_buffer(M.timeline_buf)
  
  -- Calculate window dimensions
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.7)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  -- Open floating window
  M.timeline_win = vim.api.nvim_open_win(M.timeline_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'rounded',
    title = ' Timeline ',
    title_pos = 'center'
  })
  
  -- Set window options
  vim.api.nvim_win_set_option(M.timeline_win, 'wrap', false)
  vim.api.nvim_win_set_option(M.timeline_win, 'cursorline', true)
  
  -- Position cursor on first file entry
  if #M.timeline > 0 then
    vim.api.nvim_win_set_cursor(M.timeline_win, {4, 0})
  end
  
  -- Setup keymaps
  setup_timeline_keymaps(M.timeline_buf)
end

function M.clear_timeline()
  M.timeline = {}
  print("Timeline cleared")
  
  -- Refresh timeline window if open
  if M.timeline_buf and vim.api.nvim_buf_is_valid(M.timeline_buf) then
    vim.api.nvim_buf_set_option(M.timeline_buf, 'modifiable', true)
    populate_timeline_buffer(M.timeline_buf)
  end
end

function M.setup()
  -- Create autocommand group
  local group = vim.api.nvim_create_augroup('Timeline', { clear = true })
  
  -- Track buffer visits
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = on_buf_enter,
    desc = 'Track visited files in timeline'
  })
  
  -- Track file edits
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    callback = on_buf_write_post,
    desc = 'Track edited files in timeline'
  })
  
  -- Create commands
  vim.api.nvim_create_user_command('TimelineShow', M.show_timeline, {
    desc = 'Show timeline window'
  })
  
  vim.api.nvim_create_user_command('TimelineClear', M.clear_timeline, {
    desc = 'Clear timeline history'
  })
  
  -- Add keymaps
  vim.keymap.set('n', '<leader>t', M.show_timeline, { desc = 'Show Timeline' })
end

return M