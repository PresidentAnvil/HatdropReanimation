-- MADE BY LOADLUA
-- getSpeed func is iffy. i'll work on it soon enough.
-- use this as you would a module (it's object oriented!)
-- old tutorial on how to use this: https://www.youtube.com/watch?v=TMRx-xR7vR4

local TS = game:GetService("TweenService");
local count2;
local maxcount2;
local count;
local function getnext(tbl,number)
	local c=100
	local rtrnv=0
	for i,v in pairs(tbl) do
		if i>number and i-number<c then
			c=i-number
			rtrnv=i
		end
	end
	return(rtrnv)
end
local function kftotbl(kf)
	local tbl3 = {}
	for i,v in pairs(kf:GetDescendants()) do
		if v:IsA("Pose") then
			tbl3[string.sub(v.Name,1,1)..string.sub(v.Name,#v.Name,#v.Name)] = v.CFrame
		end
	end
	return(tbl3)
end
local function getSpeed(lastTimeStamp: number, currentTimeStamp: number)
	if currentTimeStamp == 0 then return 0 end
    return math.abs(lastTimeStamp - currentTimeStamp) * 2
end

local function getAnimation(animationId: string)
	local animationObject
	local S,E = pcall(function()
		--animationObject = game:GetService("InsertService"):LoadAsset(animationId):GetChildren()[1]
		animationObject = game:GetObjects(animationId)[1]
	end)
	return animationObject
end

local Main = {}
Main.__index = Main

function Main.LoadDummy(DummyChar: Model)
	local metatable = {}
	
	setmetatable(metatable, Main)

	metatable.char = DummyChar

	return metatable
end


function Main:LoadAnimation(animationId: string)
	local Character = self.char
	local animationObject = getAnimation(animationId)
	if animationObject == nil then return end
	print(animationObject)
	local metatable = {}

	setmetatable(metatable, Main)
	
	metatable.char = Character
	metatable.animObject = animationObject

	return metatable
end


function Main:Play()
	local Character = self.char
	local animationObject = self.animObject
	local Looped = animationObject.Loop
	local anim={}
	for i,v in pairs(animationObject:GetChildren()) do
		if v:IsA("Keyframe") then
			anim[v.Time]=kftotbl(v)
		end
	end
	local LH = Character.Torso["Left Hip"].C0
	local RH = Character.Torso["Right Hip"].C0
	local LS = Character.Torso["Left Shoulder"].C0
	local RS = Character.Torso["Right Shoulder"].C0
	local RoH = Character.HumanoidRootPart["RootJoint"].C0
	local N = Character.Torso["Neck"].C0
	count = -1
	local lastTimeStamp = 0
	local char=Character
	self.played = false
	while task.wait() do
		if self.played then 
			Character.Torso["Left Hip"].C0 = LH
			Character.Torso["Right Hip"].C0 = RH
			Character.Torso["Left Shoulder"].C0 = LS
			Character.Torso["Right Shoulder"].C0 = RS
			Character.HumanoidRootPart["RootJoint"].C0 = RoH
			Character.Torso["Neck"].C0 = N
			break 
		end
		if not Looped then 
			self.played = true
		end	
		for i,oasjdadlasdkadkldjkl in pairs(anim) do
			local asdf=getnext(anim,count)
			local v=anim[asdf]
 
			count2=0
			maxcount2=asdf-count
			count=asdf
			wait(asdf-count)
			count2=maxcount2
			if v["Lg"] then

				local Ti = TweenInfo.new(getSpeed(lastTimeStamp,asdf))
				
				TS:Create(Character.Torso["Left Hip"] , Ti, {C0 = LH*v["Lg"]}):Play()
				
			end
			if v["Rg"] then

				local Ti = TweenInfo.new(getSpeed(lastTimeStamp,asdf))

				TS:Create(Character.Torso["Right Hip"] , Ti, {C0 = RH*v["Rg"]}):Play()
				
			end
			if v["Lm"] then

				local Ti = TweenInfo.new(getSpeed(lastTimeStamp,asdf))

				TS:Create(Character.Torso["Left Shoulder"] , Ti, {C0 = LS*v["Lm"]}):Play()

			end
			if v["Rm"] then

				local Ti = TweenInfo.new(getSpeed(lastTimeStamp,asdf))

				TS:Create(Character.Torso["Right Shoulder"] , Ti, {C0 = RS*v["Rm"]}):Play()

			end
			if v["To"] then

				local Ti = TweenInfo.new(getSpeed(lastTimeStamp,asdf))

				TS:Create(Character.HumanoidRootPart["RootJoint"] , Ti, {C0 = RoH*v["To"]}):Play()

			end
			if v["Hd"] then

				local Ti = TweenInfo.new(getSpeed(lastTimeStamp,asdf))

				TS:Create(Character.Torso["Neck"] , Ti, {C0 = N*v["Hd"]}):Play()
				
			end
			task.wait(getSpeed(lastTimeStamp,asdf))
			lastTimeStamp = asdf
		end
	end
	
end

function Main:Stop()
	self.played = true
end

return Main
