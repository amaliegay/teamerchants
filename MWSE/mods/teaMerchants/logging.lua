local this = {}
local config = require("teaMerchants.config").config
local logger = require("logging.logger")
---@type MWSELogger
this.log = logger.new { name = "Tea Merchants", logLevel = config.logLevel }
this.loggers = { this.log }
this.createLogger = function(serviceName)
	local logger = logger.new { name = string.format("Tea Merchants - %s", serviceName), logLevel = config.logLevel }
	table.insert(this.loggers, logger)
	return logger
end
return this
