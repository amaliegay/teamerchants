local this = {}
this.mod = "Tea Merchants"
this.version = "1.0"
local summary = "This mod is an addon for Ashfall. It adds Tea Merchants in the game."
local configPath = "teaMerchants"
this.config = mwse.loadConfig(configPath) or {
	logLevel = "INFO",
	teaMerchants = {
		-- manually picked merchants that have teaTypes available
		["anarenen"] = true, -- Ald'ruhn, heather/comberry
		["andil"] = true, -- Tel Vos, black anther/gold kanet/stoneflower/kresh fiber/scathecraw
		["andilu drothan"] = true, -- Vivec Foreign Quarter, trama root/gold kanet/comberry/heather
		["anis seloth"] = true, -- Sadrith Mora, coda flower/hackle-lo/trama root/heather
		["ajira"] = true, -- Balmora, black anther/comberry/heather
		["aurane frernis"] = true, -- Vivec Foreign Quarter, black anther/coda flower
		["bildren areleth"] = true, -- Tel Aruhn, bittergreen/stoneflower/kresh fiber/heather
		["cocistian quaspus"] = true, -- Buckmoth, scathecraw/fire petal/bittergreen/kresh fiber/stoneflower
		["danoso andrano"] = true, -- Ald'ruhn, roobrush/coda flower
		["daynali dren"] = true, -- Tel Mora, black anther/gold kanet/hackle-lo/trama root
		["felara andrethi"] = true, -- Tel Aruhn, chokeweed/comberry
		["galuro belan"] = true, --	Vivec Telvanni Canton, fire petal/stonflower/scathecraw/kresh fiber
		["irna maryon"] = true, -- 	Tel Aruhn, roobrush/scathecraw/fire petal
	},
}

local function modConfigReady()
	local template = mwse.mcm.createTemplate { name = "Tea Merchants", headerImagePath = "textures/jsmk/MCMHeader.tga" }
	template:saveOnClose(configPath, this.config)
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
		variable = mwse.mcm.createTableVariable { id = "logLevel", table = this.config },
	}

	-- TEA MERCHANT LIST
	template:createExclusionsPage{
		label = "Tea Merchants List",
		description = "Move merchants into the left list to allow them to offer Hot Tea services.",
		variable = mwse.mcm.createTableVariable { id = "teaMerchants", table = this.config },
		leftListLabel = "Merchants who offer Hot Tea services",
		rightListLabel = "Merchants",
		filters = {
			{
				label = "Merchants",
				callback = function()
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
				end,
			},
		},
	}
end

event.register("modConfigReady", modConfigReady)

return this
