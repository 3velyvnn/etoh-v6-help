--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Framework = ReplicatedStorage.Framework
local Kit = Framework.Kit
local Managers = Framework.Kit.Managers
local _T = require(Framework.ClientTypes)
local Types = require(Kit.Utility.Config.Type)

--[=[
	@within PlayerMod
	@class PlayerModConfig
	
	This is the configuration for `PlayerMod`
]=]--

local PlayerModConfig = {
	BaseConfig = {
		Revert = false,
		Cooldown = 1,
	},
	MovementConfig = {
		Enabled = false,
		RelativeToCamera = true,
		LockAxisConfig = {
			Enabled = false,
			Axis = Vector3.zero
		},
		DirectionalConfig = {
			Enabled = false,
			ForwardOverride = Vector3.zero,
			InvertedMovement = true,
		},
	},
	CameraConfig = {
		Enabled = false,
		FieldOfView = 70,
	}
}
return PlayerModConfig
