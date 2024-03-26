include("sh_init.lua")
include("cl_mesh_cache.lua")
include("cl_convars.lua")
include("cl_net.lua")
include("cl_render.lua")
include("cl_dynamic_materials.lua")

LoadPhoton2MetaFiles()

include("cl_ui.lua")
include("cl_ui_skin.lua")
include("cl_hud.lua")
include("sh_component_builder.lua")
include("cl_render_light_projected.lua")
include("cl_render_light_2d.lua")
include("cl_render_light_mesh.lua")
include("cl_render_light_bone.lua")
include("cl_render_bloom.lua")
include("sh_input.lua")
include("cl_input.lua")

include("sh_ent_meta.lua")
include("sh_library.lua")
include("sh_index.lua")

if CLIENT then
	hook.Add("Initialize", "Photon2:Initialize", LoadPhoton2MetaFiles)
end

function Photon2.FreezeFrame()
	PHOTON2_FREEZE = true
end

function Photon2.ResumeFrame()
	PHOTON2_FREEZE = false
end

function Photon2.NextFrame()
	for _, ent in pairs(ents.FindByClass("photon_controller")) do
		ent:DoNextFrame()
		ent:DoPulse()
	end
end

concommand.Add( "ph2_toggle_freeze", function()
	if ( PHOTON2_FREEZE ) then
		Photon2.ResumeFrame()
		return
	end
	Photon2.FreezeFrame()
end)

concommand.Add( "ph2_next_frame", function()
	Photon2.NextFrame()
end)

PhotonMaterial.New({
	Name = "flashlight/wide",
	Shader = "UnlitGeneric",
	Parameters = {
		["$basetexture"] = "photon/flashlight/wide.png"
	}
})