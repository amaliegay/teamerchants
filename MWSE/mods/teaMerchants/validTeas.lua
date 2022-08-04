local this = {}
local common = require("mer.ashfall.common.common")
local teaConfig = common.staticConfigs.teaConfig
for ingredId, _ in pairs(teaConfig.teaTypes) do
	table.insert(this, ingredId)
end
return this
