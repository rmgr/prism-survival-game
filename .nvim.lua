-- Project-specific nvim configuration for prism-template
-- This file is automatically loaded when you open nvim in this directory
-- Uses lldebugger (local-lua-debugger-vscode) for LOVE2D debugging

-- Signal to load LOVE2D debug plugin
vim.g.enable_love2d_debug = true

local love_path = vim.fn.expand("~/Downloads/love-linux-X64.AppImage/love.AppImage")
local project_dir = vim.fn.getcwd()

-- Keymap to run LÖVE game without debugging
vim.keymap.set("n", "<leader>rr", function()
	vim.fn.jobstart({ love_path, project_dir }, {
		on_exit = function(_, exit_code)
			print("LÖVE exited with code: " .. exit_code)
		end,
	})
	print("Launching LÖVE game...")
end, { desc = "[R]un: [R]un LÖVE game (no debug)" })

print("Loaded prism-template configuration - Use <F5> to debug, <leader>rr to run")
