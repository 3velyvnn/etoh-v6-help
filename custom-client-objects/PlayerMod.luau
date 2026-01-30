--!strict
--!optimize 2
--@version playermod-6.1.2
--@creator 3velyvnn

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

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

local SequencerSupport = require(script.SequencerSupport)
local function handleCache(rootScope: _T.Scope, utility: _T.Utility)
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	local cache = {
		Player = LocalPlayer,
		PlayerModule = playerModule,
		MovementController = playerModule:GetControls()
	}
	SequencerSupport(rootScope, utility, cache)
	return cache
end

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
	if not objectConfig or not objectConfig.Parent then
		return
	end

	local pad = objectConfig.Parent
	if not pad or not pad:IsA("BasePart") then
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
				scope, objectConfig:FindFirstChild("MovementConfiguration"), {
					Enabled = true,
					RelativeToCamera = true,
				}
			)
				:ObserveChanges(),
			LockAxis = Config.GetConfig(
				scope, objectConfig:FindFirstChild("LockAxisConfiguration"), 
				_TDefs.MovementConfig.LockAxisConfig
			)
				:ObserveChanges(),
			DirectionalConfig = Config.GetConfig(
				scope, objectConfig:FindFirstChild("DirectionalConfiguration"), 
				_TDefs.MovementConfig.DirectionalConfig
			)
				:ObserveChanges()
		},
		CameraConfiguration = {
			__index = Config.GetConfig(
				scope, objectConfig:FindFirstChild("CameraConfiguration"), {
					Enabled = false,
					FieldOfView = 70,
				}
			)
				:ObserveChanges(),
			LockCamera = Config.GetConfig(scope, objectConfig:FindFirstChild("LockCameraConfiguration"), _TDefs.CameraConfig.LockCameraConfig)
				:ObserveChanges(),
			RotateCamera = Config.GetConfig(scope, objectConfig:FindFirstChild("RotateCameraConfiguration"), _TDefs.CameraConfig.RotateCameraConfig)
				:ObserveChanges()
		},
		CooldownActive = false,
	}

	--> congigfires (thank you ramification for this section name)
	local movementConfig = _C.MovementConfiguration
	local cameraConfig = _C.CameraConfiguration
	local baseConfig = _C.BaseConfiguration

	local playerCharacter = Character.getCharacter()
	local humanoid = Character.getHumanoid()	

	--> Handler
	_C.__index = {}
	_C.__index.Connections = {}
	_C.__index.Movement = function(): ()
		local lockAxis = movementConfig.LockAxis
		local directionalConfig = movementConfig.DirectionalConfig
		local MovementController = playerModule:GetControls()
		MovementController.moveFunction = function(player: Player, walkDirection: Vector3, relativeToCamera: boolean)
			if lockAxis.Enabled then
				-- the only valid axis should only be Vector3.zAxis and Vector3.xAxis
				if lockAxis.Axis == Vector3.xAxis then
					LocalPlayer.Move(player, Vector3.xAxis * walkDirection.X, movementConfig.__index.RelativeToCamera)
				elseif lockAxis.Axis == Vector3.zAxis then
					LocalPlayer.Move(player, Vector3.zAxis * walkDirection.Z, movementConfig.__index.RelativeToCamera)
				end
			
			end
			if directionalConfig.Enabled then
				if directionalConfig.InvertedMovement then
					LocalPlayer.Move(player, -walkDirection, relativeToCamera)
				else
					LocalPlayer.Move(player, directionalConfig.ForwardOverride, movementConfig.__index.RelativeToCamera)
				end
			end
		end
	end
	_C.__index.Camera = function(): ()
		local lockCamera = cameraConfig.LockCamera
		local rotateCamera = cameraConfig.RotateCamera
		
		if lockCamera.Enabled then
			currentCamera.CameraType = Enum.CameraType.Scriptable
			local lockRotation = lockCamera.LockRotation.Rotation :: CFrame
			currentCamera.CFrame *= lockRotation
		end
		
		if rotateCamera.Enabled then
			currentCamera.CameraType = Enum.CameraType.Scriptable
			_C.__index.Connections.RenderStepped = RunService.RenderStepped:Connect(function(deltaTime: number)
				currentCamera.CFrame *= CFrame.Angles(0, math.rad(rotateCamera.RotationSpeed), 0)
			end)
		end
		
		if cameraConfig.__index.FieldOfView >= 5 then
			utility.Functions.tween(currentCamera, baseConfig.TweenConfiguration, {FieldOfView = cameraConfig.__index.FieldOfView})
		end
	end
	

	_C.__index.__call = function()
		print("call")
		if baseConfig.__index.Revert then
			currentCamera.FieldOfView = CAMERA_DEFAULTS.FieldOfView
			currentCamera.CameraType = CAMERA_DEFAULTS.CameraType
			MovementController.moveFunction = function(player: Player, walkDirection: Vector3, relativeToCamera: boolean)
				LocalPlayer.Move(player, walkDirection, relativeToCamera)
			end
		else
			if movementConfig.__index.Enabled then
				scope:add(_C.__index.Movement(), _C.__index.Camera())
			end
		end
	end
	
	_C.__index.Connections.OnTouched = pad.Touched:Connect(function(part: BasePart)
		if not utility.ClientObjects.evaluateToucher(pad, part, baseConfig.TouchConfiguration) then return end
		if not playerCharacter or not humanoid or not LocalPlayer then return end

		if _C.CooldownActive == false then
			_C.CooldownActive = true

			scope:add(_C.__index.__call())
			scope:delay(typeof(baseConfig.__index.Cooldown) == "number" and baseConfig.__index.Cooldown or 1, function()
				_C.CooldownActive = false
			end)
		end
	end)
	--> Connections
	scope:add(_C.__index.Connections)
	--> Sequencer Cache Support
	local cache = utility.Scope.getCached(scope, scope.scriptPath, handleCache)
end
return PlayerMod
