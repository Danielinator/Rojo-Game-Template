local data = require("@game/ReplicatedStorage/Packages/dataService")

local template = {
	playtime = 0,
	settings = {} :: { [string]: any },
	timeOfFirstJoin = 0,
	sessionJoinTime = 0,
}

export type template = typeof(template)

return data({ template = template })
