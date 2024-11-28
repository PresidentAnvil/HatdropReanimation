-- fixed version
-- solara only :3

if getgenv().conn then getgenv().conn:Disconnect()getgenv().conn=nil return end

getgenv().velocity = Vector3.new(15,15,15)
getgenv().Accessories = {
	-- Limb/Part name | {Accessory name, offset}
	["Left Arm"] = {"Kate Hair",CFrame.Angles(0,0,math.rad(90))},
	["Right Arm"] = {"Pal Hair",CFrame.Angles(0,0,-math.rad(90))},
	["Right Leg"] = {"Hat1",CFrame.Angles(0,0,math.rad(90))},
	["Left Leg"] = {"BrownCharmerHair",CFrame.Angles(0,0,math.rad(90))},
	["Torso"] = {"MeshPartAccessory",CFrame.Angles(0,0,-math.rad(14))},
	["Head"] = {"",CFrame.new(0,0,0.2)},
	["FlingPart"] = {"MediHood",CFrame.new(0,0,0)}
}

function Align(Part1,Part0,CFrameOffset) 
    local AlignPos = Instance.new('AlignPosition', Part1);
    AlignPos.Parent.CanCollide = false;
    AlignPos.ApplyAtCenterOfMass = true;
    AlignPos.MaxForce = 67752;
    AlignPos.MaxVelocity = math.huge/9e110;
    AlignPos.ReactionForceEnabled = false;
    AlignPos.Responsiveness = 200;
    AlignPos.RigidityEnabled = false;
    local AlignOri = Instance.new('AlignOrientation', Part1);
    AlignOri.MaxAngularVelocity = math.huge/9e110;
    AlignOri.MaxTorque = 67752;
    AlignOri.PrimaryAxisOnly = false;
    AlignOri.ReactionTorqueEnabled = false;
    AlignOri.Responsiveness = 200;
    AlignOri.RigidityEnabled = false;
    local AttachmentA=Instance.new('Attachment',Part1);
    local AttachmentB=Instance.new('Attachment',Part0);
    AttachmentB.CFrame = AttachmentB.CFrame * CFrameOffset
    AlignPos.Attachment0 = AttachmentA;
    AlignPos.Attachment1 = AttachmentB;
    AlignOri.Attachment0 = AttachmentA;
    AlignOri.Attachment1 = AttachmentB;
    return {AttachmentB,AlignOri,AlignPos,AttachmentA,Part1}
end

function deepfind(t,a)
    for i,v in pairs(t) do
        if v[1]==a then return i end
    end

    return false
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

local ps = game:GetService("RunService").PostSimulation
local fpdh = game.Workspace.FallenPartsDestroyHeight
local Player = game.Players.LocalPlayer

function HatdropCallback(Character, callback)
    local AnimationInstance = Instance.new("Animation");AnimationInstance.AnimationId = "rbxassetid://35154961"

    local hrp = Character.HumanoidRootPart
    local torso = Character.Torso
    local startCF = hrp.CFrame
    
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
    Character.Humanoid:ChangeState(15)
    torso.AncestryChanged:wait()
    for i,v in pairs(locks) do
        v:Disconnect()
    end
    for i,v in pairs(allhats) do
        sethiddenproperty(v[1],"BackendAccoutrementState",4)
    end

    callback(allhats)
end

Player.Character.Archivable = true
local FakeCharacter = Player.Character:Clone()
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

HatdropCallback(Player.Character, function(allhats)
    for i,v in pairs(allhats) do
        local limb = FakeCharacter[v[2]]

        v.Parent=FakeCharacter
        Align(v[1].Handle,limb,CFrame.new(0,0,0))
        v[1].Handle.CanCollide=false
    end
end)

getgenv().conn = Player.CharacterAdded:Connect(function(Character)
    task.wait(0.35)
    HatdropCallback(Player.Character, function(allhats)
        for i,v in pairs(allhats) do
            local limb = FakeCharacter[v[2]]

            v.Parent=FakeCharacter
            Align(v[1].Handle,limb,CFrame.new(0,0,0))
            v[1].Handle.CanCollide=false
        end
    end)
end)
