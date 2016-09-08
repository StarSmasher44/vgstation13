// the underfloor wiring terminal for the APC
// autogenerated when an APC is placed
// all conduit connects go to this object instead of the APC
// using this solves the problem of having the APC in a wall yet also inside an area

/obj/machinery/power/terminal
	name = "terminal"
	icon_state = "term"
	desc = "It's an underfloor wiring terminal for power equipment."
	level = 1
	plane = ABOVE_PLATING_PLANE
	var/obj/machinery/power/master
	anchored = 1
	layer = WIRE_TERMINAL_LAYER

	holomap = TRUE
	auto_holomap = TRUE


/obj/machinery/power/terminal/New()
	..()
	var/turf/T = src.loc
	if(level==1)
		hide(T.intact)
	return


/obj/machinery/power/terminal/hide(var/i)
	if(i)
		invisibility = 101
		icon_state = "term-f"
	else
		invisibility = 0
		icon_state = "term"

/obj/machinery/power/terminal/t_scanner_expose()
	if (level != LEVEL_BELOW_FLOOR)
		return

	invisibility = 0
	plane = ABOVE_TURF_PLANE

	spawn(1 SECONDS)
		var/turf/U = loc
		if(istype(U) && U.intact)
			invisibility = 101
			plane = initial(plane)

/obj/machinery/power/terminal/Destroy()
	if (master)
		master:terminal = null
		master = null

	..()

/obj/machinery/power/terminal/attackby(obj/item/W, mob/user)
	if(iswirecutter(W) && !master) //Sanity in the rare case something destroys a machine and leaves a terminal
		getFromPool(/obj/item/stack/cable_coil, get_turf(src), 10)
		qdel(src)
		return
	..()

/obj/machinery/power/proc/make_terminal(mob/user)
	if(!can_attach_terminal(user))
		to_chat(user, "<span class='warning'>You can't wire \the [src] like that!</span>")
		return 0

	var/turf/T = get_turf(user)
	if(T.intact)
		to_chat(user, "<span class='warning'>The floor plating must be removed first.</span>")
		return 0

	to_chat(user, "<span class='notice'>You start adding cable to \the [src].</span>")
	playsound(get_turf(src), 'sound/items/zip.ogg', 100, 1)
	if (do_after(user, src, 100) && !T.intact && can_attach_terminal(user))

		//Shock chance
		var/obj/structure/cable/N = T.get_cable_node()
		if (prob(50) && electrocute_mob(user, N, N))
			var/datum/effect/effect/system/spark_spread/s = getFromPool(/datum/effect/effect/system/spark_spread)
			s.set_up(5, 1, src)
			s.start()
			return 0

		finalise_terminal(get_turf(user))
		return 1
	return 0

/obj/machinery/power/proc/finalise_terminal(newloc)
	terminal = new /obj/machinery/power/terminal(newloc)
	terminal.dir = get_dir(newloc, src)
	terminal.master = src

/obj/machinery/power/proc/can_attach_terminal(mob/user)
	return user.loc != src.loc && (get_dir(user, src) in cardinal) && !terminal
