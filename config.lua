Config = {}
Config.Locale = "zh"

Config.DrawDistance = 10.0

Config.DrawDistanceStop = 20.0

Config.ImpoundCost = 3000

Config.SeperateGarage = false

Config.retrieveVerify = true

Config.TextUI = function(text)
    ESX.ShowHelpNotification(text)
    -- local isOpen, current_text = lib.isTextUIOpen()
    -- if not isOpen or current_text ~= text then
    --     lib.showTextUI(text, {
    --         icon = 'car',
    --         style = {
    --             borderRadius = 0.2,
    --             backgroundColor = '#BB2649',
    --             color = 'white'
    --         }
    --     })
    -- end
end

Config.CloseUI = function()
    -- lib.hideTextUI()
end

Config.Markers = {
	EntryPoint = {
		Type = 27,
		Size = {
			x = 1.0,
			y = 1.0,
			z = 0.5,
		},
		Color = {
			r = 187,
			g = 38,
			b = 73,
		},
	},
	StopPoint = {
		Type = 27,
		Size = {
			x = 2.0,
			y = 2.0,
			z = 0.5,
		},
		Color = {
			r = 187,
			g = 38,
			b = 73,
		},
	},
	GetOutPoint = { 
		Type = 27,
		Size = {
			x = 1.0,
			y = 1.0,
			z = 0.5,
		},
		Color = {
			r = 187,
			g = 38,
			b = 73,
		},
	},
}

Config.Garages = {
    --garages
	VespucciBoulevard = {
        coords = {
            EntryPoint = vec(-285.2, -886.5, 31.0),
            StopPoint = vec(-302.35, -899.31, 31.0),
        },
        SpawnPoint = vec(-309.3, -897.0, 31.0, 351.8),
		blip = {
            Coords = vec(-285.2, -886.5, 31.0),
            Enable = true,
            Sprite = 357,
		    Scale = 0.8,
		    Colour = 3,
            Text = 'Garage'
        }
	},
	SanAndreasAvenue = {
        coords = {
            EntryPoint = vec(216.57, -809.83, 30.8),
            StopPoint = vec(216.4, -786.6, 30.8),
        },
        SpawnPoint = vec(230.09, -798.7, 30.8, 158.8),
		blip = {
            Coords = vec(216.57, -809.83, 30.8),
            Enable = true,
            Sprite = 357,
		    Scale = 0.8,
		    Colour = 3,
            Text = 'Garage'
        }
	},
    --impounds
    LosSantos = {
        coords = {
            GetOutPoint = vec(400.7, -1630.5, 29.3)
        },
		SpawnPoint = vec(404.2541, -1643.5513, 29.2919, 222.4407),
        blip = {
            Coords = vec(400.7, -1630.5, 29.3),
            Enable = true,
            Sprite = 524,
            Scale = 0.8,
            Colour = 1,
            Text = 'Impound'
        }
	},
	PaletoBay = {
        coords = {
            GetOutPoint = vec(-211.4, 6206.5, 31.4)
        },
		SpawnPoint = vec(-204.6, 6221.6, 30.5, 227.2),
		blip = {
            Coords = vec(-211.4, 6206.5, 31.4),
            Enable = true,
            Sprite = 524,
            Scale = 0.8,
            Colour = 1,
            Text = 'Impound'
        }
	},
	SandyShores = {
        coords = {
            GetOutPoint = vec(1645.23, 3807.01, 35.12)
        },
		SpawnPoint = vec(1643.63, 3801.42, 35.01, 142.66),
		blip = {
            Coords = vec(1645.23, 3807.01, 35.12),
            Enable = true,
            Sprite = 524,
            Scale = 0.8,
            Colour = 1,
            Text = 'Impound'
        }
	},
}
