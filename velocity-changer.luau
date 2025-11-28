--!strict
local _C = require(game:GetService("ReplicatedStorage").Framework.Kit.Repository.Interactables.PropertyChanger.TypeDefs)
local script, workspace, Workspace, game, Game, shared, _G, wait, task, spawn, delay, Spawn, Delay, Wait, require, Instance
local Toucher, Tagged, TagFromSequenceVariable, Changer, Character = _C.Toucher, _C.Tagged, _C.TagFromSequenceVariable, _C.Changer, _C.Character
-- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE -- -- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE --

-- run this code in the command bar, YOU MUST SELECT THE PROPERTYCHANGERCONFIGURATION BTW 
--[[
game.Selection:Get()[1]:SetAttribute("Speed", 30)
]]--
local Properties: _C.Format = {
	{
		Instance = Toucher(),
		AssemblyLinearVelocity = function(_E)
				return _E.Value("CameraCFrame").LookVector * _E.Changer():FindChildOfClass("Configuration"):Property("Speed")
		end
	},
}
	
return Properties