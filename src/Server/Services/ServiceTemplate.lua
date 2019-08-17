--[[
	Service template
--]]

local ServiceTemplate={}

---------------------
-- Roblox Services --
---------------------

-------------
-- DEFINES --
-------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ServiceTemplate:Init()

	self:DebugLog("[Service Template] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ServiceTemplate:Start()
	self:DebugLog("[Service Template] Started!")

end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Stop
-- @Description : Called when the service is being stopped.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ServiceTemplate:Stop()

	self:Log("[Service Template] Stopped!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Unload
-- @Description : Called when the service is being unloaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ServiceTemplate:Unload()

	self:Log("[Service Template] Unloaded!")
end

return ServiceTemplate