local COMPONENT = Photon2.LibraryComponent()

COMPONENT.Name = "photon_whe_dominator_2"

COMPONENT.Author = "Photon"
COMPONENT.Credits = {
	Model = "SGM",
	Code = "Schmal"
}

COMPONENT.States = {
	[1] = "R",
	[2] = "B",
	[3] = "A",
	[4] = "A"
}

COMPONENT.Model = "models/sentry/props/dominator2.mdl"

COMPONENT.Templates = {
	["2D"] = {
		Light = {
			Width 	= 3.7,
			Height	= 1.85,
			Detail = PhotonMaterial.GenerateLightQuad("photon/lights/whe_dominator_detail.png").MaterialName,
			Shape = PhotonMaterial.GenerateLightQuad("photon/lights/whe_dominator_shape.png").MaterialName,
			Scale = 1.25,
			ForwardBloomOffset = 0.1,
			ForwardVisibilityOffset = -0.3
		}
	}
}

COMPONENT.StateMap = "[1/3] 1 [2/4] 2"

COMPONENT.Elements = {
	[1] = { "Light", Vector( -2.04, 0.2, 0 ), Angle( 0, 180, 0 ) },
	[2] = { "Light", Vector( 2.04, 0.2, 0 ), Angle( 0, 180, 0 ) },
}

COMPONENT.Segments = {
	All = {
		Frames = {
			[1] = "1 2"
		},
		Sequences = {
			ALL = { 1 }
		}
	}
}

COMPONENT.Inputs = {
	["Emergency.Warning"] = {
		["MODE1"] = {
			All = "ALL"
		}
	}
}

Photon2.RegisterComponent( COMPONENT )

COMPONENT = Photon2.LibraryComponent()
COMPONENT.Name = "photon_whe_dominator_4"
COMPONENT.Model = "models/sentry/props/dominator4.mdl"
COMPONENT.Base = "photon_whe_dominator_2"
COMPONENT.StateMap = "[1/3] 1 3 [2/4] 2 4"
COMPONENT.Elements = {
	[3] = { "Light", Vector( -6.3, 0.2, 0 ), Angle( 0, 180, 0 ) },
	[4] = { "Light", Vector( 6.3, 0.2, 0 ), Angle( 0, 180, 0 ) },
}

COMPONENT.Segments = {
	All = {
		Frames = {
			[1] = "1 2 3 4"
		},
		Sequences = {
			ALL = { 1 }
		}
	}
}
Photon2.RegisterComponent( COMPONENT )

COMPONENT = Photon2.LibraryComponent()
COMPONENT.Name = "photon_whe_dominator_6"
COMPONENT.Model = "models/sentry/props/dominator6.mdl"
COMPONENT.Base = "photon_whe_dominator_4"
COMPONENT.StateMap = "[1/3] 1 3 5 [2/4] 2 4 6"
COMPONENT.Elements = {
	[5] = { "Light", Vector( -10.5, 0.2, 0 ), Angle( 0, 180, 0 ) },
	[6] = { "Light", Vector( 10.5, 0.2, 0 ), Angle( 0, 180, 0 ) },
}

COMPONENT.Segments = {
	All = {
		Frames = {
			[1] = "1 2 3 4 5 6"
		},
		Sequences = {
			ALL = { 1 }
		}
	}
}
Photon2.RegisterComponent( COMPONENT )

COMPONENT = Photon2.LibraryComponent()
COMPONENT.Name = "photon_whe_dominator_8"
COMPONENT.Model = "models/sentry/props/dominator8.mdl"
COMPONENT.Base = "photon_whe_dominator_6"
COMPONENT.StateMap = "[1/3] 1 3 5 7 [2/4] 2 4 6 8"
COMPONENT.Elements = {
	[7] = { "Light", Vector( -14.7, 0.2, 0 ), Angle( 0, 180, 0 ) },
	[8] = { "Light", Vector( 14.7, 0.2, 0 ), Angle( 0, 180, 0 ) },
}

COMPONENT.Segments = {
	All = {
		Frames = {
			[1] = "1 2 3 4 5 6 7 8"
		},
		Sequences = {
			ALL = { 1 }
		}
	}
}
Photon2.RegisterComponent( COMPONENT )