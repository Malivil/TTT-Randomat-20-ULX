surface.CreateFont("TitleLabel", {
    font = "Roboto",
    size = 16
})

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

--------------------------------------------------------------
local function AddToList(element, list)
    element:Dock(TOP)
    element:DockMargin(0, 5, 0, 0)
    list:Add(element)
end

local function loadRandomatULXEvents(eventsULX)
    for k, v in pairs(eventsULX) do
        local pnl = xlib.makelistlayout{ w=415, h=330, parent=xgui.null }

        local lst = vgui.Create("DListLayout", pnl)
        lst:SetPos(5, 25)
        lst:SetSize(390, 330)
        lst:DockPadding(0, 5, 0, 0)

        local name = ""
        if v.name ~= "" and v.name ~= nil then
            name = name .. v.name
        end
        if v.altname ~= "" and v.altname ~= nil then
            if string.len(name) == 0 then
                name = v.altname
            else
                name = name .. " (aka " .. v.altname .. ")"
            end
        end
        if name ~= "" then
            local labeltxt = xlib.makelabel{label=name, parent=lst, tooltip=name, font="TitleLabel"}
            lst:Add(labeltxt)
        end

        if v.dsc ~= "" and v.dsc ~= nil then
            local labeltxt = xlib.makelabel{label=v.dsc, parent=lst, tooltip=v.dsc}
            AddToList(labeltxt, lst)
        end

        local enable = xlib.makecheckbox{label="Enabled", repconvar="rep_ttt_randomat_"..k, parent=lst}
        AddToList(enable, lst)

        local min_players = xlib.makeslider{label="Minimum required players", repconvar="rep_ttt_randomat_"..k.."_min_players", min=0, max=32, 0, parent=lst}
        AddToList(min_players, lst)

        if v.sdr ~= nil then
            for _, j in pairs(v.sdr) do
                local conslider = xlib.makeslider{label=j.dsc, repconvar="rep_randomat_"..k.."_"..j.cmd, min=j.min, max=j.max, decimal=j.dcm or 0, parent=lst}
                AddToList(conslider, lst)
            end
        end

        if v.chk ~= nil then
            for _, j in pairs(v.chk) do
                local concheck = xlib.makecheckbox{label=j.dsc, repconvar="rep_randomat_"..k.."_"..j.cmd, parent=lst}
                AddToList(concheck, lst)
            end
        end

        if v.txt ~= nil then
            for _, j in pairs(v.txt) do
                local labeltxt = xlib.makelabel{label=j.dsc, parent=lst}
                AddToList(labeltxt, lst)
                local contxt = xlib.maketextbox{repconvar="rep_randomat_"..k.."_"..j.cmd, enableinput=true, parent=lst}
                AddToList(contxt, lst)
            end
        end

        local trigger = xlib.makebutton{w=150, label="Trigger Event", parent=lst}
        trigger.DoClick=function()
            RunConsoleCommand("ttt_randomat_trigger", k)
        end
        AddToList(trigger, lst)

        xgui.hookEvent("onProcessModules", nil, pnl.processModules)

        if v.name ~= "" and v.name ~= nil then
            xgui.addSubModule(string.TrimLeft(v.name, "#"), pnl, nil, "randomat_settings")
        end
        if v.altname ~= "" and v.altname ~= nil then
            xgui.addSubModule(string.TrimLeft(v.altname, "#"), pnl, nil, "randomat_settings")
        end
    end
end

net.Receive("randomatULXEventsTransfer", function()
	local importEventsJSON = net.ReadString()
	local importedEvents = util.JSONToTable(importEventsJSON)
	loadRandomatULXEvents(importedEvents)
    -- Reload the modules since by this time its usually loaded already
    xgui.processModules()
end)

-----------General-Settings----------------------
local pnl = xlib.makelistlayout{ w=415, h=325, parent=xgui.null }

local lst = vgui.Create("DListLayout", pnl)
lst:SetPos(5, 25)
lst:SetSize(390, 325)
lst:DockPadding(0, 5, 0, 0)

local labeltxt = xlib.makelabel{label="Randomat Configs", parent=lst, font="TitleLabel"}
lst:Add(labeltxt)

local rdmtauto = xlib.makecheckbox{label="Auto randomat on round start", repconvar="rep_ttt_randomat_auto", parent=lst}
AddToList(rdmtauto, lst)

local rdmtautochance = xlib.makeslider{label="Auto randomat chance", repconvar="rep_ttt_randomat_auto_chance", min=0,max=1,decimal=2, parent=lst}
AddToList(rdmtautochance, lst)

local rdmtrebuy = xlib.makecheckbox{label="Rebuyable randomat (Requires restart)", repconvar="rep_ttt_randomat_rebuyable", parent=lst}
AddToList(rdmtrebuy, lst)

local rdmtchoice = xlib.makecheckbox{label="Choose events (See settings in 'Choose' event config)", repconvar="rep_ttt_randomat_chooseevent", parent=lst}
AddToList(rdmtchoice, lst)

local rdmthint = xlib.makecheckbox{label="Give event hints", repconvar="rep_ttt_randomat_event_hint", parent=lst}
AddToList(rdmthint, lst)

local rdmthintchat = xlib.makecheckbox{label="Give event hints in chat", repconvar="rep_ttt_randomat_event_hint_chat", parent=lst}
AddToList(rdmthintchat, lst)

local enableButton = xlib.makebutton{w=150, label="Enable all events", parent=lst }
enableButton.DoClick=function()
	net.Start("rdmtenableall")
	net.SendToServer()
end
AddToList(enableButton, lst)

local disableButton = xlib.makebutton{ w=150, label="Disable all events", parent=lst }
disableButton.DoClick=function()
	net.Start("rdmtdisableall")
	net.SendToServer()
end
AddToList(disableButton, lst)

local clearButton = xlib.makebutton{w=150, label="Clear all active events", parent=lst }
clearButton.DoClick=function()
	net.Start("rdmtclear")
	net.SendToServer()
end
AddToList(clearButton, lst)

local resetButton = xlib.makebutton{w=150, label="Reset configs to default", parent=lst }
resetButton.DoClick=function()
	net.Start("rdmtreset")
	net.SendToServer()
end
AddToList(resetButton, lst)

local randomButton = xlib.makebutton{w=150, label="Trigger random event", parent=lst }
randomButton.DoClick=function()
	net.Start("rdmtrandom")
	net.SendToServer()
end
AddToList(randomButton, lst)

xgui.hookEvent("onProcessModules", nil, pnl.processModules)
xgui.addSubModule("- Randomat Configs -", pnl, nil, "randomat_settings")