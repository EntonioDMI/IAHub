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
        gravityMultiplier = 1,
        itemsEnabled = false
    }
    
    -- Store item labels
    local itemLabels = {}
    
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
    
    -- Function to create item label
    local function createItemLabel(player)
        if player == LocalPlayer then return end
        
        -- Remove existing label if any
        if itemLabels[player] then
            itemLabels[player]:Destroy()
            itemLabels[player] = nil
        end
        
        -- Create new label
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ItemLabel"
        billboardGui.Size = UDim2.new(0, 200, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.MaxDistance = 100
        
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, 0, 1, 0)
        itemFrame.BackgroundTransparency = 1
        itemFrame.Parent = billboardGui
        
        local itemList = Instance.new("TextLabel")
        itemList.Size = UDim2.new(1, 0, 1, 0)
        itemList.BackgroundTransparency = 1
        itemList.Font = Enum.Font.GothamBold
        itemList.TextSize = 14
        itemList.TextColor3 = Color3.new(1, 1, 1)
        itemList.TextStrokeTransparency = 0
        itemList.TextStrokeColor3 = Color3.new(0, 0, 0)
        itemList.Parent = itemFrame
        
        -- Function to update items text
        local function updateItems()
            if not player.Character then return end
            
            local items = {}
            -- Check backpack
            for _, item in ipairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(items, item.Name)
                end
            end
            -- Check equipped items
            for _, item in ipairs(player.Character:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(items, item.Name .. " [E]")
                end
            end
            
            itemList.Text = table.concat(items, "\n")
        end
        
        -- Connect update function
        player.Character.ChildAdded:Connect(updateItems)
        player.Character.ChildRemoved:Connect(updateItems)
        player.Backpack.ChildAdded:Connect(updateItems)
        player.Backpack.ChildRemoved:Connect(updateItems)
        
        -- Initial update
        updateItems()
        
        -- Parent to character
        if player.Character and player.Character:FindFirstChild("Head") then
            billboardGui.Parent = player.Character.Head
        end
        
        itemLabels[player] = billboardGui
        
        -- Update visibility
        billboardGui.Enabled = settings.itemsEnabled
        
        return billboardGui
    end
    
    -- Function to update all item labels
    local function updateItemLabels()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if settings.itemsEnabled then
                    if not itemLabels[player] and player.Character then
                        createItemLabel(player)
                    end
                else
                    if itemLabels[player] then
                        itemLabels[player]:Destroy()
                        itemLabels[player] = nil
                    end
                end
            end
        end
    end
    
    -- Player connections
    Players.PlayerAdded:Connect(function(player)
        if settings.itemsEnabled then
            player.CharacterAdded:Connect(function()
                createItemLabel(player)
            end)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if itemLabels[player] then
            itemLabels[player]:Destroy()
            itemLabels[player] = nil
        end
    end)
    
    -- Create UI elements
    local movementSection = Tab:AddSection("Movement")
    
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
    
    -- Items display
    local visualsSection = Tab:AddSection("Visuals")
    
    local itemsToggle = Tab:AddToggle("ItemsEnabled", {
        Title = "Show Items",
        Description = "Display items above players' heads",
        Default = false,
        Callback = function(Value)
            settings.itemsEnabled = Value
            updateItemLabels()
        end
    })
    
    -- Run movement simulation
    RunService.Heartbeat:Connect(simulateMovement)
    
    -- Update item labels
    RunService.RenderStepped:Connect(function()
        if settings.itemsEnabled then
            for player, label in pairs(itemLabels) do
                if player.Character and player.Character:FindFirstChild("Head") then
                    -- Update label position if needed
                    if label.Parent ~= player.Character.Head then
                        label.Parent = player.Character.Head
                    end
                end
            end
        end
    end)
end
