local module = {}

const dataModule = require("@shared/playerData")
const dataServer = dataModule.server

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

return module
