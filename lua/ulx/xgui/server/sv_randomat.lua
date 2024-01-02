--Only execute the following code if it's a terrortown gamemode
if GetConVar("gamemode"):GetString() ~= "terrortown" then return end

util.AddNetworkString("randomatULXEventsTransfer")

local commands = {}
local function init()
    table.insert(commands, "ttt_randomat_auto")
    table.insert(commands, "ttt_randomat_auto_min_rounds")
    table.insert(commands, "ttt_randomat_auto_chance")
    table.insert(commands, "ttt_randomat_auto_silent")
    table.insert(commands, "ttt_randomat_auto_choose")
    table.insert(commands, "ttt_randomat_chooseevent")
    table.insert(commands, "ttt_randomat_rebuyable")
    table.insert(commands, "ttt_randomat_event_weight")
    table.insert(commands, "ttt_randomat_event_hint")
    table.insert(commands, "ttt_randomat_event_hint_chat")
    table.insert(commands, "ttt_randomat_event_history")
    table.insert(commands, "ttt_randomat_allow_client_list")
    table.insert(commands, "ttt_randomat_always_silently_trigger")

    for _, v in pairs(commands) do
        if ConVarExists(v) then
            ULib.replicatedWritableCvar(v, "rep_"..v, GetConVar(v):GetString(), false, false, "xgui_gmsettings")
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
            local sliders, checks, textboxes
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
            if v.ExtDescription and #v.ExtDescription > 0 then
                data.d = v.ExtDescription
            elseif v.Description and #v.Description > 0 then
                data.d = v.Description
            end
            if type(v.Categories) == "table" and #v.Categories > 0 then
                data.ct = v.Categories
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
                ULib.replicatedWritableCvar(convar, "rep_" .. convar, GetConVar(convar):GetString(), false, false, "xgui_gmsettings")
            end

            local min_players = convar .. "_min_players"
            if ConVarExists(min_players) then
                table.insert(commands, min_players)
                ULib.replicatedWritableCvar(min_players, "rep_" .. min_players, GetConVar(min_players):GetString(), false, false, "xgui_gmsettings")
            end

            local weight = convar .. "_weight"
            if ConVarExists(weight) then
                table.insert(commands, weight)
                ULib.replicatedWritableCvar(weight, "rep_" .. weight, GetConVar(weight):GetString(), false, false, "xgui_gmsettings")
            end

            local numeric = table.Add(table.Add({}, sliders or {}), checks or {})
            for _, cv in pairs(numeric) do
                local cmd = "randomat_" .. v.id .. "_" .. cv.cmd
                if ConVarExists(cmd) then
                    table.insert(commands, cmd)
                    ULib.replicatedWritableCvar(cmd, "rep_" .. cmd, GetConVar(cmd):GetString(), false, false, "xgui_gmsettings")
                end
            end

            for _, cv in pairs(textboxes or {}) do
                local cmd = "randomat_" .. v.id .. "_" .. cv.cmd
                if ConVarExists(cmd) then
                    table.insert(commands, cmd)
                    ULib.replicatedWritableCvar(cmd, "rep_" .. cmd, GetConVar(cmd):GetString(), false, false, "xgui_gmsettings")
                end
            end
        end
    end
end)

hook.Add("PlayerInitialSpawn", "sendCombinedULXEventsTable", function(ply)
    local neweventsJSON = util.TableToJSON(newevents)
    local compressedString = util.Compress(neweventsJSON)
    local len = #compressedString
    timer.Simple(1, function()
        print("[RANDOMAT IMPORT EVENT ULX] Transfering randomat addon tables to: " .. tostring(ply))
        net.Start("randomatULXEventsTransfer")
        net.WriteUInt(len, 16)
        net.WriteData(compressedString, len)
        net.Send(ply)
    end)
end)

-------------------
-- Chat commands --
-------------------

local WRONG_GAMEMODE = "The current gamemode is not trouble in terrorist town!"
local CATEGORY_NAME = "Randomat"

ulx.rdmt_events = {}
local function updateEventIds()
    if GAMEMODE.FolderName ~= "terrortown" then return end

    table.Empty(ulx.rdmt_events) -- Don't reassign so we don't lose our refs

    for _, e in pairs(Randomat.Events) do
        table.insert(ulx.rdmt_events, e.Id or e.id)
    end
    table.sort(ulx.rdmt_events, function(a, b) return a < b end)
end
hook.Add(ULib.HOOK_UCLCHANGED, "ULXRandomatEventIdsUpdate", updateEventIds)
hook.Add("TTTPrepareRound", "ULXRandomatEventIdsUpdate_PrepareRound", updateEventIds)

function ulx.rdmt(calling_ply, target_event, safe)
    if GetConVar("gamemode"):GetString() ~= "terrortown" then
        ULib.tsayError(calling_ply, WRONG_GAMEMODE, true)
        return
    end

    local method = ""
    if safe then
        method = "safely "
        Randomat:SafeTriggerEvent(target_event, calling_ply, true)
    else
        Randomat:TriggerEvent(target_event, calling_ply)
    end
    ulx.fancyLogAdmin(calling_ply, false, "#A " .. method .. "started a Randomat event with an ID of #s.", target_event)
end

local rdmt = ulx.command(CATEGORY_NAME, "ulx rdmt", ulx.rdmt, "!rdmt")
rdmt:addParam { type = ULib.cmds.StringArg, completes = ulx.rdmt_events, hint = "Event ID", error = "Invalid Event ID \"%s\" specified", ULib.cmds.restrictToCompletes }
rdmt:addParam { type = ULib.cmds.BoolArg, invisible = true }
rdmt:defaultAccess(ULib.ACCESS_SUPERADMIN)
rdmt:setOpposite("ulx srdmt", { _, _, true }, "!srdmt", true)
rdmt:help("Starts a Randomat event with the given ID")

function ulx.clearevent(calling_ply, target_event)
    if GetConVar("gamemode"):GetString() ~= "terrortown" then
        ULib.tsayError(calling_ply, WRONG_GAMEMODE, true)
        return
    end

    Randomat:EndActiveEvent(target_event)
    ulx.fancyLogAdmin(calling_ply, false, "#A stopped a Randomat event with an ID of #s.", target_event)
end

local clearevent = ulx.command(CATEGORY_NAME, "ulx clearevent", ulx.clearevent, "!clearevent")
clearevent:addParam { type = ULib.cmds.StringArg, hint = "Event ID" }
clearevent:defaultAccess(ULib.ACCESS_SUPERADMIN)
clearevent:setOpposite("ulx stopevent", {}, "!stopevent", true)
clearevent:help("Stops a Randomat event with the given ID")

function ulx.clearevents(calling_ply)
    if GetConVar("gamemode"):GetString() ~= "terrortown" then
        ULib.tsayError(calling_ply, WRONG_GAMEMODE, true)
        return
    end

    Randomat:EndActiveEvents()
    ulx.fancyLogAdmin(calling_ply, false, "#A stopped all active Randomat events.")
end

local clearevents = ulx.command(CATEGORY_NAME, "ulx clearevents", ulx.clearevents, "!clearevents")
clearevents:defaultAccess(ULib.ACCESS_SUPERADMIN)
clearevents:setOpposite("ulx stopevents", {}, "!stopevents", true)
clearevents:help("Stops all active Randomat events")

-------------
-- Buttons --
-------------

util.AddNetworkString("rdmtdisableall")
util.AddNetworkString("rdmtenableall")
util.AddNetworkString("rdmtclear")
util.AddNetworkString("rdmtreset")
util.AddNetworkString("rdmtrandom")
util.AddNetworkString("rdmtresetweights")
util.AddNetworkString("rdmtclearhistory")

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

net.Receive("rdmtclearhistory", function()
    RunConsoleCommand("ttt_randomat_clearhistory")
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