# Chat Commands
*!rdmt EventId* - Starts an event with the given "EventId".\
*!srdmt EventId* - Safely starts an event with the given "EventId". Will cause a server-side error if the event's conditions are not met.\
*!clearevent EventId*/*!stopevent EventId* - Stops an event with the given "EventId". Will cause a server-side error if no event with that ID is running.\
*!clearevents*/*!stopevents* - Stops all active events.

# GetConVars Implementation Example

``` lua
CreateConVar("randomat_example_slider", 2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Small slider", 1, 10)
CreateConVar("randomat_example_slider2", 200, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Large slider", 0, 1000)
CreateConVar("randomat_example_checkbox", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Checkbox")
CreateConVar("randomat_example_textbox", "value", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Textbox")

EVENT.Title = "GetConVars Example"
EVENT.Description = "An example implementation of GetConVars"
EVENT.id = "example"

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"slider", "slider2"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,                    -- The command extension (e.g. everything after "randomat_example_")
                dsc = convar:GetHelpText(), -- The description of the ConVar
                min = convar:GetMin(),      -- The minimum value for this slider-based ConVar
                max = convar:GetMax(),      -- The maximum value for this slider-based ConVar
                dcm = 0                     -- The number of decimal points to support in this slider-based ConVar
            })
        end
    end

    local checks = {}
    for _, v in pairs({"checkbox"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,                    -- The command extension (e.g. everything after "randomat_example_")
                dsc = convar:GetHelpText()  -- The description of the ConVar
            })
        end
    end

    local textboxes = {}
    for _, v in pairs({"textbox"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(textboxes, {
                cmd = v,                    -- The command extension (e.g. everything after "randomat_example_")
                dsc = convar:GetHelpText()  -- The description of the ConVar
            })
        end
    end

    return sliders, checks, textboxes
end
```