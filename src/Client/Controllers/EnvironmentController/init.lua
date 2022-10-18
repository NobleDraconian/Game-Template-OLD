--[[
	Environment Controller
	Handles the various aspects of the game's deployment environment, such as returning version information, etc.
--]]

local EnvironmentController = {}

------------------
-- Dependencies --
------------------
local EnvironmentService;

-------------
-- Defines --
-------------
local EnvironmentName = ""
local GameVersion = "v0.0.0@000000"
local PlaceIDs = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetEnvironmentName
-- @Description : Returns the name of the environment the game is running on
-- @Returns : string "EnvironmentName" - The name of the environment the game is running on
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentController:GetEnvironmentName()
	return EnvironmentName
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetGameVersion
-- @Description : Returns the game's version number and its commit hash.
-- @Returns : string "VersionNumber" : The game's version number.
--            string "CommitHash" : The game's commit hash.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentController:GetGameVersion()
	local VersionNumber = string.split(GameVersion,"@")[1]
	local CommitHash = string.split(GameVersion,"@")[2]

	return VersionNumber, CommitHash
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetGamePlaceIDs
-- @Description : Returns the IDs of all places in the game's universe.
-- @Returns : table "PlaceIDs" : The IDs of all places in the game's universe.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentController:GetGamePlaceIDs()
	return PlaceIDs
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : IsProServer
-- @Description : Returns whether or not the server is a Pro server.
-- @Returns : boolean "IsProServer" : Whether or not the server is a Pro server.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentController:IsProServer()
	return game.PlaceId == self:GetGamePlaceIDs().pro
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentController:Init()
	self:DebugLog("[Environment Controller] Initializing...")

	local GameVersionNumber = ""
	local GameCommitHash = ""

	EnvironmentService = self:GetService("EnvironmentService")

	EnvironmentName = EnvironmentService:GetEnvironmentName()
	GameVersionNumber, GameCommitHash = EnvironmentService:GetGameVersion()
	PlaceIDs = EnvironmentService:GetGamePlaceIDs()
	GameVersion = GameVersionNumber .. "@" .. GameCommitHash

	self:DebugLog("[Environment Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EnvironmentController:Start()
	self:DebugLog("[Environment Controller] Running!")

end

return EnvironmentController