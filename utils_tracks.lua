local utils = ...



function utils.velocity_to_dir (v)
	if math.abs (v.x) > math.abs (v.z) then
		return { x = utils.get_sign (v.x), y = utils.get_sign (v.y), z = 0 }
	else
		return { x = 0, y = utils.get_sign (v.y), z = utils.get_sign (v.z) }
	end
end



function utils.is_track (pos, railtype)
	local node = utils.get_far_node (pos)

	if node then
		local lwroads_track = minetest.get_item_group (node.name, "lwroads_track")

		if lwroads_track > 0 then
			if not railtype then
				return true
			end

			return minetest.get_item_group (node.name, "connect_to_raillike") == railtype
		end
	end

	return false
end




function utils.check_front_up_down (pos, dir_, check_up, railtype)
	local dir = vector.new (dir_)

	-- Front
	dir.y = 0
	if utils.is_track (vector.add (pos, dir), railtype) then
		return dir
	end

	-- Up
	if check_up then
		dir.y = 1
		if utils.is_track (vector.add (pos, dir), railtype) then
			return dir
		end
	end

	-- Down
	dir.y = -1
	if utils.is_track (vector.add (pos, dir), railtype) then
		return dir
	end

	return nil
end



function utils.get_track_direction (pos_, dir, ctrl, old_switch, railtype)
	local pos = vector.round (pos_)
	local left_check, right_check = true, true

	-- Check left and right
	local left = { x = 0, y = 0, z = 0 }
	local right = { x = 0, y = 0, z = 0 }
	if dir.z ~= 0 and dir.x == 0 then
		left.x = -dir.z
		right.x = dir.z
	elseif dir.x ~= 0 and dir.z == 0 then
		left.z = dir.x
		right.z = -dir.x
	end

	local straight_priority = ctrl and dir.y ~= 0

	-- Normal, to disallow rail switching up- & downhill
	if straight_priority then
		local cur = utils.check_front_up_down (pos, dir, true, railtype)

		if cur then
			return cur
		end
	end

	if ctrl then
		if old_switch == 1 then
			left_check = false
		elseif old_switch == 2 then
			right_check = false
		end

		if ctrl.left and left_check then
			local cur = utils.check_front_up_down (pos, left, false, railtype)

			if cur then
				return cur, 1
			end

			left_check = false
		end

		if ctrl.right and right_check then
			local cur = utils.check_front_up_down (pos, right, false, railtype)

			if cur then
				return cur, 2
			end

			right_check = true
		end
	end

	-- Normal
	if not straight_priority then
		local cur = utils.check_front_up_down (pos, dir, true, railtype)

		if cur then
			return cur
		end
	end

	-- Left, if not already checked
	if left_check then
		local cur = utils.check_front_up_down (pos, left, false, railtype)

		if cur then
			return cur
		end
	end

	-- Right, if not already checked
	if right_check then
		local cur = utils.check_front_up_down (pos, right, false, railtype)

		if cur then
			return cur
		end
	end

	-- Backwards
	if not old_switch then
		local cur = utils.check_front_up_down (
			pos,
			{
				x = -dir.x,
				y = dir.y,
				z = -dir.z
			},
			true,
			railtype)

		if cur then
			return cur
		end
	end

	return { x = 0, y = 0, z = 0 }
end



function utils.pathfinder (pos_, old_pos, old_dir, distance, ctrl,
									pf_switch, railtype)

	local pos = vector.round (pos_)
	if vector.equals (old_pos, pos) then
		return
	end

	local pf_pos = vector.round (old_pos)
	local pf_dir = vector.new (old_dir)
	distance = math.min (utils.settings.path_distance_max, math.floor (distance + 1))

	for i = 1, distance, 1 do
		pf_dir, pf_switch = utils.get_track_direction (
			pf_pos, pf_dir, ctrl, pf_switch or 0, railtype)

		if vector.equals (pf_dir, { x = 0, y = 0, z = 0 }) then
			-- No way forwards
			return pf_pos, pf_dir
		end

		pf_pos = vector.add (pf_pos, pf_dir)

		if vector.equals (pf_pos, pos) then
			-- Success! Cart moved on correctly
			return
		end
	end

	-- Not found. Put cart to predicted position
	return pf_pos, pf_dir
end



-- MOD api
function lwroad_tracks.boost_track (pos, amount)
	if utils.is_track (pos, nil) then
		minetest.get_meta (pos):set_string ("lwroads_acceleration", tostring(amount))

		for _,obj_ in ipairs(minetest.get_objects_inside_radius (pos, 0.5)) do
			if not obj_:is_player () and obj_:get_luaentity () and
				obj_:get_luaentity ().lwroad_is_car then

				obj_:get_luaentity ():on_punch ()
			end
		end
	end
end



-- MOD api
function lwroad_tracks.register_track (name, def)
	local sound_func = default.node_sound_dirt_defaults
								or default.node_sound_defaults

	local def_default = {
		drawtype = "raillike",
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = { -1/2, -1/2, -1/2, 1/2, -1/2 + 1/16, 1/2 },
		},
		sounds = sound_func ()
	}

	for k, v in pairs(def) do
		def_default[k] = v
	end

	if not def_default.inventory_image then
		def_default.wield_image = def_default.tiles[1]
		def_default.inventory_image = def_default.tiles[1]
	end

	minetest.register_node (name, def_default)
end



-- MOD api
function lwroad_tracks.get_track_groups (additional_groups)
	-- Get the default rail groups and add more when a table is given
	local groups = {
		attached_node = 1,
		lwroads_track = 1,
		connect_to_raillike = 1
	}

	if minetest.raillike_group then
		groups.connect_to_raillike = minetest.raillike_group ("lwroads_track")
	end

	if type (additional_groups) == "table" then
		for k, v in pairs (additional_groups) do
			groups[k] = v
		end
	end

	return groups
end



local function turnoff_detector_track (pos)
	local node = utils.get_far_node (pos)

	if minetest.get_item_group (node.name, "detector_rail") == 1 then
		if node.name == "lwroad_tracks:detectortrack_on" then --has not been dug
			minetest.swap_node (pos, { name = "lwroad_tracks:detectortrack", param2 = node.param2 })
		end

		mesecon.receptor_off (pos, utils.mesecons_rules)
	end
end



local function signal_detector_track (pos)
	local node = utils.get_far_node (pos)

	if minetest.get_item_group (node.name, "detector_rail") ~= 1 then
		return
	end

	if node.name == "lwroad_tracks:detectortrack" then
		minetest.swap_node (pos, { name = "lwroad_tracks:detectortrack_on", param2 = node.param2 } )

		mesecon.receptor_on (pos, utils.mesecons_rules)
		minetest.after (0.5, turnoff_detector_track, pos)
	end
end



function utils.on_track_step (entity, pos, distance)
	local sound = "lwroads_rev"

	if math.random (20) == 10 then
		sound = "lwroads_horn"
	end

	-- Play car sound
	if entity.sound_counter <= 0 then
		minetest.sound_play (sound, {
			pos = pos,
			max_hear_distance = 40,
			gain = 0.5
		})

		entity.sound_counter = math.random (4, 15)
	end

	entity.sound_counter = entity.sound_counter - distance

	if utils.mesecons_supported then
		signal_detector_track (pos)
	end
end



--
