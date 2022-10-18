local LogtailSDK = {}

---------------------
-- Roblox Services --
---------------------
local HTTPService = game:GetService("HttpService")

-------------
-- Defines --
-------------
local SDKToken = ""
local ServerID = game.JobId

if ServerID == "" then
	ServerID = HTTPService:GenerateGUID(false)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetServerID
-- @Description : Returns the server ID that the SDK is has created for the server.
-- @Return : string
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LogtailSDK:GetServerID()
	return ServerID
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RegisterToken
-- @Description : Registers the token to be used with the logtail API
-- @Params : string "Token" - The token to send to the logtail API
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LogtailSDK:RegisterToken(Token)
	SDKToken = Token
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : IngestLogs
-- @Description : Ingests the specified logs and sends them to logtail servers
-- @Params : table "Logs" - The logs to send to logtail servers.
--           format : {Timestamp = DateTime.now(), Message = "Message", Context = "Server", ClientSessionID = "SessionID"}
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LogtailSDK:IngestLogs(Logs)
	local LogsToIngest = {}

	for Index,Log in ipairs(Logs) do
		table.insert(LogsToIngest,{
			dt = DateTime.fromUnixTimestampMillis(tonumber(Log.Timestamp)):ToIsoDate(),
			message = Log.Message,
			context = Log.Context,
			clientsessionid = Log.ClientSessionID or "",
			serverid = ServerID,
			timeindex = Index,
			messagetype = Log.MessageType
		})
	end

	local Success, Response = pcall(function()
		return HTTPService:RequestAsync({
			Url = "https://in.logtail.com",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = "Bearer " .. SDKToken
			},
			Body = HTTPService:JSONEncode(LogsToIngest)
			
		})
	end)

	return Success,Response
end

return LogtailSDK
