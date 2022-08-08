local this = {}
local teaConfig = require("mer.ashfall.common.common").staticConfigs.teaConfig
for ingredId, _ in pairs(teaConfig.teaTypes) do
	table.insert(this, ingredId)
end
return this
