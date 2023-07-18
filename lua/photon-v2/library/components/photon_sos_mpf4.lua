if (Photon2.ReloadComponentFile()) then return end
local COMPONENT = Photon2.LibraryComponent()

COMPONENT.Author = "Photon"

COMPONENT.Credits = {
	Model = "SGM",
	Code = "Schmal"
}

-- photon_s[ound]o[ff]s[ignal]_mp[ower]f[ascia]4[inch]lic[ense plate]_h[orizontal]
COMPONENT.PrintName = [[SoundOff Signal mpower Fascia 4"]]

COMPONENT.Model = "models/sentry/props/soundofffascia.mdl"

local s = 1.6

COMPONENT.Templates = {
	["2D"] = {
		Full = {
			Material = PhotonDynamicMaterial.GenerateLightQuad("photon/lights/sos_mpf4_shape.png").MaterialName,
			MaterialOverlay = PhotonDynamicMaterial.GenerateLightQuad("photon/lights/sos_mpf4_detail.png").MaterialName,
			MaterialBloom = PhotonDynamicMaterial.GenerateBloomQuad("photon/lights/sos_mpf4_bloom.png").MaterialName,
			Width = 6,
			Height = 6,
			Ratio = 1,
			Scale = 1,
			ForwardVisibilityOffset = -0.1,
			ForwardBloomOffset = 0.1,
			LightMatrix = { Vector(s, 0, 0), Vector(-s, 0, 0),  },
			LightMatrixScaleMultiplier = 0.6
		}
	}
}

COMPONENT.ColorMap = "[R] 1"

COMPONENT.Lights = {
	[1] = { "Full", Vector(0.5, 0, 0), Angle(0, -90, 0) }
}

COMPONENT.Segments = {
	Full = {
		Frames = {
			[1] = "1 1",
		},
		Sequences = {
			["STEADY"] = { 1 }
		}
	}
}

COMPONENT.Patterns = {
	["Vehicle.Lights"] = {
		["HEADLIGHTS"] = {
			Full = "STEADY"
			-- All = "STEADY"
		}
	}
}