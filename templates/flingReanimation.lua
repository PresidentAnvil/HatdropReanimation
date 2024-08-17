-- you're going to have to give collision to hats on the serverside on death

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
	["Head"] = {"VarietyShades02",cn(0,0,0)},
	["FlingPart"] = {"",cn(0,0,0)}
}

------------------------------------------------------------------------------------------------------------------------
local plr = game.Players.LocalPlayer
local fph = workspace.FallenPartsDestroyHeight
local mouse = plr:GetMouse()
local ps = game:GetService("RunService").PostSimulation
local printdebug = true
local FakeCharacter
local flingCooldown
local flingpart

function updatestate(hat,state)
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

function HatdropCallback(character: Model, callback: Function, yeild: bool?)
	local hrp = character:WaitForChild("HumanoidRootPart")
	local hum = character:WaitForChild("Humanoid")
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	local allhats = {}
	local locks = {}
	local dropped
	local tpt
	
	for i,v in ipairs(character:GetChildren()) do
		if v:IsA("Accessory") then
			table.insert(allhats,v)
		end
	end
	
	for i,v in ipairs(allhats) do
		table.insert(locks,v.Changed:Connect(function(p)
			if p == "BackendAccoutrementState" then
				updatestate(v,0)
			end
		end))
		updatestate(v,2)
	end
	
	if printdebug then 
		character.ChildRemoved:Connect(function(v)
			if v:IsA"BasePart" then
				print(v.Name)
			end
		end)
	end
	
	local dropcf = cn(hrp.CFrame.X,fph + 2,hrp.CFrame.Z) * ca(r(90),0,0)
	if character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		-- when i find a good anim 🎥
	else
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://35154961"
		local loadanim = hum:LoadAnimation(anim)
		loadanim:Play(0, 100, 0)
		loadanim.TimePosition = 3.24
	end
	hum:ChangeState(16)
	coroutine.wrap(function()
		while hrp.Parent ~= nil and tpt ~= true do
			hrp.CFrame = dropcf
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			ps:Wait()
		end
	end)()
	
	task.wait(.25)
	hum.Health=0
	tpt=true
	torso.AncestryChanged:Wait()
	for i,v in ipairs(locks) do
		v:Disconnect()
	end
	for i,v in ipairs(allhats) do
		updatestate(v,4)
	end

	repeat
		local foundhandle = false
		for i,v in ipairs(allhats) do
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
	return {AttachmentB,AlignOri,AlignPos,AttachmentA,Part1}
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

	HatdropCallback(RealChar, function(hats, dropped)
		if not dropped then
			print("not dropped")
		else
			print("dropped")
		end

		for i,v in pairs(hats) do
			if v:FindFirstChild("Handle") and complexfind(Accessories, v.Name) then
				local limb, info = complexfind(Accessories, v.Name)
				if limb == "FlingPart" then 					
					local part = Instance.new("Part")
					part.Parent = workspace
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1

					flingpart = Align(v.Handle,part,info[2])  
					continue 
				end

				Align(v.Handle,FakeCharacter[limb],info[2])
			end
		end
	end)
end

ps:Connect(function()
	--workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
end)

plr.CharacterAdded:Connect(function(c)
	task.wait(0.1)
	
	HatdropCallback(c, function(hats, dropped)
		if not dropped then
			print("not dropped")
		else
			print("dropped")
		end

		for i,v in pairs(hats) do
			if v:FindFirstChild("Handle") and complexfind(Accessories, v.Name) then
				local limb, info = complexfind(Accessories, v.Name)
				if limb == "FlingPart" then 
					local part = Instance.new("Part")
					part.Parent = workspace
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1

					flingpart = Align(v.Handle,part,info[2]) 
					continue 
				end

				Align(v.Handle,FakeCharacter[limb],info[2])
			end
		end
	end)
end)

mouse.Button1Down:Connect(function()
	-- srry for messy code idk how i'd made this look better
	local target = mouse.Target

	if Accessories["FlingPart"][1] ~= "" then return end
	if flingCooldown then return end

	if target.Parent:FindFirstChild("Humanoid") and target.Parent ~= workspace and target.Parent.Name ~= FakeCharacter.Name or target.Parent.Name ~= plr.Name and flingpart ~= nil then
		if flingpart[4].Parent == nil then return end
		flingCooldown = true
		local flingCon = ps:Connect(function()
			flingpart[5].AssemblyLinearVelocity = Vector3.new(9999,9999,9999)
		end)
		task.wait(1.5)
		flingCon:Disconnect()
		task.wait(0.2)
		flingCooldown = false
	end
end)
