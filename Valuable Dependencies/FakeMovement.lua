-- fake movement (pasted from some really really old reanimation :P)
-- make sure to define FakeCharacter


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