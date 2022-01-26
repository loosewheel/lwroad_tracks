local version = "0.1.1"


if boost_cart and dye then
local mod_storage = minetest.get_mod_storage ()



lwroad_tracks = {}



function lwroad_tracks.version ()
	return version
end



local utils = { }



modpath = minetest.get_modpath ("lwroad_tracks")

loadfile (modpath.."/utils.lua") (utils, mod_storage)
loadfile (modpath.."/tracks.lua") (utils)
loadfile (modpath.."/cars.lua") (utils)
loadfile (modpath.."/crafting.lua") (utils)



end

--
