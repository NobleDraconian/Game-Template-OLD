--[[
	Environment Service
	Handles the various aspects of the game's deployment environment, such as returning version information, etc.
--]]

local EnvironmentService = {Client = {}}
EnvironmentService.Client.Server = EnvironmentService

---------------------
-- Roblox Services --
---------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-------------
-- Defines --
-------------
local EnvironmentName = ReplicatedStorage._ENV.EnvironmentName.Value
local GameVersion = ReplicatedStorage._ENV.GameVersion.Value
local ResourceIDs = HttpService:JSONDecode(ReplicatedStorage._ENV.ResourceIDs.Value)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetGameVersion
-- @Description : Returns the game's version number and its commit hash.
-- @Returns : string "VersionNumber" : The game's version number.
--            string "CommitHash" : The game's commit hash.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentService:GetGameVersion()
	local VersionNumber = string.split(GameVersion,"@")[1]
	local CommitHash = string.split(GameVersion,"@")[2]

	return VersionNumber, CommitHash
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.GetGameVersion
-- @Description : Returns the game's version number and its commit hash.
-- @Returns : string "VersionNumber" : The game's version number.
--            string "CommitHash" : The game's commit hash.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentService.Client:GetGameVersion()
	return self.Server:GetGameVersion()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetEnvironmentName
-- @Description : Gets the name of the environment that the game is running under
-- @Returns : string "EnvironmentName" - The name of the environment the game is running under
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentService:GetEnvironmentName()
	return EnvironmentName
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.GetEnvironmentName
-- @Description : Returns the name of the environment the game is running under
-- @Returns : string "EnvironmentName" - The name of the environment the game is running under
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentService.Client:GetEnvironmentName()
	return self.Server:GetEnvironmentName()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetGamePlaceIDs
-- @Description : Returns the IDs of all places in the game's universe.
-- @Returns : table "PlaceIDs" : The IDs of all places in the game's universe.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentService:GetGamePlaceIDs()
	local PlaceIDs = {}

	for ResourceKey,ResourceValue in pairs(ResourceIDs) do
		local SplitKey = string.split(ResourceKey,"_")
		if SplitKey[1] == "place" then
			PlaceIDs[SplitKey[2]] = ResourceValue.place.assetId
		end
	end

	return PlaceIDs
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.GetGamePlaceIDs
-- @Description : Returns the IDs of all places in the game's universe.
-- @Returns : table "PlaceIDs" : The IDs of all places in the game's universe.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentService.Client:GetGamePlaceIDs()
	return self.Server:GetGamePlaceIDs()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : IsProServer
-- @Description : Returns whether or not the server is a Pro server.
-- @Returns : boolean "IsProServer" : Whether or not the server is a Pro server.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentService:IsProServer()
	return game.PlaceId == self:GetGamePlaceIDs().pro
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentService:Init()

	self:DebugLog("[Environment] Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentService:Start()
	self:DebugLog("[Environment Service] Started!")

end

return EnvironmentService