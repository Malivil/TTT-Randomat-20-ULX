local commands = {}

local function init()
    if GetConVarString("gamemode") == "terrortown" then --Only execute the following code if it's a terrortown gamemode
        table.insert(commands, "ttt_randomat_bees")
        table.insert(commands, "ttt_randomat_ammo")
        table.insert(commands, "ttt_randomat_barrels")
        table.insert(commands, "ttt_randomat_blind")
        table.insert(commands, "ttt_randomat_blink")
        table.insert(commands, "ttt_randomat_butter")
        table.insert(commands, "ttt_randomat_cantstop")
        table.insert(commands, "ttt_randomat_crabs")
        table.insert(commands, "ttt_randomat_credits")
        table.insert(commands, "ttt_randomat_crowbar")
        table.insert(commands, "ttt_randomat_explode")
        table.insert(commands, "ttt_randomat_falldamage")
        table.insert(commands, "ttt_randomat_flash")
        table.insert(commands, "ttt_randomat_fov")
        table.insert(commands, "ttt_randomat_freeze")
        table.insert(commands, "ttt_randomat_gas")
        table.insert(commands, "ttt_randomat_gungame")
        table.insert(commands, "ttt_randomat_intensifies")
        table.insert(commands, "ttt_randomat_lifesteal")
        table.insert(commands, "ttt_randomat_malfunction")
        table.insert(commands, "ttt_randomat_mayhem")
        table.insert(commands, "ttt_randomat_moongravity")
        table.insert(commands, "ttt_randomat_privacy")
        table.insert(commands, "ttt_randomat_randomhealth")
        table.insert(commands, "ttt_randomat_randomweapon")
        table.insert(commands, "ttt_randomat_randomxn")
        table.insert(commands, "ttt_randomat_regeneration")
        table.insert(commands, "ttt_randomat_search")
        table.insert(commands, "ttt_randomat_shrink")
        table.insert(commands, "ttt_randomat_shutup")
        table.insert(commands, "ttt_randomat_sosig")
        table.insert(commands, "ttt_randomat_suddendeath")
        table.insert(commands, "ttt_randomat_switch")
        table.insert(commands, "ttt_randomat_texplode")
        table.insert(commands, "ttt_randomat_visualiser")
        table.insert(commands, "ttt_randomat_wallhack")
        table.insert(commands, "ttt_randomat_choose")
        table.insert(commands, "randomat_barrels_count")
        table.insert(commands, "randomat_barrels_range")
        table.insert(commands, "randomat_bees_count")
        table.insert(commands, "randomat_blind_duration")
        table.insert(commands, "randomat_blink_cap")
        table.insert(commands, "randomat_blink_delay")
        table.insert(commands, "randomat_butter_timer")
        table.insert(commands, "randomat_butter_affectall")
        table.insert(commands, "randomat_cantstop_disableback")
        table.insert(commands, "randomat_crabs_count")
        table.insert(commands, "randomat_crowbar_damage")
        table.insert(commands, "randomat_crowbar_push")
        table.insert(commands, "randomat_explode_timer")
        table.insert(commands, "randomat_flash_scale")
        table.insert(commands, "randomat_fov_scale")
        table.insert(commands, "randomat_freeze_duration")
        table.insert(commands, "randomat_freeze_timer")
        table.insert(commands, "randomat_freeze_afectall")
        table.insert(commands, "randomat_gas_timer")
        table.insert(commands, "randomat_gas_affectall")
        table.insert(commands, "randomat_gas_discombob")
        table.insert(commands, "randomat_gas_incendiary")
        table.insert(commands, "randomat_gas_smoke")
        table.insert(commands, "randomat_gungame_timer")
        table.insert(commands, "randomat_intensifies_timer")
        table.insert(commands, "randomat_lifesteal_health")
        table.insert(commands, "randomat_lifesteal_cap")
        table.insert(commands, "randomat_malfunction_upper")
        table.insert(commands, "randomat_malfunction_lower")
        table.insert(commands, "randomat_malfunction_affectall")
        table.insert(commands, "randomat_malfunction_duration")
        table.insert(commands, "randomat_moongravity_gravity")
        table.insert(commands, "randomat_randomhealth_upper")
        table.insert(commands, "randomat_randomhealth_lower")
        table.insert(commands, "randomat_randomxn_triggers")
        table.insert(commands, "randomat_regeneration_delay")
        table.insert(commands, "randomat_regeneration_health")
        table.insert(commands, "randomat_shrink_scale")   
        table.insert(commands, "randomat_switch_timer")
        table.insert(commands, "randomat_texplode_timer")
        table.insert(commands, "randomat_auto_chance")
        table.insert(commands, "ttt_randomat_auto")
        table.insert(commands, "ttt_randomat_rebuyable")
        table.insert(commands, "randomat_choose_choices")
        table.insert(commands, "ttt_randomat_chooseevent")
        table.insert(commands, "randomat_choose_vote")
        table.insert(commands, "randomat_choose_votetimer")
        table.insert(commands, "randomat_choose_deadvoters")
        table.insert(commands, "ttt_randomat_president")
        table.insert(commands, "randomat_president_bonushealth")
        table.insert(commands, "ttt_randomat_inventory")
        table.insert(commands, "randomat_inventory_timer")
        table.insert(commands, "randomat_texplode_radius")
        table.insert(commands, "randomat_barrels_timer")
        table.insert(commands, "randomat_freeze_hint")

        --ToT-Commands--
        table.insert(commands, "randomat_suspicion_chance")
        table.insert(commands, "randomat_grave_health")
        table.insert(commands, "ttt_randomat_suspicion")
        table.insert(commands, "ttt_randomat_oldjester")
        table.insert(commands, "ttt_randomat_jesters")
        table.insert(commands, "ttt_randomat_upgrade")
        table.insert(commands, "ttt_randomat_grave")
        table.insert(commands, "randomat_upgrade_chooserole")

        for k, v in pairs(commands) do
            if ConVarExists(v) then
                ULib.replicatedWritableCvar( v, "rep_"..v, GetConVarNumber( v ), false, false, "xgui_gmsettings" )
            end
        end
    end
end

util.AddNetworkString("randomatULXEventsTransfer")

local newevents = {}
hook.Add("Initialize", "InitRandomatULXEventTransfer", function()
    if GetConVarString("gamemode") ~= "terrortown" then return end

    for _, v in pairs(Randomat.Events) do
        local convar = "ttt_randomat_" .. v.id
        if not table.HasValue(commands, convar) then
            local sliders, checks, textboxes;
            if v.GetConVars then
                sliders, checks, textboxes = v:GetConVars()
            end

            newevents[v.id] = {
                name = v.Title,
                altname = v.AltTitle,
                sdr = sliders,
                chk = checks,
                txt = textboxes
            }

            table.insert(commands, convar)
            if ConVarExists(convar) then
                ULib.replicatedWritableCvar( convar, "rep_"..convar, GetConVarNumber( convar ), false, false, "xgui_gmsettings" )
            end

            local numeric = table.Add(table.Add({}, sliders or {}), checks or {})
            for _, cv in pairs(numeric) do
                local cmd = "randomat_"..v.id.."_"..cv.cmd
                if ConVarExists(cmd) then
                    ULib.replicatedWritableCvar( cmd, "rep_" .. cmd, GetConVarNumber( cmd ), false, false, "xgui_gmsettings" )
                end
            end

            for _, cv in pairs(textboxes or {}) do
                local cmd = "randomat_"..v.id.."_"..cv.cmd
                if ConVarExists(cmd) then
                    ULib.replicatedWritableCvar( cmd, "rep_" .. cmd, GetConVarString( cmd ), false, false, "xgui_gmsettings" )
                end
            end
        end
    end
end)

hook.Add("PlayerInitialSpawn", "sendCombinedULXEventsTable", function( ply )
    local neweventsJSON = util.TableToJSON(newevents)
    timer.Simple(1, function()
        print("[RANDOMAT IMPORT EVENT ULX] Transfering randomat addon tables to: " .. tostring(ply))
        net.Start("randomatULXEventsTransfer")
        net.WriteString(neweventsJSON)
        net.Send(ply)
    end)
end)

util.AddNetworkString("rdmtdisableall")
util.AddNetworkString("rdmtenableall")
util.AddNetworkString("rdmtclear")
util.AddNetworkString("rdmtreset")
util.AddNetworkString("rdmtrandom")

net.Receive("rdmtdisableall", function()
    RunConsoleCommand("ttt_randomat_disableall")
end)

net.Receive("rdmtenableall", function()
    RunConsoleCommand("ttt_randomat_enableall")
end)

net.Receive("rdmtclear", function()
    RunConsoleCommand("ttt_randomat_clearevents")
    for _, v in pairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, "Cleared all active randomat events")
    end
end)

net.Receive("rdmtrandom", function()
    RunConsoleCommand("ttt_randomat_triggerrandom")
end)

net.Receive("rdmtreset", function()
    RunConsoleCommand("ttt_randomat_clearevents")
    for _, v in pairs(commands) do
        RunConsoleCommand(v, GetConVar(v):GetDefault())
    end

    for _, v in pairs(player.GetAll()) do
        v:PrintMessage(HUD_PRINTTALK, "Reset configs to deafult values")
    end
end)

xgui.addSVModule( "randomat", init )