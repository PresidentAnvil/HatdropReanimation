-- dear digitality
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
