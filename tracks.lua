local utils = ...
local S = utils.S



boost_cart:register_rail ("lwroad_tracks:track", {
	description = S("Road Track"),
	tiles = {
		"track_straight.png", "track_curved.png",
		"track_t_junction.png", "track_crossing.png"
	},
	groups = boost_cart:get_rail_groups (),
	sounds = default.node_sound_dirt_defaults ()
})



-- Power track
boost_cart:register_rail ("lwroad_tracks:powertrack", {
	description = S("Powered track"),
	tiles = {
		"powertrack_straight.png", "powertrack_curved.png",
		"powertrack_t_junction.png", "powertrack_crossing.png"
	},
	groups = boost_cart:get_rail_groups (),
	sounds = default.node_sound_dirt_defaults (),

	after_place_node = function (pos, placer, itemstack)
		if not mesecon then
			minetest.get_meta (pos):set_string ("cart_acceleration", "0.5")
		end
	end,

	mesecons = {
		effector = {
			action_on = function (pos, node)
				boost_cart:boost_rail (pos, 0.5)
			end,

			action_off = function (pos, node)
				minetest.get_meta (pos):set_string ("cart_acceleration", "0")
			end,
		},
	},
})



-- Brake track
boost_cart:register_rail ("lwroad_tracks:braketrack", {
	description = S("Brake track"),
	tiles = {
		"braketrack_straight.png", "braketrack_curved.png",
		"braketrack_t_junction.png", "braketrack_crossing.png"
	},
	groups = boost_cart:get_rail_groups (),
	sounds = default.node_sound_dirt_defaults (),

	after_place_node = function (pos, placer, itemstack)
		if not mesecon then
			minetest.get_meta (pos):set_string ("cart_acceleration", "-0.3")
		end
	end,

	mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.get_meta (pos):set_string ("cart_acceleration", "-0.3")
			end,

			action_off = function (pos, node)
				minetest.get_meta (pos):set_string ("cart_acceleration", "0")
			end,
		},
	},
})



-- Start/Stop track
boost_cart:register_rail ("lwroad_tracks:startstoptrack", {
	description = S("Start-stop track"),
	tiles = {
		"startstoptrack_straight.png", "startstoptrack_curved.png",
		"startstoptrack_t_junction.png", "startstoptrack_crossing.png"
	},
	groups = boost_cart:get_rail_groups (),
	sounds = default.node_sound_dirt_defaults (),

	after_place_node = function (pos, placer, itemstack)
		if not mesecon then
			minetest.get_meta (pos):set_string ("cart_acceleration", "halt")
		end
	end,

	mesecons = {
		effector = {
			action_on = function (pos, node)
				boost_cart:boost_rail (pos, 0.5)
			end,

			action_off = function (pos, node)
				minetest.get_meta (pos):set_string ("cart_acceleration", "halt")
			end,
		},
	},
})



local boom_gate_groups = boost_cart:get_rail_groups ({ not_in_creative_inventory = 1, choppy = 2 })
boom_gate_groups.dig_immediate = nil


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
		"lwboom_top.png", "lwboom_top.png",
		"lwboom_side.png", "lwboom_side.png",
		"lwboom_front.png", "lwboom_front.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	use_texture_alpha = "blend",
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
	groups = boom_gate_groups,
	drop = "lwroad_tracks:boom_gate",

	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		minetest.swap_node (pos, { name = "lwroad_tracks:boom_gate",
											param1 = node.param1, param2 = node.param2 })
	end,

	mesecons = {
		effector = {
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
		"lwboom_top.png", "lwboom_top.png",
		"lwboom_side.png", "lwboom_side.png",
		"lwboom_front.png", "lwboom_front.png"
	},
	groups = { choppy = 2 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	use_texture_alpha = "blend",
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
	sounds = default.node_sound_dirt_defaults (),

	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		minetest.swap_node (pos, { name = "lwroad_tracks:boom_gate_open",
											param1 = node.param1, param2 = node.param2 })
	end,

	mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node (pos, { name = "lwroad_tracks:boom_gate_open",
													param1 = node.param1, param2 = node.param2 })
			end,
		},
	},
})



-- only if mesecons loaded
if minetest.global_exists ("mesecon") then


-- Detector track
boost_cart:register_rail ("lwroad_tracks:detectortrack", {
	description = "Detector track",
	tiles = {
		"detectortrack_straight.png", "detectortrack_curved.png",
		"detectortrack_t_junction.png", "detectortrack_crossing.png"
	},
	groups = boost_cart:get_rail_groups ({ detector_rail = 1 }),
	sounds = default.node_sound_dirt_defaults (),

	mesecons = { receptor = { state = "off", rules = mesecon.rules.flat } },
})



boost_cart:register_rail ("lwroad_tracks:detectortrack_on", {
	description = "Detector track",
	tiles = {
		"detectortrack_on_straight.png", "detectortrack_on_curved.png",
		"detectortrack_on_t_junction.png", "detectortrack_on_crossing.png"
	},
	groups = boost_cart:get_rail_groups({
		detector_rail = 1,
		not_in_creative_inventory = 1
	}),
	sounds = default.node_sound_dirt_defaults (),
	drop = "lwroad_tracks:detectortrack",

	mesecons = { receptor = { state = "on", rules = mesecon.rules.flat } },
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
		"lwboom_mesecons_top.png", "lwboom_mesecons_top.png",
		"lwboom_mesecons_side.png", "lwboom_mesecons_side.png",
		"lwboom_mesecons_front.png", "lwboom_mesecons_front.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	use_texture_alpha = "blend",
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
	groups = boom_gate_groups,
	drop = "lwroad_tracks:boom_gate_mesecons",

	mesecons = {
		effector = {
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
		"lwboom_mesecons_top.png", "lwboom_mesecons_top.png",
		"lwboom_mesecons_side.png", "lwboom_mesecons_side.png",
		"lwboom_mesecons_front.png", "lwboom_mesecons_front.png"
	},
	groups = { choppy = 2 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = true,
	use_texture_alpha = "blend",
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
	sounds = default.node_sound_dirt_defaults (),

	mesecons = {
		effector = {
			action_on = function (pos, node)
				minetest.swap_node (pos, { name = "lwroad_tracks:boom_gate_mesecons_open",
													param1 = node.param1, param2 = node.param2 })
			end,
		},
	},
})


end -- mesecons loaded


--
