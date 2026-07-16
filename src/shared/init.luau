local runService = game:GetService("RunService")

local function debugPrint(server: boolean, client: boolean, debug: boolean, text: string)
	if server and debug then
		print(text)
	elseif client and debug then
		print(`DEBUG: {text}`)
	end
end

-- self explanatory
local function numberInList(list: { number }, checkNumber: number): boolean
	for _, number in list do
		if number == checkNumber then
			return true
		end
	end
	return false
end

-- combines a table of modules into one central table while preventing duplicate names
local function combineModuleTables(
	modules: { ModuleScript },
	takenNames: { [string]: boolean },
	output: { ModuleScript }
)
	for _, module in modules do
		if not module:IsA("ModuleScript") then
			continue
		end
		if takenNames[module.Name] then
			error(`Modules must have unique names! Duplicate: {module.Name}`)
		else
			takenNames[module.Name] = true
			table.insert(output, module)
		end
	end
end

-- creates a table which dictates the loading order of modules
local function makePriorityTable(modules: { ModuleScript }, attributeName: string): { number }
	local priorities: { number } = {}

	for _, module in modules do
		local priority = module:GetAttribute(attributeName) or math.huge :: number
		if not numberInList(priorities, priority) then
			table.insert(priorities, priority)
		end
	end

	table.sort(priorities, function(a: number, b: number): boolean
		if (a >= 0) == (b >= 0) then
			return a < b
		else
			return a > b
		end
	end)

	return priorities
end

local loader = {}

--[=[
	Initialises and starts all modules.<br>
	<br>
	Server and client modules may have the same name as they<br>
	don't overlap, but <b>cannot</b> share names with shared modules.<br>
	<br>
	Modules are grouped into priority orders dictated by<br>
	"ClientLoadPriority" / "ServerLoadPriority" number attributes<br>
	A lower number means that module is loaded before ones with a<br>
	higher number. For example, a module with a priority of 0 will<br>
	load and :Init() before a module with a priority of 1,2,10,etc<br>
	A negative number will load LAST, and the larger the negative<br>
	number is (the closer to 0 it is), the later it will load.<br>
	For example, a module with a priority of -1 will load after<br>
	a module with a priority of -2,-3,-10, etc.<br>
	<br>
	You do not need to set the attributes for each module - if the<br>
	module has no attribute, the loader assumes its priority is<br>
	math.huge and so it will load AFTER any modules with a positive<br>
	priority less than math.huge and BEFORE any modules with a negative<br>
	priority. For most cases, you don't need to set an attribute, and you<br>
	should only use them when a module requires another module to load<br>
	before it or if another module requires it to be loaded first.<br>
	<br>
	It is not reccomended to set priorities sequencially (e.g. 1,2,3,4)<br>
	as this makes it more difficult to insert scripts inbetween existing<br>
	priorities. You should instead use large multiples like 10, 100, 250, etc.<br>
	as this doesn't change the order the scripts execute in and it allows<br>
	you to add more scripts at another time. For the same reason, it is <br>
	not reccomended to use 0 or -1 as a priority. An example of good usage:<br>
	<pre>
	script:                  priority:
	importantScript          100
	<b><i>newInbetweenScript       150</b></i>
	scriptRelyingOnThat      200
	generalScript            n/a (math.huge)
	finalScript              -100
	</pre>
	
	For each priority bucket, Modules are first required and then <br>
	immediately initialised. Separate warnings will print to the console<br>
	depending if the require() or the :Init() errored (hopefully, neither).<br>
	<br>
	<b>:Init() functions should only use module loader functions<br>
	with a LOWER load priority than them, as they are guaranteed.<br>
	to have been required and initialised first.</b><br>
	It is safe for :Init() functions to use packages.<br>
	<br>
	After all modules have been required and initialised, :Start()<br>
	is called on each module if :Start() exists, and a warning will<br>
	print to the console if it errors.
	@param boolean? Optional arg that enables debug printing
]=]
function loader:LoadAll(debugPrinting: boolean?)
	local startTime = DateTime.now().UnixTimestampMillis
	debugPrinting = debugPrinting or false
	local server = runService:IsServer()
	local client = runService:IsClient()

	local sharedModules: { ModuleScript } = script:GetChildren()
	local serverOrClientModules: { ModuleScript } = {}
	local allModules: { ModuleScript } = {}

	local takenNames: { [string]: boolean } = {}
	local modules: { [string]: any } = {}

	local loadPriorities: { number } = {}
	local serverOrClientPriority = ""
	local orderedModules: { { ModuleScript } } = {}

	-- Get if server or local

	if server then
		local serverScriptService = game:GetService("ServerScriptService")
		serverOrClientModules = serverScriptService.Server:GetChildren() :: { ModuleScript }
		serverOrClientPriority = "ServerLoadPriority"
	elseif client then
		local playerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
		serverOrClientModules = playerScripts:WaitForChild("Client"):GetChildren() :: { ModuleScript }
		serverOrClientPriority = "ClientLoadPriority"
	end

	-- Combine modules
	combineModuleTables(sharedModules, takenNames, allModules)
	combineModuleTables(serverOrClientModules, takenNames, allModules)

	-- Create load priority
	loadPriorities = makePriorityTable(allModules, serverOrClientPriority)
	for index, priority in loadPriorities do
		orderedModules[index] = {}
		for _, module in allModules do
			local moduleLoadPriority = module:GetAttribute(serverOrClientPriority) or math.huge :: number
			if moduleLoadPriority == priority then
				table.insert(orderedModules[index], module)
			end
		end
	end
	-- Init modules

	for index, modulePriorityLevel in orderedModules do
		debugPrint(server, client, debugPrinting, `Loading modules at priority level: {loadPriorities[index]}`)

		for _, module in modulePriorityLevel do
			debugPrint(server, client, debugPrinting, `Loading module: {module}`)

			local success, result = pcall(function()
				return require(module)
			end)
			if not success then
				warn(`{module.Name} failed to load: {result}`)
				continue
			end

			if type(result) ~= "table" then
				continue
			end
			modules[module.Name] = result

			if not result.Init then
				continue
			end
			local success2, err = pcall(function()
				result:Init()
			end)
			if not success2 then
				warn(`{module.Name} failed to init: {err}`)
			end
		end
	end

	-- Start modules

	for name, module in modules do
		if not module.Start then
			continue
		end

		local success, err = pcall(function()
			module:Start()
		end)
		if not success then
			warn(`{name} failed to start: {err}`)
		end
	end

	print(
		`It took {string.format("%.3f", ((DateTime.now().UnixTimestampMillis - startTime) / 1000))} seconds to load {#allModules} modules!`
	)
end

return loader
