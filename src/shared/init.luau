local loader = {}

local runService = game:GetService("RunService")

--[[
	Initialises and starts all modules.<br>
	<br>
	Server and client modules may have the same name as they<br>
	don't overlap, but <b>cannot</b> share names with shared modules.<br>
	<br>
	Modules are first required and then immediately initialised.<br>
	Separate warnings will print to the console depending on<br>
	whether the require() or the :Init() failed.<br>
	<b>:Init() functions should never require modules from the<br>
	module loader, they should be independent.</b><br>
	<br>
	After all modules have been required and initialised, :Start()<br>
	is called on each module if it exists, and a warning will<br>
	print to the console if this fails.
]]
--
function loader:LoadAll()
	local sharedModules: { ModuleScript } = script:GetChildren()
	local serverOrClientModules: { ModuleScript } = {}
	local allModules: { ModuleScript } = {}
	local takenNames: { string: boolean } = {}
	local modules: { [string]: any } = {}

	-- Get if server or local

	if runService:IsServer() then
		local serverScriptService = game:GetService("ServerScriptService")
		serverOrClientModules = serverScriptService.Server:GetChildren() :: { ModuleScript }
	elseif runService:IsClient() then
		local playerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
		serverOrClientModules = playerScripts:WaitForChild("Client"):GetChildren() :: { ModuleScript }
	end

	for _, module in sharedModules do
		if not module:IsA("ModuleScript") then
			continue
		end
		if takenNames[module.Name] then
			error(`Modules must have unique names! Duplicate: {module.Name}`)
		else
			takenNames[module.Name] = true
			table.insert(allModules, module)
		end
	end

	for _, module in serverOrClientModules do
		if not module:IsA("ModuleScript") then
			continue
		end
		if takenNames[module.Name] then
			error(`Modules must have unique names! Duplicate: {module.Name}`)
		else
			takenNames[module.Name] = true
			table.insert(allModules, module)
		end
	end

	-- Init modules

	for _, module in allModules do
		local success, result = pcall(function()
			return require(module)
		end)
		if not success then
			warn(`{module.Name} failed to load: {result}`)
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
end

return loader
