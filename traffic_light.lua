local utils = ...
local S = utils.S



-- only if msescons loaded
if utils.mesecons_supported then


-- Mesecons traffic light
minetest.register_node ("lwroad_tracks:traffic_light_light", {
	description = S("Traffic Light"),
	drawtype = "airlike",
	light_source = 7,
	sunlight_propagates = true,
	walkable = true,
	pointable = false,
	diggable = false,
	climbable = false,
	buildable_to = false,
	floodable = false,
	is_ground_content = false,
	drop = "",
	groups = { not_in_creative_inventory = 1 },
	paramtype = "light",
	collision_box = {
		type = "fixed",
		fixed = {
			{-1/16, -8/16, -1/16, 1/16, 7/16, 1/16},
			{-3/16,  7/16, -2/16, 3/16, 10/16, 2/16}
		}
	},
	-- unaffected by explosions
	on_blast = function() end,
})



minetest.register_node ("lwroad_tracks:traffic_light_green", {
	description = S("Traffic Light"),
	tiles = { "lwroads_traffic_light.png" },
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "mesh",
	mesh = "lwroads_traffic_light_green.obj",
	selection_box = {
		type = "fixed",
		fixed = {
			{-1/16, -8/16, -1/16, 1/16, 15/16, 1/16},
			{-3/16,  15/16, -2/16, 3/16, 26/16, 2/16}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-1/16, -8/16, -1/16, 1/16, 15/16, 1/16},
			{-3/16,  15/16, -2/16, 3/16, 26/16, 2/16}
		}
	},
	sounds = default.node_sound_wood_defaults (),
	groups = { not_in_creative_inventory = 1, choppy = 2 },
	drop = "lwroad_tracks:traffic_light",

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_off = function (pos, node)
				minetest.swap_node (pos, { name = "lwroad_tracks:traffic_light",
													param1 = node.param1, param2 = node.param2 })
			end,
		},
	},

	on_destruct = function (pos)
		local above = { x = pos.x, y = pos.y + 1, z = pos.z }
		local node = utils.get_far_node (above)

		if node and node.name == "lwroad_tracks:traffic_light_light" then
			minetest.remove_node (above)
		end
	end,
})



minetest.register_node ("lwroad_tracks:traffic_light", {
	description = S("Traffic Light"),
	tiles = { "lwroads_traffic_light.png" },
	wield_image = "lwroads_traffic_light_item.png",
	inventory_image = "lwroads_traffic_light_item.png",
	groups = { choppy = 2 },
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "mesh",
	mesh = "lwroads_traffic_light_red.obj",
	selection_box = {
		type = "fixed",
		fixed = {
			{-1/16, -8/16, -1/16, 1/16, 15/16, 1/16},
			{-3/16,  15/16, -2/16, 3/16, 26/16, 2/16}
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-1/16, -8/16, -1/16, 1/16, 15/16, 1/16},
			{-3/16,  15/16, -2/16, 3/16, 26/16, 2/16}
		}
	},
	sounds = default.node_sound_wood_defaults (),

	mesecons = {
		effector = {
			rules = utils.mesecons_rules,

			action_on = function (pos, node)
				minetest.swap_node (pos, { name = "lwroad_tracks:traffic_light_green",
													param1 = node.param1, param2 = node.param2 })
			end,
		},
	},

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local pos = pointed_thing.under
			local node = utils.get_far_node (pos)
			local def = (node and minetest.registered_nodes[node.name]) or nil

			if not (node and (node.name == "air" or (def and def.buildable_to))) then
				pos = pointed_thing.above
				node = utils.get_far_node (pos)
				def = (node and minetest.registered_nodes[node.name]) or nil

				if not (node and (node.name == "air" or (def and def.buildable_to))) then
					return itemstack
				end

				node = utils.get_far_node ({ x = pos.x, y = pos.y + 1, z = pos.z })
				def = (node and minetest.registered_nodes[node.name]) or nil

				if not (node and (node.name == "air" or (def and def.buildable_to))) then
					return itemstack
				end
			end

			return minetest.item_place (itemstack, placer, pointed_thing)
		end

		return itemstack
	end,

	on_destruct = function (pos)
		local above = { x = pos.x, y = pos.y + 1, z = pos.z }
		local node = utils.get_far_node (above)

		if node and node.name == "lwroad_tracks:traffic_light_light" then
			minetest.remove_node (above)
		end
	end,

	after_place_node = function (pos, placer, itemstack, pointed_thing)
		minetest.set_node ({ x = pos.x, y = pos.y + 1, z = pos.z },
								 { name = "lwroad_tracks:traffic_light_light" })
	end,
})

end -- mesecons loaded



--
