local version = "0.1.0"


if boost_cart and dye then



lwroad_tracks = {}



function lwroad_tracks.version ()
	return version
end



local utils = { }



modpath = minetest.get_modpath ("lwroad_tracks")

loadfile (modpath.."/utils.lua") (utils)
loadfile (modpath.."/tracks.lua") (utils)
loadfile (modpath.."/cars.lua") (utils)
loadfile (modpath.."/crafting.lua") (utils)



end

--
