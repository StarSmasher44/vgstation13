/mob/living/carbon/monkey
	name = "monkey"
	voice_name = "monkey"
	//speak_emote = list("chimpers")
	icon_state = "monkey1"
	icon = 'icons/mob/monkey.dmi'
	gender = NEUTER
	pass_flags = PASSTABLE
	update_icon = 0		///no need to call regenerate_icon
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal/monkey
	species_type = /mob/living/carbon/monkey
	treadmill_speed = 0.8 //Slow apes!
	var/attack_text = "bites"
	var/languagetoadd = LANGUAGE_MONKEY

	mob_bump_flag = MONKEY
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL|ALIEN

	size = SIZE_SMALL

	var/canWearClothes = 1
	var/canWearHats = 1
	var/canWearGlasses = 1

	var/obj/item/clothing/monkeyclothes/uniform = null
	var/obj/item/clothing/head/hat = null
	var/obj/item/clothing/glasses/glasses = null

	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/greaterform = "Human"                  // Used when humanizing a monkey.
	icon_state = "monkey1"
	//var/uni_append = "12C4E2"                // Small appearance modifier for different species.
	var/list/uni_append = list(0x12C,0x4E2)    // Same as above for DNA2.
	var/update_muts = 1                        // Monkey gene must be set at start.
	var/alien = 0								//Used for reagent metabolism.

/mob/living/carbon/monkey/Destroy()
	..()
	uniform = null
	hat = null
	glasses = null

/mob/living/carbon/monkey/abiotic()
	for(var/obj/item/I in held_items)
		if(I.abstract)
			continue

		return 1

	return (wear_mask || back || uniform || hat)

/mob/living/carbon/monkey/tajara
	name = "farwa"
	voice_name = "farwa"
	speak_emote = list("mews")
	icon_state = "tajkey1"
	uni_append = list(0x0A0,0xE00) // 0A0E00
	species_type = /mob/living/carbon/monkey/tajara
	languagetoadd = LANGUAGE_CATBEAST

/mob/living/carbon/monkey/skrell
	name = "neaera"
	voice_name = "neaera"
	speak_emote = list("squicks")
	icon_state = "skrellkey1"
	uni_append = list(0x01C,0xC92) // 01CC92
	species_type = /mob/living/carbon/monkey/skrell
	languagetoadd = LANGUAGE_SKRELLIAN

/mob/living/carbon/monkey/unathi
	name = "stok"
	voice_name = "stok"
	speak_emote = list("hisses")
	icon_state = "stokkey1"
	uni_append = list(0x044,0xC5D) // 044C5D
	canWearClothes = 0
	species_type = /mob/living/carbon/monkey/unathi
	languagetoadd = LANGUAGE_UNATHI

/mob/living/carbon/monkey/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	if(name == initial(name)) //To stop Pun-Pun becoming generic.
		name = "[name] ([rand(1, 1000)])"
		real_name = name

	if (!(dna))
		if(gender == NEUTER)
			setGender(pick(MALE, FEMALE))
		dna = new /datum/dna( null )
		dna.real_name = real_name
		dna.b_type = random_blood_type()
		dna.ResetSE()
		dna.ResetUI()
		//dna.uni_identity = "00600200A00E0110148FC01300B009"
		//dna.SetUI(list(0x006,0x002,0x00A,0x00E,0x011,0x014,0x8FC,0x013,0x00B,0x009))
		//dna.struc_enzymes = "43359156756131E13763334D1C369012032164D4FE4CD61544B6C03F251B6C60A42821D26BA3B0FD6"
		//dna.SetSE(list(0x433,0x591,0x567,0x561,0x31E,0x137,0x633,0x34D,0x1C3,0x690,0x120,0x321,0x64D,0x4FE,0x4CD,0x615,0x44B,0x6C0,0x3F2,0x51B,0x6C6,0x0A4,0x282,0x1D2,0x6BA,0x3B0,0xFD6))
		dna.unique_enzymes = md5(name) //Possibly not working?

		// We're a monkey
		dna.SetSEState(MONKEYBLOCK,   1)
		dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)
		// Fix gender
		dna.SetUIState(DNA_UI_GENDER, gender != MALE, 1)

		// Set the blocks to uni_append, if needed.
		if(uni_append.len>0)
			for(var/b=1;b<=uni_append.len;b++)
				dna.SetUIValue(DNA_UI_LENGTH-(uni_append.len-b),uni_append[b], 1)
		dna.UpdateUI()

		update_muts=1

		add_language(languagetoadd)
		default_language = all_languages[languagetoadd]

	..()
	update_icons()
	return

/mob/living/carbon/monkey/unathi/New()

	..()
	dna.mutantrace = "lizard"
	greaterform = "Unathi"

/mob/living/carbon/monkey/skrell/New()

	..()
	dna.mutantrace = "skrell"
	greaterform = "Skrell"

/mob/living/carbon/monkey/tajara/New()

	..()
	dna.mutantrace = "tajaran"
	greaterform = "Tajaran"


///mob/living/carbon/monkey/diona/New()
//Moved to it's duplicate declaration modules\mob\living\carbon\monkey\diona.dm

/mob/living/carbon/monkey/movement_delay()
	var/tally = 0

	if(reagents)
		if(reagents.has_reagent(HYPERZINE))
			return -1

		if(reagents.has_reagent(NUKA_COLA))
			return -1

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45)
		tally += (health_deficiency / 25)

	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	var/turf/T = loc
	if(istype(T))
		tally = T.adjust_slowdown(src, tally)

		if(tally == -1)
			return tally

	return tally+config.monkey_delay

/mob/living/carbon/monkey/show_inv(mob/living/carbon/user as mob)
	user.set_machine(src)

	var/dat

	for(var/i = 1 to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'>[makeStrippingButton(back)]</A>"

	dat += "<BR>"

	if(canWearHats)
		dat +=	"<br><b>Headwear:</b> <A href='?src=\ref[src];item=[slot_head]'>[makeStrippingButton(hat)]</A>"

	dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=[slot_wear_mask]'>[makeStrippingButton(wear_mask)]</A>"
	if(has_breathing_mask())
		dat += "<BR>[HTMLTAB]&#8627;<B>Internals:</B> [src.internal ? "On" : "Off"]  <A href='?src=\ref[src];internals=1'>(Toggle)</A>"

	if(canWearGlasses)
		dat +=	"<br><b>Glasses:</b> <A href='?src=\ref[src];item=[slot_glasses]'>[makeStrippingButton(glasses)]</A>"

	if(canWearClothes)
		dat +=	"<br><b>Uniform:</b> <A href='?src=\ref[src];item=[slot_w_uniform]'>[makeStrippingButton(uniform)]</A>"

	if(handcuffed)
		dat += "<BR><B>Handcuffed:</B> <A href='?src=\ref[src];item=[slot_handcuffed]'>Remove</A>"

	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()

//mob/living/carbon/monkey/bullet_act(var/obj/item/projectile/Proj)taken care of in living

/mob/living/carbon/monkey/getarmor(var/def_zone, var/type)

	var/armorscore = 0
	if((def_zone == LIMB_HEAD) || (def_zone == "eyes") || (def_zone == LIMB_HEAD))
		if(hat)
			armorscore = hat.armor[type]
	else
		if(uniform)
			armorscore = uniform.armor[type]
	return armorscore

/mob/living/carbon/monkey/attack_paw(mob/M as mob)
	..()

	if (M.a_intent == I_HELP)
		help_shake_act(M)
	else
		if ((M.a_intent == I_HURT && !( istype(wear_mask, /obj/item/clothing/mask/muzzle) )))
			if ((prob(75) && health > 0))
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				if(istype(M, /mob/living/carbon/monkey))
					var/mob/living/carbon/monkey/Mo = M
					src.visible_message("<span class='danger'>[Mo.name] [Mo.attack_text] [name]!</span>")
				else
					src.visible_message("<span class='danger'>[M.name] bites [name]!</span>")
				var/damage = rand(1, 5)
				adjustBruteLoss(damage)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
				for(var/datum/disease/D in M.viruses)
					if(D.spread == "Bite")
						contract_disease(D,1,0)
			else
				for(var/mob/O in viewers(src, null))
					O.show_message("<span class='danger'>[M.name] lunges towards [name], but misses!</span>", 1)
	return


/mob/living/carbon/monkey/proc/defense(var/power, var/def_zone)
	var/armor = run_armor_check(def_zone, "melee", "Your armor has protected your [def_zone].", "Your armor has softened hit to your [def_zone].")
	if(armor >= 2)
		return 0
	if(!power)
		return 0

	var/damage = power
	if(armor)
		damage = (damage/(armor+1))
	return damage

/mob/living/carbon/monkey/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == I_HURT)//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.use(2500)
					Weaken(5)
					if (stuttering < 5)
						stuttering = 5
					Stun(5)

					for(var/mob/O in viewers(src, null))
						if (O.client)
							O.show_message("<span class='danger'>[src] has been touched with the stun gloves by [M]!</span>", 1, "<span class='warning'>You hear someone fall</span>", 2)
					return
				else
					to_chat(M, "<span class='warning'>Not enough charge! </span>")
					return

	if (M.a_intent == I_HELP)
		help_shake_act(M)
	else
		if (M.a_intent == I_HURT)
			if ((prob(75) && health > 0))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>[] has punched [name]!</span>", M), 1)

				playsound(loc, "punch", 25, 1, -1)
				var/damage = rand(5, 10)
				var/dam_zone = ""
				if(M.zone_sel && M.zone_sel.selecting)
					dam_zone = M.zone_sel.selecting
				damage = defense(damage,dam_zone)
				if ((damage > 5) && prob(40))
					damage = rand(10, 15)
					if (paralysis < 5)
						Paralyse(rand(10, 15))
						spawn( 0 )
							for(var/mob/O in viewers(src, null))
								if ((O.client && !( O.blinded )))
									O.show_message(text("<span class='danger'>[] has knocked out [name]!</span>", M), 1)
							return
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>[] has attempted to punch [name]!</span>", M), 1)
		else
			if (M.a_intent == I_GRAB)
				if (M == src || anchored)
					return

				var/obj/item/weapon/grab/G = getFromPool(/obj/item/weapon/grab,M,src)

				M.put_in_active_hand(G)

				grabbed_by += G
				G.synch()

				LAssailant = M

				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("<span class='warning'>[] has grabbed [name] passively!</span>", M), 1)
			else
				if (!( paralysis ))
					if (prob(25))
						Paralyse(2)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("<span class='danger'>[] has pushed down [name]!</span>", M), 1)
					else
						drop_item()
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("<span class='danger'>[] has disarmed [name]!</span>", M), 1)
	return

/mob/living/carbon/monkey/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	switch(M.a_intent)
		if (I_HELP)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>"), 1)

		if (I_HURT)
			if ((prob(95) && health > 0))
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					if (paralysis < 15)
						Paralyse(rand(10, 15))
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("<span class='danger'>[] has wounded [name]!</span>", M), 1)
				else
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("<span class='danger'>[] has slashed [name]!</span>", M), 1)
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>[] has attempted to lunge at [name]!</span>", M), 1)

		if (I_GRAB)
			if (M == src)
				return
			var/obj/item/weapon/grab/G = getFromPool(/obj/item/weapon/grab,M,src)

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<span class='warning'>[] has grabbed [name] passively!</span>", M), 1)

		if (I_DISARM)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			var/damage = 5
			if(prob(95))
				Weaken(15)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>[] has tackled down [name]!</span>", M), 1)
			else
				drop_item()
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>[] has disarmed [name]!</span>", M), 1)
			adjustBruteLoss(damage)
			updatehealth()
	return

//using the default attack_animal() in carbon.dm

/mob/living/carbon/monkey/attack_slime(mob/living/carbon/slime/M as mob)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.Victim)
		return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("<span class='danger'>The [M.name] glomps []!</span>", src), 1)
		add_logs(M, src, "glomped on", 0)

		var/damage = rand(1, 3)

		if(istype(src, /mob/living/carbon/slime/adult))
			damage = rand(20, 40)
		else
			damage = rand(5, 35)

		adjustBruteLoss(damage)

		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2)
					stunprob = 20
				if(3 to 4)
					stunprob = 30
				if(5 to 6)
					stunprob = 40
				if(7 to 8)
					stunprob = 60
				if(9)
					stunprob = 70
				if(10)
					stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>The [M.name] has shocked []!</span>", src), 1)

				Weaken(power)
				if (stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/effect/system/spark_spread/s = getFromPool(/datum/effect/effect/system/spark_spread)
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))


		updatehealth()

	return

/mob/living/carbon/monkey/Stat()
	..()
	if(statpanel("Status"))
		stat(null, text("Intent: []", a_intent))
		stat(null, text("Move Mode: []", m_intent))
		if(client && mind)
			if (client.statpanel == "Status")
				if(mind.changeling)
					stat("Chemical Storage", mind.changeling.chem_charges)
					stat("Genetic Damage Time", mind.changeling.geneticdamage)
	return


/mob/living/carbon/monkey/verb/removeinternal()
	set name = "Remove Internals"
	set category = "IC"
	internal = null
	return

/mob/living/carbon/monkey/var/co2overloadtime = null
/mob/living/carbon/monkey/var/temperature_resistance = T0C+75

/mob/living/carbon/monkey/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\the [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

	if(wear_id)
		wear_id.emp_act(severity)
	..()

/mob/living/carbon/monkey/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	if(!blinded)
		flash_eyes(visual = 1)

	switch(severity)
		if(1.0)
			if (stat != 2)
				adjustBruteLoss(200)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		if(2.0)
			if (stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(30)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
			if (prob(50))
				Paralyse(10)
		else
	return

/mob/living/carbon/monkey/blob_act()
	if(flags & INVULNERABLE)
		return
	..()
	playsound(loc, 'sound/effects/blobattack.ogg',50,1)
	if (stat != DEAD)
		adjustFireLoss(60)
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
	if (prob(50))
		Paralyse(10)
	if (stat == DEAD && client)
		gib()
		return
	if (stat == DEAD && !client)
		gibs(loc, viruses)
		qdel(src)
		return


/mob/living/carbon/monkey/IsAdvancedToolUser()//Unless its monkey mode monkeys cant use advanced tools
	return dexterity_check()

// Get ALL accesses available.
/mob/living/carbon/monkey/GetAccess()
	var/list/ACL=list()
	var/obj/item/I = get_active_hand()
	if(istype(I))
		ACL |= I.GetAccess()
	return ACL

/mob/living/carbon/monkey/get_visible_id()
	var/id = null
	for(var/obj/item/I in held_items)
		id = I.GetID()
		if(id)
			break
	return id
	
/mob/living/carbon/monkey/assess_threat(var/obj/machinery/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!
	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(find_held_item_by_type(/obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 4

		if(lasercolor == "r")
			if(find_held_item_by_type(/obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 4

		return threatcount

	//Check for weapons
	if(judgebot.weaponscheck)
		for(var/obj/item/I in held_items)
			if(judgebot.check_for_weapons(I))
				threatcount += 4

	//Loyalty implants imply trustworthyness
	if(isloyal(src))
		threatcount -= 1

	return threatcount

/mob/living/carbon/monkey/dexterity_check()
	if(stat != CONSCIOUS)
		return 0
	if(ticker.mode.name == "monkey")
		return 1
	if(reagents.has_reagent(METHYLIN))
		return 1
	return 0

/mob/living/carbon/monkey/reset_layer()
	if(lying)
		plane = LYING_MOB_PLANE
	else
		plane = MOB_PLANE
