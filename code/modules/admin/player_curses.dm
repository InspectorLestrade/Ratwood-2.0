/proc/now_days()
    return round((world.realtime / 10) / 86400)

/proc/get_player_curses(key)
    if(!key) return

    var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
    if(!fexists(json_file))
        WRITE_FILE(json_file, "{}")

    var/list/json = json_decode(file2text(json_file))
    if(!json) json = list()

    return json

/proc/has_player_curse(key, curse)
    if(!key || !curse) return FALSE

    var/list/json = get_player_curses(key)
    if(!json || !json[curse]) return FALSE

    var/list/C = json[curse]

    // expired?
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
    admin_name = "unknown",
    reason = "No reason supplied."
)
    if(!key || !curse) return FALSE

    var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
    if(!fexists(json_file))
        WRITE_FILE(json_file, "{}")

    var/list/json = json_decode(file2text(json_file))
    if(!json) json = list()

    if(json[curse]) return FALSE

    json[curse] = list(
        "expires" = now_days() + duration_days,
        "chance" = chance_percent,
        "cooldown" = cooldown_seconds,
        "last_trigger" = 0,
        "trigger" = trigger,
        "effect" = effect_proc,
        "admin" = admin_name,
        "reason" = reason
    )

    fdel(json_file)
    WRITE_FILE(json_file, json_encode(json))

    return TRUE

/proc/remove_player_curse(key, curse)
    if(!key || !curse) return FALSE

    var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
    if(!fexists(json_file))
        WRITE_FILE(json_file, "{}")

    var/list/json = json_decode(file2text(json_file))
    if(!json) return FALSE

    json[curse] = null

    fdel(json_file)
    WRITE_FILE(json_file, json_encode(json))

    return TRUE

// =========================================================
//   PANEL-INVOKED CURSE CREATOR POPUP
// =========================================================

/client/proc/curse_player_popup(mob/target)
    if(!target || !target.ckey)
        usr << "Invalid target."
        return

    var/key = target.ckey

    var/list/trigger_list = list(
        "on spawn",
        "on death",
        "on behead",
        "on crit",
        "on sleep",
        "on walk",
        "on run",
        "on jump",
        "on bite",
        "on break wall/door/window",
        "on attack",
        "on cast spell",
        "on receive damage",
        "on receive miracle",
        "on sex"
    )

    var/trigger = input(src,
        "Choose a trigger event for this curse:",
        "Trigger Selection"
    ) as null|anything in trigger_list

    if(!trigger) return

    var/chance = input(src,
        "Percent chance (1–100):",
        "Chance",
        100
    ) as null|num

    if(isnull(chance)) return
    if(chance < 1) chance = 1
    if(chance > 100) chance = 100

    var/list/effect_list = list(
        "lesser miracle on self",
        "remove trait",
        "add trait",
        "drain stam",
        "drain rogstam",
        "nauseate",
        "slip",
        "jail in arcyne walls",
        "make deadite",
        "shock",
        "set on fire",
        "easy ambush",
        "difficult ambush",
        "explode",
        "nugget",
        "gib and spawn player controlled mob",
        "gib",
        "gib and explode"
    )

    var/effect_proc = input(src,
        "Choose a mob proc to call when the curse triggers:",
        "Effect Selection"
    ) as null|anything in effect_list

    if(!effect_proc) return

    var/duration = input(src,
        "Duration (REAL WORLD DAYS):",
        "Duration",
        1
    ) as null|num

    if(!duration || duration <= 0) return

    var/cooldown = input(src,
        "Cooldown between activations (seconds):",
        "Cooldown",
        45
    ) as null|num

    if(cooldown < 0) cooldown = 0

    var/reason = input(src,
        "Reason for curse (admin note):",
        "Reason",
        "None"
    ) as null|text

    var/curse_name = "[chance]pct_[effect_proc]_[trigger]_[rand(1000,9999)]"

    var/success = apply_player_curse(
        key,
        curse_name,
        duration,
        cooldown,
        chance,
        trigger,
        effect_proc,
        usr.ckey,
        reason
    )

    if(success)
        src << "<span class='notice'>Applied curse <b>[curse_name]</b> to [target].</span>"
        target << "<span class='warning'>A strange curse settles upon you…</span>"
    else
        src << "<span class='warning'>Failed to apply curse.</span>"
