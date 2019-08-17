--[[
	Clientpaths

	Contains resource paths for the client sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local Players=game:GetService("Players")

return{
	["SharedClasses"]={},

	["Utils"]={},

	["Controllers"]={Players.LocalPlayer.PlayerScripts:WaitForChild("Controllers")}
}