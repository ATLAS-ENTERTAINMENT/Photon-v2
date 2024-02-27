local COMPONENT = Photon2.LibraryComponent()

COMPONENT.Name = "photon_whe_inner_edge_left"
COMPONENT.Author = "Photon"
COMPONENT.Credits = {
	Model = "SuperMighty",
	Code = "Schmal"
}

COMPONENT.Title = "Whelen Inner Edge"

COMPONENT.Model = "models/supermighty/photon/inner_edge_driver.mdl"

COMPONENT.States = {
	[1] = "R",
	[2] = "B"
}

COMPONENT.Templates = {
	["2D"] = {
		Takedown = {
			Width 	= 4,
			Height	= 2,
			Shape = PhotonMaterial.GenerateLightQuad("photon/lights/whe_inner_edge_shape.png").MaterialName,
			Detail = PhotonMaterial.GenerateLightQuad("photon/lights/whe_inner_edge_detail.png").MaterialName,
			Scale = 2
		},
		Normal = {
			Width 	= 4.3,
			Height	= 4.4,
			Shape = PhotonMaterial.GenerateLightQuad("photon/lights/sm_whe_lib_ii_primary_shape.png").MaterialName,
			Detail = PhotonMaterial.GenerateLightQuad("photon/lights/sm_whe_lib_ii_primary_detail.png").MaterialName,
			Scale = 1.25
		}
	},
	["Projected"] = {
		Illumination = {
			States = {
				["TD"] = {
					Inherit = "W",
					Intensity = 0.6
				}
			}
		}
	}
}

COMPONENT.StateMap = "[W] 1 7 [1] 2 3 4 5 6"

COMPONENT.Elements = {
	[1] = { "Takedown", Vector( 2.25, -10.6, -0.06 ), Angle( 0, -85, 0 ) },
	[2] = { "Normal", Vector( 1.5, -6.7, -0.06 ), Angle( 0, -84, 0 ) },
	[3] = { "Normal", Vector( 0.66, -3, -0.06 ), Angle( 0, -84, 0 ) },
	[4] = { "Normal", Vector( -0.18, 0.75, -0.06 ), Angle( 0, -84, 0 ) },
	[5] = { "Normal", Vector( -1.02, 4.6, -0.06 ), Angle( 0, -84, 0 ) },
	[6] = { "Normal", Vector( -1.86, 8.45, -0.06 ), Angle( 0, -84, 0 ) },
	[7] = { "Illumination", Vector( 0, 0, 0 ), Angle( 0, -90, 0 ) }
}

local sequence = Photon2.SequenceBuilder.New

COMPONENT.Segments = {
	All = {
		Frames = {
			[1] = "1 2 3 4 5 6",
			[2] = "2 3 4 5 6",
		},
		Sequences = {
			ON = { 1 },
			STEADY_FLASH = sequence():SteadyFlash( 2 ),
			["QUAD_FLASH"] = sequence():QuadFlash( 1 ),
			["QUAD_FLASH:A"] = sequence():QuadFlash( 1, 0 ),
			["QUAD_FLASH:B"] = sequence():QuadFlash( 0, 1 ),
			["ALT_MED"] = sequence():Alternate( 2, 0, 8 ),
			["ALT_MED:B"] = sequence():Alternate( 0, 2, 8 ),
		}
	},
	Takedown = {
		Frames = {
			[1] = "1 [TD] 7",
		},
		Sequences = {
			["TAKEDOWN"] = { 1 },
		}
	},
	Flood = {
		Frames = {
			[1] = "[W] 1 2 3 4 5 6 7",
		},
		Sequences = {
			["FLOOD"] = { 1 },
		}
	}
}

COMPONENT.Inputs = {
	["Emergency.Warning"] = {
		["MODE1"] = {
			All = "STEADY_FLASH"
		},
		["MODE2"] = {
			All = "ALT_MED"
		},
		["MODE3"] = {
			All = "QUAD_FLASH"
		}
	},
	["Emergency.SceneForward"] = {
		["ON"] = {
			Takedown = "TAKEDOWN"
		},
		["FLOOD"] = {
			Flood = "FLOOD"
		}
	}
}

Photon2.RegisterComponent( COMPONENT )

COMPONENT = Photon2.LibraryComponent()
COMPONENT.Name = "photon_whe_inner_edge_right"
COMPONENT.Base = "photon_whe_inner_edge_left"
COMPONENT.Model = "models/supermighty/photon/inner_edge_passenger.mdl"

COMPONENT.Elements = {
	[1] = { "Takedown", Vector( 2.25, 10.6, -0.06 ), Angle( 0, -95, 0 ) },
	[2] = { "Normal", Vector( 1.5, 6.7, -0.06 ), Angle( 0, -96, 0 ) },
	[3] = { "Normal", Vector( 0.66, 3, -0.06 ), Angle( 0, -96, 0 ) },
	[4] = { "Normal", Vector( -0.18, -0.75, -0.06 ), Angle( 0, -96, 0 ) },
	[5] = { "Normal", Vector( -1.02, -4.6, -0.06 ), Angle( 0, -96, 0 ) },
	[6] = { "Normal", Vector( -1.86, -8.45, -0.06 ), Angle( 0, -96, 0 ) },
}

Photon2.RegisterComponent( COMPONENT )