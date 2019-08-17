--[[
	ServerPaths

	Contains resource paths for the server sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local ServerScriptService=game:GetService("ServerScriptService")

return{
	["ServerClasses"]={},
	["SharedClasses"]={},

	["Utils"]={},

	["Services"]={ServerScriptService.Services}
}