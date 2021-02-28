local utils = ...



if minetest.get_translator and minetest.get_translator ("lwroad_tracks") then
	utils.S = minetest.get_translator ("lwroad_tracks")
elseif minetest.global_exists ("intllib") then
   if intllib.make_gettext_pair then
      utils.S = intllib.make_gettext_pair ()
   else
      utils.S = intllib.Getter ()
   end
else
   utils.S = function (s) return s end
end

local S = utils.S



utils.modpath = minetest.get_modpath ("lwroad_tracks")



local function turnoff_detector_rail (pos)
	local node = minetest.get_node (pos)

	if minetest.get_item_group (node.name, "detector_rail") == 1 then
		if node.name == "lwroad_tracks:detectortrack_on" then --has not been dug
			minetest.swap_node (pos, { name = "lwroad_tracks:detectortrack", param2 = node.param2 })
		end

		mesecon.receptor_off (pos, mesecon.rules.flat)
	end
end



local function signal_detector_rail (pos)
	local node = minetest.get_node (pos)

	if minetest.get_item_group (node.name, "detector_rail") ~= 1 then
		return
	end

	if node.name == "lwroad_tracks:detectortrack" then
		minetest.swap_node (pos, { name = "lwroad_tracks:detectortrack_on", param2 = node.param2 } )
	end

	mesecon.receptor_on (pos, mesecon.rules.flat)
	minetest.after (0.5, turnoff_detector_rail, pos)
end



local function on_rail_step (entity, pos, distance)
	-- Play car sound
	if entity.sound_counter <= 0 then
		minetest.sound_play ("car", {
			pos = pos,
			max_hear_distance = 40,
			gain = 0.5
		})

		entity.sound_counter = math.random(4, 15)
	end

	entity.sound_counter = entity.sound_counter - distance

	if boost_cart.MESECONS then
		signal_detector_rail (pos)
	end
end



local function on_rightclick (self, clicker)
	if not clicker or not clicker:is_player () then
		return
	end

	local player_name = clicker:get_player_name ()
	if self.driver and player_name == self.driver then
		self.driver = nil
		boost_cart:manage_attachment (clicker, nil)

	elseif not self.driver then
		self.driver = player_name
		boost_cart:manage_attachment (clicker, self.object)

		if default.player_set_animation then
			-- player_api(/default) does not update the animation
			-- when the player is attached, reset to default animation
			default.player_set_animation (clicker, "stand")
		end
	end
end



local function on_activate (self, staticdata, dtime_s)
	self.object:set_armor_groups ({ immortal = 1 })
	self.sound_counter = math.random (4, 15)

	if string.sub (staticdata, 1, string.len ("return")) ~= "return" then
		return
	end

	local data = minetest.deserialize (staticdata)
	if type (data) ~= "table" then
		return
	end

	self.railtype = data.railtype
	self.old_dir = data.old_dir or self.old_dir
	self.old_pos = data.old_pos or self.old_pos

	self.itemname = data.itemname
	self.texture = data.texture
	self.texture_stop = data.texture_stop

	-- Correct the position when the cart drives further after the last 'step()'
	if self.old_pos and boost_cart:is_rail (self.old_pos, self.railtype) then
		self.object:set_pos (self.old_pos)
	end
end



local function get_staticdata (self)
	return minetest.serialize ({
		railtype = self.railtype,
		old_dir = self.old_dir,
		old_pos = self.old_pos,
		itemname = self.itemname,
		texture = self.texture,
		texture_stop = self.texture_stop
	})
end



-- 0.5.x and later: When the driver leaves
local function on_detach_child (self, child)
	if child and child:get_player_name () == self.driver then
		self.driver = nil
		boost_cart:manage_attachment (child, nil)
	end
end



local function on_punch (self, puncher, time_from_last_punch, tool_capabilities, direction)
	local pos = self.object:get_pos ()
	local vel = self.object:get_velocity ()

	if not self.railtype or vector.equals (vel, { x = 0, y = 0, z = 0 }) then
		local node = minetest.get_node (pos).name
		self.railtype = minetest.get_item_group (node, "connect_to_raillike")
	end

	if not puncher or not puncher:is_player () then
		local cart_dir = boost_cart:get_rail_direction (pos, self.old_dir, nil, nil, self.railtype)

		if vector.equals (cart_dir, { x = 0, y = 0, z = 0 }) then
			return
		end

		self.velocity = vector.multiply (cart_dir, 3)
		self.punched = true

		return
	end

	if puncher:get_player_control ().sneak then
		-- Pick up cart: Drop all attachments
		if self.driver then
			if self.old_pos then
				self.object:set_pos (self.old_pos)
			end

			local player = minetest.get_player_by_name (self.driver)
			boost_cart:manage_attachment (player, nil)
		end

		for _, obj_ in pairs (self.attached_items) do
			if obj_ then
				obj_:set_detach ()
			end
		end

		local leftover = puncher:get_inventory ():add_item ("main", self.itemname)
		if not leftover:is_empty () then
			minetest.add_item (pos, leftover)
		end

		self.object:remove ()

		return
	end

	-- Driver punches to accelerate the cart
	if puncher:get_player_name () == self.driver then
		if math.abs (vel.x + vel.z) > boost_cart.punch_speed_max then
			return
		end
	end

	local punch_dir = boost_cart:velocity_to_dir (puncher:get_look_dir ())
	punch_dir.y = 0
	local cart_dir = boost_cart:get_rail_direction (pos, punch_dir, nil, nil, self.railtype)

	if vector.equals (cart_dir, { x = 0, y = 0, z = 0 }) then
		return
	end

	local punch_interval = 1

	if tool_capabilities and tool_capabilities.full_punch_interval then
		punch_interval = tool_capabilities.full_punch_interval
	end

	time_from_last_punch = math.min (time_from_last_punch or punch_interval, punch_interval)
	local f = 3 * (time_from_last_punch / punch_interval)

	self.velocity = vector.multiply (cart_dir, f)
	self.old_dir = cart_dir
	self.punched = true
end



local v3_len = vector.length

local function on_step (self, dtime)
	local vel = self.object:get_velocity ()

	if self.punched then
		vel = vector.add (vel, self.velocity)
		self.object:set_velocity (vel)
		self.old_dir.y = 0

	elseif vector.equals (vel, { x = 0, y = 0, z = 0 }) then
		local ctrl, player

		-- Get player controls
		if self.driver then
			player = minetest.get_player_by_name (self.driver)

			if player then
				ctrl = player:get_player_control ()

				if ctrl and ctrl.up then
					self.object:punch (player, 0.3, { full_punch_interval = 1 }, nil)
				end
			end
		end

		return

	end

	local ctrl, player
	local distance = 1

	-- Get player controls
	if self.driver then
		player = minetest.get_player_by_name (self.driver)

		if player then
			ctrl = player:get_player_control ()
		end
	end

	local pos = self.object:get_pos ()
	local cart_dir = boost_cart:velocity_to_dir (vel)
	local same_dir = vector.equals (cart_dir, self.old_dir)
	local update = {}

	if (self.old_pos and not self.punched and same_dir) and not (ctrl and ctrl.up) then
		local flo_pos = vector.round (pos)
		local flo_old = vector.round (self.old_pos)

		if vector.equals (flo_pos, flo_old) then
			-- Do not check one node multiple times
			return
		end
	end

	local stop_wiggle = false

	if self.old_pos and same_dir then
		-- Detection for "skipping" nodes (perhaps use average dtime?)
		-- It's sophisticated enough to take the acceleration in account
		local acc = self.object:get_acceleration ()
		distance = dtime * (v3_len (vel) + 0.5 * dtime * v3_len (acc))

		local new_pos, new_dir = boost_cart:pathfinder (
			pos, self.old_pos, self.old_dir, distance, ctrl,
			self.old_switch, self.railtype)

		if new_pos then
			-- No rail found: set to the expected position
			pos = new_pos
			update.pos = true
			cart_dir = new_dir
		end

	elseif self.old_pos and self.old_dir.y ~= 1 and not self.punched then
		-- Stop wiggle
		stop_wiggle = true
	end

	-- dir:         New moving direction of the cart
	-- switch_keys: Currently pressed L(1) or R(2) key,
	--              used to ignore the key on the next rail node
	local dir, switch_keys = boost_cart:get_rail_direction (
		pos, cart_dir, ctrl, self.old_switch, self.railtype)

	local dir_changed = not vector.equals (dir, self.old_dir)

	local acc = 0
	local brakes_on = false

	if stop_wiggle or vector.equals (dir, { x = 0, y = 0, z = 0 }) then
		vel = { x=0, y=0, z=0 }
		local pos_r = vector.round (pos)

		if not boost_cart:is_rail (pos_r, self.railtype) and self.old_pos then
			pos = self.old_pos
		elseif not stop_wiggle then
			pos = pos_r
		else
			pos.y = math.floor (pos.y + 0.5)
		end

		update.pos = true
		update.vel = true

	else
		-- Direction change detected
		if dir_changed then
			vel = vector.multiply (dir, math.abs (vel.x + vel.z))
			update.vel = true

			if dir.y ~= self.old_dir.y then
				pos = vector.round (pos)
				update.pos = true
			end

		end

		-- Center on the rail
		if dir.z ~= 0 and math.floor (pos.x + 0.5) ~= pos.x then
			pos.x = math.floor (pos.x + 0.5)
			update.pos = true
		end

		if dir.x ~= 0 and math.floor (pos.z + 0.5) ~= pos.z then
			pos.z = math.floor (pos.z + 0.5)
			update.pos = true
		end

		-- Calculate current cart acceleration
		acc = nil

		local acc_meta = minetest.get_meta (pos):get_string ("cart_acceleration")

		if acc_meta == "halt" and not self.punched then
			-- Stop rail
			vel = { x = 0, y = 0, z = 0 }
			acc = false
			pos = vector.round (pos)
			update.pos = true
			update.vel = true
		end

		if acc == nil then
			-- Meta speed modifier
			local speed_mod = tonumber (acc_meta)

			if speed_mod and speed_mod ~= 0 then
				-- Try to make it similar to the original carts mod
				acc = speed_mod * 10
			end
		end

		if acc == nil and boost_cart.MTG_CARTS then
			-- MTG Cart API adaption
			local rail_node = minetest.get_node (vector.round (pos))
			local railparam = carts.railparams[rail_node.name]

			if railparam and railparam.acceleration then
				acc = railparam.acceleration
			end
		end

		if acc ~= false then
			-- Handbrake
			if ctrl and ctrl.down then
				acc = (acc or 0) - 2
				brakes_on = true
			elseif ctrl and ctrl.up then
				acc = (acc or 0) + 2
			elseif acc == nil then
				acc = -0.4
			end
		end

		if ctrl and ctrl.sneak then
			-- Descend when sneak is pressed
			boost_cart:manage_attachment (player, nil)
			player = nil
			ctrl = nil
		end

		if acc then
			-- Slow down or speed up, depending on Y direction
			acc = acc + dir.y * -2.1
		else
			acc = 0
		end
	end

	-- Limit cart speed
	local vel_len = vector.length (vel)

	if vel_len > boost_cart.speed_max then
		vel = vector.multiply (vel, boost_cart.speed_max / vel_len)
		update.vel = true
	end

	if vel_len >= boost_cart.speed_max and acc > 0 then
		acc = 0
	end

	self.object:set_acceleration (vector.multiply (dir, acc))

	self.old_pos = vector.round (pos)
	local old_y_dir = self.old_dir.y

	if not vector.equals (dir, { x = 0, y = 0, z = 0 }) and not stop_wiggle then
		self.old_dir = dir
	else
		-- Cart stopped, set the animation to 0
		self.old_dir.y = 0
	end

	self.old_switch = switch_keys

	on_rail_step (self, self.old_pos, distance)

	if self.punched then
		-- Collect dropped items
		for _, obj_ in pairs (minetest.get_objects_inside_radius (pos, 1)) do
			local ent = obj_:get_luaentity ()

			-- Careful here: physical_state and disable_physics are item-internal APIs
			if ent and ent.name == "__builtin:item" and ent.physical_state then
				-- Check API to support 5.2.0 and older
				if ent.disable_physics then
					ent:disable_physics ()
				end

				obj_:set_attach (self.object, "", { x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
				self.attached_items[#self.attached_items + 1] = obj_
			end
		end

		self.punched = false
		update.vel = true
	end

	if brakes_on then
		self.object:set_texture_mod (self.texture_stop)
	else
		self.object:set_texture_mod ("")
	end

	if not (update.vel or update.pos) then
		return
	end

	-- Re-use "dir", localize self.old_dir
	dir = self.old_dir

	local yaw = 0
	if dir.x < 0 then
		yaw = 0.5
	elseif dir.x > 0 then
		yaw = 1.5
	elseif dir.z < 0 then
		yaw = 1
	end

	self.object:set_yaw (yaw * math.pi)


	local anim = { x = 0, y = 0 }

	if dir.y == -1 then
		anim = { x = 1, y = 1 }
	elseif dir.y == 1 then
		anim = { x = 2, y = 2 }
	end

	self.object:set_animation (anim, 1, 0)


	-- Change player model rotation, depending on the Y direction
	if player and dir.y ~= old_y_dir then
		local feet = { x = 0, y = -4, z = 0 }
		local eye = { x = 0, y = -4, z = 0 }

		if dir.y ~= 0 then
			-- TODO: Find a better way to calculate this
			feet.y = feet.y + 4
			feet.z = -dir.y * 2

			eye.z = -dir.y * 8
		end

		player:set_attach (self.object, "", feet,
								 { x = dir.y * -30, y = 0, z =0 } )
		player:set_eye_offset (eye, eye)
	end

	if update.vel then
		self.object:set_velocity (vel)
	end

	if update.pos then
		if dir_changed then
			self.object:set_pos (pos)
		else
			self.object:move_to (pos)
		end
	end
end




function utils.register_car (itemname, name, mesh, texture, texture_stop,
									  texture_top, texture_front, texture_side)
	local car_entity = {
		initial_properties = {
			physical = false,
			collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			visual = "mesh",
			mesh = mesh,
			visual_size = { x = 1, y = 1 },
			textures = { texture },
		},

		driver = nil,
		punched = false, -- used to re-send velocity and position
		velocity = { x = 0, y = 0, z = 0 }, -- only used on punch
		old_dir = { x = 1, y = 0, z = 0 }, -- random value to start the cart on punch
		old_pos = nil,
		old_switch = 0,
		sound_counter = 0,
		railtype = nil,
		attached_items = {},
		itemname = itemname,
		texture = texture,
		texture_stop = "^"..texture_stop,

		on_activate = on_activate,
		on_rightclick = on_rightclick,
		get_staticdata = get_staticdata,
		on_detach_child = on_detach_child,
		on_punch = on_punch,
		on_step = on_step,
	}

	minetest.register_entity (itemname, car_entity)

-- Register item to place the entity
--if not boost_cart.MTG_CARTS then
	minetest.register_craftitem (itemname, {
		description = S(name.." (Sneak+Click to pick up)"),
		inventory_image = minetest.inventorycube (
			texture_top,
			texture_front,
			texture_side
		),
		wield_image = texture_front,

		on_place = function (itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" then
				return
			end

			if boost_cart:is_rail (pointed_thing.under) then
				minetest.add_entity (pointed_thing.under, itemname)
			elseif boost_cart:is_rail (pointed_thing.above) then
				minetest.add_entity (pointed_thing.above, itemname)
			else
				return
			end

			if not minetest.settings:get_bool ("creative_mode") then
				itemstack:take_item ()
			end

			return itemstack
		end,
	})
--end
end
