return function(Fluent, Tab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    -- Store original sizes
    local originalSizes = {}

    local function resetHitboxes()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local character = player.Character
            if not character then continue end
            
            local head = character:FindFirstChild("Head")
            local torso = character:FindFirstChild("HumanoidRootPart")
            
            if head and originalSizes[head] then
                head.Size = originalSizes[head]
                head.Transparency = 0
            end
            
            if torso and originalSizes[torso] then
                torso.Size = originalSizes[torso]
                torso.Transparency = 0
            end
        end
    end

    local function storeOriginalSize(part)
        if not originalSizes[part] then
            originalSizes[part] = part.Size
        end
    end

    local function updateHitboxes()
        if not _G.hitboxSettings.enabled then
            resetHitboxes()
            return
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local character = player.Character
            if not character then continue end
            
            local head = character:FindFirstChild("Head")
            local torso = character:FindFirstChild("HumanoidRootPart")
            
            if head then storeOriginalSize(head) end
            if torso then storeOriginalSize(torso) end
            
            -- Reset non-target parts first
            if _G.hitboxSettings.targetPart == "Head" and torso then
                torso.Size = originalSizes[torso]
                torso.Transparency = 0
            elseif _G.hitboxSettings.targetPart == "HumanoidRootPart" and head then
                head.Size = originalSizes[head]
                head.Transparency = 0
            end
            
            -- Update target part
            local targetPart = character:FindFirstChild(_G.hitboxSettings.targetPart)
            if targetPart then
                targetPart.Size = Vector3.new(_G.hitboxSettings.size, _G.hitboxSettings.size, _G.hitboxSettings.size)
                targetPart.Transparency = _G.hitboxSettings.transparency
                targetPart.BrickColor = BrickColor.new("Really blue")
                targetPart.Material = "Neon"
                targetPart.CanCollide = false
            end
        end
    end

    RunService.RenderStepped:Connect(updateHitboxes)
end
