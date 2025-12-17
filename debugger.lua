-- Local Lua Debugger for nvim-dap
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
	-- Load the debugger from global location
	local home = os.getenv("HOME")
	local lldebugger = assert(loadfile(home .. "/.local/bin/lldebugger/debugger/lldebugger.lua"))()
	lldebugger.start()

	-- Wrap love.run to catch errors
	local run = love.run
	function love.run(...)
		local f = lldebugger.call(run, false, ...)
		return function(...)
			return lldebugger.call(f, false, ...)
		end
	end
end
