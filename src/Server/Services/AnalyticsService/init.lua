--[[
	Handles the various aspects of the game's analytics
--]]

local AnalyticsService = {Client = {}}
AnalyticsService.Client.Server = AnalyticsService

---------------------
-- Roblox Services --
---------------------
local RbxAnalyticsService = game:GetService("AnalyticsService")
local ScriptContextService = game:GetService("ScriptContext")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

------------------
-- Dependencies --
------------------
local EnvironmentService;

local Queue;
local LOGTAIL_API_KEY = require(script.APIKEY)
local LogtailSDK = require(script.LogtailSDK)

-------------
-- Defines --
-------------
local DEBUG_ENABLED = true
local GAME_VERSION;
local ENVIRONMENT_NAME;
local LOG_INGESTION_ENABLED = false
local ERROR_LOGGING_ENABLED = false

local LoggingQueue;

local ServerErrorCache = {}
local PlayersErrorCache = {}
local ServerLogsCache = {}
local ClientsLogsCache = {}
local ClientSessionIDs = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Helper functions
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RemoveGsubSpecialCharactersFromString(InputString)
	local SanitizedString = string.gsub(InputString,"[%(%)%.%%%+%-%*%?%[%]%^%$]",function(SubString)
		return "%" .. SubString
	end)
	
	return SanitizedString
end

local function ScrubPlayerFromOutput(Player,OutputString)

	return string.gsub(OutputString,Player.Name,"[Player]")
end

local function ScrubBadCharsFromOutput(OutputString)
	OutputString = string.gsub(OutputString,"\r","")
	OutputString = string.gsub(OutputString,"\n","")
	OutputString = string.gsub(OutputString,",","")
	OutputString = string.gsub(OutputString,'"',"")

	return OutputString
end

local function CleanOutput(Player,OutputString)
	OutputString = RemoveGsubSpecialCharactersFromString(OutputString)

	if Player ~= nil then
		OutputString = ScrubPlayerFromOutput(Player,OutputString)
	end
	OutputString = ScrubBadCharsFromOutput(OutputString)

	OutputString = string.gsub(OutputString,"%%","")
	
	return OutputString
end

local function LogErrorToAnalytics(Player,ErrorMessage,ErrorStackTrace)
	local ClientSessionID = ""
	
	if Player ~= nil then
		ClientSessionID = ClientSessionIDs[tostring(Player.UserId)]
	end

	RbxAnalyticsService:FireLogEvent(
		Player,
		Enum.AnalyticsLogLevel.Error,
		ErrorMessage,
		{
			errorCode = "ScriptContext.Error",
			stackTrace = ErrorStackTrace
		},
		{
			GameVersion = GAME_VERSION,
			GameId = game.GameId,
			ClientSessionID = ClientSessionID
		}
	)

	if DEBUG_ENABLED then
		warn("Logged error!")
		warn("Message",ErrorMessage)
		warn("Stack trace",ErrorStackTrace)
	end
end

local function SendLogsToLogtail()
	local LogsToIngest = {}

	AnalyticsService:DebugLog("[Analytics Service] Ingesting logs...")

	for Index,Log in ipairs(ServerLogsCache) do
		table.insert(LogsToIngest,{
			Timestamp = Log.Timestamp,
			Message = Log.Message,
			Context = "Server",
			TimeIndex = Index,
			MessageType = Log.MessageType
		})
	end

	for PlayerID,Logs in pairs(ClientsLogsCache) do
		local ClientSessionID = ClientSessionIDs[tostring(PlayerID)]

		for _,Log in ipairs(Logs) do
			table.insert(LogsToIngest,{
				Timestamp = Log.Timestamp,
				Message = Log.Message,
				Context = "Client",
				ClientSessionID = ClientSessionID,
				MessageType = Log.MessageType
			})
		end
	end

	local Success,ErrorMessage = LogtailSDK:IngestLogs(LogsToIngest)

	if Success then -- Logs successfully ingested, clear caches
		AnalyticsService:DebugLog("[Analytics Service] Succesfully ingested all logs!")

		ServerLogsCache = {}

		for PlayerID,_ in pairs(ClientsLogsCache) do
			if Players:GetPlayerByUserId(PlayerID) == nil then
				ClientsLogsCache[PlayerID] = nil
				ClientSessionIDs[PlayerID] = nil
			else
				ClientsLogsCache[PlayerID] = {}
			end
		end
	else
		AnalyticsService:Log("[Analytics Service] Failed to ingest logs : " .. ErrorMessage,"Warning")
	end

	if DEBUG_ENABLED then
		warn(LogsToIngest)
	end
end

local function HandlePlayerAdded(Player)
	local ClientSessionID = HttpService:GenerateGUID(false)

	PlayersErrorCache[tostring(Player.UserId)] = {}
	ClientSessionIDs[tostring(Player.UserId)] = ClientSessionID
	ClientsLogsCache[tostring(Player.UserId)] = {}
end

local function HandlePlayerLeaving(Player)
	PlayersErrorCache[tostring(Player.UserId)] = nil
end

local function GetPlayerErrorCache(Player)
	return PlayersErrorCache[tostring(Player.UserId)]
end

local function GetPlayerLogsCache(Player)
	return ClientsLogsCache[tostring(Player.UserId)]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- API Methods
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.IsLoggingEnabled
-- @Description : Returns whether or not logging is enabled
-- @Returns : bool "IsLoggingEnabled" - A bool describing whether or not logging is enabled
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AnalyticsService.Client:IsLoggingEnabled()
	return LOG_INGESTION_ENABLED
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.IsErrorTrackingEnabled
-- @Description : Returns whether or not error tracking is enabled
-- @Returns : bool "IsErrorTrackingEnabled" - A bool describing whether or not error tracking is enabled
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AnalyticsService.Client:IsErrorTrackingEnabled()
	return ERROR_LOGGING_ENABLED
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.GetClientSessionID
-- @Description : Returns the session ID for the current client
-- @Return : string "SessionID" - The session ID for the current client
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AnalyticsService.Client:GetClientSessionID(Player)
	return ClientSessionIDs[tostring(Player.UserId)]
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.RequestProcessLogs
-- @Description : Processes the specified log for the calling player
-- @Params : string "Logs" - A table containing the logs to process
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AnalyticsService.Client:RequestProcessLogs(Player,Logs)
	if LOG_INGESTION_ENABLED then
		local PlayerLogsCache = GetPlayerLogsCache(Player)

		for _,Log in pairs(Logs) do
			table.insert(PlayerLogsCache,{
				Timestamp = Log.Timestamp,
				Message = Log.Message,
				MessageType = Log.MessageType
			})
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Client.RequestProcessError
-- @Description : Processes the specified error for the calling player
-- @Params : string "ErrorMessage" - The error message of the error that occured
--           string "StackTrace" - The stack trace of the error that occured
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AnalyticsService.Client:RequestProcessError(Player,ErrorMessage,StackTrace)
	local CleanedErrorMessage = CleanOutput(Player,ErrorMessage)
	local CleanedStackTrace = CleanOutput(Player,StackTrace)
	local FullErrorString = CleanedErrorMessage .. " | " .. CleanedStackTrace
	local PlayerErrorCache = GetPlayerErrorCache(Player)

	if table.find(PlayerErrorCache,FullErrorString) == nil then
		table.insert(PlayerErrorCache,FullErrorString)
		LogErrorToAnalytics(Player,CleanedErrorMessage,CleanedStackTrace)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the service module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AnalyticsService:Init()
	Queue = self:GetModule("Queue")
	LoggingQueue = Queue.new()

	LogtailSDK:RegisterToken(LOGTAIL_API_KEY)

	self:DebugLog("[Analytics Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all services are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AnalyticsService:Start()
	self:DebugLog("[Analytics Service] Started!")

	EnvironmentService = self:GetService("EnvironmentService")

	GAME_VERSION = EnvironmentService:GetGameVersion()
	ENVIRONMENT_NAME = EnvironmentService:GetEnvironmentName()

	LOG_INGESTION_ENABLED = (not RunService:IsStudio()) and ENVIRONMENT_NAME == "Test"
	ERROR_LOGGING_ENABLED = (not RunService:IsStudio()) and (ENVIRONMENT_NAME == "Test" or ENVIRONMENT_NAME == "Production")

	------------------------------------------------------------------
	-- Creating/destroying player error caches on player join/leave --
	------------------------------------------------------------------
	for _,Player in pairs(Players:GetPlayers()) do
		coroutine.wrap(HandlePlayerAdded)(Player)
	end
	Players.PlayerAdded:connect(HandlePlayerAdded)

	Players.PlayerRemoving:connect(HandlePlayerLeaving)

	if ERROR_LOGGING_ENABLED then
		---------------------------------------------------
		-- Reporting errors to analytics when they occur --
		---------------------------------------------------
		ScriptContextService.Error:connect(function(ErrorMessage,ErrorStackTrace)
			local FullErrorString = ErrorMessage .. " | " .. ErrorStackTrace

			if table.find(ServerErrorCache,FullErrorString) == nil then
				table.insert(ServerErrorCache,FullErrorString)
				LogErrorToAnalytics(nil,CleanOutput(nil,ErrorMessage),CleanOutput(nil,ErrorStackTrace))
			end
		end)

		----------------------------------------
		-- Flushing error caches every minute --
		----------------------------------------
		coroutine.wrap(function()
			while true do
				task.wait(60)
				ServerErrorCache = {}
				for Key,_ in pairs(PlayersErrorCache) do
					PlayersErrorCache[Key] = {}
				end
			end
		end)()
	end

	if LOG_INGESTION_ENABLED then
		----------------------------------------------------
		-- Batch-reporting logs to logtail at an interval --
		----------------------------------------------------
		for _,Log in ipairs(self:GetLogHistory()) do
			table.insert(ServerLogsCache,{
				Timestamp = Log.Timestamp,
				Message = Log.Message,
				MessageType = Log.Type
			})
		end

		self.MessageLogged:connect(function(Message,MessageType,Timestamp)
			table.insert(ServerLogsCache,{
				Message = Message,
				Timestamp = Timestamp,
				MessageType = MessageType
			})
		end)

		coroutine.wrap(function()
			while true do
				task.wait(20)

				LoggingQueue:AddAction(SendLogsToLogtail)

				if not LoggingQueue:IsExecuting() then
					LoggingQueue:Execute()
				end
			end
		end)()

		---------------------------------------------------------------
		-- Reporting logs to logtail before letting server shut down --
		---------------------------------------------------------------
		game:BindToClose(function()
			self:Log("[Analytics Service] Server '" .. LogtailSDK:GetServerID() .. "' is shutting down!")

			LoggingQueue:AddAction(SendLogsToLogtail)

			if not LoggingQueue:IsExecuting() then
				LoggingQueue:Execute()
			end

			while true do
				if LoggingQueue:GetSize() == 0 then
					break
				else
					RunService.Stepped:wait()
				end
			end
		end)
	end
end

return AnalyticsService