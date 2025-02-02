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
        part.Size = props.Size
        part.Transparency = props.Transparency
        part.Color = props.Color
        part.Material = props.Material
        part.CanCollide = props.CanCollide
        part.CustomPhysicalProperties = props.CustomPhysicalProperties
        part.CollisionGroupId = props.CollisionGroupId
        
        -- Reset mesh if it exists
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

        activeHitboxes[part] = nil
    end

    local function modifyHitbox(part)
        if not part then return end
        
        -- Store original properties before modification
        storeOriginalProperties(part)
        
        -- Handle mesh-based parts
        local mesh = part:FindFirstChildOfClass("SpecialMesh") or 
                    part:FindFirstChildOfClass("FileMesh") or
                    part:FindFirstChildOfClass("BlockMesh")
        
        if mesh then
            -- Scale the mesh instead of the part
            local scale = Vector3.new(_G.hitboxSettings.size / part.Size.X, 
                                    _G.hitboxSettings.size / part.Size.Y,
                                    _G.hitboxSettings.size / part.Size.Z)
            mesh.Scale = mesh.Scale * scale
        else
            -- For regular parts, modify the size directly
            part.Size = Vector3.new(_G.hitboxSettings.size, _G.hitboxSettings.size, _G.hitboxSettings.size)
        end
        
        -- Apply common properties
        part.Transparency = _G.hitboxSettings.transparency
        part.Color = _G.hitboxSettings.color
        part.Material = Enum.Material.ForceField
        
        -- Completely disable collision
        part.CanCollide = false
        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        part.CollisionGroupId = 32 -- Use a unique collision group to prevent any collisions
        
        activeHitboxes[part] = true
    end

    local function resetAllHitboxes()
        for part, _ in pairs(activeHitboxes) do
            if part and part.Parent then
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

    -- Clean up when the script is disabled
    game:GetService("Players").PlayerRemoving:Connect(function(player)
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
