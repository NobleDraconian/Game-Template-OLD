--[[
	Handles the client-sided aspects of analytics logging
--]]

local AnalyticsController = {}

---------------------
-- Roblox Services --
---------------------
local ScriptContextService = game:GetService("ScriptContext")

------------------
-- Dependencies --
------------------
local AnalyticsService;
local DebugController;

-------------
-- Defines --
-------------
local ClientSessionID = ""
local ErrorCache = {}
local LogCache = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetClientSessionID
-- @Description : Returns the ID of the client session
-- @Returns : string "ClientSessionID" - The ID of the client session
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AnalyticsController:GetClientSessionID()
	return ClientSessionID
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Called when the Controller module is first loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AnalyticsController:Init()
	AnalyticsService = self:GetService("AnalyticsService")
	DebugController = self:GetController("DebugController")
	ClientSessionID = AnalyticsService:GetClientSessionID()

	self:DebugLog("[Analytics Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Called after all Controllers are loaded.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AnalyticsController:Start()
	self:DebugLog("[Analytics Controller] Started!")

	DebugController:AddDebugVariableLabel("ClientSessionID",ClientSessionID)

	if AnalyticsService:IsErrorTrackingEnabled() then
		------------------------------------------------------------
		-- Reporting client-side errors to server when they occur --
		------------------------------------------------------------
		ScriptContextService.Error:connect(function(ErrorMessage,ErrorStackTrace)
			local FullErrorString = ErrorMessage .. " | " .. ErrorStackTrace

			if table.find(ErrorCache,FullErrorString) == nil then
				table.insert(ErrorCache,FullErrorString)
				AnalyticsService:RequestProcessError(ErrorMessage,ErrorStackTrace)
			end
		end)

		---------------------------------------
		-- Clearing error cache every minute --
		---------------------------------------
		coroutine.wrap(function()
			while true do
				task.wait(60)
				ErrorCache = {}
			end
		end)()
	end

	if AnalyticsService:IsLoggingEnabled() then
		---------------------------------------------------------
		-- Reporting client-side logs to server at an interval --
		---------------------------------------------------------
		for _,Log in ipairs(self:GetLogHistory()) do
			table.insert(LogCache,{
				Timestamp = Log.Timestamp,
				Message = Log.Message,
				MessageType = Log.Type
			})
		end

		self.MessageLogged:connect(function(Message,MessageType,Timestamp)
			table.insert(LogCache,{
				Message = Message,
				Timestamp = Timestamp,
				MessageType = MessageType
			})
		end)

		coroutine.wrap(function()
			while true do
				local MessagesToProcess = {}

				task.wait(15)
				self:DebugLog("[Analytics Controller] Sending logs to server for ingestion...")

				for _,Log in ipairs(LogCache) do
					table.insert(MessagesToProcess,{
						Message = Log.Message,
						Timestamp = Log.Timestamp,
						MessageType = Log.MessageType
					})
				end

				AnalyticsService:RequestProcessLogs(MessagesToProcess)
				LogCache = {}

				self:DebugLog("[Analytics Controller] Sent logs to server for ingestion!")
			end
		end)()
	end
end

return AnalyticsController