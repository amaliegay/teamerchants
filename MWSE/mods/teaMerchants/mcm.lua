local configPath = "teaMerchants"
-- local logger = require("logging.logger")
-- local config = require("teaMerchants.config")
local mcm = { config = mwse.loadConfig(configPath) or { logLevel = "DEBUG" } }
local function modConfigReady()
	local template = mwse.mcm.createTemplate { name = "Tea Merchants" }
	template:saveOnClose(configPath, mcm.config)
	-- template:register()
	local page = template:createPage()
	local block = page:createSideBySideBlock()
	block:createDropdown{
		label = "Log Level",
		description = "Set the logging level.",
		options = {
			{ label = "TRACE", value = "TRACE" },
			{ label = "DEBUG", value = "DEBUG" },
			{ label = "INFO", value = "INFO" },
			{ label = "ERROR", value = "ERROR" },
			{ label = "NONE", value = "NONE" },
		},
		variable = mwse.mcm.createTableVariable { id = "logLevel", table = mcm.config },
	}
	mwse.mcm.register(template)
end

event.register("modConfigReady", modConfigReady)
