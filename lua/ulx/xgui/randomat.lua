surface.CreateFont("TitleLabel", {
    font = "Roboto",
    size = 16
})

local config_label = "- Randomat Configs -"
local randomat_settings = xlib.makepanel{ parent=xgui.null }

randomat_settings.panel = xlib.makepanel{ x=165, y=25, w=415, h=318, parent=randomat_settings }
randomat_settings.search = xlib.maketextbox{ x=5, y=2, w=155, h=21, enableinput=true, parent=randomat_settings }
randomat_settings.catList = xlib.makelistview{ x=5, y=25, w=155, h=318, parent=randomat_settings }
randomat_settings.catList:AddColumn("Events")
randomat_settings.catList.Columns[1].DoClick = function() end

randomat_settings.catList.OnRowSelected = function(self, LineID, Line)
    local nPanel = xgui.modules.submodule[Line:GetValue(2)].panel

    if randomat_settings.curPanel ~= nil then
        randomat_settings.curPanel:SetZPos(-1)
        xlib.addToAnimQueue("pnlSlide", { panel=randomat_settings.curPanel, startx=0, starty=0, endx=-435, endy=0, setvisible=false })
    end

    if nPanel ~= randomat_settings.curPanel then
        nPanel:SetZPos(0)
        xlib.addToAnimQueue("pnlSlide", { panel=nPanel, startx=-435, starty=0, endx=0, endy=0, setvisible=true })
        randomat_settings.curPanel = nPanel
    else
        self:ClearSelection()
        randomat_settings.curPanel = nil
    end
    xlib.animQueue_start()
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

randomat_settings.search:SetPlaceholderText("Search...")
randomat_settings.search:SetUpdateOnType(true)
randomat_settings.search.OnValueChange = function(box, value)
    randomat_settings.catList:ClearSelection()
    randomat_settings.curPanel = nil
    randomat_settings.processModules()
    local lines = randomat_settings.catList:GetLines()
    for i, line in ipairs(lines) do
        local text = line:GetColumnText(1)
        if text ~= config_label and not string.find(text:lower(), value:lower()) then
            randomat_settings.catList:RemoveLine(i)
        end
    end
end

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
        local pnl = xlib.makelistlayout{ w=415, h=315, parent=xgui.null }
        pnl.scroll:SetSize(414, 315)

        local lst = vgui.Create("DListLayout", pnl)
        lst:SetPos(5, 25)
        lst:SetSize(415, 315)
        lst:DockPadding(0, 5, 0, 0)

        local name = ""
        if v.n ~= "" and v.n ~= nil then
            name = name .. v.n
        end
        if v.an ~= "" and v.an ~= nil then
            if string.len(name) == 0 then
                name = v.an
            else
                name = name .. " (aka " .. v.an .. ")"
            end
        end
        if name ~= "" then
            local labeltxt = xlib.makelabel{label=name, parent=lst, tooltip=name, font="TitleLabel"}
            lst:Add(labeltxt)
        end

        if v.d ~= "" and v.d ~= nil then
            local labeltxt = xlib.makelabel{label=v.d, parent=lst, tooltip=v.d}
            AddToList(labeltxt, lst)
        end

        local enable = xlib.makecheckbox{label="Enabled", repconvar="rep_ttt_randomat_"..k, parent=lst}
        AddToList(enable, lst)

        local min_players = xlib.makeslider{label="Minimum required players", repconvar="rep_ttt_randomat_"..k.."_min_players", min=0, max=32, 0, parent=lst}
        AddToList(min_players, lst)

        local weight = xlib.makeslider{label="Event selection weight", repconvar="rep_ttt_randomat_"..k.."_weight", min=-1, max=50, 0, parent=lst}
        AddToList(weight, lst)

        if v.s ~= nil then
            for _, j in pairs(v.s) do
                local conslider = xlib.makeslider{label=j.d, repconvar="rep_randomat_"..k.."_"..j.c, min=j.m, max=j.x, decimal=j.e or 0, parent=lst}
                AddToList(conslider, lst)
            end
        end

        if v.c ~= nil then
            for _, j in pairs(v.c) do
                local concheck = xlib.makecheckbox{label=j.d, repconvar="rep_randomat_"..k.."_"..j.c, parent=lst}
                AddToList(concheck, lst)
            end
        end

        if v.t ~= nil then
            for _, j in pairs(v.t) do
                local labeltxt = xlib.makelabel{label=j.d, parent=lst}
                AddToList(labeltxt, lst)
                local contxt = xlib.maketextbox{repconvar="rep_randomat_"..k.."_"..j.c, enableinput=true, parent=lst}
                AddToList(contxt, lst)
            end
        end

        local trigger = xlib.makebutton{w=150, label="Trigger Event", parent=lst}
        trigger.DoClick=function()
            RunConsoleCommand("ttt_randomat_trigger", k)
        end
        AddToList(trigger, lst)

        xgui.hookEvent("onProcessModules", nil, pnl.processModules)

        if v.n ~= "" and v.n ~= nil then
            xgui.addSubModule(string.TrimLeft(v.n, "#"), pnl, nil, "randomat_settings")
        end
        if v.an ~= "" and v.an ~= nil then
            xgui.addSubModule(string.TrimLeft(v.an, "#"), pnl, nil, "randomat_settings")
        end
    end
end

net.Receive("randomatULXEventsTransfer", function()
    local importEventsJson = net.ReadString()
    local importedEvents = util.JSONToTable(importEventsJson)
    loadRandomatULXEvents(importedEvents)
    -- Reload the modules since by this time its usually loaded already
    xgui.processModules()
end)

-----------General-Settings----------------------
local pnl = xlib.makelistlayout{ w=415, h=315, parent=xgui.null }
pnl.scroll:SetSize(414, 315)

local lst = vgui.Create("DListLayout", pnl)
lst:SetPos(5, 25)
lst:SetSize(415, 315)
lst:DockPadding(0, 5, 0, 0)

local labeltxt = xlib.makelabel{label="Randomat Configs", parent=lst, font="TitleLabel"}
lst:Add(labeltxt)

local rdmtauto = xlib.makecheckbox{label="Auto randomat on round start", repconvar="rep_ttt_randomat_auto", parent=lst}
AddToList(rdmtauto, lst)

local rdmtautochance = xlib.makeslider{label="Auto randomat chance", repconvar="rep_ttt_randomat_auto_chance", min=0,max=1,decimal=2, parent=lst}
AddToList(rdmtautochance, lst)

local rdmtautosilent = xlib.makecheckbox{label="Auto randomats are silent", repconvar="rep_ttt_randomat_auto_silent", parent=lst}
AddToList(rdmtautosilent, lst)

local rdmtautochoose = xlib.makecheckbox{label="Auto randomat is always \"choose\"", repconvar="rep_ttt_randomat_auto_choose", parent=lst}
AddToList(rdmtautochoose, lst)

local rdmtrebuy = xlib.makecheckbox{label="Rebuyable randomat (Requires restart)", repconvar="rep_ttt_randomat_rebuyable", parent=lst}
AddToList(rdmtrebuy, lst)

local rdmtchoice = xlib.makecheckbox{label="Choose events (See settings in 'Choose' event config)", repconvar="rep_ttt_randomat_chooseevent", parent=lst}
AddToList(rdmtchoice, lst)

local rdmteventweight = xlib.makeslider{label="Default event selection weight", repconvar="rep_ttt_randomat_event_weight", min=1,max=50, parent=lst}
AddToList(rdmteventweight, lst)

local rdmthint = xlib.makecheckbox{label="Give event hints", repconvar="rep_ttt_randomat_event_hint", parent=lst}
AddToList(rdmthint, lst)

local rdmthintchat = xlib.makecheckbox{label="Give event hints in chat", repconvar="rep_ttt_randomat_event_hint_chat", parent=lst}
AddToList(rdmthintchat, lst)

local rdmthistory = xlib.makeslider{label="Historical event tracking count", repconvar="rep_ttt_randomat_event_history", min=0,max=100, parent=lst}
AddToList(rdmthistory, lst)

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

local resetWeightsButton = xlib.makebutton{w=150, label="Reset event weights", parent=lst }
resetWeightsButton.DoClick=function()
    net.Start("rdmtresetweights")
    net.SendToServer()
end
AddToList(resetWeightsButton, lst)

local clearHistoryButton = xlib.makebutton{w=150, label="Clear event history", parent=lst }
clearHistoryButton.DoClick=function()
    net.Start("rdmtclearhistory")
    net.SendToServer()
end
AddToList(clearHistoryButton, lst)

xgui.hookEvent("onProcessModules", nil, pnl.processModules)
xgui.addSubModule(config_label, pnl, nil, "randomat_settings")