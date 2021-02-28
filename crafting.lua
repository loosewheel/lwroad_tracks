local utils = ...
local S = utils.S



minetest.register_craft ({
	output = "lwroad_tracks:track 48",
	recipe = {
		{"default:dirt", "default:gravel", "default:dirt"},
		{"default:dirt", "default:gravel", "default:dirt"},
		{"default:dirt", "default:gravel", "default:dirt"},
	}
})



minetest.register_craft ({
	output = "lwroad_tracks:powertrack 8",
	recipe = {
		{"default:gravel", "default:dirt", "default:gravel"},
		{"default:gravel", "default:dirt", "default:gravel"},
		{"default:gravel", "default:dirt", "default:gravel"},
	}
})



minetest.register_craft ({
	output = "lwroad_tracks:braketrack 8",
	recipe = {
		{"default:gravel", "default:dirt", "default:gravel"},
		{"default:gravel", "default:coal_lump", "default:gravel"},
		{"default:gravel", "default:dirt", "default:gravel"},
	}
})



minetest.register_craft({
	type = "shapeless",
	output = "lwroad_tracks:startstoptrack 2",
	recipe = {"lwroad_tracks:powertrack", "lwroad_tracks:braketrack"},
})



-- only if msescons loaded
if mesecon then

minetest.register_craft ({
	output = "lwroad_tracks:detectortrack 8",
	recipe = {
		{"default:dirt", "mesecons:wire_00000000_off", "default:gravel"},
		{"default:dirt", "group:stick", "default:gravel"},
		{"default:dirt", "mesecons:wire_00000000_off", "default:gravel"},
	},
})

end -- mesecons loaded



minetest.register_craft ({
	output = "lwroad_tracks:white_car",
	recipe = {
		{"default:steel_ingot", "dye:white", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})



minetest.register_craft ({
	output = "lwroad_tracks:red_car",
	recipe = {
		{"default:steel_ingot", "dye:red", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})



minetest.register_craft ({
	output = "lwroad_tracks:blue_car",
	recipe = {
		{"default:steel_ingot", "dye:blue", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})



minetest.register_craft ({
	output = "lwroad_tracks:green_car",
	recipe = {
		{"default:steel_ingot", "dye:green", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})



minetest.register_craft ({
	output = "lwroad_tracks:yellow_car",
	recipe = {
		{"default:steel_ingot", "dye:yellow", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	},
})



--
