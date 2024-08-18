-- MADE BY LOADLUA
-- getSpeed func is iffy. i'll work on it soon enough.
-- use this as you would a module (it's object oriented!)
-- old tutorial on how to use this: https://www.youtube.com/watch?v=TMRx-xR7vR4
local TS = game:GetService("TweenService");
local Main = {}
local AnimationLoader = {}
local AnimationTrack = {}
Main.__index = Main

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
			tbl3[v.Name] = {v.CFrame,v.EasingStyle,v.EasingDirection}
		end
	end
	return(tbl3)
end

local function getSpeed(lastTimeStamp: number, currentTimeStamp: number)
	if currentTimeStamp == 0 then return 0 end
    return math.abs(lastTimeStamp - currentTimeStamp)
end

local function getAnimation(animationId: string)
	local animationObject
	local S,E = pcall(function()
		--animationObject = game:GetService("InsertService"):LoadAsset(animationId):GetChildren()[1] -- for studio
		animationObject = game:GetObjects(animationId)[1]
	end)
	return animationObject
end

function AnimationLoader:AddElement(Name: string, Part0: BasePart, Part1: BasePart, StartCFrame: CFrame?): nil
    assert(typeof(Name) == "string", "first argument is the name of the motor6d")
    assert(typeof(Part0) == "Instance", "second argument is Part0")
    assert(typeof(Part1) == "Instance", "third argument is Part1")
    assert(Part0 == Part1, "Part0 and Part1 cannot be the same")
    if not StartCFrame then StartCFrame = CFrame.new(0,0,0) end

    local m6d = Instance.new("Motor6D")
    m6d.Parent = Part0
    m6d.Part0 = Part0
    m6d.Part1 = Part1
    m6d.C0 = StartCFrame

    return nil
end

function AnimationLoader:LoadAnimation(animationId: string)
	local Character = self.char
	local animationObject = getAnimation(animationId)
	if animationObject == nil then error("animation doesn't exist") end

	local t = table.clone(AnimationTrack)
	
	t.char = Character
	t.animObject = AnimationTrack

	return t
end

function AnimationTrack:Play(): nil
	local Character = self.char
	local animationObject = self.animObject
	local Looped = animationObject.Loop
	local anim = {}
    local defaultC0s = {}
    local count

	for i,v in pairs(animationObject:GetChildren()) do
		if v:IsA("Keyframe") then
			anim[v.Time]=kftotbl(v)
		end
	end
    for _,motor in ipairs(Character:GetDescendants()) do
        if motor:IsA("Motor6D") then
            defaultC0s[motor.Name] = motor.C0
        end
    end

	count = -1
	local lastTimeStamp = 0
	self.played = false
    coroutine.wrap(function()
    	while task.wait() do
            if self.played then 
                for _,motor in ipairs(Character:GetDescendants()) do
                    if motor:IsA("Motor6D") and defaultC0s[motor.Name] then
                        motor.C0 = defaultC0s[motor.Name]
                    end
                end
                break 
            end
            if not Looped then 
                self.played = true
            end	
            for i,oasjdadlasdkadkldjkl in pairs(anim) do
                local asdf=getnext(anim,count)
                local v=anim[asdf]
                count=asdf
    
                for name,info in pairs(v) do
                    coroutine.wrap(function()
                        for _,motor in ipairs(Character:GetDescendants()) do
                            if motor.Name == name and motor:IsA("Motor6D") then
                                local cf, style, dir = table.unpack(info)
                                local Ti = TweenInfo.new(getSpeed(lastTimeStamp,asdf),Enum.EasingStyle[style.Name],Enum.EasingDirection[dir.Name])
                                
                                TS:Create(motor, Ti, {C0 = defaultC0s[motor.Name]*cf}):Play()
                            end
                        end
                    end)()
                end
    
                task.wait(getSpeed(lastTimeStamp,asdf))
                lastTimeStamp = asdf
            end
        end
    end)()
end

function AnimationTrack:Stop(): nil
	self.played = true
end

function Main.loadDummy(DummyChar: Model)
	local t = table.clone(AnimationLoader)

	t.char = DummyChar

	return t
end

return Main
