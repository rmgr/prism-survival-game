# Debugging Guide for Love2D/Prism

## Quick Start

### Console Output
Run the game from terminal to see debug output:
```bash
love .
```

### Simple Debugging
```lua
-- Basic printing
print("Debug message:", value)

-- Using the built-in logger (recommended)
prism.logger.debug("Player moved to", x, y)
prism.logger.info("Level loaded successfully")
prism.logger.warn("Low health!")
prism.logger.error("Something went wrong!")
```

## Debugging Options Ranked by Ease of Use

### 1. Built-in Logger (Easiest, Already Set Up)
The prism logger is configured and ready to use.

**Configuration (in main.lua):**
```lua
prism.logger.level = "debug"      -- Show debug and higher
prism.logger.outFile = "game.log" -- Optional: log to file
prism.logger.useColor = true      -- Color-coded output
```

**Log Levels (from most to least verbose):**
- `trace` - Very detailed information
- `debug` - Debug information
- `info` - General information (default)
- `warn` - Warnings
- `error` - Errors only

**Output Format:**
```
[DEBUG 14:32:45] modules/game/actors/player.lua:42: Player position: 10 5
```

**Location:** `prism/engine/lib/log.lua`

### 2. Neovim with nvim-dap (Best for Breakpoint Debugging)
Use DAP (Debug Adapter Protocol) with the lldebugger already configured in this project.

**Required Neovim Plugins:**
```lua
-- Using lazy.nvim
{
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',              -- Visual debug UI
    'theHamsta/nvim-dap-virtual-text',   -- Inline variable values
  },
}
```

**DAP Configuration (~/.config/nvim/lua/config/dap.lua):**
```lua
local dap = require('dap')

-- Adapter configuration
dap.adapters['lua-local'] = {
  type = 'executable',
  command = 'love',
  args = {'.'},
  env = {
    LOCAL_LUA_DEBUGGER_VSCODE = '1'
  }
}

-- Launch configuration
dap.configurations.lua = {
  {
    type = 'lua-local',
    request = 'launch',
    name = 'Love2D Debug',
  }
}

-- Optional keybindings
vim.keymap.set('n', '<F5>', dap.continue)
vim.keymap.set('n', '<F10>', dap.step_over)
vim.keymap.set('n', '<F11>', dap.step_into)
vim.keymap.set('n', '<F12>', dap.step_out)
vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint)
```

**Usage:**
1. Set breakpoints: `<leader>b` or `:lua require('dap').toggle_breakpoint()`
2. Start debugging: `<F5>` or `:lua require('dap').continue()`
3. Step through code with F10/F11/F12
4. Inspect variables in DAP UI

### 3. VSCode with lldebugger (Alternative)
If you prefer VSCode:

**Steps:**
1. Install "Local Lua Debugger" extension
2. Set environment variable:
   ```bash
   LOCAL_LUA_DEBUGGER_VSCODE=1 love .
   ```
3. Set breakpoints and attach debugger

**Already configured in:** `debugger.lua:1`

### 4. MobDebug (Remote Debugging)
For debugging over network or more complex setups.

**Installation:**
```bash
luarocks install mobdebug
```

**Usage:**
```lua
local mobdebug = require('mobdebug')
mobdebug.start()  -- Connect to debug server
mobdebug.pause()  -- Breakpoint
```

## Debugging Techniques

### Print Debugging
```lua
-- Simple values
print("x:", x, "y:", y)

-- Tables
function printTable(t, indent)
  indent = indent or 0
  for k, v in pairs(t) do
    if type(v) == "table" then
      print(string.rep("  ", indent) .. k .. ":")
      printTable(v, indent + 1)
    else
      print(string.rep("  ", indent) .. k .. ": " .. tostring(v))
    end
  end
end
```

### Conditional Breakpoints
```lua
-- Only pause when condition is met
if player.health < 10 then
  prism.logger.warn("Low health detected!")
  -- Set breakpoint here in your debugger
end
```

### Performance Profiling
```lua
-- Time a function
local start = love.timer.getTime()
myExpensiveFunction()
local duration = love.timer.getTime() - start
prism.logger.debug("Function took", duration, "seconds")
```

### Debug Drawing
```lua
-- In your draw function
if DEBUG_MODE then
  love.graphics.setColor(1, 0, 0)
  love.graphics.circle("line", player.x, player.y, 10)
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
end
```

## Recommended Debugging Workflow

### For Quick Bugs
1. Add `prism.logger.debug()` statements
2. Run `love .` from terminal
3. Check output

### For Complex Issues
1. Set up nvim-dap (one-time setup)
2. Set breakpoints in Neovim
3. Launch with `<F5>`
4. Step through code and inspect variables

### For Game State Issues
1. Add debug overlay showing game state
2. Use logger to track state changes
3. Dump problematic objects with printTable()

## Love2D Specific Debugging

### Check for Common Issues
```lua
-- Image loading
local img = love.graphics.newImage("path.png")
if not img then
  prism.logger.error("Failed to load image!")
end

-- Audio issues
love.audio.setVolume(1.0)
prism.logger.debug("Audio volume:", love.audio.getVolume())

-- FPS monitoring
prism.logger.debug("FPS:", love.timer.getFPS())
prism.logger.debug("Delta time:", dt)
```

### Debug Console/Overlay
Create a debug overlay to see game state in real-time:
```lua
-- In your draw function
function love.draw()
  -- Your normal drawing

  -- Debug overlay
  if DEBUG_MODE then
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 300, 200)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Memory: " .. collectgarbage("count") .. " KB", 10, 30)
    -- Add your game state here
  end
end
```

## Reading Material

### Lua Debugging
- [Lua Debug Library](https://www.lua.org/manual/5.1/manual.html#5.9) - Official Lua debug documentation
- [Programming in Lua - Debug Library](https://www.lua.org/pil/23.html) - Chapter on debugging

### Love2D Specific
- [Love2D Wiki - Debugging](https://love2d.org/wiki/Debugging) - Official debugging guide
- [Love2D Console](https://github.com/love2d-community/love-console) - In-game console
- [LÖVE Frames](https://github.com/Nikolai-Shkonda/LoveFrames) - GUI for debug displays

### Neovim DAP
- [nvim-dap Documentation](https://github.com/mfussenegger/nvim-dap) - Main DAP plugin
- [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) - Visual debug interface
- [DAP Getting Started](https://github.com/mfussenegger/nvim-dap/wiki/Getting-Started) - Setup guide

### Local Lua Debugger
- [lldebugger](https://github.com/tomblind/local-lua-debugger-vscode) - The debugger configured in this project
- [DAP Protocol](https://microsoft.github.io/debug-adapter-protocol/) - Understanding DAP

### General Debugging Techniques
- [Debugging Guide for Beginners](https://blog.regehr.org/archives/199) - Fundamental debugging strategies
- [The Art of Debugging](https://debugging.works/) - Advanced debugging mindset

### Lua Performance
- [Lua Performance Tips](http://lua-users.org/wiki/OptimisationTips) - Optimization guide
- [LuaJIT Performance Guide](http://wiki.luajit.org/Numerical-Computing-Performance-Guide) - If using LuaJIT

## Troubleshooting

### "Debugger won't connect"
- Check `LOCAL_LUA_DEBUGGER_VSCODE=1` is set
- Verify lldebugger is installed in project
- Try running from terminal instead of editor

### "No debug output showing"
- Ensure logger level is set to "debug" or lower
- Check you're running from terminal (`love .`)
- Verify `prism.logger.enabled = true`

### "Breakpoints not working"
- Confirm DAP adapter is configured correctly
- Check file paths match exactly
- Try setting breakpoint after file loads

### "Game runs too slow when debugging"
- Disable virtual text plugin
- Use conditional breakpoints
- Consider using logger instead for that section

## Tips

1. **Start simple** - Use print/logger before setting up full debugger
2. **One thing at a time** - Debug one issue before moving to next
3. **Git commits** - Commit before debugging so you can revert debug code
4. **Comment debug code** - Mark with `-- DEBUG` so you can find and remove later
5. **Use logger levels** - Keep debug statements with appropriate levels, disable in production

## Project-Specific Notes

- Logger is available globally as `prism.logger`
- lldebugger is already configured in `debugger.lua:1`
- Set `DEBUG_MODE = true` in main.lua for debug overlays
- Check `conf.lua` for window settings if debug overlay is off-screen
