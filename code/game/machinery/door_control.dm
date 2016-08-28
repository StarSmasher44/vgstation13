/obj/machinery/door_control
	name = "remote door-control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	power_channel = ENVIRON
	var/id_tag = null
	var/range = 10
	var/normaldoorcontrol = 0
	var/specialfunctions = 1
	/*
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties

	*/

	var/exposedwires = 0
	var/wires = 3
	/*
	Bitflag,	1=checkID
				2=Network Access
	*/

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

	ghost_read=0
	ghost_write=0

	machine_flags = EMAGGABLE | MULTITOOL_MENU

/obj/machinery/door_control/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	if(wires & 2)
		return src.attack_hand(user)
	else
		to_chat(user, "Error, no route to host.")

/obj/machinery/door_control/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_control/emag(mob/user)
	req_access = list()
	req_one_access = list()
	playsound(get_turf(src), "sparks", 100, 1)

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user as mob)
	..()
	..()
	/* For later implementation
	if (isscrewdriver(W))
	{
		if(wiresexposed)
			icon_state = "doorctrl0"
			wiresexposed = 0

		else
			icon_state = "doorctrl-open"
			wiresexposed = 1

		return
	}
	*/
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/door_control/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && (wires & 1))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		flick("doorctrl-denied",src)
		return

	use_power(5)
	icon_state = "doorctrl1"
	add_fingerprint(user)

	if(normaldoorcontrol)
		for(var/obj/machinery/door/airlock/D in range(range))
			if(D.id_tag == src.id_tag)
				spawn(0)
				if(D)
					if(D.density)
						D.open()
					else
						D.close()
					return
				if(specialfunctions & IDSCAN)
					D.aiDisabledIdScanner = !D.aiDisabledIdScanner
				if(specialfunctions & BOLTS)
					if(!D.isWireCut(4) && D.arePowerSystemsOn())
						D.locked = !D.locked
						D.update_icon()
				if(specialfunctions & SHOCK)
					D.secondsElectrified = D.secondsElectrified ? 0 : -1
				if(specialfunctions & SAFE)
					D.safe = !D.safe

	else
		for(var/obj/machinery/door/poddoor/M in poddoors)
			if (M.id_tag == src.id_tag)
				if (M.density)
					spawn( 0 )
						M.open()
						return
				else
					spawn( 0 )
						M.close()
						return
	spawn(15)
		if(!(stat & NOPOWER))
			icon_state = "doorctrl0"

/obj/machinery/door_control/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/obj/machinery/door_control/change_area(oldarea, newarea)
	..()
	name = replacetext(name,oldarea,newarea)

/obj/machinery/driver_button/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/weapon/W, mob/user as mob)
	. = ..()
	if(.)
		return .

	if(istype(W, /obj/item/device/detective_scanner))
		return

	if(iswrench(W))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, src, 30))
			to_chat(user, "<span class='notice'>You detach \the [src] from the wall.</span>")
			new/obj/item/mounted/frame/driver_button(get_turf(src))
			qdel(src)
		return 1

	return src.attack_hand(user)


/obj/machinery/driver_button/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<ul>
	<li>[format_tag("ID Tag","id_tag")]</li>
	</ul>"}

/obj/machinery/driver_button/attack_hand(mob/user as mob)

	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return
	add_fingerprint(user)

	use_power(5)

	launch_sequence()

	return

/obj/machinery/driver_button/proc/launch_sequence()
	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in poddoors)
		if (M.id_tag == src.id_tag)
			spawn()
				M.open()

	sleep(20)

	for(var/obj/machinery/mass_driver/M in mass_drivers)
		if(M.id_tag == src.id_tag)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in poddoors)
		if (M.id_tag == src.id_tag)
			spawn()
				M.close()
				return

	icon_state = "launcherbtt"
	active = 0

/obj/machinery/driver_button/change_area(oldarea, newarea)
	..()
	name = replacetext(name,oldarea,newarea)
