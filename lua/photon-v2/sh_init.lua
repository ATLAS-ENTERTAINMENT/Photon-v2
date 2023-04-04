include("sh_schema.lua")

function LoadPhoton2MetaFiles()
	exmeta.LoadFile("photon-v2/meta/sh_light.lua")
	exmeta.LoadFile("photon-v2/meta/sh_light_2d.lua")

	exmeta.LoadFile("photon-v2/meta/sh_base_entity.lua")

	exmeta.LoadFile("photon-v2/meta/sh_lighting_component.lua")
	exmeta.LoadFile("photon-v2/meta/sh_lighting_segment.lua")
	exmeta.LoadFile("photon-v2/meta/sh_sequence.lua")
	exmeta.LoadFile("photon-v2/meta/sh_sequence_collection.lua")

	exmeta.LoadFile("photon-v2/meta/sh_vehicle_equipment.lua")
	exmeta.LoadFile("photon-v2/meta/sh_vehicle.lua")
end

LoadPhoton2MetaFiles()

if CLIENT then
	hook.Add("Initialize", "Photon2:Initialize", LoadPhoton2MetaFiles)
end
