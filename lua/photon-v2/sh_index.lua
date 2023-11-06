---@type Photon2.Index
Photon2.Index = Photon2.Index or {
	Components = {},
	Vehicles = {},
	Sirens = {},
	Tones = {},
	Profiles = {
		Map = {},
		-- For entities that :IsVehicle() and have .VehicleName defined.
		Vehicles = {}
	},
	ComponentClasses = {
		["Default"] = "PhotonLightingComponent",
		["Siren"] = "PhotonSirenComponent"
	}
}

--[[
	Profiles = {
		Map = {
			["prop_vehicle_jeep"] = {
				["models/sentry/20fpiu_new.mdl"] = {
					["~default"] = "photon_sgm_fpiu20",
					["20fpiu_new_sgm"] = "photon_sgm_fpiu20"
				}
			}
		},
		Vehicles = {
			["sgm_fpiu_2020_new"] = "photon_sgm_fpiu20"
		}	
	}
]]

local print = Photon2.Debug.PrintF
local printf = Photon2.Debug.PrintF

local lastSave = SysTime()
local doubleSaveThreshold = 1

local index = Photon2.Index
local library = Photon2.Library
local debug = Photon2.Debug

--[[---------------------
		Config
--]]---------------------
local mergeComponentReloads = false


--[[---------------------
	Component Index
-----------------------]]

function Photon2.Index.ProcessComponentLibrary()	
	local dependencyList = {}
	-- High-level dependency check
	for name, component in pairs(library.Components) do
		table.insert(dependencyList, { name, component.Base })
		if (component.Base) and (not library.Components[component.Base]) then
			debug.Print("Component [" .. tostring(name) .. "] is based on [" .. tostring(component.Base) .. "], which could not be found. Aborting.")
			error()
		end
	end

	local loadOrder = {}
	-- Determines load order by dependencies
	while (not table.IsEmpty(dependencyList)) do
		for i, entry in pairs( dependencyList ) do
			if ((not entry[2]) or table.HasValue(loadOrder, entry[2])) then
				loadOrder[#loadOrder + 1] = entry[1]
				dependencyList[i] = nil
			end
		end
	end

	local function setMetaTable(targ, meta)
		for k, v in pairs(meta) do
			if istable(v) then
				if (targ[k] == nil) then
					targ[k] = meta[k]
				end
				setMetaTable(targ[k], meta[k])
			end
		end
		debug.setmetatable(targ, { __index = meta })
	end

	for i = 1, #loadOrder do
		local name = loadOrder[i]
		local component = library.Components[name]
		if (not component.Base) then
			-- debug.setmetatable( component, { __index = PhotonLightingComponent } )
			Photon2.CompileComponent( name, component )

			-- exmeta.SetMetaTable(component, PhotonLightingComponent)
		else
			if ( not library.Components[component.Base] ) then
				error("Attempted to inherit from [" .. tostring( component.Base ) .."], which could not found.")
			end
			Photon2.CompileComponent( name, component )
			-- TODO: Component inheritance
			--setMetaTable(component, index.Components[component.Base])
			-- exmeta.SetMetaTable(component, Index.Components[component.Base])
		end
	end

end


---@param name string
---@param inputComponent PhotonLibraryComponent
---@return PhotonComponent
function Photon2.CompileComponent( name, inputComponent )
	print("Compiling component [" .. name .. "]")
	
	local base

	if ( isstring( inputComponent.Base ) ) then
		base = library.Components[inputComponent.Base]
	end

	local className = inputComponent.Class or "Default"
	local class = Photon2.Index.ComponentClasses[className]

	local component = _G[class].New( name, inputComponent, base )
	-- local component = PhotonLightingComponent.New( name, inputComponent, base )
	component.CompileTime = RealTime()
	if ( mergeComponentReloads and istable(Photon2.Index.Components[name] ) ) then
		table.Merge(Photon2.Index.Components[name], component)
	else
		Photon2.Index.Components[name] = component
	end

	-- Rebuild child components
	for id, _ in pairs( Photon2.Library.ComponentsGraph[name] or {} ) do
		if Photon2.Library.Components[id] then
			Photon2.CompileComponent( id, Photon2.Library.Components[id] )
		end
	end

	hook.Run( "Photon2:ComponentReloaded", name, library.Components[name] )
	return Photon2.Index.Components[name]
end


--[[---------------------
	Vehicle Index
-----------------------]]

function Photon2.Index.ProcessVehicleLibrary()
	local dependencyList = {}
	for name, vehicle in pairs(library.Vehicles) do
		dependencyList[#dependencyList+1] = { name, vehicle.Base }
		if (vehicle.Base) and (not library.Vehicles[vehicle.Base]) then
			debug.Print("Vehicle [" .. tostring(name) .. "] is based on [" .. tostring(component.Base) .. "], which could not be found. Aborting.")
			error()
		end
	end

	local loadOrder = {}
	while (not table.IsEmpty(dependencyList)) do
		for i, entry in pairs( dependencyList ) do
			if ( ( not entry[2] ) or ( table.HasValue(loadOrder, entry[2]) ) ) then
				loadOrder[#loadOrder+1] = entry[1]
				dependencyList[i] = nil
			end
		end
	end

	for i=1, #loadOrder do
		local name = loadOrder[i]
		local vehicle = library.Vehicles[name]
		if (not vehicle.Base) then
			Photon2.Index.CompileVehicle( name, vehicle )
		else
			-- TODO: Vehicle inheritance
		end
	end

end

local equipmentTypeMap = {
	["Components"] = "Component",
	["Props"] = "Prop"
}

---@param name string The name of the vehicle profile.
---@param inputVehicle PhotonLibraryVehicle The library vehicle instance to compile.
---@param isReload? boolean If the component is being reloaded (i.e. the file was just saved).
function Photon2.Index.CompileVehicle( name, inputVehicle, isReload )
	local current = Photon2.Index.Vehicles[name]

	if (not current) then
		isReload = false
	end

	local currentEquipmentCount, newEquipmentCount
	local currentEquipmentSignature, newEquipmentSignature

	local currentSelectionsSignature, newSelectionsSignature

	local hardSet = true

	local function buildEquipmentSignature( tbl )
		local sig = ""
		for equipmentType, entries in pairs( tbl ) do
			if (equipmentTypeMap[equipmentType]) then
				sig = sig .. string.format("[%s]=>{", equipmentType)
				for index, entry in ipairs( entries ) do
					local baseClassName = ""
					if (istable(entry.BaseClass)) then
						baseClassName = entry.BaseClass.Name
					end
					sig = sig .. string.format("<%s:%s(%s/%s)>", index, entry[equipmentTypeMap[equipmentType]], baseClassName, entry.Name)
				end
				sig = sig .. "}"
			end
		end
		return sig
	end

	local function buildSelectionSignature( tbl )
		local sig = ""
		for key, category in ipairs(tbl) do
			sig = sig .. string.format("[%s]", key)
			for mapKey, option in pairs(category.Map) do
				sig = sig .. tostring(mapKey) .. "("
					if (option.Option) then
						sig = sig .. string.format("<%s>*%s,", mapKey, option.Option)

					elseif (option.Variant) then
						sig = sig .. string.format("<%s>^%s,", mapKey, option.Variant)
					end
				sig = sig .. ")"
			end
		end
		return sig
	end

	if (isReload) then
		currentEquipmentSignature = buildEquipmentSignature( current.Equipment )
		-- Build Selections signature of current table
		if (current.EquipmentSelections) then
			currentSelectionsSignature = buildSelectionSignature( current.EquipmentSelections )
			print("currentSelectionSignature: " .. tostring(currentSelectionsSignature))
		end
		
	end

	Photon2.Index.Vehicles[name] = PhotonVehicle.New( inputVehicle )

	local newVehicle = Photon2.Index.Vehicles[name]


	if (isReload) then
		-- Build new Equipment signature
		newEquipmentSignature = buildEquipmentSignature( newVehicle.Equipment )
		
		printf("EQUIPMENT SIGNATURE\nOld: %s\nNew:%s", currentEquipmentSignature, newEquipmentSignature)
		if (currentEquipmentSignature == newEquipmentSignature) then
			hardSet = false
		end

		-- Build new Selections signature
		-- (any modifications of the Selections tree needs to require a hard reload)
		if (currentSelectionsSignature) then
			if ( newVehicle.EquipmentSelections ) then
				newSelectionsSignature = buildSelectionSignature( newVehicle.EquipmentSelections )
				print("newSelectionSignature: " .. tostring(currentSelectionsSignature))
				
				if (newSelectionsSignature ~= currentSelectionsSignature) then
					hardSet = true
				end
			else
				hardSet = true
			end
		elseif ((newVehicle.EquipmentSelections) and (not currentSelectionsSignature)) then
			hardSet = true
		end

		-- Saving a file twice within the specified threshold forces a hard-reload of the profile
		if ( ( lastSave + doubleSaveThreshold ) >= SysTime() ) then 
			hardSet = true 
		end
		lastSave = SysTime()
	end

	if (PHOTON2_DEBUG_VEHICLE_HARDRELOAD) then
		print("Debug global PHOTON2_DEBUG_VEHICLE_HARDRELOAD is currently true.")
		hardSet = true
	end

	hook.Run("Photon2.VehicleCompiled", name, Photon2.Index.Vehicles[name], hardSet)
	return Photon2.Index.Vehicles[name]
end

hook.Add("Photon2.VehicleCompiled", "Photon2:OnVehicleCompiled", function(name, vehicle)
	print("Vehicle compiled (%s)", name)
end)


function index.CompileSiren( siren )
	if ( not isstring( siren.Name ) ) then 
		ErrorNoHaltWithStack( "Siren Name must be defined and must be a string. Received: " .. tostring( siren.Name ) )
		return nil
	end

	local result = table.Copy(siren)
	local buildTones = false

	if ( not result.Tones ) then
		result.Tones = {}
		buildTones = true
	end

	for name, sound in pairs( result.Sounds ) do
		sound.Name = name
		sound.Siren = result.Name
		if ( not sound.Label ) then
			sound.Label = name
		end
		if ( buildTones ) then
			if ( sound.Tone ) then
				result.Tones[sound.Tone] = sound
			end
		end
		local id = string.lower( result.Name .. "/" .. sound.Name )
		Photon2.Index.Tones[id] = sound
	end

	Photon2.Index.Sirens[result.Name] = result
	
	printf( "Compiling siren [%s] and adding to index.", result.Name )
	return Photon2.Index.Sirens[result.Name]
end

function index.ProcessSirenLibrary()
	for name, data in pairs ( library.Sirens ) do
		index.CompileSiren( data )
	end
end

function Photon2.GetSirenTone( name )
	return Photon2.Index.Tones[name]
end