-- set/gethiddenproperty required
r=math.rad
ca=CFrame.Angles
cn=CFrame.new

getgenv().velocity = Vector3.new(20,20,20)
getgenv().viewdeath = false
getgenv().Accessories = {
	-- Limb/Part name | {Accessory name, offset}
	["Left Arm"] = {"MessyHair",ca(0,0,r(90))},
	["Right Arm"] = {"Pal Hair",ca(0,0,-r(90))},
	["Right Leg"] = {"Hat1",ca(0,0,r(90))},
	["Left Leg"] = {"BrownCharmerHair",ca(0,0,r(90))},
	["Torso"] = {"MeshPartAccessory",ca(0,0,-r(14))},
	["Head"] = {"MediHood",cn(0,0,0.2)},
	["FlingPart"] = {"",cn(0,0,0)}
}
------------------------------------------------------------------------------------------------------------------------
local plr = game.Players.LocalPlayer
local fph = workspace.FallenPartsDestroyHeight
local Accessories = getgenv().Accessories
local mouse = plr:GetMouse()
local ps = game:GetService("RunService").PostSimulation
local printdebug = true
local FakeCharacter
local flingCooldown
local flingpart

function complexfind(t,c)
	-- table.find is Bad i domp like irwt

	for i,v in pairs(t) do
		if v == c then return i,v end
		if type(v) == "table" then if complexfind(v,c) then return i,v end end -- will return most parent and not 1 or 2
	end

	return false
end

function HatdropCallback(character: Model, callback: Function, yeild: bool?)
    local velocity = getgenv().velcoity
    local c=character
    local hrp = c:WaitForChild('HumanoidRootPart')
	for i, v in pairs(c.Humanoid:GetPlayingAnimationTracks()) do
        v:Stop()
    end
    hrp.CFrame = FakeCharacter.HumanoidRootPart.CFrame
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://35154961"
    local loadanim = c.Humanoid:LoadAnimation(anim)
    loadanim:Play()
    loadanim.TimePosition = 3.24
    loadanim:AdjustSpeed(0)
    local a = FakeCharacter.HumanoidRootPart.CFrame
    for i, v in c.Humanoid:GetAccessories() do
        sethiddenproperty(v,"BackendAccoutrementState",0)
        local limb, info = complexfind(Accessories,v.Name)
        local isleghat = limb:find("Leg")


        task.delay(0.7+.8,function()
            local con;con = game:GetService"RunService".PostSimulation:Connect(function(dt)
                pcall(function()
                    if not v:FindFirstChild("Handle") then
                        con:Disconnect()
                    end
                    if isleghat then
                        v.Handle.CanCollide = false
                    end
                    v.Handle.AssemblyLinearVelocity = velocity               
                end)
            end)
        end)
    end
    hrp.CFrame *= CFrame.Angles(math.rad(90),0,0)
    c.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    game:GetService("TweenService"):Create(hrp,TweenInfo.new(1.8,Enum.EasingStyle.Linear),{CFrame = CFrame.new(a.X,fph+6,a.Z)* ca(r(90),0,0)}):Play()
    local t = {}
    c.ChildRemoved:Connect(function(v)
        if v:IsA("BasePart") then
            table.insert(t,v.Name)
        end
    end)
    coroutine.wrap(function()
        while hrp.Parent ~= nil do
            game:GetService("RunService").PostSimulation:Wait()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)()
    task.wait(0.85+.8)
    c.Humanoid.Health = 0
	callback(c.Humanoid:GetAccessories())
    local stopat = tick()+2
    repeat task.wait() until t[7] or tick()>stopat
    if t[7] == "Head" and t[1] == "HumanoidRootPart" then
        print("Your hats got collision")
    else
        print("Body parts were deleted out of order. You may not have gotten collision")
    end
end

function Align(Part1,Part0,CFrameOffset) 
    local con;con=ps:Connect(function()
        if Part1.Parent == nil then con:Disconnect() return end
        Part1.CFrame = Part0.CFrame * CFrameOffset
    end)
end

do
	local RealChar = plr.Character

	RealChar.Archivable = true
	FakeCharacter = RealChar:Clone()
	FakeCharacter.Name = FakeCharacter.Name.."_fake"
	FakeCharacter.Parent = workspace
	
	do
		-- fake movement (pasted from some really really old reanimation :P)
		
		local LVecPart = Instance.new("Part", workspace) 
		LVecPart.CanCollide = false 
		LVecPart.Transparency = 1
		local walk = Instance.new("Animation",FakeCharacter)
		walk.AnimationId = "http://www.roblox.com/asset/?id=180426354"
		local walka = FakeCharacter.Humanoid:LoadAnimation(walk)
		local jump = Instance.new("Animation",FakeCharacter)
		jump.AnimationId = "http://www.roblox.com/asset/?id=125750702"
		local jumpa = FakeCharacter.Humanoid:LoadAnimation(jump)
		local CONVEC
		local function VECTORUNIT()
			if HumanDied then CONVEC:Disconnect(); return end
			local lookVec = workspace.Camera.CFrame.lookVector
			local Root = FakeCharacter["HumanoidRootPart"]
			LVecPart.Position = Root.Position
			LVecPart.CFrame = CFrame.new(LVecPart.Position, Vector3.new(lookVec.X * 9999, lookVec.Y, lookVec.Z * 9999))
		end
		CONVEC = game:GetService("RunService").Heartbeat:Connect(VECTORUNIT)
		local CONDOWN
		local WDown, ADown, SDown, DDown, SpaceDown = false, false, false, false, false
		local function KEYDOWN(_,Processed) 
			if HumanDied then CONDOWN:Disconnect(); return end
			if Processed ~= true then
				local Key = _.KeyCode
				if Key == Enum.KeyCode.W then
					WDown = true end
				if Key == Enum.KeyCode.A then
					ADown = true end
				if Key == Enum.KeyCode.S then
					SDown = true end
				if Key == Enum.KeyCode.D then
					DDown = true end
				if Key == Enum.KeyCode.Space then
					SpaceDown = true 
				end 
			end 
		end
		CONDOWN = game:GetService("UserInputService").InputBegan:Connect(KEYDOWN)

		local CONUP
		local function KEYUP(_,a)
			if a then return end
			if HumanDied then CONUP:Disconnect(); return end
			local Key = _.KeyCode
			if Key == Enum.KeyCode.W then
				WDown = false end
			if Key == Enum.KeyCode.A then
				ADown = false end
			if Key == Enum.KeyCode.S then
				SDown = false end
			if Key == Enum.KeyCode.D then
				DDown = false end
			if Key == Enum.KeyCode.Space then
				SpaceDown = false end 
		end
		CONUP = game:GetService("UserInputService").InputEnded:Connect(KEYUP)

		local function MoveClone(X,Y,Z)
			LVecPart.CFrame = LVecPart.CFrame * CFrame.new(-X,Y,-Z)
			FakeCharacter.Humanoid.WalkToPoint = LVecPart.Position
		end

		coroutine.wrap(function() 
			while true do game:GetService("RunService").RenderStepped:Wait()
				if HumanDied then break end
				if WDown then  MoveClone(0,0,1e4) if walka.IsPlaying ~= true then walka:Play() end end
				if ADown then MoveClone(1e4,0,0) if walka.IsPlaying ~= true then walka:Play() end end
				if SDown then MoveClone(0,0,-1e4) if walka.IsPlaying ~= true then walka:Play() end end
				if DDown then MoveClone(-1e4,0,0) if walka.IsPlaying ~= true then walka:Play() end end
				if SpaceDown then FakeCharacter["Humanoid"].Jump = true if jumpa.IsPlaying ~= true then jumpa:Play() end end
				if WDown ~= true and ADown ~= true and SDown ~= true and DDown ~= true and SpaceDown ~= true then
					walka:Stop()
					FakeCharacter.Humanoid.WalkToPoint = FakeCharacter.HumanoidRootPart.Position end
			end 
		end)()
	end

	for i, v in ipairs(FakeCharacter:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
		elseif v:IsA("Decal") then
			v.Transparency = 1
		end
	end
ps:Connect(function()
    if getgenv().viewdeath then return end
	workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
end)
	HatdropCallback(RealChar, function(hats, dropped)
        Accessories = getgenv().Accessories
		for i,v in pairs(FakeCharacter:GetChildren()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and Accessories[v.Name][1] ~= "" then
                local hat
                for i,h in pairs(hats) do
                    if h.Name == Accessories[v.Name][1] and h:FindFirstChild("Handle") then
                        hat = h
                        continue
                    end
                end
                if not hat then continue end
                hat.Parent = FakeCharacter
				Align(hat.Handle,FakeCharacter[v.Name],Accessories[v.Name][2])
			end
		end
	end)
end

ps:Connect(function()
	for i, v in ipairs(FakeCharacter:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
        end
	end
end)

plr.CharacterAdded:Connect(function(c)
	task.wait(0.3)
	HatdropCallback(c, function(hats, dropped)
        Accessories = getgenv().Accessories
		for i,v in pairs(FakeCharacter:GetChildren()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and Accessories[v.Name][1] ~= "" then
                local hat
                for i,h in pairs(hats) do
                    if h.Name == Accessories[v.Name][1] and h:FindFirstChild("Handle") then
                        hat = h
                        continue
                    end
                end
                if not hat then continue end
                hat.Parent = FakeCharacter
				Align(hat.Handle,FakeCharacter[v.Name],Accessories[v.Name][2])
			end
		end
	end)
end)

plr.CharacterRemoving:Connect(function()
    for i,v in ipairs(FakeCharacter:GetChildren()) do
        if v:IsA("Accessory") then
            v:Destroy()
        end
    end
end)