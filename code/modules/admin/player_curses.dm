////////////////////////////////////////////////////////////
//  CURSE DATUM
////////////////////////////////////////////////////////////

/datum/modular_curse
	var/name
	var/expires
	var/chance
	var/cooldown
	var/last_trigger = 0
	var/trigger
	var/effect
	var/list/effect_args
	var/admin
	var/reason
	var/mob/owner
	var/list/signals = list()

/datum/modular_curse/proc/attach_to_mob(mob/M)
	owner = M

	switch(trigger)
		if("on death")
			RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DEATH
		if("on beheaded")
			RegisterSignal(M, COMSIG_MOB_DECAPPED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DECAPPED
		if("on dismembered")
			RegisterSignal(M, COMSIG_MOB_DISMEMBER, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DISMEMBER
		if("on sleep")
			RegisterSignal(M, COMSIG_LIVING_STATUS_SLEEP, PROC_REF(on_signal_trigger))
			signals += COMSIG_LIVING_STATUS_SLEEP
		if("on attack")
			RegisterSignal(M, COMSIG_MOB_ATTACK_HAND, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_ATTACK_HAND
			RegisterSignal(M, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_ITEM_ATTACK
			RegisterSignal(M, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_ATTACK_RANGED
		if("on receive damage")
			RegisterSignal(M, COMSIG_MOB_APPLY_DAMGE, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_APPLY_DAMGE
		if("on cast spell")
			RegisterSignal(M, COMSIG_MOB_CAST_SPELL, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_CAST_SPELL
		if("on spell or miracle target")
			RegisterSignal(M, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_RECEIVE_MAGIC
		if("on cut tree")
			RegisterSignal(M, COMSIG_MOB_FELL_TREE, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_FELL_TREE
		if("on orgasm")
			RegisterSignal(M, COMSIG_MOB_EJACULATED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_EJACULATED
		if("on move")
			RegisterSignal(M, COMSIG_MOVABLE_MOVED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOVABLE_MOVED
		if("on dawn")
			RegisterSignal(M, COMSIG_MOB_DAWNED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DAYED
		if("on day")
			RegisterSignal(M, COMSIG_MOB_DAYED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DAYED
		if("on dusk")
			RegisterSignal(M, COMSIG_MOB_DUSKED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DAYED
		if("on night")
			RegisterSignal(M, COMSIG_MOB_NIGHTED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_NIGHTED

	// spawn trigger fires instantly
	if(trigger == "on spawn")
		check_trigger("on spawn")

/datum/modular_curse/proc/trigger_effect()
	if(!owner)
		return

	var/mob/living/L = owner

	switch(effect)
		if("buff or debuff")
			var/debuff_id = effect_args["debuff_id"]
			if(!debuff_id || !istype(debuff_id, /datum/status_effect))
				return
			L.apply_status_effect(debuff_id)
			//notify_player_of_effect(L, trigger, effect, TRUE)
		if("remove trait")
			var/trait_id = effect_args["trait"]
			if(!trait_id)
				return
			REMOVE_TRAIT(L, trait_id, TRAIT_GENERIC)
		if("add trait")
			var/trait_id = effect_args["trait"]
			if(!trait_id)
				return
			ADD_TRAIT(L, trait_id, TRAIT_GENERIC)
		if("add 2u reagent")
			var/reagent_type = effect_args["reagent_type"]

			if(istext(reagent_type))
				reagent_type = text2path(reagent_type)

			if(!reagent_type)
				return

			var/mob/living/carbon/M = L
			var/datum/reagents/reagents = new()
			reagents.add_reagent(reagent_type, 2)
			reagents.trans_to(M, 2, transfered_by = M, method = INGEST)
		if("add arousal")
			L.sexcon.arousal += 5
		if("shrink sex organs")
			var/obj/item/organ/penis/penis = L.getorganslot(ORGAN_SLOT_PENIS)
			var/obj/item/organ/testicles/testicles = L.getorganslot(ORGAN_SLOT_TESTICLES)
			var/obj/item/organ/breasts/breasts = L.getorganslot(ORGAN_SLOT_BREASTS)
			if(penis)
				if(penis.penis_size > MIN_PENIS_SIZE)
					penis.penis_size--
			if(testicles)
				if(testicles.ball_size > MIN_TESTICLES_SIZE)
					testicles.ball_size--
			if(breasts)
				if(breasts.breast_size > MIN_BREASTS_SIZE )
					breasts.breast_size--
			L.update_body()
		if("enlarge sex organs")
			var/obj/item/organ/penis/penis = L.getorganslot(ORGAN_SLOT_PENIS)
			var/obj/item/organ/testicles/testicles = L.getorganslot(ORGAN_SLOT_TESTICLES)
			var/obj/item/organ/breasts/breasts = L.getorganslot(ORGAN_SLOT_BREASTS)
			if(penis)
				if(penis.penis_size < MAX_PENIS_SIZE)
					penis.penis_size++
			if(testicles)
				if(testicles.ball_size < MAX_TESTICLES_SIZE)
					testicles.ball_size++
			if(breasts)
				if(breasts.breast_size < MAX_BREASTS_SIZE )
					breasts.breast_size++
			L.update_body()
		if("nauseate")
			var/mob/living/carbon/M = L
			M.add_nausea(4)
		if("clothesplosion")
			L.drop_all_held_items()
			// Remove all clothing except collar
			for(var/obj/item/I in L.get_equipped_items())
				L.dropItemToGround(I, TRUE)
		if("slip")
			spawn(0)
				L.liquid_slip(total_time = 1 SECONDS, stun_duration = 1 SECONDS, height = 12, flip_count = 0)
			/*
		if("jail in arcyne walls")
			var/turf/target = get_turf(L)

			for(var/turf/affected_turf in view(1, L))
				if(!(affected_turf in view(L)))
					continue
				if(get_dist(L, affected_turf) != 1)
					continue
				new /obj/effect/temp_visual/trap_wall(affected_turf)
				addtimer(CALLBACK(src, PROC_REF(/obj/effect/proc_holder/spell/invoked/forcewall/new_wall), affected_turf, L), wait = 0 SECONDS)
				/obj/effect/proc_holder/spell/invoked/forcewall/proc/new_wall(var/turf/target, mob/user)
	new wall_type(target, user)
		if("make deadite")
			if(istype(L, /mob/living/carbon/human))	
				var/mob/living/carbon/human/H = L
				H.transform_into_deadite()
		if("make vampire")
			if(istype(L, /mob/living/carbon/human))	
				var/mob/living/carbon/human/H = L
				H.transform_into_vampire()
		if("make werewolf")
			if(istype(L, /mob/living/carbon/human))	
				var/mob/living/carbon/human/H = L
				H.transform_into_werewolf()*/
		if("shock")
			L.electrocute_act(rand(15,30), src)
		if("add fire stack")
			L.adjust_fire_stacks(rand(1,6))
			L.ignite_mob()
		/*if("easy ambush")
			var/mob/living/simple_animal/M = effect_args["mob_type"]
			if(!M || !istype(M, /mob/living/simple_animal))
				return
			ambush_mob_at_target(L, M, easy = TRUE)
		if("difficult ambush")
			var/mob/living/simple_animal/M = effect_args["mob_type"]
			if(!M || !istype(M, /mob/living/simple_animal))
				return
			ambush_mob_at_target(L, M, easy = FALSE)*/
		if("explode")
			explosion(get_turf(L), 1, 2, 3, 0, TRUE, TRUE)
		/*
		if("nugget")
			if(istype(L, /mob/living/carbon/human))	
				var/mob/living/carbon/human/H = L
				H.spawn_gold_nugget()
		if("gib and spawn player controlled mob")
			var/mob/living/simple_animal/M = effect_args["mob_type"]
			if(!M || !istype(M, /mob/living/simple_animal))
				return
			L.gib()
			spawn_player_controlled_mob_at(M, L.loc, L.ckey)
		if("gib and reset body")
			if(istype(L, /mob/living/carbon/human))	
				var/mob/living/carbon/human/H = L
				H.gib_and_reset_body()
		*/
		if("gib")
			if(!L)
				return
			message_admins(span_adminnotice("[key_name_admin(owner)] gibbed due to curse."))
			SSblackbox.record_feedback("tally", "curse", 1, "Gib Curse") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living, gib), 1, 1, 1), 2)
			return

		else
			// Unknown effect
			return

/datum/modular_curse/proc/on_signal_trigger()
	if(!owner)
		return
	check_trigger(trigger)

/datum/modular_curse/proc/detach()
	unregister_all_signals()
	owner = null
	signals = list()
	qdel(src)

/datum/modular_curse/proc/check_trigger(trigger_name)
	if(!owner)
		return

	if(trigger != trigger_name)
		return

	if(expires <= now_days())
		var/ck = owner?.ckey
		detach()
		if(ck)
			remove_player_curse(ck, name)
		return

	// cooldown
	if(world.time < last_trigger + (cooldown * 10))
		return

	if(!prob(chance))
		return

	last_trigger = world.time
	trigger_effect()

/datum/modular_curse/proc/unregister_all_signals()
	if(!owner || !signals || !signals.len)
		return

	for(var/S in signals)
		UnregisterSignal(owner, S)

	signals.Cut()

////////////////////////////////////////////////////////////
//  TIME HELPER
////////////////////////////////////////////////////////////

/proc/now_days()
	return round((world.realtime / 10) / 86400)

////////////////////////////////////////////////////////////
//  JSON LOAD / SAVE
////////////////////////////////////////////////////////////

/proc/get_player_curses(key)
	if(!key)
		return

	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")

	var/list/json = json_decode(file2text(json_file))
	if(!json)
		json = list()

	return json


/proc/has_player_curse(key, curse)
	if(!key || !curse)
		return FALSE

	var/list/json = get_player_curses(key)
	if(!json || !json[curse])
		return FALSE

	var/list/C = json[curse]

	if(C["expires"] <= now_days())
		remove_player_curse(key, curse)
		return FALSE

	return TRUE


/proc/apply_player_curse(
	key,
	curse,
	duration_days = 1,
	cooldown_seconds = 0,
	chance_percent = 100,
	trigger = null,
	effect_proc = null,
	list/effect_args = null,
	admin_name = "unknown",
	reason = "No reason supplied."
)
	if(!key || !curse)
		return FALSE

	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")

	var/list/json = json_decode(file2text(json_file))
	if(!json)
		json = list()

	if(json[curse])
		return FALSE

	json[curse] = list(
		"expires"      = now_days() + duration_days,
		"chance"       = chance_percent,
		"cooldown"     = cooldown_seconds,
		"last_trigger" = 0,
		"trigger"      = trigger,
		"effect"       = effect_proc,
		"effect_args"  = effect_args,
		"admin"        = admin_name,
		"reason"       = reason
	)

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	// Live-refresh if they're online
	refresh_player_curses_for_key(key)

	return TRUE


/proc/remove_player_curse(key, curse_name)
	if(!key || !curse_name)
		return FALSE

	// --- Load JSON ---
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")

	var/list/json = json_decode(file2text(json_file))
	if(!json || !json[curse_name])
		return FALSE

	// --- Remove from JSON ---
	json[curse_name] = null

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	// --- Live cleanup if player online ---
	for(var/client/C in GLOB.clients)
		if(C && C.ckey == key)
			var/mob/M = C.mob
			if(!M || !M.mind || !M.mind.curses)
				break

			if(M.mind.curses[curse_name])
				var/datum/modular_curse/CR = M.mind.curses[curse_name]

				// ✅ detach signals
				if(CR)
					CR.detach()

				// ✅ remove datum from mind
				M.mind.curses -= curse_name

			break

	return TRUE




////////////////////////////////////////////////////////////
//  LIVE REFRESH TO MIND / MOB
////////////////////////////////////////////////////////////

/proc/load_curses_into_mind(datum/mind/M, key)
	if(!M || !key)
		return

	var/list/json = get_player_curses(key)
	if(!json)
		json = list()

	if(!M.curses)
		M.curses = list()

	for(var/existing in M.curses)
		if(!(existing in json))
			var/datum/modular_curse/oldC = M.curses[existing]
			if(oldC)
				oldC.detach()
			M.curses -= existing

	for(var/curse_name in json)
		var/list/C = json[curse_name]
		if(!C)
			continue

		// already exists? update fields
		if(M.curses[curse_name])
			var/datum/modular_curse/existingC = M.curses[curse_name]
			existingC.expires      = C["expires"]
			existingC.chance       = C["chance"]
			existingC.cooldown     = C["cooldown"]
			existingC.last_trigger = C["last_trigger"]
			existingC.trigger      = C["trigger"]
			existingC.effect       = C["effect"]
			existingC.effect_args  = C["effect_args"]
			existingC.admin        = C["admin"]
			existingC.reason       = C["reason"]
			continue

		// create NEW curse datum
		var/datum/modular_curse/newC = new
		newC.name         = curse_name
		newC.expires      = C["expires"]
		newC.chance       = C["chance"]
		newC.cooldown     = C["cooldown"]
		newC.last_trigger = C["last_trigger"]
		newC.trigger      = C["trigger"]
		newC.effect       = C["effect"]
		newC.effect_args  = C["effect_args"]
		newC.admin        = C["admin"]
		newC.reason       = C["reason"]

		M.curses[curse_name] = newC

/proc/apply_curses_to_mob(mob/M, datum/mind/MN)
	if(!M || !MN || !MN.curses)
		return

	for(var/curse_name in MN.curses)
		var/datum/modular_curse/C = MN.curses[curse_name]

		if(C.owner == M)
			continue

		C.attach_to_mob(M)


/proc/refresh_player_curses_for_key(key)
	if(!key)
		return

	for(var/client/C in GLOB.clients)
		if(!C || C.ckey != key)
			continue

		var/mob/M = C.mob
		if(!M)
			return

		if(!M.mind)
			M.mind_initialize()

		if(M.mind)
			if(M.mind.curses)
				for(var/datum/modular_curse/CRS in M.mind.curses)
					CRS.detach()
			load_curses_into_mind(M.mind, key)
			apply_curses_to_mob(M, M.mind)
		return



////////////////////////////////////////////////////////////
//  ADMIN POPUP – CURSE CREATION
////////////////////////////////////////////////////////////

/client/proc/curse_player_popup(mob/target)
	if(!target || !target.ckey)
		usr << "Invalid target."
		return

	var/key = target.ckey

	// ---- Trigger Selection ----
	//commented out do not currently have signals
	var/list/trigger_list = list(
		"on spawn",
		"on death",
		"on beheaded",
		"on dismembered",
		"on sleep",
		"on attack",
		"on receive damage",
		"on cast spell,
		"on spell or miracle target",
		//"on break wall/door/window",
		"on cut tree",
		//"on craft",
		"on orgasm",
		//"on bite",
		//"on jump",
		//"on climb",
		//"on swim",
		"on move",
		"on dawn",
		"on day",
		"on dusk",
		"on night"
	)

	var/trigger = input(
		src,
		"Choose a trigger event for this curse:",
		"Trigger Selection"
	) as null|anything in trigger_list

	if(!trigger)
		return

	// ---- Chance ----
	var/chance = input(
		src,
		"Percent chance (1 to 100):",
		"Chance",
		100
	) as null|num

	if(isnull(chance))
		return
	chance = clamp(chance, 1, 100)

	// ---- Effect Selection ----
	var/list/effect_list = list(
		"buff or debuff",
		"remove trait",
		"add trait",
		"add 2u reagent",
		"add arousal",
		"shrink sex organs",
		"enlarge sex organs",
		"nauseate",
		"clothesplosion",
		"slip",
		//"jail in arcyne walls",
		//"make deadite",
		//"make vampire",
		//"make werewolf",
		"shock",
		"add fire stack",
		//"cbt",
		//"easy ambush",
		//"difficult ambush",
		"explode",
		//"nugget",
		//"gib and spawn player controlled mob",
		//"gib and reset body",
		"gib"
	)

	var/effect_proc = input(
		src,
		"Choose the effect this curse will apply:",
		"Effect Selection"
	) as null|anything in effect_list

	if(!effect_proc)
		return

	var/list/effect_args = null

	// ---- Trait selection ----
	if(effect_proc == "add trait" || effect_proc == "remove trait")
		var/list/trait_choices = GLOB.roguetraits.Copy()

		var/action = (effect_proc == "add trait" ? "add" : "remove")

		var/trait_id = input(
			src,
			"Select the trait to [action]:",
			"Trait Selection"
		) as null|anything in trait_choices

		if(!trait_id)
			return

		effect_args = list("trait" = trait_id)

	// ---- Buff / Debuff selection ----
	if(effect_proc == "buff or debuff")
		var/debuff_id = input(
			src,
			"Select the effect to apply:",
			"Effect Selection"
		) as null|anything in subtypesof(/datum/status_effect)

		if(!debuff_id)
			return

		effect_args = list(
			"debuff_id" = debuff_id
		)

	// ---- Reagent selection ----
	if(effect_proc == "add 2u reagent")
		var/reagent_type = input(
			src,
			"Select the reagent to add (typepath):",
			"Reagent Selection"
		) as null|anything in subtypesof(/datum/reagent)

		if(!reagent_type)
			return

		effect_args = list(
			"reagent_type" = reagent_type
		)

	// ---- Mob-spawning effects ----
	if(effect_proc in list("gib and spawn player controlled mob", "easy ambush", "difficult ambush"))
		var/mob_type = input(
			src,
			"Select the mob to spawn/give:",
			"Mob Selection"
		) as null|anything in subtypesof(/mob/living/simple_animal)

		if(!mob_type)
			return

		effect_args = list(
			"mob_type" = mob_type
		)

	// ---- Duration ----
	var/duration = input(
		src,
		"Duration (REAL WORLD DAYS):",
		"Duration",
		3
	) as null|num

	if(!duration || duration <= 0)
		return

	// ---- Cooldown ----
	var/cooldown = input(
		src,
		"Cooldown between activations (seconds):",
		"Cooldown",
		1
	) as null|num

	if(cooldown < 0)
		cooldown = 0

	// ---- Reason ----
	var/reason = input(
		src,
		"Reason for curse (admin note):",
		"Reason",
		"Change me or I determine you shitmin"
	) as null|text

	// ---- Generate name ----
	var/cname_safe_effect = replacetext(effect_proc, " ", "_")
	var/cname_safe_trigger = replacetext(trigger, " ", "_")
	var/curse_name = "[chance]percent_[cname_safe_effect]_[cname_safe_trigger]_[rand(1000,9999)]"

	// ---- Apply ----
	var/success = apply_player_curse(
		key,
		curse_name,
		duration,
		cooldown,
		chance,
		trigger,
		effect_proc,
		effect_args,
		usr.ckey,
		reason
	)

	if(success)
		src << "<span class='notice'>Applied curse <b>[curse_name]</b> to [target].</span>"
		target << "<span class='warning'>A strange curse settles upon you…</span>"
	else
		src << "<span class='warning'>Failed to apply curse.</span>"
