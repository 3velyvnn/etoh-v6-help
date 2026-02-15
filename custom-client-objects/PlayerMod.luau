--!strict
--!optimize 2
--@version playermod-6.1.2
--@creator 3velyvnn

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Framework = ReplicatedStorage.Framework
local Kit = Framework.Kit
local Managers = Framework.Kit.Managers

--> Types
local _T = require(Framework.ClientTypes)
local _TDefs = require(script.TypeDefs)
local Type = require(Kit.Utility.Config.Type)
local CharacterManager_Types = require(Managers.CharacterManager.TypeDefs)
local LocalPlayer = Players.LocalPlayer

local PlayerMod = {
	CanQueue = true,
	RunOnStart = false,
}

local CONFIG_TEMPLATE = {}
local CAMERA_DEFAULTS = {
	FieldOfView = 70,
	CameraType = Enum.CameraType.Custom
}

local currentCamera = workspace.CurrentCamera

function PlayerMod.Init(utility: _T.Utility)
	local Config = utility.Config
	CONFIG_TEMPLATE = _TDefs.BaseConfig
end

function PlayerMod.Run(scope: _T.Scope, utility: _T.Utility)
	--> Setup
	local objectConfig = scope.instance
	if (not objectConfig) or (not objectConfig.Parent) then
		return
	end

	local pad = objectConfig.Parent
	if (not pad) or (not pad:IsA("BasePart")) then
		return
	end

	--> Player Module
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	local MovementController = playerModule:GetControls()

	--> Restore to defaults on unload.
	scope:add(function()
		MovementController.moveFunction = LocalPlayer.Move
	end)

	--> Utility
	local Character = utility.Character
	local Functions = utility.Functions
	local ObjectConfigs = objectConfig:GetChildren()
	local _OC = {
		MovementConfiguration = objectConfig:WaitForChild("MovementConfiguration"),
		CameraConfiguration = objectConfig:WaitForChild("CameraConfiguration")
	}

	----> Configurations
	local Config = utility.Config
	local _C = {
		BaseConfiguration = {
			__index = Config.GetConfig(scope, objectConfig, CONFIG_TEMPLATE):ObserveChanges(),
			TouchConfiguration = Config.GetConfig(scope, objectConfig:FindFirstChild("TouchConfiguration"), Config.TOUCH_CONFIG):ObserveChanges(),
			TweenConfiguration = Config.GetConfig(scope, objectConfig:FindFirstChild("TweenConfiguration"), Config.TWEEN_CONFIG):ObserveChanges(),
		},
		MovementConfiguration = {
			__index = Config.GetConfig(
				scope, _OC.MovementConfiguration, {
					Enabled = true,
					RelativeToCamera = true,
				}
			)
				:ObserveChanges(),
			LockAxis = Config.GetConfig(
				scope, _OC.MovementConfiguration:WaitForChild("LockAxisConfiguration"),
				_TDefs.MovementConfig.LockAxisConfig
			)
				:ObserveChanges(),
			DirectionalConfig = Config.GetConfig(
				scope, _OC.MovementConfiguration:WaitForChild("DirectionalConfiguration"), 
				_TDefs.MovementConfig.DirectionalConfig
			)
				:ObserveChanges()
		},
		CameraConfiguration = Config.GetConfig(
			scope, _OC.CameraConfiguration, _TDefs.CameraConfig)
			:ObserveChanges(),
		CooldownActive = false
	}

	--> congigfires (thank you ramification for this section name)
	local movementConfig = _C.MovementConfiguration
	local cameraConfig = _C.CameraConfiguration
	local baseConfig = _C.BaseConfiguration

	local playerCharacter = Character.getCharacter()
	local humanoid = Character.getHumanoid()
	if (not playerCharacter.primaryPart) then return end	

	local lockAxis = movementConfig.LockAxis
	local directionalConfig = movementConfig.DirectionalConfig
	--> Handler
	_C.__index = {}
	_C.__index.Connections = {}
	_C.__index.Movement = function(): ()

		local MovementController = playerModule:GetControls()
		MovementController.moveFunction = function(player: Player, walkDirection: Vector3, relativeToCamera: boolean)
			if (lockAxis.Enabled) then
				-- the only valid axis should only be Vector3.zAxis and Vector3.xAxis
				if (lockAxis.Axis == Vector3.xAxis) then
					LocalPlayer.Move(player, Vector3.xAxis * walkDirection.X, movementConfig.__index.RelativeToCamera)
				elseif (lockAxis.Axis == Vector3.zAxis) then
					LocalPlayer.Move(player, Vector3.zAxis * walkDirection.Z, movementConfig.__index.RelativeToCamera)
				end
			end
			if (directionalConfig.Enabled) then
				if (directionalConfig.InvertedMovement )then
					LocalPlayer.Move(player, -walkDirection, relativeToCamera)
				else
					LocalPlayer.Move(player, directionalConfig.ForwardOverride, movementConfig.__index.RelativeToCamera)
				end
			end
		end
	end

	_C.__index.Camera = function(): ()
		if (not currentCamera) then return end
		-- Store the current FOV to prevent reversion to 70
		local targetFOV = cameraConfig.FieldOfView or currentCamera.FieldOfView
		Functions.tween(
			currentCamera, 
			_C.BaseConfiguration.TweenConfiguration,
			{FieldOfView = targetFOV}
		)
	end
	_C.__index.__call = function()
		if (baseConfig.__index.Revert) then
			MovementController.moveFunction = function(player: Player, walkDirection: Vector3, relativeToCamera: boolean)
				LocalPlayer.Move(player, walkDirection, relativeToCamera)
			end

			Functions.tween(
				currentCamera, 
				_C.BaseConfiguration.TweenConfiguration,
				{
					FieldOfView = 70
				}
			)
		else
			if (movementConfig.__index.Enabled) then
				scope:add(_C.__index.Movement())
			end
			if (cameraConfig.Enabled) then
				scope:add(_C.__index.Camera())
			end
		end
	end

	_C.__index.Connections.OnTouched = pad.Touched:Connect(function(part: BasePart)
		if (not playerCharacter) or (not humanoid) or (not LocalPlayer) then return end

		if (_C.CooldownActive == false) then
			_C.CooldownActive = true

			scope:add(_C.__index.__call())
			scope:delay(
				(typeof(baseConfig.__index.Cooldown) == "number") and (baseConfig.__index.Cooldown) or 1, 
				function()
					_C.CooldownActive = false
				end
			)
		end
	end)
	--> Connections
	scope:add(_C.__index.Connections)
end
return PlayerMod
