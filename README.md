# Chat Commands
*!rdmt EventId* - Starts an event with the given "EventId".\
*!srdmt EventId* - Safely starts an event with the given "EventId". Will cause a server-side error if the event's conditions are not met.\
*!clearevent EventId*/*!stopevent EventId* - Stops an event with the given "EventId". Will cause a server-side error if no event with that ID is running.\
*!clearevents*/*!stopevents* - Stops all active events.

# GetConVars Implementation Example

``` lua
-- NOTE: All convars MUST be named in this format: randomat_{EVENT ID}_{restofthename}
CreateConVar("randomat_example_slider", 2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Small slider", 1, 10)
CreateConVar("randomat_example_slider2", 200, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Large slider", 0, 1000)
CreateConVar("randomat_example_checkbox", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Checkbox")
CreateConVar("randomat_example_textbox", "value", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Textbox")

EVENT.Title = "GetConVars Example"
EVENT.Description = "An example implementation of GetConVars"
EVENT.id = "example"

function EVENT:GetConVars()
    local sliders = {}
    for _, v in pairs({"slider", "slider2", "slider3"}) do
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
    for _, v in pairs({"checkbox1", "checkbox2", "checkbox3"}) do
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
    for _, v in pairs({"textbox1", "textbox2", "textbox3"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(textboxes, {
                cmd = v,                    -- The command extension (e.g. everything after "randomat_example_")
                dsc = convar:GetHelpText()  -- The description of the ConVar
            })
        end
    end

    -- OPTIONAL: By default, convars will appear in ULX in the order sliders -> checkboxes -> textboxes, and within
    -- those groups in the order that you insert them into e.g. `for _, v in pairs({"slider", "slider2", "slider3"}) do`.
    -- You can optionally specify the order in which convars appear, and/or group them together - either in a collapsible
    -- list or just under a heading. Convars without a specified order/group will appear at the bottom.
    local layout = {
        ["checkbox1"] = 1,                  -- Individual convar assigned position 1
        ["textbox1"] = 2,                   -- Individual convar assigned position 2

        ["Example Group"] = {               -- A group with the title "Example Group"
            pos = 3,                        -- The group's position in the overall list
            collapsible = true,             -- Whether the group is a collapsible list rather than a heading
            expanded = true,                -- Whether the list starts expanded or collapsed (collapsed if not specified)
            items = {                       -- The group's convars (in the order they will appear in ULX)
                "checkbox2",
                "slider3",
                "slider1"
            }
        },

        ["textbox2"] = 4                    -- Individual convar assigned position 4

        ["Another Example Group"] = {       -- A group with the title "Another Example Group"
            pos = 5,                        -- The group's position in the overall list
            items = {                       -- The group's convars (in the order they will appear in ULX)
                "checkbox3",
                "textbox3",
                "slider2"
            }
        }
    }

    return sliders, checks, textboxes, layout
end
```