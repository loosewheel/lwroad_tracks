local utils = ...


utils.settings = { }

utils.settings.speed_max =
	tonumber (minetest.settings:get ("lwroad_tracks_speed_max") or 10)

utils.settings.punch_speed_max =
	tonumber (minetest.settings:get ("lwroad_tracks_punch_speed_max") or 7)

-- Maximal distance for the path correction (for dtime peaks)
utils.settings.path_distance_max = 3

--
