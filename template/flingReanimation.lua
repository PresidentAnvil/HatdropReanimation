r=math.rad
ca=CFrame.Angles
cn=CFrame.new
local Accessories = {
    -- Limb/Part name | {Accessory name, offset}
    ["Left Arm"] = {"",ca(0,0,r(90))},
    ["Right Arm"] = {"",ca(0,0,r(90))},
    ["Right Leg"] = {"",ca(0,0,r(90))},
    ["Left Leg"] = {"",ca(0,0,r(90))},
    ["Torso"] = {"",cn(0,0,0)},
    ["Head"] = {"",cn(0,0,0)},
    ["FlingPart"] = {"",cn(0,0,0)}
}

------------------------------------------------------------------------------------------------------------------------
local plr = game.Players.LocalPlayer
local fph = workspace.FallenPartsDestroyHeight
local FakeCharacter

function HatdropCallback(character: Model, callback: Function, yeild: bool?)
    if not yeild then
        coroutine.wrap(HatdropCallback)(character, true)
        return
    end

    local hrp = character:WaitForChild("HumanoidRootPart")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

    local function updatestate(hat,state)
        if sethiddenproperty then
            sethiddenproperty(hat,"BackendAccoutrementState",state)
        elseif setscriptable then
            setscriptable(hat,"BackendAccoutrementState",true)
            hat.BackendAccoutrementState = state
        else
            local success = pcall(function()
                hat.BackendAccoutrementState = state
            end)
            if not success then
                error("executor not supported, sorry!")
            end
        end
    end

    local allhats = {}
    for i,v in pairs(character:GetChildren()) do
        if v:IsA("Accessory") then
            table.insert(allhats,v)
        end
    end

    local locks = {}
    for i,v in pairs(allhats) do
        table.insert(locks,v.Changed:Connect(function(p)
            if p == "BackendAccoutrementState" then
                updatestate(v,0)
            end
        end))
        updatestate(v,2)
    end

    workspace.FallenPartsDestroyHeight = 0/0

    local function play(id,speed,prio,weight)
        local Anim = Instance.new("Animation")
        Anim.AnimationId = "https"..tostring(math.random(1000000,9999999)).."="..tostring(id)
        local track = character.Humanoid:LoadAnimation(Anim)
        track.Priority = prio
        track:Play()
        track:AdjustSpeed(speed)
        track:AdjustWeight(weight)
        return track
    end

    local r6fall = 180436148
    local r15fall = 507767968

    local dropcf = CFrame.new(character.HumanoidRootPart.Position.x,fph-.25,character.HumanoidRootPart.Position.z)
    if character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
        dropcf =  dropcf * CFrame.Angles(math.rad(20),0,0)
        character.Humanoid:ChangeState(16)
        play(r15fall,1,5,1).TimePosition = .1
    else
        play(r6fall,1,5,1).TimePosition = .1
    end

    spawn(function()
        while hrp.Parent ~= nil do
            hrp.CFrame = dropcf
            hrp.Velocity = Vector3.new(0,25,0) -- 10 is the original for r6
            hrp.RotVelocity = Vector3.new(0,0,0)
            game:GetService("RunService").Heartbeat:wait()
        end
    end)

    task.wait(.25)
    character.Humanoid:ChangeState(15)
    torso.AncestryChanged:wait()

    for i,v in pairs(locks) do
        v:Disconnect()
    end
    for i,v in pairs(allhats) do
        updatestate(v,4)
    end

    local dropped = false
    repeat
        local foundhandle = false
        for i,v in pairs(allhats) do
            if v:FindFirstChild("Handle") then
                foundhandle = true
                if v.Handle.CanCollide then
                    dropped = true
                    break
                end
            end
        end
        if not foundhandle then
            break
        end
        task.wait()
    until plr.Character ~= character or dropped

    callback(allhats,dropped)

    workspace.FallenPartsDestroyHeight = fph
end

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
    return {AttachmentB,AlignOri,AlignPos}
end

function complexfind(t,c)
    -- table.find is Bad i domp like irt

    for i,v in pairs(t) do
        if v == c then return i,v end
        if type(v) == "table" then if complexfind(v,c) then return i,v end end -- will return most parent and not 1 or 2
    end

    return false
end

do
    local RealChar = plr.Character

    RealChar.Archivable = true
    FakeCharacter = RealChar:Clone()
    FakeCharacter.Parent = workspace

    for i, v in ipairs(FakeCharacter:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 1
        elseif v:IsA("Decal") then
            v.Transparency = 1
        end
    end

    HatdropCallback(RealChar, function(hats, dropped)
        if not dropped then
            -- undetermined
        end

        for i,v in pairs(hats) do
            if v:FindFirstChild("Handle") and complexfind(Accessories, v.Name) then
                local limb, info = complexfind(Accessories, v.Name)
                if limb == "FlingPart" then continue end
                
                Align(v.Handle,FakeCharacter[limb],info[2])
            end
        end

        task.wait(0.1)

        plr.Character = FakeCharacter
        workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
    end)
end

plr.CharacterAdded:Connect(function(c)
    HatdropCallback(c, function(hats, dropped)
        if not dropped then
            -- undetermined
        end

        for i,v in pairs(hats) do
            if v:FindFirstChild("Handle") and complexfind(Accessories, v.Name) then
                local limb, info = complexfind(Accessories, v.Name)
                if limb == "FlingPart" then continue end

                Align(v.Handle,FakeCharacter[limb],info[2])
            end
        end

        task.wait(0.1)

        plr.Character = FakeCharacter
        workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
    end, true)
end)
