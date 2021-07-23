--Only execute the following code if it's a terrortown gamemode
if GetConVarString("gamemode") ~= "terrortown" then return end

util.AddNetworkString("randomatULXEventsTransfer")

local commands = {}
local function init()
    table.insert(commands, "ttt_randomat_auto")
    table.insert(commands, "ttt_randomat_auto_chance")
    table.insert(commands, "ttt_randomat_auto_silent")
    table.insert(commands, "ttt_randomat_auto_choose")
    table.insert(commands, "ttt_randomat_chooseevent")
    table.insert(commands, "ttt_randomat_rebuyable")
    table.insert(commands, "ttt_randomat_event_weight")
    table.insert(commands, "ttt_randomat_event_hint")
    table.insert(commands, "ttt_randomat_event_hint_chat")

    for _, v in pairs(commands) do
        if ConVarExists(v) then
            ULib.replicatedWritableCvar(v, "rep_"..v, GetConVarNumber(v), false, false, "xgui_gmsettings")
        end
    end
end

local function MinimizeConVarData(data)
    return {
        c = data.cmd,
        d = data.dsc
    }
end

local function MinimizeNumberConVarData(data)
    local min = MinimizeConVarData(data)
    min.e = data.dcm or 0
    if data.min then
        min.m = math.Round(data.min, min.e)
    end
    if data.max then
        min.x = math.Round(data.max, min.e)
    end
    return min
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

            local data = {}
            -- Only save the properties that are being used
            if v.Title and #v.Title > 0 then
                data.n = v.Title
            end
            if v.AltTitle and #v.AltTitle > 0 then
                data.an = v.AltTitle
            end
            if v.Description and #v.Description > 0 then
                data.d = v.Description
            end

            -- Only bother sending the cvar lists that have entries
            if sliders and #sliders > 0 then
                data.s = {}
                for _, s in ipairs(sliders) do
                    table.insert(data.s, MinimizeNumberConVarData(s))
                end
            end
            if checks and #checks > 0 then
                data.c = {}
                for _, c in ipairs(checks) do
                    table.insert(data.c, MinimizeConVarData(c))
                end
            end
            if textboxes and #textboxes > 0 then
                data.t = {}
                for _, t in ipairs(textboxes) do
                    table.insert(data.t, MinimizeConVarData(t))
                end
            end

            newevents[v.id] = data

            if ConVarExists(convar) then
                table.insert(commands, convar)
                ULib.replicatedWritableCvar(convar, "rep_" .. convar, GetConVarNumber(convar), false, false, "xgui_gmsettings")
            end

            local min_players = convar .. "_min_players"
            if ConVarExists(min_players) then
                table.insert(commands, min_players)
                ULib.replicatedWritableCvar(min_players, "rep_" .. min_players, GetConVarNumber(min_players), false, false, "xgui_gmsettings")
            end

            local weight = convar .. "_weight"
            if ConVarExists(weight) then
                table.insert(commands, weight)
                ULib.replicatedWritableCvar(weight, "rep_" .. weight, GetConVarNumber(weight), false, false, "xgui_gmsettings")
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
util.AddNetworkString("rdmtresetweights")

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

net.Receive("rdmtresetweights", function()
    RunConsoleCommand("ttt_randomat_resetweights")
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