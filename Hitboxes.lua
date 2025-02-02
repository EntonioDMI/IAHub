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

    local function modifyHitbox(part)
        if not part then return end
        
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
            scaleFactor = math.min(scaleFactor, 10) -- Maximum 10x scaling for mesh parts
            
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
        
        -- Update collision box size
        collisionBox.Size = originalProps[part].Size
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
        if not _G.hitboxSettings.enabled then
            resetAllHitboxes()
            return
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local character = player.Character
            if not character then continue end
            
            local head = character:FindFirstChild("Head")
            local torso = character:FindFirstChild("HumanoidRootPart")
            
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

    RunService.RenderStepped:Connect(updateHitboxes)
end
