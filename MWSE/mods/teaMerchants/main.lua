local mod = "Tea Merchants"
local version = "1.0.0"
local function initialized()
	if tes3.isModActive("Ashfall.esp") then
		require("teaMerchants.teaMerchant")
		require("teaMerchants.addTea")
		-- require("teaMerchants.coffeeEffect")
		mwse.log("[%s %s] Initialized", mod, version)
	else
		tes3.messageBox("Tea Merchants requires Ashfall. Please install Ashfall to use this mod.")
	end
end
event.register("initialized", initialized)
require("teaMerchants.mcm")
