LWComputers
	by loosewheel


Licence
=======
Code licence:
LGPL 2.1

Art licence:
CC BY 4.0

Sound licence:
CC BY 4.0


Version
=======
0.1.1


Minetest Version
================
This mod was developed on version 5.3.0


Dependencies
============
default
boost_cart
dye


Optional Dependencies
=====================
intllib
mesecons


Installation
============
Copy the 'lwroad_tracks' folder to your mods folder.


Bug Report
==========
https://forum.minetest.net/viewtopic.php?f=9&t=26361


Description
===========
Provides cars and road tracks, similar in function to rail carts. This mod
is derived from the boost_cart mod, and relies on it to run.

The road tracks act the same as rail tracks but have a tyre track texture.

The cars work the same as rail carts but also respond to the up/forward (W)
key to start and accelerate.

Controls:
Right click - mount/dismount.
Sneak+Right click - open car inventory.
Punch - start/accelerate.
Sneak+Punch - Dig (will not dig if inventory is not empty).
Up/forward (W) - start/accelerate.
Down/Back (S) - decelerate/stop.
Left (A) - turn left (if track allows).
Right (D) - turn right (if track allows).

Boom gates can only be placed on flat straight track. Tracks do not
automatically connect to boom gates, the layout of tracks must be led up
to it. Boom gate rotation depends on player direction when placed. Boom
gates can be toggled opened and closed by right clicking or with a
mesecons' power pulse. Mesecons boom gates are only open when mesecons
power is applied.

See boost_cart settings for mod settings that effect this mod.
