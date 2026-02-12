local path = ...
local basePath = path:match("^(.*)%.") or ""

prism.levelgen = {}
prism.levelgen.util = {}
--- @module "modules.levelgen.generator"
prism.levelgen.Generator = require(basePath .. ".generator")
prism.levelgen.util.BspGenerator = require(basePath .. ".util.bsp_generator")

prism.registerRegistry("generators", prism.levelgen.Generator)
