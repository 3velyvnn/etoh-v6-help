--!strict
local _C = require(game:GetService("ReplicatedStorage").Framework.Kit.Repository.Interactables.PropertyChanger.TypeDefs)
local script, workspace, Workspace, game, Game, shared, _G, wait, task, spawn, delay, Spawn, Delay, Wait, require, Instance
local Toucher, Tagged, TagFromSequenceVariable, Changer, Character = _C.Toucher, _C.Tagged, _C.TagFromSequenceVariable, _C.Changer, _C.Character
-- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE -- -- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE --

local Properties: _C.Format = {
	{
		Instance = Tagged("UICaption"),
		Text = function(_E)
			local metadata = _E.SequenceInstance("TouchingPart"):FindChild("_metadata")
			local typeOfAction = metadata:Property("GoalType")
			local validTypes: {[string]: any} = {
				Button = function()
					local buttonTag = _E.Tagged(metadata:Property("ButtonTag"))
					return ""
				end,
				Coin = function()
					return ""
				end,
				Distance = function()
					return ""
				end,
			}
			return validTypes[typeOfAction]()
		end,
	},
}

return Properties
