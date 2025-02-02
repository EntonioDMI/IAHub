return function(Fluent, Tab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    
    -- Movement settings
    local settings = {
        speedEnabled = false,
        speedMultiplier = 1,
        jumpEnabled = false,
        jumpMultiplier = 1,
        gravityEnabled = false,
        gravityMultiplier = 1
    }
    
    -- Movement simulation
    local function simulateMovement()
        if not LocalPlayer.Character then return end
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
        
        -- Speed simulation
        if settings.speedEnabled then
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                rootPart.CFrame = rootPart.CFrame + moveDirection * (humanoid.WalkSpeed * 0.016 * (settings.speedMultiplier - 1))
            end
        end
        
        -- Jump simulation
        if settings.jumpEnabled and humanoid.Jump then
            rootPart.Velocity = Vector3.new(
                rootPart.Velocity.X,
                humanoid.JumpPower * (settings.jumpMultiplier - 1),
                rootPart.Velocity.Z
            )
        end
        
        -- Gravity simulation
        if settings.gravityEnabled then
            local gravity = workspace.Gravity * (settings.gravityMultiplier - 1)
            if not humanoid:GetState().Name == "Jumping" then
                rootPart.Velocity = Vector3.new(
                    rootPart.Velocity.X,
                    rootPart.Velocity.Y + gravity * 0.016,
                    rootPart.Velocity.Z
                )
            end
        end
    end
    
    -- Speed modifier
    local speedToggle = Tab:AddToggle("SpeedEnabled", {
        Title = "Speed Boost",
        Description = "Increase movement speed",
        Default = false,
        Callback = function(Value)
            settings.speedEnabled = Value
        end
    })
    
    local speedSlider = Tab:AddSlider("SpeedMultiplier", {
        Title = "Speed Multiplier",
        Description = "Adjust speed boost multiplier",
        Default = 1,
        Min = 1,
        Max = 3,
        Rounding = 2,
        Callback = function(Value)
            settings.speedMultiplier = Value
        end
    })
    
    -- Jump modifier
    local jumpToggle = Tab:AddToggle("JumpEnabled", {
        Title = "Jump Boost",
        Description = "Increase jump height",
        Default = false,
        Callback = function(Value)
            settings.jumpEnabled = Value
        end
    })
    
    local jumpSlider = Tab:AddSlider("JumpMultiplier", {
        Title = "Jump Multiplier",
        Description = "Adjust jump height multiplier",
        Default = 1,
        Min = 1,
        Max = 3,
        Rounding = 2,
        Callback = function(Value)
            settings.jumpMultiplier = Value
        end
    })
    
    -- Gravity modifier
    local gravityToggle = Tab:AddToggle("GravityEnabled", {
        Title = "Gravity Modifier",
        Description = "Modify gravity effect",
        Default = false,
        Callback = function(Value)
            settings.gravityEnabled = Value
        end
    })
    
    local gravitySlider = Tab:AddSlider("GravityMultiplier", {
        Title = "Gravity Multiplier",
        Description = "Adjust gravity multiplier (lower = higher jumps)",
        Default = 1,
        Min = 0.1,
        Max = 3,
        Rounding = 2,
        Callback = function(Value)
            settings.gravityMultiplier = Value
        end
    })
    
    -- Run movement simulation
    RunService.Heartbeat:Connect(simulateMovement)
end
