local utils, mod_storage = ...



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



utils.mesecons_supported = minetest.global_exists ("mesecon")
utils.player_api_supported = minetest.global_exists ("player_api")
utils.player_attached = {}


if utils.player_api_supported then
	-- This is a table reference!
	utils.player_attached = player_api.player_attached
end



utils.mesecons_rules =
{
	{ x = -1, y = -1, z =  0 },
	{ x = -1, y =  0, z =  0 },
	{ x = -1, y =  1, z =  0 },
	{ x =  1, y = -1, z =  0 },
	{ x =  1, y =  0, z =  0 },
	{ x =  1, y =  1, z =  0 },
	{ x =  0, y = -1, z = -1 },
	{ x =  0, y =  0, z = -1 },
	{ x =  0, y =  1, z = -1 },
	{ x =  0, y = -1, z =  1 },
	{ x =  0, y =  0, z =  1 },
	{ x =  0, y =  1, z =  1 },
	{ x =  0, y = -1, z =  0 },
	{ x =  0, y = -2, z =  0 },
}



function utils.get_far_node (pos)
	local node = minetest.get_node (pos)

	if node.name == "ignore" then
		minetest.get_voxel_manip ():read_from_map (pos, pos)

		node = minetest.get_node (pos)

		if node.name == "ignore" then
			return nil
		end
	end

	return node
end



function utils.get_sign (n)
	if n == 0 then
		return 0
	end

	return n / math.abs (n)
end



--
