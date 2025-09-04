# Timeline.nvim

A Neovim plugin that tracks your file editing timeline, distinguishing between visited and edited files.

## Features

- 📁 Track visited files (when you open/navigate to them)
- ✏️ Track edited files (when you save changes)
- 🕒 Chronological timeline with timestamps
- 🎨 File type icons with colors (via nvim-web-devicons)
- 🎯 Jump to any file by pressing Enter in the timeline
- 🧹 Auto-cleanup: keeps only the most recent 100 entries
- 🔄 Manual timeline clearing

## Usage

### Commands

- `:TimelineShow` - Show the timeline window
- `:TimelineClear` - Clear the timeline history

### Default Keymaps

- `<leader>t` - Show timeline window

### Timeline Window Keymaps

- `<CR>` (Enter) - Open the file under cursor
- `q` - Close timeline window
- `r` - Refresh timeline display

## Timeline Display

The timeline shows:
- 👁️ Files you've visited (opened/navigated to)
- ✏️ Files you've edited (saved changes to)
- 🎨 File type icons with appropriate colors
- Timestamps for each action
- Relative file paths

Most recent actions appear at the top.

## Installation

### Using lazy.nvim

Add to your plugins configuration:

```lua
{
  dir = "~/timeline-nvim",
  name = "timeline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
```

## Configuration

The plugin works out of the box with sensible defaults. The timeline automatically:
- Tracks file visits and edits
- Maintains a maximum of 100 entries
- Ignores special buffers and temporary files
- Shows the most recent activity first

No additional configuration is required.