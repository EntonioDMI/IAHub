return function(Fluent, Tab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    -- Store original properties
    local originalProps = {}
    local activeHitboxes = {}

    local function storeOriginalProperties(part)
        if not originalProps[part] then
            originalProps[part] = {
                Size = part.Size,
                Transparency = part.Transparency,
                Color = part.Color,
                Material = part.Material,
                CanCollide = part.CanCollide,
                CustomPhysicalProperties = part.CustomPhysicalProperties,
                CollisionGroupId = part.CollisionGroupId
            }
            
            -- Store mesh properties if they exist
            local mesh = part:FindFirstChildOfClass("SpecialMesh") or 
                        part:FindFirstChildOfClass("FileMesh") or
                        part:FindFirstChildOfClass("BlockMesh")
            if mesh then
                originalProps[part].Mesh = {
                    Scale = mesh.Scale,
                    Offset = mesh.Offset,
                    VertexColor = mesh.VertexColor
                }
            end
        end
    end

    local function resetPart(part)
        if not part or not originalProps[part] then return end
        
        local props = originalProps[part]
        
        -- Reset mesh first if it exists
        if props.Mesh then
            local mesh = part:FindFirstChildOfClass("SpecialMesh") or 
                        part:FindFirstChildOfClass("FileMesh") or
                        part:FindFirstChildOfClass("BlockMesh")
            if mesh then
                mesh.Scale = props.Mesh.Scale
                mesh.Offset = props.Mesh.Offset
                mesh.VertexColor = props.Mesh.VertexColor
            end
        end

        part.Size = props.Size
        part.Transparency = props.Transparency
        part.Color = props.Color
        part.Material = props.Material
        part.CanCollide = props.CanCollide
        part.CustomPhysicalProperties = props.CustomPhysicalProperties
        part.CollisionGroupId = props.CollisionGroupId

        activeHitboxes[part] = nil
        originalProps[part] = nil
    end

    local function modifyHitbox(part, isNPC, isBoss)
        if not part then return end
        
        -- Check if player is a friend (only for players)
        if not isNPC and not isBoss then
            local player = Players:GetPlayerFromCharacter(part.Parent)
            if player and _G.isFriend and _G.isFriend(player) then
                return
            end
        end
        
        -- Store original properties before modification
        storeOriginalProperties(part)
        
        -- Handle mesh-based parts differently
        local mesh = part:FindFirstChildOfClass("SpecialMesh") or 
                    part:FindFirstChildOfClass("FileMesh") or
                    part:FindFirstChildOfClass("BlockMesh")
        
        if mesh then
            -- For mesh parts, we'll use a more conservative scaling approach
            local originalSize = originalProps[part].Size
            local targetSize = _G.hitboxSettings.size
            local scaleFactor = targetSize / math.max(originalSize.X, originalSize.Y, originalSize.Z)
            
            -- Limit scale factor to prevent infinite scaling
            scaleFactor = math.min(scaleFactor, 5) -- Maximum 5x scaling for mesh parts
            
            mesh.Scale = Vector3.new(scaleFactor, scaleFactor, scaleFactor)
            
            -- Don't modify the part's size for mesh parts
            part.Size = originalSize
        else
            -- For regular parts, modify the size directly
            part.Size = Vector3.new(_G.hitboxSettings.size, _G.hitboxSettings.size, _G.hitboxSettings.size)
        end
        
        -- Apply common properties
        part.Transparency = _G.hitboxSettings.transparency
        part.Color = _G.hitboxSettings.color
        part.Material = Enum.Material.ForceField
        
        -- New approach to handling collisions
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
            
            -- Create weld
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = part
            weld.Part1 = collisionBox
            weld.Parent = collisionBox
            
            collisionBox.Parent = part
        end
        
        -- Update collision box size (using a smaller size than the visual hitbox)
        collisionBox.Size = originalProps[part].Size * 1.5 -- Only 1.5x the original size for collision
        collisionBox.CustomPhysicalProperties = originalProps[part].CustomPhysicalProperties
        
        activeHitboxes[part] = true
    end

    local function resetAllHitboxes()
        for part, _ in pairs(activeHitboxes) do
            if part and part.Parent then
                -- Remove collision box if it exists
                local collisionBox = part:FindFirstChild("HitboxCollision")
                if collisionBox then
                    collisionBox:Destroy()
                end
                resetPart(part)
            end
        end
        activeHitboxes = {}
    end

    local function updateHitboxes()
        -- Players
        if _G.hitboxSettings.enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                
                local character = player.Character
                if not character then continue end
                
                local head = character:FindFirstChild("Head")
                local torso = character:FindFirstChild("HumanoidRootPart")
                
                -- Skip if player is a friend
                if _G.isFriend and _G.isFriend(player) then
                    if head then resetPart(head) end
                    if torso then resetPart(torso) end
                    continue
                end
                
                -- Reset non-target parts first
                if _G.hitboxSettings.targetPart == "Head" then
                    if torso then resetPart(torso) end
                    if head then modifyHitbox(head) end
                else
                    if head then resetPart(head) end
                    if torso then modifyHitbox(torso) end
                end
            end
        end

        -- NPCs
        if _G.hitboxSettings.npcEnabled then
            local npcs = workspace:FindFirstChild("NPCs")
            if npcs then
                for _, npc in ipairs(npcs:GetChildren()) do
                    if not npc:IsA("Model") then continue end
                    
                    local head = npc:FindFirstChild("Head")
                    local torso = npc:FindFirstChild("HumanoidRootPart")
                    
                    if _G.hitboxSettings.targetPart == "Head" then
                        if torso then resetPart(torso) end
                        if head then modifyHitbox(head, true, false) end
                    else
                        if head then resetPart(head) end
                        if torso then modifyHitbox(torso, true, false) end
                    end
                end
            end
        end

        -- Bosses
        if _G.hitboxSettings.bossEnabled then
            local bosses = workspace.NPCs:FindFirstChild("Boss")
            if bosses then
                for _, boss in ipairs(bosses:GetChildren()) do
                    if not boss:IsA("Model") then continue end
                    
                    -- Check if it's a player-boss (Juggernaut)
                    local isPlayerBoss = false
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Character == boss then
                            isPlayerBoss = true
                            break
                        end
                    end
                    
                    local head = boss:FindFirstChild("Head")
                    local torso = boss:FindFirstChild("HumanoidRootPart")
                    
                    if _G.hitboxSettings.targetPart == "Head" then
                        if torso then resetPart(torso) end
                        if head then modifyHitbox(head, false, true) end
                    else
                        if head then resetPart(head) end
                        if torso then modifyHitbox(torso, false, true) end
                    end
                end
            end
        end
    end

    -- Clean up when players leave
    Players.PlayerRemoving:Connect(function(player)
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if activeHitboxes[part] then
                    resetPart(part)
                end
            end
        end
    end)

    -- Create UI elements
    local hitboxSection = Tab:AddSection("Hitbox Settings")

    -- Player Hitboxes
    local playerToggle = Tab:AddToggle("HitboxEnabled", {
        Title = "Player Hitboxes",
        Description = "Enable hitbox modification for players",
        Default = false,
        Callback = function(Value)
            _G.hitboxSettings.enabled = Value
            if not Value then
                -- Reset player hitboxes
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            resetPart(part)
                        end
                    end
                end
            end
        end
    })

    -- NPC Hitboxes
    local npcToggle = Tab:AddToggle("NPCHitboxEnabled", {
        Title = "NPC Hitboxes",
        Description = "Enable hitbox modification for NPCs",
        Default = false,
        Callback = function(Value)
            _G.hitboxSettings.npcEnabled = Value
            if not Value then
                -- Reset NPC hitboxes
                local npcs = workspace:FindFirstChild("NPCs")
                if npcs then
                    for _, npc in ipairs(npcs:GetChildren()) do
                        if npc:IsA("Model") then
                            for _, part in ipairs(npc:GetDescendants()) do
                                resetPart(part)
                            end
                        end
                    end
                end
            end
        end
    })

    -- Boss Hitboxes
    local bossToggle = Tab:AddToggle("BossHitboxEnabled", {
        Title = "Boss Hitboxes",
        Description = "Enable hitbox modification for bosses",
        Default = false,
        Callback = function(Value)
            _G.hitboxSettings.bossEnabled = Value
            if not Value then
                -- Reset boss hitboxes
                local bosses = workspace.NPCs:FindFirstChild("Boss")
                if bosses then
                    for _, boss in ipairs(bosses:GetChildren()) do
                        if boss:IsA("Model") then
                            for _, part in ipairs(boss:GetDescendants()) do
                                resetPart(part)
                            end
                        end
                    end
                end
            end
        end
    })

    -- Common Settings
    Tab:AddDropdown("HitboxTarget", {
        Title = "Target Part",
        Description = "Select which part to modify",
        Values = {"Head", "HumanoidRootPart"},
        Default = "HumanoidRootPart",
        Callback = function(Value)
            _G.hitboxSettings.targetPart = Value
        end
    })

    Tab:AddSlider("HitboxSize", {
        Title = "Hitbox Size",
        Description = "Adjust the size of hitboxes",
        Default = 10,
        Min = 1,
        Max = 20,
        Rounding = 1,
        Callback = function(Value)
            _G.hitboxSettings.size = Value
        end
    })

    Tab:AddSlider("HitboxTransparency", {
        Title = "Hitbox Transparency",
        Description = "Adjust the transparency of hitboxes",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.hitboxSettings.transparency = Value
        end
    })

    Tab:AddColorPicker("HitboxColor", {
        Title = "Hitbox Color",
        Description = "Choose the color of hitboxes",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(Value)
            _G.hitboxSettings.color = Value
        end
    })

    RunService.RenderStepped:Connect(updateHitboxes)
end
