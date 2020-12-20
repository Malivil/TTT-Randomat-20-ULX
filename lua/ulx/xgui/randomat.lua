local randomat_settings = xlib.makepanel{ parent=xgui.null }

randomat_settings.panel = xlib.makepanel{ x=165, y=25, w=415, h=318, parent=randomat_settings }
randomat_settings.catList = xlib.makelistview{ x=5, y=25, w=155, h=318, parent=randomat_settings }
randomat_settings.catList:AddColumn("Configs")
randomat_settings.catList.Columns[1].DoClick = function() end

randomat_settings.catList.OnRowSelected = function(self, LineID, Line)
	local nPanel = xgui.modules.submodule[Line:GetValue(2)].panel
	if nPanel ~= randomat_settings.curPanel then
		nPanel:SetZPos(0)
		xlib.addToAnimQueue("pnlSlide", { panel=nPanel, startx=-435, starty=0, endx=0, endy=0, setvisible=true })
		if randomat_settings.curPanel then
			randomat_settings.curPanel:SetZPos(-1)
			xlib.addToAnimQueue(randomat_settings.curPanel.SetVisible, randomat_settings.curPanel, false)
		end
		xlib.animQueue_start()
		randomat_settings.curPanel = nPanel
	else
		xlib.addToAnimQueue("pnlSlide", { panel=nPanel, startx=0, starty=0, endx=-435, endy=0, setvisible=false })
		self:ClearSelection()
		randomat_settings.curPanel = nil
		xlib.animQueue_start()
	end
	if nPanel.onOpen then nPanel.onOpen() end --If the panel has it, call a function when it's opened
end

--Process modular settings
function randomat_settings.processModules()
	randomat_settings.catList:Clear()
	for i, module in ipairs(xgui.modules.submodule) do
		if module.mtype == "randomat_settings" and (not module.access or LocalPlayer():query(module.access)) then
			local w,h = module.panel:GetSize()
			if w == h and h == 0 then module.panel:SetSize(275, 322) end

			if module.panel.scroll then --For DListLayouts
				module.panel.scroll.panel = module.panel
				module.panel = module.panel.scroll
			end
			module.panel:SetParent(randomat_settings.panel)

			local line = randomat_settings.catList:AddLine(module.name, i)
			if (module.panel == randomat_settings.curPanel) then
				randomat_settings.curPanel = nil
				randomat_settings.catList:SelectItem(line)
			else
				module.panel:SetVisible(false)
			end
		end
	end
	randomat_settings.catList:SortByColumn(1, false)
end
randomat_settings.processModules()

xgui.hookEvent("onProcessModules", nil, randomat_settings.processModules)
xgui.addModule("Randomat", randomat_settings, "icon16/rdmt.png", "xgui_gmsettings")

local events = {}

local Bees = 1
local ToT = 1
local Angels = 1

--[ammo]--------------------------------------------------

events["ammo"] = {}
events["ammo"].name = "Infinite Ammo!"

--[barrels]--------------------------------------------------

events["barrels"] = {}
events["barrels"].name = "Gunpowder, Treason, and Plot"

events["barrels"].sdr = {}
local slider = events["barrels"].sdr
slider[1] = {}
slider[1].cmd = "count"
slider[1].dsc = "Number of barrels (def. 3)"
slider[1].max = 10
slider[1].min = 1

slider[2] = {}
slider[2].cmd = "range"
slider[2].dsc = "Distance of barrel spawns (def. 100)"
slider[2].max = 1000
slider[2].min = 10

slider[3] = {}
slider[3].cmd = "timer"
slider[3].dsc = "Timer (def. 60)"
slider[3].max = 180
slider[3].min = 5

--[bees]--------------------------------------------------

events["bees"] = {}
events["bees"].name = "NOT THE BEES!"

if Bees then
	events["bees"].sdr = {}
	slider = events["bees"].sdr
	slider[1] = {}
	slider[1].cmd = "count"
	slider[1].dsc = "Number of bees per player (def. 4)"
	slider[1].max = 15
	slider[1].min = 1
else
	events["bees"].chk = {}
	local check = events["bees"].chk
	check[1].cmd = ""
	check[1].dsc = "Subscribe to the randomat bees addon to enable this event!"
end

--[blind]--------------------------------------------------

events["blind"] = {}
events["blind"].name = "All traitors have been blinded"
events["blind"].altname = "Blind Traitors"
events["blind"].sdr = {}

slider = events["blind"].sdr
slider[1] = {}
slider[1].cmd = "duration"
slider[1].dsc = "Duration (def. 30)"
slider[1].max = 90
slider[1].min = 5

--[blink]--------------------------------------------------

events["blink"] = {}
events["blink"].name = "Don't. Blink."
events["blink"].sdr = {}

if Angels then
	slider = events["blink"].sdr
	slider[1] = {}
	slider[1].cmd = "cap"
	slider[1].dsc = "Max angel spawns (def. 12)"
	slider[1].max = 20
	slider[1].min = 0

	slider[2] = {}
	slider[2].cmd = "delay"
	slider[2].dsc = "Angel spawn delay (def. 0.5)"
	slider[2].dcm = 1
	slider[2].max = 10
	slider[2].min = 0
else
	events["blink"].chk = {}
	local check = events["blink"].chk
	check[1].cmd = ""
	check[1].dsc = "Subscribe to the randomat angels addon to enable this event!"
end

--[butter]--------------------------------------------------

events["butter"] = {}
events["butter"].name = "Butterfingers"

events["butter"].sdr = {}
slider = events["butter"].sdr
slider[1] = {}
slider[1].cmd = "timer"
slider[1].dsc = "Timer (def. 10)"
slider[1].max = 60
slider[1].min = 1

events["butter"].chk = {}
local check = events["butter"].chk
check[1] = {}
check[1].cmd = "afectall"
check[1].dsc = "Afect everyone (def. 0)"

--[cantstop]--------------------------------------------------

events["cantstop"] = {}
events["cantstop"].name = "Can't stop, won't stop."

events["cantstop"].chk = {}
check = events["cantstop"].chk
check[1] = {}
check[1].cmd = "disableback"
check[1].dsc = "Disable 's' key (def. 1)"

--[crabs]--------------------------------------------------

events["crabs"] = {}
events["crabs"].name = "Crabs are People"

events["crabs"].sdr = {}
slider = events["crabs"].sdr
slider[1] = {}
slider[1].cmd = "count"
slider[1].dsc = "Number of crabs (def. 5)"
slider[1].min = 1
slider[1].max = 15

--[credits]--------------------------------------------------

events["credits"] = {}
events["credits"].name = "Infinite Credits for everyone!"

--[crowbar]--------------------------------------------------

events["crowbar"] = {}
events["crowbar"].name = "The 'bar has been raised!"

events["crowbar"].sdr = {}
slider = events["crowbar"].sdr
slider[1] = {}
slider[1].cmd = "push"
slider[1].dsc = "Crowbar push force (def. 20)"
slider[1].min = 1
slider[1].max = 100

slider[2] = {}
slider[2].cmd = "damage"
slider[2].dsc = "Crowbar damage (def. 2.5)"
slider[2].min = 1
slider[2].max = 100
slider[2].dcm = 1

--[explode]--------------------------------------------------

events["explode"] = {}
events["explode"].name = "A random person will explode every 30 seconds"

events["explode"].sdr = {}
slider = events["explode"].sdr
slider[1] = {}
slider[1].cmd = "timer"
slider[1].dsc = "Timer (def. 30)"
slider[1].max = 90
slider[1].min = 10

--[falldamage]--------------------------------------------------

events["falldamage"] = {}
events["falldamage"].name = "No more Fall Damage!"

--[flash]--------------------------------------------------

events["flash"] = {}
events["flash"].name = "Everything is as fast as Flash now!"

events["flash"].sdr = {}
slider = events["flash"].sdr
slider[1] = {}
slider[1].cmd = "scale"
slider[1].dsc = "Speed increase (def. 50)"
slider[1].max = 500
slider[1].min = 10

--[fov]--------------------------------------------------

events["fov"] = {}
events["fov"].name = "Quake Pro"

events["fov"].sdr = {}
slider = events["fov"].sdr
slider[1] = {}
slider[1].cmd = "scale"
slider[1].dsc = "Fov increase (def. 1.5)"
slider[1].max = 2
slider[1].min = 1.1
slider[1].dcm = 2

--[freeze]--------------------------------------------------

events["freeze"] = {}
events["freeze"].name = "Freeze"

events["freeze"].sdr = {}
slider = events["freeze"].sdr
slider[1] = {}
slider[1].cmd = "duration"
slider[1].dsc = "Freeze duration (def. 5)"
slider[1].max = 10
slider[1].min = 1
slider[1].dcm = 1

slider[2] = {}
slider[2].cmd = "timer"
slider[2].dsc = "Timer (def. 30)"
slider[2].max = 90
slider[2].min = 1

--[gas]--------------------------------------------------

events["gas"] = {}
events["gas"].name = "Bad Gas"

events["gas"].sdr = {}
slider = events["gas"].sdr
slider[1] = {}
slider[1].cmd = "timer"
slider[1].dsc = "Timer (def. 15)"
slider[1].min = 1
slider[1].max = 60

events["gas"].chk = {}
check = events["gas"].chk
check[1] = {}
check[1].cmd = "afectall"
check[1].dsc = "Afect everyone (def. 0)"

check[2] = {}
check[2].cmd = "discombob"
check[2].dsc = "Should spawn discombobulators (def. 1)"

check[3] = {}
check[3].cmd = "incendiary"
check[3].dsc = "Should spawn incendiaries (def. 0)"

check[4] = {}
check[4].cmd = "smoke"
check[4].dsc = "Should spawn smokes (def. 0)"

--[grave]--------------------------------------------------


events["grave"] = {}
events["grave"].name = "RISE FROM YOUR GRAVE"

if ToT then
	events["grave"].sdr = {}
	slider = events["grave"].sdr
	slider[1] = {}
	slider[1].cmd = "health"
	slider[1].dsc = "Health of zombies (def. 30)"
	slider[1].min = "1"
	slider[1].max = "100"
else
	events["grave"].chk = {}
	local check = events["grave"].chk
	check[1].cmd = ""
	check[1].dsc = "Subscribe to the randomat Town of Terror addon to enable this event!"
end


--[gungame]--------------------------------------------------

events["gungame"] = {}
events["gungame"].name = "Gun Game"

events["gungame"].sdr = {}
slider = events["gungame"].sdr
slider[1] = {}
slider[1].cmd = "timer"
slider[1].dsc = "Timer (def. 5)"
slider[1].min = "1"
slider[1].max = "30"

--[intensifies]--------------------------------------------------

events["intensifies"] = {}
events["intensifies"].name = "Randomness Intensifies"

events["intensifies"].sdr = {}
slider = events["intensifies"].sdr
slider[1] = {}
slider[1].cmd = "timer"
slider[1].dsc = "Timer (def. 20)"
slider[1].min = "5"
slider[1].max = "60"

--[jesters]--------------------------------------------------

events["jesters"] = {}
events["jesters"].name = "One traitor, One Detective. Everyone else is a jester. Detective is stronger."

if not ToT then
	events["jesters"].chk = {}
	local check = events["jesters"].chk
	check[1].cmd = ""
	check[1].dsc = "Subscribe to the randomat Town of Terror addon to enable this event!"
end

--[lifesteal]--------------------------------------------------

events["lifesteal"] = {}
events["lifesteal"].name = "Gaining life for killing people? Is it really worth it..."

events["lifesteal"].sdr = {}
slider = events["lifesteal"].sdr
slider[1] = {}
slider[1].cmd = "health"
slider[1].dsc = "Health gained (def. 25)"
slider[1].min = "1"
slider[1].max = "100"

slider[2] = {}
slider[2].cmd = "cap"
slider[2].dsc = "Health cap (def. 0, 0 to disable)"
slider[2].min = 0
slider[2].max = 500

--[malfunction]--------------------------------------------------

events["malfunction"] = {}
events["malfunction"].name = "Malfunction"

events["malfunction"].sdr = {}
slider = events["malfunction"].sdr
slider[1] = {}
slider[1].cmd = "upper"
slider[1].dsc = "Timer upper cap (def. 15)"
slider[1].min = 1
slider[1].max = 60

slider[2] = {}
slider[2].cmd = "lower"
slider[2].dsc = "Timer lower cap (def. 3)"
slider[2].min = 1
slider[2].max = 60

slider[3] = {}
slider[3].cmd = "duration"
slider[3].dsc = "Duration (def. 0.5)"
slider[3].min = 0.1
slider[3].max = 10
slider[3].dcm = 2

events["malfunction"].chk = {}
check = events["malfunction"].chk
check[1] = {}
check[1].cmd = "afectall"
check[1].dsc = "Affect everyone (def. 0)"

--[mayhem]--------------------------------------------------

events["mayhem"] = {}
events["mayhem"].name = "Total Mayhem"

--[moongravity]--------------------------------------------------

events["moongravity"] = {}
events["moongravity"].name = "What? Moon Gravity on Earth?"

events["moongravity"].sdr = {}
slider = events["moongravity"].sdr
slider[1] = {}
slider[1].cmd = "gravity"
slider[1].dsc = "Gravity multiplier (def. 0.1)"
slider[1].min = 0.01
slider[1].max = 1
slider[1].dcm = 2

--[oldjester]--------------------------------------------------

events["oldjester"] = {}
events["oldjester"].name = "BringBackOldJester"

if not ToT then
	events["oldjester"].chk = {}
	local check = events["oldjester"].chk
	check[1].cmd = ""
	check[1].dsc = "Subscribe to the randomat Town of Terror addon to enable this event!"
end

--[privacy]--------------------------------------------------

events["privacy"] = {}
events["privacy"].name = "We've updated our privacy policy."

--[randomhealth]--------------------------------------------------

events["randomhealth"] = {}
events["randomhealth"].name = "Random Health for everyone!"

events["randomhealth"].sdr = {}
slider = events["randomhealth"].sdr
slider[1] = {}
slider[1].cmd = "upper"
slider[1].dsc = "Highest health gain (def. 100)"
slider[1].min = 0
slider[1].max = 500

slider[2] = {}
slider[2].cmd = "lower"
slider[2].dsc = "Lowest health gain (def. 0)"
slider[2].min = -100
slider[2].max = 200

--[randomweapon]--------------------------------------------------

events["randomweapon"] = {}
events["randomweapon"].name = "Try your best..."

--[randomxn]--------------------------------------------------

events["randomxn"] = {}
events["randomxn"].name = "Random x5"

events["randomxn"].sdr = {}
slider = events["randomxn"].sdr
slider[1] = {}
slider[1].cmd = "triggers"
slider[1].dsc = "Number of randomats used (def. 5)"
slider[1].min = 2
slider[1].max = 10

--[regeneration]--------------------------------------------------

events["regeneration"] = {}
events["regeneration"].name = "We learned how to heal over time, its hard, but definitely possible..."
events["regeneration"].altname = "Regeneration"

events["regeneration"].sdr = {}
slider = events["regeneration"].sdr
slider[1] = {}
slider[1].cmd = "delay"
slider[1].dsc = "Delay before heal (def. 10)"
slider[1].min = 0
slider[1].max = 30

slider[2] = {}
slider[2].cmd = "health"
slider[2].dsc = "Health per second (def. 1)"
slider[2].min = 1
slider[2].max = 10

--[search]--------------------------------------------------

events["search"] = {}
events["search"].name = "Dead Men Tell no Tales"

--[shrink]--------------------------------------------------

events["shrink"] = {}
events["shrink"].name = "Honey, I shrunk the terrorists"

events["shrink"].sdr = {}
slider = events["shrink"].sdr
slider[1] = {}
slider[1].cmd = "scale"
slider[1].dsc = "Shrink scale (def. 0.5)"
slider[1].min = 0.1
slider[1].max = 0.9
slider[1].dcm = 2

--[shutup]--------------------------------------------------

events["shutup"] = {}
events["shutup"].name = "SHUT UP!"

--[sosig]--------------------------------------------------

events["sosig"] = {}
events["sosig"].name = "Sosig."

--[suddendeath]--------------------------------------------------

events["suddendeath"] = {}
events["suddendeath"].name = "Sudden Death!"

--[suspicion]--------------------------------------------------

events["suspicion"] = {}
events["suspicion"].name = "A player is acting suspicious..."

if ToT then
	events["suspicion"].sdr = {}
	slider = events["suspicion"].sdr
	slider[1] = {}
	slider[1].cmd = "chance"
	slider[1].dsc = "% chance of being a jester (def. 50)"
	slider[1].min = 1
	slider[1].max = 99
else
	events["suspicion"].chk = {}
	check = events["suspicion"].chk
	check[1].cmd = ""
	check[1].dsc = "Subscribe to the randomat Town of Terror addon to enable this event!"
end

--[switch]--------------------------------------------------

events["switch"] = {}
events["switch"].name = "There's this game my father taught me years ago, it's called \"Switch\""
events["switch"].altname = "Switch"

events["switch"].sdr = {}
slider = events["switch"].sdr
slider[1] = {}
slider[1].cmd = "timer"
slider[1].dsc = "Timer (def. 15)"
slider[1].min = 5
slider[1].max = 60

--[texplode]--------------------------------------------------

events["texplode"] = {}
events["texplode"].name = "A traitor will explode in 60 seconds!"

events["texplode"].sdr = {}
slider = events["texplode"].sdr
slider[1] = {}
slider[1].cmd = "timer"
slider[1].dsc = "Timer (def. 60)"
slider[1].min = 5
slider[1].max = 120

slider[2] = {}
slider[2].cmd = "radius"
slider[2].dsc = "Explosion Radius (def. 600)"
slider[2].min = 100
slider[2].max = 2000

--[upgrade]--------------------------------------------------

events["upgrade"] = {}
events["upgrade"].name = "An innocent has been upgraded!"

events["upgrade"].chk = {}
check = events["upgrade"].chk
check[1] = {}
check[1].cmd = "chooserole"
check[1].dsc = "Player chooses Mercenary or Killer"

--[visualiser]--------------------------------------------------

events["visualiser"] = {}
events["visualiser"].name = "I see dead people"

--[wallhack]--------------------------------------------------

events["wallhack"] = {}
events["wallhack"].name = "No one can hide from my sight"

--[choose]--------------------------------------------------

events["choose"] = {}
events["choose"].name = "Choose an Event!"

events["choose"].chk = {}
check = events["choose"].chk
check[1] = {}
check[1].cmd = "vote"
check[1].dsc = "All players vote on the event (def. 0)"
check[2] = {}
check[2].cmd = "deadvoters"
check[2].dsc = "Dead players can vote (def. 0)"

events["choose"].sdr = {}
slider = events["choose"].sdr
slider[1] = {}
slider[1].cmd = "choices"
slider[1].dsc = "Choices (def. 3)"
slider[1].min = 2
slider[1].max = 10
slider[2] = {}
slider[2].cmd = "votetimer"
slider[2].dsc = "Vote Timer (def. 10)"
slider[2].min = 5
slider[2].max = 30

--[president]--------------------------------------------------

events["president"] = {}
events["president"].name = "Get Down Mr President!"

events["president"].sdr = {}
slider = events["president"].sdr
slider[1] = {}
slider[1].cmd = "bonushealth"
slider[1].dsc = "Detective bonus health (def. 100)"
slider[1].min = 0
slider[1].max = 300

--[inventory]--------------------------------------------------

events["inventory"] = {}
events["inventory"].name = "Taking Inventory"

events["inventory"].sdr = {}
slider = events["inventory"].sdr
slider[1] = {}
slider[1].cmd = "timer"
slider[1].dsc = "Timer (def. 15)"
slider[1].min = 5
slider[1].max = 60

--[inventory]--------------------------------------------------

events["inventory"] = {}
events["inventory"].name = "Taking Inventory"

events["inventory"].sdr = {}
slider = events["inventory"].sdr
slider[1] = {}
slider[1].cmd = "timer"
slider[1].dsc = "Timer (def. 15)"
slider[1].min = 5
slider[1].max = 60

--[president]--------------------------------------------------

events["president"] = {}
events["president"].name = "Get Down Mr. President"

events["president"].sdr = {}
slider = events["president"].sdr
slider[1] = {}
slider[1].cmd = "bonushealth"
slider[1].dsc = "Detective Bonus Health (def. 100)"
slider[1].min = 0
slider[1].max = 300

--------------------------------------------------------------

local function loadRandomatULXEvents(eventsULX)
    for k, v in pairs(eventsULX) do
        local pnl = xlib.makelistlayout{ w=415, h=318, parent=xgui.null }

        local lst = vgui.Create("DPanelList", pnl)
        lst:SetPos(5, 25)
        lst:SetSize(390, 275)
        lst:SetSpacing(5)

        local enable = xlib.makecheckbox{label="Enabled", repconvar="rep_ttt_randomat_"..k, parent=lst}
        lst:AddItem(enable)

        local elements = 1
        if v.sdr ~= nil then
            for _, j in pairs(v.sdr) do
                local conslider = xlib.makeslider{label=j.dsc, repconvar="rep_randomat_"..k.."_"..j.cmd, min=j.min, max=j.max, decimal=j.dcm or 0, parent=lst}
                lst:AddItem(conslider)
                elements = elements + 1
            end
        end

        if v.chk ~= nil then
            for _, j in pairs(v.chk) do
                local concheck = xlib.makecheckbox{label=j.dsc, repconvar="rep_randomat_"..k.."_"..j.cmd, parent=lst}
                lst:AddItem(concheck)
                elements = elements + 1
            end
        end

        if v.txt ~= nil then
            for _, j in pairs(v.txt) do
                local labeltxt = xlib.makelabel{label=j.dsc, parent=lst}
                lst:AddItem(labeltxt)
                elements = elements + 1
                local contxt = xlib.maketextbox{repconvar="rep_randomat_"..k.."_"..j.cmd, enableinput=true, parent=lst}
                lst:AddItem(contxt)
                elements = elements + 1
            end
        end

        xlib.makebutton{y = (25*elements) - 5, w=150, label="Trigger Event", parent=lst}.DoClick=function()
            RunConsoleCommand("ttt_randomat_trigger", k)
        end

        xgui.hookEvent("onProcessModules", nil, pnl.processModules)

        if v.name ~= "" and v.name ~= nil then
            xgui.addSubModule(v.name, pnl, nil, "randomat_settings")
        end
        if v.altname ~= "" and v.altname ~= nil then
            xgui.addSubModule(v.altname, pnl, nil, "randomat_settings")
        end
    end
end
loadRandomatULXEvents(events)

net.Receive("randomatULXEventsTransfer", function()
	local importEventsJSON = net.ReadString()
	local importedEvents = util.JSONToTable(importEventsJSON)
	loadRandomatULXEvents(importedEvents)
    -- Reload the modules since by this time its usually loaded already
    xgui.processModules()
end)

-----------General-Settings----------------------
local pnl = xlib.makelistlayout{ w=415, h=325, parent=xgui.null }

local lst = vgui.Create("DPanelList", pnl)
lst:SetPos(5, 25)
lst:SetSize(390, 325)
lst:SetSpacing(5)

local rdmtauto = xlib.makecheckbox{label="Auto randomat on round start", repconvar="rep_ttt_randomat_auto", parent=lst}
lst:AddItem(rdmtauto)

local rdmtautochance = xlib.makeslider{label="Auto randomat chance", repconvar="rep_ttt_randomat_auto_chance", min=0,max=1,decimal=2, parent=lst}
lst:AddItem(rdmtautochance)

local rdmtrebuy = xlib.makecheckbox{label="Rebuyable randomat (Requires restart)", repconvar="rep_ttt_randomat_rebuyable", parent=lst}
lst:AddItem(rdmtrebuy)

local rdmtchoice = xlib.makecheckbox{label="Choose events (settings in event configs)", repconvar="rep_ttt_randomat_chooseevent", parent=lst}
lst:AddItem(rdmtchoice)

local rdmthint = xlib.makecheckbox{label="Give event hints", repconvar="rep_ttt_randomat_event_hint", parent=lst}
lst:AddItem(rdmthint)

local rdmthintchat = xlib.makecheckbox{label="Give event hints in chat", repconvar="rep_ttt_randomat_event_hint_chat", parent=lst}
lst:AddItem(rdmthintchat)

local y = 135
xlib.makebutton{y = y, w=150, label="Enable all events", parent=lst }.DoClick=function()
	net.Start("rdmtenableall")
	net.SendToServer()
end
y = y + 25

xlib.makebutton{y = y, w=150, label="Disable all events", parent=lst }.DoClick=function()
	net.Start("rdmtdisableall")
	net.SendToServer()
end
y = y + 25

xlib.makebutton{y = y, w=150, label="Clear all active events", parent=lst }.DoClick=function()
	net.Start("rdmtclear")
	net.SendToServer()
end
y = y + 25

xlib.makebutton{y = y, w=150, label="Reset configs to default", parent=lst }.DoClick=function()
	net.Start("rdmtreset")
	net.SendToServer()
end
y = y + 25

xlib.makebutton{y = y, w=150, label="Trigger random event", parent=lst }.DoClick=function()
	net.Start("rdmtrandom")
	net.SendToServer()
end

xgui.hookEvent("onProcessModules", nil, pnl.processModules)
xgui.addSubModule("-Randomat Configs", pnl, nil, "randomat_settings")