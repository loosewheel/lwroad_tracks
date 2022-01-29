local utils = ...
local S = utils.S



lwroad_tracks.register_track ("lwroad_tracks:track", {
	description = S("Road Track"),
	tiles = {
		"lwroads_track_straight.png", "lwroads_track_curved.png",
		"lwroads_track_t_junction.png", "lwroads_track_crossing.png"
	},
	groups = lwroad_tracks.get_track_groups ({ dig_immediate = 2 }),
})



-- Power track
lwroad_tracks.register_track ("lwroad_tracks:powertrack", {
	description = S("Powered Track"),
	tiles = {
		"lwroads_powertrack_straight.png", "lwroads_powertrack_curved.png",
		"lwroads_powertrack_t_junction.png", "lwroads_powertrack_crossing.png"
	},
	groups = lwroad_tracks.get_track_groups ({ dig_immediate = 2 }),

	after_place_node = function (pos, placer, itemstack)
		if not mesecon then
			minetest.get_meta (pos):set_string ("lwroads_acceleration", "0.5")
		end
	end,

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_on = function (pos, node)
				lwroad_tracks.boost_track (pos, 0.5)
			end,

			action_off = function (pos, node)
				minetest.get_meta (pos):set_string ("lwroads_acceleration", "0")
			end,
		},
	},
})



-- Brake track
lwroad_tracks.register_track ("lwroad_tracks:braketrack", {
	description = S("Brake Track"),
	tiles = {
		"lwroads_braketrack_straight.png", "lwroads_braketrack_curved.png",
		"lwroads_braketrack_t_junction.png", "lwroads_braketrack_crossing.png"
	},
	groups = lwroad_tracks.get_track_groups ({ dig_immediate = 2 }),

	after_place_node = function (pos, placer, itemstack)
		if not mesecon then
			minetest.get_meta (pos):set_string ("lwroads_acceleration", "-0.3")
		end
	end,

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_on = function (pos, node)
				minetest.get_meta (pos):set_string ("lwroads_acceleration", "-0.3")
			end,

			action_off = function (pos, node)
				minetest.get_meta (pos):set_string ("lwroads_acceleration", "0")
			end,
		},
	},
})



-- Start/Stop track
lwroad_tracks.register_track ("lwroad_tracks:startstoptrack", {
	description = S("Start-Stop Track"),
	tiles = {
		"lwroads_startstoptrack_straight.png", "lwroads_startstoptrack_curved.png",
		"lwroads_startstoptrack_t_junction.png", "lwroads_startstoptrack_crossing.png"
	},
	groups = lwroad_tracks.get_track_groups ({ dig_immediate = 2 }),

	after_place_node = function (pos, placer, itemstack)
		if not mesecon then
			minetest.get_meta (pos):set_string ("lwroads_acceleration", "halt")
		end
	end,

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_on = function (pos, node)
				lwroad_tracks.boost_track (pos, 0.5)
			end,

			action_off = function (pos, node)
				minetest.get_meta (pos):set_string ("lwroads_acceleration", "halt")
			end,
		},
	},
})



-- Boom gate
minetest.register_node ("lwroad_tracks:boom_gate_open", {
	description = S("Boom Gate"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.485, 0.5},
		}
	},
	tiles = {
		"lwroads_boom_top.png", "lwroads_boom_top.png",
		"lwroads_boom_side.png", "lwroads_boom_side.png",
		"lwroads_boom_front.png", "lwroads_boom_front.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	use_texture_alpha = "clip",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4999, 0.5},
		}
	},
	sounds = default.node_sound_dirt_defaults (),
	groups = lwroad_tracks.get_track_groups ({ not_in_creative_inventory = 1, choppy = 2 }),
	drop = "lwroad_tracks:boom_gate",

	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		minetest.swap_node (pos, { name = "lwroad_tracks:boom_gate",
											param1 = node.param1, param2 = node.param2 })
	end,

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_on = function (pos, node)
				minetest.swap_node (pos, { name = "lwroad_tracks:boom_gate",
													param1 = node.param1, param2 = node.param2 })
			end,
		},
	},
})



minetest.register_node ("lwroad_tracks:boom_gate", {
	description = S("Boom Gate"),
	tiles = {
		"lwroads_boom_top.png", "lwroads_boom_top.png",
		"lwroads_boom_side.png", "lwroads_boom_side.png",
		"lwroads_boom_front.png", "lwroads_boom_front.png"
	},
	groups = { choppy = 2 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.485, 0.5},
			{-0.5, 0.25, -0.125, 0.5, 0.5, 0.125},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			{-0.5, 0.25, -0.125, 0.5, 0.5, 0.125},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4999, 0.5},
			{-0.5, 0.25, -0.125, 0.5, 0.5, 0.125},
		}
	},
	sounds = default.node_sound_wood_defaults (),

	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		minetest.swap_node (pos, { name = "lwroad_tracks:boom_gate_open",
											param1 = node.param1, param2 = node.param2 })
	end,

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_on = function (pos, node)
				minetest.swap_node (pos, { name = "lwroad_tracks:boom_gate_open",
													param1 = node.param1, param2 = node.param2 })
			end,
		},
	},
})



-- only if mesecons loaded
if utils.mesecons_supported then


-- Detector track
lwroad_tracks.register_track ("lwroad_tracks:detectortrack", {
	description = "Detector Track",
	tiles = {
		"lwroads_detectortrack_straight.png", "lwroads_detectortrack_curved.png",
		"lwroads_detectortrack_t_junction.png", "lwroads_detectortrack_crossing.png"
	},
	groups = lwroad_tracks.get_track_groups ({ dig_immediate = 2, detector_rail = 1 }),

	mesecons = { receptor = { state = "off", rules = utils.mesecons_rules } },
})



lwroad_tracks.register_track ("lwroad_tracks:detectortrack_on", {
	description = "Detector Track",
	tiles = {
		"lwroads_detectortrack_on_straight.png", "lwroads_detectortrack_on_curved.png",
		"lwroads_detectortrack_on_t_junction.png", "lwroads_detectortrack_on_crossing.png"
	},
	groups = lwroad_tracks.get_track_groups ({
		dig_immediate = 2,
		detector_rail = 1,
		not_in_creative_inventory = 1
	}),
	drop = "lwroad_tracks:detectortrack",

	mesecons = { receptor = { state = "on", rules = utils.mesecons_rules } },
})



-- Mesecons boom gate
minetest.register_node ("lwroad_tracks:boom_gate_mesecons_open", {
	description = S("Mesecons Boom Gate"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.485, 0.5},
		}
	},
	tiles = {
		"lwroads_boom_mesecons_top.png", "lwroads_boom_mesecons_top.png",
		"lwroads_boom_mesecons_side.png", "lwroads_boom_mesecons_side.png",
		"lwroads_boom_mesecons_front.png", "lwroads_boom_mesecons_front.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	use_texture_alpha = "clip",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4999, 0.5},
		}
	},
	sounds = default.node_sound_dirt_defaults (),
	groups = lwroad_tracks.get_track_groups ({ not_in_creative_inventory = 1, choppy = 2 }),
	drop = "lwroad_tracks:boom_gate_mesecons",

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_off = function (pos, node)
				minetest.swap_node (pos, { name = "lwroad_tracks:boom_gate_mesecons",
													param1 = node.param1, param2 = node.param2 })
			end,
		},
	},
})



minetest.register_node ("lwroad_tracks:boom_gate_mesecons", {
	description = S("Mesecons Boom Gate"),
	tiles = {
		"lwroads_boom_mesecons_top.png", "lwroads_boom_mesecons_top.png",
		"lwroads_boom_mesecons_side.png", "lwroads_boom_mesecons_side.png",
		"lwroads_boom_mesecons_front.png", "lwroads_boom_mesecons_front.png"
	},
	groups = { choppy = 2 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.485, 0.5},
			{-0.5, 0.25, -0.125, 0.5, 0.5, 0.125},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			{-0.5, 0.25, -0.125, 0.5, 0.5, 0.125},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4999, 0.5},
			{-0.5, 0.25, -0.125, 0.5, 0.5, 0.125},
		}
	},
	sounds = default.node_sound_wood_defaults (),

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_on = function (pos, node)
				minetest.swap_node (pos, { name = "lwroad_tracks:boom_gate_mesecons_open",
													param1 = node.param1, param2 = node.param2 })
			end,
		},
	},
})



-- Mesecons stop line
minetest.register_node ("lwroad_tracks:stop_line_go", {
	description = S("Stop Line"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.485, 0.5},
		}
	},
	tiles = {
		"lwroads_stop_line.png", "lwroads_blank.png",
		"lwroads_blank.png", "lwroads_blank.png",
		"lwroads_blank.png", "lwroads_blank.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	use_texture_alpha = "clip",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4999, 0.5},
		}
	},
	sounds = default.node_sound_dirt_defaults (),
	groups = lwroad_tracks.get_track_groups ({ not_in_creative_inventory = 1, dig_immediate = 2 }),
	drop = "lwroad_tracks:stop_line",

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_off = function (pos, node)
				minetest.swap_node (pos, { name = "lwroad_tracks:stop_line",
													param1 = node.param1, param2 = node.param2 })
			end,
		},
	},
})



minetest.register_node ("lwroad_tracks:stop_line", {
	description = S("Stop Line"),
	tiles = {
		"lwroads_stop_line.png", "lwroads_blank.png",
		"lwroads_blank.png", "lwroads_blank.png",
		"lwroads_blank.png", "lwroads_blank.png"
	},
	wield_image = "lwroads_stop_line.png",
	inventory_image = "lwroads_stop_line.png",
	groups = { dig_immediate = 2 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.485, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4999, 0.5},
		}
	},
	sounds = default.node_sound_wood_defaults (),

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_on = function (pos, node)
				minetest.swap_node (pos, { name = "lwroad_tracks:stop_line_go",
													param1 = node.param1, param2 = node.param2 })
			end,
		},
	},
})


end -- mesecons loaded



--
