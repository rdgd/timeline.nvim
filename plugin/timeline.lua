-- Plugin entry point for timeline.nvim
-- This file is automatically loaded by Neovim

if vim.g.loaded_timeline then
  return
end
vim.g.loaded_timeline = 1

-- Setup the timeline plugin
require('timeline').setup()