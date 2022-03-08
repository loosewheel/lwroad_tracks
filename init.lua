local version = "0.1.4"
local mod_storage = minetest.get_mod_storage ()



lwroad_tracks = {}



function lwroad_tracks.version ()
	return version
end



local utils = { }

utils.modpath = minetest.get_modpath ("lwroad_tracks")

loadfile (utils.modpath.."/settings.lua") (utils)
loadfile (utils.modpath.."/utils.lua") (utils)
loadfile (utils.modpath.."/utils_tracks.lua") (utils)
loadfile (utils.modpath.."/utils_cars.lua") (utils, mod_storage)
loadfile (utils.modpath.."/tracks.lua") (utils)
loadfile (utils.modpath.."/cars.lua") ()
loadfile (utils.modpath.."/traffic_light.lua") (utils)
loadfile (utils.modpath.."/crafting.lua") (utils)



--
