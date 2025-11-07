--!strict
local _C = require(game:GetService("ReplicatedStorage").Framework.Kit.Repository.Interactables.PropertyChanger.TypeDefs)
local script, workspace, Workspace, game, Game, shared, _G, wait, task, spawn, delay, Spawn, Delay, Wait, require, Instance
local Toucher, Tagged, TagFromSequenceVariable, Changer, Character = _C.Toucher, _C.Tagged, _C.TagFromSequenceVariable, _C.Changer, _C.Character
-- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE -- -- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE --

--[[
-- # READ THIS # READ THIS # READ THIS # READ THIS # READ THIS # --
if the client object is a spinner:
1. add a `Configuration` object to the model
2. also add a tag called `TargetSpinner`
3. rename it to ModifyConfiguration
4. add the following Attributes
	- TargetSpeed: number
	- Duration: number
	- Reverses: boolean
	- ChangeDelay: number

if the client object is a conveyor:
1. add a tag called `TargetConveyor` TO THE PART BTW
2. repeat the following steps from before: 1, 3, 4
]]--

local Properties: _C.Format = {
	-- # SPINNERS
	{
		Instance = Tagged("TargetSpinner"),
		Tween = TweenInfo.new(
			Tagged("TargetSpinner"):FindChild("ModifyConfiguration"):Property("Duration"), 
			Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, 
			Tagged("TargetSpinner"):FindChild("ModifyConfiguration"):Property("Reverses"),
			Tagged("TargetSpinner"):FindChild("ModifyConfiguration"):Property("ChangeDelay")
		), 
		AngularVelocity = Tagged("TargetSpinner"):FindChild("ModifyConfiguration"):Property("TargetSpeed")
	},
	-- # CONVEYORS
	{
		Instance = Tagged("TargetConveyor"),
		Tween = TweenInfo.new(
			Tagged("TargetSpinner"):FindChild("ModifyConfiguration"):Property("Duration"), 
			Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, 
			Tagged("TargetSpinner"):FindChild("ModifyConfiguration"):Property("Reverses"),
			Tagged("TargetSpinner"):FindChild("ModifyConfiguration"):Property("ChangeDelay")
		),
		AssemblyLinearVelocity = function(_E)
				return _E.Tagged("TargetConveyor").CFrame.LookVector * _E.Tagged("TargetConveyor"):FindChild("ModifyConfiguration"):Property("TargetSpeed")
		end
	},
	{
		Instance = Tagged("TargetConveyor"):FindChild("Beam"),
		Tween = TweenInfo.new(
			Tagged("TargetSpinner"):FindChild("ModifyConfiguration"):Property("Duration"), 
			Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, 
			Tagged("TargetSpinner"):FindChild("ModifyConfiguration"):Property("Reverses"),
			Tagged("TargetSpinner"):FindChild("ModifyConfiguration"):Property("ChangeDelay")
		),
		TextureSpeed = Tagged("TargetConveyor"):FindChild("ModifyConfiguration"):Property("TargetSpeed") / _E.Tagged("TargetConveyor"):FindChildOfClass("Beam"):Property("TextureLength")
	},
}
	
return Properties