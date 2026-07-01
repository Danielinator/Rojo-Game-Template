local module = {}

local replicatedStorage = game:GetService("ReplicatedStorage")
local dataModule = require(replicatedStorage.Shared.playerData)
local dataServer = dataModule.server

function module:Init()
	function dataServer.Service:onPlayerInit(plr, data)
		local time = os.time()
		if data.timeOfFirstJoin == 0 then
			data.timeOfFirstJoin = time
		end
		data.sessionJoinTime = time

		print(`{plr} data loaded: {data}`)
	end
	dataServer.Service:addPlayerRemovingCallback(function(plr, data: dataModule.template)
		data.playtime += os.time() - data.sessionJoinTime
		print(data.playtime)
	end)
end

return module
