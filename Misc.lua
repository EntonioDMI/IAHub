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
    
    -- Item display
    local itemLabels = {}
    
    local function createItemLabel(player)
        if player == LocalPlayer then return end
        
        local label = Instance.new("BillboardGui")
        label.Name = "ItemDisplay"
        label.Size = UDim2.new(0, 200, 0, 50)
        label.StudsOffset = Vector3.new(0, 3, 0)
        label.AlwaysOnTop = true
        label.MaxDistance = 100
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.new(1, 1, 1)
        text.TextStrokeTransparency = 0
        text.TextStrokeColor3 = Color3.new(0, 0, 0)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 14
        text.Parent = label
        
        itemLabels[player] = label
        return label
    end
    
    local function updateItemLabel(player)
        if not player or not player.Character then return end
        
        local label = itemLabels[player] or createItemLabel(player)
        if not label then return end
        
        local items = {}
        -- Check backpack and character for tools
        for _, container in pairs({player.Backpack, player.Character}) do
            if container then
                for _, tool in pairs(container:GetChildren()) do
                    if tool:IsA("Tool") then
                        table.insert(items, tool.Name)
                    end
                end
            end
        end
        
        local text = label.TextLabel
        text.Text = #items > 0 and table.concat(items, "\n") or "No items"
        
        if player.Character and player.Character:FindFirstChild("Head") then
            label.Parent = player.Character.Head
        end
    end
    
    local function removeItemLabel(player)
        if itemLabels[player] then
            itemLabels[player]:Destroy()
            itemLabels[player] = nil
        end
    end
    
    -- Make updateItemDisplay function global
    _G.updateItemDisplay = function()
        if _G.miscSettings.showItems then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    updateItemLabel(player)
                end
            end
        else
            for player, label in pairs(itemLabels) do
                removeItemLabel(player)
            end
        end
    end
    
    -- Player events
    Players.PlayerAdded:Connect(function(player)
        if _G.miscSettings.showItems then
            updateItemLabel(player)
        end
        
        -- Update when tools change
        player.CharacterAdded:Connect(function(character)
            if _G.miscSettings.showItems then
                updateItemLabel(player)
            end
        end)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        removeItemLabel(player)
    end)
    
    -- Update item displays
    RunService.Heartbeat:Connect(function()
        if _G.miscSettings.showItems then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    updateItemLabel(player)
                end
            end
        end
    end)
    
    -- [Previous movement code remains unchanged]
end
