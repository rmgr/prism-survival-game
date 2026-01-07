--- @class BTController : Controller
--- @overload fun() : BTController
local BTController = prism.components.Controller:extend("BTController")

function BTController:__new(tree)
	self.tree = tree
	self.blackboard = {}
	self.blackboard.long = {}
	self.blackboard.short = {}
end

function BTController:act(level, actor)
	self.blackboard.short = {}
	return self.tree:run(level, actor, self)
end

return BTController
