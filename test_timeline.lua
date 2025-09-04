#!/usr/bin/env lua

-- Simple test to verify the plugin structure
print("Testing timeline.nvim plugin...")

-- Test that the main module can be loaded
local ok, timeline = pcall(require, 'timeline')
if ok then
  print("✓ Timeline module loaded successfully")
  
  -- Test that setup function exists
  if type(timeline.setup) == 'function' then
    print("✓ Setup function exists")
  else
    print("✗ Setup function missing")
  end
  
  -- Test that show_timeline function exists
  if type(timeline.show_timeline) == 'function' then
    print("✓ show_timeline function exists")
  else
    print("✗ show_timeline function missing")
  end
  
  -- Test that clear_timeline function exists
  if type(timeline.clear_timeline) == 'function' then
    print("✓ clear_timeline function exists")
  else
    print("✗ clear_timeline function missing")
  end
  
else
  print("✗ Failed to load timeline module: " .. tostring(timeline))
end

print("Test complete!")