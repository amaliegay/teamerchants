local this = {}
this.mod = "Tea Merchants"
this.version = "1.1"
local summary = "This mod is an addon for Ashfall. It adds Tea Merchants in the game."
local config = require("teaMerchants.config").config

local function modConfigReady()
	local template = mwse.mcm.createTemplate { name = this.mod, headerImagePath = "textures/jsmk/MCMHeader.tga" }
	template.onClose = function()
		config.save()
	end
	template:register()

	-- INFO PAGE
	local infoPage = template:createPage{ label = "Info" }
	infoPage:createInfo({ text = this.mod .. " v" .. this.version .. "\n" .. summary })
	infoPage:createHyperLink{
		text = "Some people like morning coffee. JosephMcKean likes morning tea.",
		url = "https://www.nexusmods.com/morrowind/mods/51656",
	}
	infoPage:createHyperLink{
		text = "JosephMcKean's morning staple is a Cha jau, Pu'er with condensed milk.",
		url = "https://www.nexusmods.com/morrowind/users/147999863?tab=user+files",
	}
	infoPage:createDropdown{
		label = "Log Level",
		description = "Set the logging level.",
		options = {
			{ label = "DEBUG", value = "DEBUG" },
			{ label = "INFO", value = "INFO" },
			{ label = "ERROR", value = "ERROR" },
			{ label = "NONE", value = "NONE" },
		},
		variable = mwse.mcm.createTableVariable { id = "logLevel", table = config },
		callback = function(self)
			for _, log in ipairs(require("teaMerchants.logging").loggers) do
				mwse.log("Setting %s to log level %s", log.name, self.variable.value)
				log:setLogLevel(self.variable.value)
			end
		end,
	}

	-- TEA MERCHANT LIST
	local function createMerchantList()
		local merchants = {}
		for obj in tes3.iterateObjects(tes3.objectType.npc) do
			if not (obj.baseObject and obj.baseObject.id ~= obj.id) then
				-- Check if npc trades in ingredients
				if obj:tradesItemType(tes3.objectType.ingredient) then
					merchants[#merchants + 1] = (obj.baseObject or obj).id:lower()
				end
			end
		end
		table.sort(merchants)
		return merchants
	end
	template:createExclusionsPage{
		label = "Tea Merchants List",
		description = "Move merchants into the left list to allow them to offer Hot Tea services.",
		variable = mwse.mcm.createTableVariable { id = "teaMerchants", table = config },
		leftListLabel = "Merchants who offer Hot Tea services",
		rightListLabel = "Merchants",
		filters = { { label = "Merchants", callback = createMerchantList } },
	}
end
event.register("modConfigReady", modConfigReady)

return this
