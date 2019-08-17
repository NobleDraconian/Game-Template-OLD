--[[
	Class Template
]]

local Class={}

---------------------
-- Roblox Services --
---------------------

-------------
-- Defines --
-------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : new
-- @Description : Creates and returns a new instance of the class.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Class.new()
	local NewInstance={
		Name="New Instance"
	}
	setmetatable(NewInstance,{__index=Class})

	return NewInstance
end