--!strict
local _C = require(game:GetService("ReplicatedStorage").Framework.Kit.Repository.Interactables.PropertyChanger.TypeDefs)
local script, workspace, Workspace, game, Game, shared, _G, wait, task, spawn, delay, Spawn, Delay, Wait, require, Instance
local Toucher, Tagged, TagFromSequenceVariable, Changer, Character = _C.Toucher, _C.Tagged, _C.TagFromSequenceVariable, _C.Changer, _C.Character
-- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE -- -- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE --

local Properties: _C.Format = {
	{
		Instance = Character(),
		ScaleTo = 2,
		PivotTo = function(_E)
			return (_E.Value("CameraCFrame") :: CFrame) + CFrame.new(0, 100, 0)
		end,
	},
}
	
return Properties