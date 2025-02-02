return function(Fluent, Tab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    -- Store original properties
    local originalProps = {}
    local activeHitboxes = {}

    -- Function to check if a model is a boss that was previously a player
    local function isPlayerBoss(model)
        return model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") and
               Players:GetPlayerFromCharacter(model) ~= nil
    end

    -- [Previous helper functions remain unchanged]

    local function modifyHitbox(part, isNPC, isBoss)
        if not part then return end
        
        -- Store original properties before modification
        storeOriginalProperties(part)
        
        -- Handle mesh-based parts differently
        local mesh = part:FindFirstChildOfClass("SpecialMesh") or 
                    part:FindFirstChildOfClass("FileMesh") or
                    part:FindFirstChildOfClass("BlockMesh")
        
        if mesh then
            local originalSize = originalProps[part].Size
            local targetSize = _G.hitboxSettings.size
            local scaleFactor = targetSize / math.max(originalSize.X, originalSize.Y, originalSize.Z)
            scaleFactor = math.min(scaleFactor, 5)
            mesh.Scale = Vector3.new(scaleFactor, scaleFactor, scaleFactor)
            part.Size = originalSize
        else
            part.Size = Vector3.new(_G.hitboxSettings.size, _G.hitboxSettings.size, _G.hitboxSettings.size)
        end
        
        part.Transparency = _G.hitboxSettings.transparency
        part.Color = _G.hitboxSettings.color
        part.Material = Enum.Material.ForceField
        
        -- Collision handling
        part.CanCollide = false
        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        
        -- Create or update collision box
        local collisionBox = part:FindFirstChild("HitboxCollision") or Instance.new("Part")
        if not part:FindFirstChild("HitboxCollision") then
            collisionBox.Name = "HitboxCollision"
            collisionBox.Transparency = 1
            collisionBox.CanCollide = true
            collisionBox.Anchored = false
            collisionBox.Massless = true
            
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = part
            weld.Part1 = collisionBox
            weld.Parent = collisionBox
            
            collisionBox.Parent = part
        end
        
        collisionBox.Size = originalProps[part].Size * 1.5
        collisionBox.CustomPhysicalProperties = originalProps[part].CustomPhysicalProperties
        
        activeHitboxes[part] = true
    end

    local function updateHitboxes()
        -- Update player hitboxes
        if _G.hitboxSettings.enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                if _G.isFriend and _G.isFriend(player) then continue end
                
                local character = player.Character
                if character then
                    local targetPart = character:FindFirstChild(_G.hitboxSettings.targetPart)
                    if targetPart then
                        modifyHitbox(targetPart, false, false)
                    end
                end
            end
        end

        -- Update NPC hitboxes
        if _G.hitboxSettings.npcEnabled then
            local npcs = workspace:FindFirstChild("NPCs")
            if npcs then
                for _, npc in ipairs(npcs:GetChildren()) do
                    if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                        local targetPart = npc:FindFirstChild(_G.hitboxSettings.targetPart)
                        if targetPart then
                            modifyHitbox(targetPart, true, false)
                        end
                    end
                end
            end
        end

        -- Update Boss hitboxes
        if _G.hitboxSettings.bossEnabled then
            local bossFolder = workspace.NPCs:FindFirstChild("Boss")
            if bossFolder then
                for _, boss in ipairs(bossFolder:GetChildren()) do
                    if boss:FindFirstChild("Humanoid") and boss:FindFirstChild("HumanoidRootPart") then
                        local targetPart = boss:FindFirstChild(_G.hitboxSettings.targetPart)
                        if targetPart then
                            modifyHitbox(targetPart, true, true)
                        end
                    end
                end
            end
        end

        -- Reset hitboxes that should no longer be active
        for part, _ in pairs(activeHitboxes) do
            if part and part.Parent then
                local model = part:FindFirstAncestorOfClass("Model")
                if not model then
                    resetPart(part)
                    continue
                end

                local shouldReset = false
                local isPlayer = Players:GetPlayerFromCharacter(model) ~= nil
                local isNPC = model:IsDescendantOf(workspace.NPCs)
                local isBoss = model:IsDescendantOf(workspace.NPCs.Boss)

                if isPlayer and not _G.hitboxSettings.enabled then
                    shouldReset = true
                elseif isNPC and not isBoss and not _G.hitboxSettings.npcEnabled then
                    shouldReset = true
                elseif isBoss and not _G.hitboxSettings.bossEnabled then
                    shouldReset = true
                end

                if shouldReset then
                    resetPart(part)
                end
            end
        end
    end

    RunService.RenderStepped:Connect(updateHitboxes)
end
