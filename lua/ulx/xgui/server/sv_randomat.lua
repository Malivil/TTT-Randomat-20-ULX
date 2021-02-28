--Only execute the following code if it's a terrortown gamemode
if GetConVarString("gamemode") ~= "terrortown" then return end

util.AddNetworkString("randomatULXEventsTransfer")

local commands = {}
local function init()
    table.insert(commands, "ttt_randomat_auto")
    table.insert(commands, "ttt_randomat_auto_chance")
    table.insert(commands, "ttt_randomat_chooseevent")
    table.insert(commands, "ttt_randomat_rebuyable")
    table.insert(commands, "ttt_randomat_event_hint")
    table.insert(commands, "ttt_randomat_event_hint_chat")

    for _, v in pairs(commands) do
        if ConVarExists(v) then
            ULib.replicatedWritableCvar(v, "rep_"..v, GetConVarNumber(v), false, false, "xgui_gmsettings")
        end
    end
end

local newevents = {}
hook.Add("Initialize", "InitRandomatULXEventTransfer", function()
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
                dsc = v.Description,
                sdr = sliders,
                chk = checks,
                txt = textboxes
            }

            if ConVarExists(convar) then
                table.insert(commands, convar)
                ULib.replicatedWritableCvar(convar, "rep_" .. convar, GetConVarNumber(convar), false, false, "xgui_gmsettings")
            end

            local min_players = convar .. "_min_players"
            if ConVarExists(min_players) then
                table.insert(commands, min_players)
                ULib.replicatedWritableCvar(min_players, "rep_" .. min_players, GetConVarNumber(min_players), false, false, "xgui_gmsettings")
            end

            local numeric = table.Add(table.Add({}, sliders or {}), checks or {})
            for _, cv in pairs(numeric) do
                local cmd = "randomat_" .. v.id .. "_" .. cv.cmd
                if ConVarExists(cmd) then
                    table.insert(commands, cmd)
                    ULib.replicatedWritableCvar(cmd, "rep_" .. cmd, GetConVarNumber(cmd), false, false, "xgui_gmsettings")
                end
            end

            for _, cv in pairs(textboxes or {}) do
                local cmd = "randomat_" .. v.id .. "_" .. cv.cmd
                if ConVarExists(cmd) then
                    table.insert(commands, cmd)
                    ULib.replicatedWritableCvar(cmd, "rep_" .. cmd, GetConVarString(cmd), false, false, "xgui_gmsettings")
                end
            end
        end
    end
end)

hook.Add("PlayerInitialSpawn", "sendCombinedULXEventsTable", function(ply)
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
        v:PrintMessage(HUD_PRINTTALK, "Reset configs to default values")
    end
end)

xgui.addSVModule("randomat", init)