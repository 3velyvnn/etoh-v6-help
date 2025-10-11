--!strict
local _C = require(game:GetService("ReplicatedStorage").Framework.Kit.Repository.Interactables.PropertyChanger.TypeDefs)
local script, workspace, Workspace, game, Game, shared, _G, wait, task, spawn, delay, Spawn, Delay, Wait, require, Instance
local Toucher, Tagged, TagFromSequenceVariable, Changer, Character = _C.Toucher, _C.Tagged, _C.TagFromSequenceVariable, _C.Changer, _C.Character
-- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE -- -- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE --

local Properties: _C.CheckerFormat = {
    {
        Instance = Changer(),
        Condition = function(_E)
            return _E.Value("Distance", _E.Instance():Property("Position")) < 10 -- boolean value
        end,
				--[[
						-- also can handle events
    				{
        				Instance = Tagged("ProximityPrompt"), -- class type must be "ProximityPrompt"
       					Event = function(_E)
            				return _E.Instance():Event("Triggered")
        				end,
    			},
				]]--
    },
}

return Properties