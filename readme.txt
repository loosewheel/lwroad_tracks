LWRoad_Tracks
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
0.1.3


Minetest Version
================
This mod was developed on version 5.3.0


Dependencies
============
default
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
is derived from the boost_cart mod.

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


Road Track
Basic track.

Powered Track
Accelerates a car on the track when mesecons power is applied.

Brake Track
Decelerates a car on the track when mesecons power is applied.

Start-stop track
When not powered will stop a car that rolls onto the track. Accelerates a
car on the track when mesecons power is applied.

Detector Track
Emits 0.5 second mesecons power when a car is on the track.

Boom Gate
Can be toggled opened and closed by right clicking or with a mesecons' power
pulse.

Mesecons Boom Gate
Only open when mesecons power is applied.

Stop Line
Will only allow a car to pass it mesecons power is applied.

Traffic Light
Displays red when not powered, and green when powered.


Boom gates and the stop line can only be placed on flat straight track. Tracks
do not automatically connect to them, the layout of tracks must be led up
to it. Their rotation depends on player direction when placed.

Tracks that accept mesecons power can be connected on the sides and below,
including a vertical mesecons wire below the block the track is on.


The mod supports the following settings:

Maximal speed
	Maximal speed of the car in m/s (min=1, max=100) (int)
	default: 10


Maximal punch speed (int)
	Maximal speed to which the driving player can accelerate the car by punching
	from inside the car. -1 will disable this feature. (min=-1, max=100)
	default: 7


An api is exposed to register cars and tracks. See mod_api.txt.
