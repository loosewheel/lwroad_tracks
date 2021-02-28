local utils = ...
local S = utils.S



boost_cart:register_rail ("lwroad_tracks:track", {
	description = S("Road Track"),
	tiles = {
		"track_straight.png", "track_curved.png",
		"track_t_junction.png", "track_crossing.png"
	},
	groups = boost_cart:get_rail_groups ()
})



-- Power track
boost_cart:register_rail ("lwroad_tracks:powertrack", {
	description = S("Powered track"),
	tiles = {
		"powertrack_straight.png", "powertrack_curved.png",
		"powertrack_t_junction.png", "powertrack_crossing.png"
	},
	groups = boost_cart:get_rail_groups (),

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



-- only if msescons loaded - Detector track
if mesecon then


boost_cart:register_rail ("lwroad_tracks:detectortrack", {
	description = "Detector track",
	tiles = {
		"detectortrack_straight.png", "detectortrack_curved.png",
		"detectortrack_t_junction.png", "detectortrack_crossing.png"
	},
	groups = boost_cart:get_rail_groups ({ detector_rail = 1 }),

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
	drop = "lwroad_tracks:detectortrack",

	mesecons = { receptor = { state = "on", rules = mesecon.rules.flat } },
})


end -- mesecons loaded

--
