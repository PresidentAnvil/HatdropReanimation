-- spawns a fakecharacter for u to use
-- ctrl+f "non fe script here" to find the place to convert non fe scripts
-- automatically detects unassigned hats to use as fling parts
-- i've only tested this on solara is it works like 92% of the time with other players and 100% of the time by urself
-- synapse z doesnt support hatdrop :(

getgenv().walkspeed = 35
getgenv().velocity = Vector3.new(15,15,15)
getgenv().flingvelocity = Vector3.new(999999,999999,999999)
getgenv().Accessories = {
	-- Limb/Part name | {Accessory name, offset}
	["Left Arm"] = {"Kate Hair",CFrame.Angles(0,0,math.rad(90))},
	["Right Arm"] = {"Hat1",CFrame.Angles(0,0,-math.rad(90))},
	["Right Leg"] = {"SidePonytail",CFrame.Angles(0,0,math.rad(0))},
	["Left Leg"] = {"LongStraightHair",CFrame.Angles(0,0,math.rad(0))},
	["Torso"] = {"MeshPartAccessory",CFrame.Angles(0,0,-math.rad(14))},
	["Head"] = {"MediHood",CFrame.new(0,0,0.2)},
	["FlingPart"] = {[3]=true} -- placeholder, will make use of this later
}


ws=workspace
pcall(function()
    sethiddenproperty(hum, "InternalBodyScale", Vector3.new(9e9,9e9,9e9))
end)
pcall(function()
    sethiddenproperty(ws, "PhysicsSteppingMethod", Enum.PhysicsSteppingMethod.Fixed)
end)
pcall(function()
    ws.InterpolationThrottling = Enum.InterpolationThrottlingMode.Disabled
end)
pcall(function()
    ws.Retargeting = "Disabled"
end)
pcall(function()
    sethiddenproperty(ws, "SignalBehavior", "Immediate")
end)
pcall(function()
    game:GetService("PhysicsSettings").PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end)
pcall(function()
    game:GetService("PhysicsSettings").AllowSleep = false
end)
pcall(function()
    game:GetService("PhysicsSettings").ThrottleAdjustTime = math.huge
end)
pcall(function()
    game:GetService("PhysicsSettings").ForceCSGv2 = false
end)
pcall(function()
    game:GetService("PhysicsSettings").DisableCSGv2 = false
end)
pcall(function()
    game:GetService("PhysicsSettings").UseCSGv2 = false
end)
pcall(function()
    game:GetService("PhysicsSettings").UseCSGv2 = false
end)
pcall(function()
    setsimulationradius(math.huge)
end)
pcall(function()
    p.MaximumSimulationRadius = 9e9
    p.SimulationRadius = 9e9
end)
local ps = game:GetService("RunService").PostSimulation
local fpdh = game.Workspace.FallenPartsDestroyHeight
local Player = game.Players.LocalPlayer
local FakeCharacter
local flingCooldown
local flingpart = Instance.new("Part")
flingpart.Parent = workspace
flingpart.Anchored = true
flingpart.CanCollide = false
flingpart.Size = Vector3.new(1,1,1)
--flingpart.Transparency = 1

function DamageFling(char)
    if not FakeCharacter then return end
    if flingCooldown then return end
    if char.Name == Player.Name then return end
    if char.Name == Player.Name.."_fake" then return end
    
    flingCooldown=true

    local con;con=ps:Connect(function()
        if not char:FindFirstChild("HumanoidRootPart") then con:Disconnect() return end
        flingpart.CFrame = char.HumanoidRootPart.CFrame
    end)
    task.delay(1,function()
        con:Disconnect()
        flingCooldown=false
    end)
end

function _isnetworkowner(Part)
	return Part.ReceiveAge == 0
end

function Align(Part1,Part0,cf) 
    local con;con=ps:Connect(function()
        if not Part1:IsDescendantOf(workspace) then con:Disconnect() return end
        if not _isnetworkowner(Part1) then return end
        Part1.CanCollide=false
        Part1.CFrame=Part0.CFrame*cf
    end)
end

function deepfind(t,a)
    for i,v in pairs(t) do
        if v[1]==a then return i end
    end

    return "FlingPart"
end

function getAllHats(Character)
    local allhats = {}
    for i,v in pairs(Character:GetChildren()) do
        local limb = deepfind(getgenv().Accessories,v.Name)
        if v:IsA("Accessory") and limb then
            table.insert(allhats,{v,limb})
        end
    end
    return allhats
end

function HatdropCallback(Character, callback)
    local AnimationInstance = Instance.new("Animation");AnimationInstance.AnimationId = "rbxassetid://35154961"

    local hrp = Character.HumanoidRootPart
    local torso = Character.Torso
    local startCF = FakeCharacter.HumanoidRootPart.CFrame
    hrp.CFrame=startCF*CFrame.new(math.random(3,6),0,math.random(3,6))
    task.wait(.25)
    local Track = Character.Humanoid.Animator:LoadAnimation(AnimationInstance)
    Track:Play()
    Track.TimePosition = 3.24
    Track:AdjustSpeed(0)
    
    local allhats = getAllHats(Character)
    
    local locks = {}
    for i,v in pairs(allhats) do
        table.insert(locks,v[1].Changed:Connect(function(p)
            if p == "BackendAccoutrementState" then
                sethiddenproperty(v[1],"BackendAccoutrementState",0)
            end
        end))
        sethiddenproperty(v[1],"BackendAccoutrementState",2)
    end
    
    local c;c=ps:Connect(function()
        if(not Character:FindFirstChild("HumanoidRootPart"))then c:Disconnect()return;end
        
        hrp.Velocity = Vector3.new(0,0,25)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = CFrame.new(startCF.X,fpdh+.25,startCF.Z) * CFrame.Angles(math.rad(90),0,0)
    end)
    
    Character.ChildRemoved:Connect(function(v)
        if v:IsA("BasePart") then
            print(v.Name)
        end
    end)
    
    task.wait(.25)
    for i,v in pairs(allhats) do
        v[1].Handle:BreakJoints()
        local con;con=ps:Connect(function()
            if not v[1]:FindFirstChild"Handle" then con:Disconnect() return end
            v[1].Handle.Velocity = (v[2]=="FlingPart" and getgenv().flingvelocity) or getgenv().velocity
        end)
    end
    callback(allhats)
    Character.Humanoid:ChangeState(15)
    torso.AncestryChanged:wait()
    for i,v in pairs(locks) do
        v:Disconnect()
    end
    for i,v in pairs(allhats) do
        sethiddenproperty(v[1],"BackendAccoutrementState",4)
    end
end

Player.Character.Archivable = true
FakeCharacter = Player.Character:Clone()
FakeCharacter.Name = FakeCharacter.Name.."_fake"
FakeCharacter.Parent = workspace
for i, v in ipairs(FakeCharacter:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Transparency = 1
    elseif v:IsA("Decal") then
        v.Transparency = 1
    end
end
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
ps:Connect(function()
    if getgenv().viewdeath then return end
    workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
end)
ps:Connect(function()
    for i, v in game.Players:GetPlayers() do
        if v ~= Player and v.Character then
            for i, v in v.Character:GetDescendants() do
                if v:IsA("BasePart") and v.ReceiveAge ~= 0 then
                    v.AssemblyLinearVelocity = Vector3.zero
                    v.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
    end
end)

coroutine.wrap(function()
    -- non fe script here, edit the character it uses to FakeCharacter
    -- also use DamageFling(Character) to fling for attacks
end)()

workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
ps:Connect(function()
    if getgenv().viewdeath == "no" then return end
    if workspace.CurrentCamera.CameraSubject == FakeCharacter.Humanoid then
        oldcam = workspace.CurrentCamera.CFrame
    end
    Player.CharacterAdded:Wait()
    workspace.CurrentCamera.CameraSubject=FakeCharacter.Humanoid
        ws.CurrentCamera.CFrame = oldcam
        ws.CurrentCamera:GetPropertyChangedSignal("CFrame"):Wait()
        workspace.CurrentCamera.CameraSubject=FakeCharacter.Humanoid
        ws.CurrentCamera.CFrame = oldcam
end)

HatdropCallback(Player.Character, function(allhats)
    workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
    workspace.CurrentCamera.CFrame = oldcam
    for i,v in pairs(allhats) do
        if not v[1]:FindFirstChild"Handle" then print(v[1].Name) continue end

        local limb = (v[2]~="FlingPart" and FakeCharacter[v[2]]) or flingpart

        v.Parent=FakeCharacter
        Align(v[1].Handle,limb,(v[2]~="FlingPart" and getgenv().Accessories[v[2]][2]) or CFrame.new(0,0,0))
    end
end)

getgenv().conn = Player.CharacterAdded:Connect(function(Character)
    task.wait(0.35)
    HatdropCallback(Player.Character, function(allhats)
        for i,v in pairs(allhats) do
            if not v[1]:FindFirstChild"Handle" then continue end
    
            local limb = (v[2]~="FlingPart" and FakeCharacter[v[2]]) or flingpart
    
            v.Parent=FakeCharacter
            Align(v[1].Handle,limb,(v[2]~="FlingPart" and getgenv().Accessories[v[2]][2]) or CFrame.new(0,0,0))
        end
    end)
end)
