return function(Fluent, Tab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local function updateHitboxes()
        if not _G.hitboxSettings.enabled then return end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local character = player.Character
            if not character then continue end
            
            local targetPart = character:FindFirstChild(_G.hitboxSettings.targetPart)
            if not targetPart then continue end
            
            targetPart.Size = Vector3.new(_G.hitboxSettings.size, _G.hitboxSettings.size, _G.hitboxSettings.size)
            targetPart.Transparency = _G.hitboxSettings.transparency
            targetPart.BrickColor = BrickColor.new("Really blue")
            targetPart.Material = "Neon"
            targetPart.CanCollide = false
        end
    end

    RunService.RenderStepped:Connect(updateHitboxes)
end
