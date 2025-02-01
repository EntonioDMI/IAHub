return function(Fluent, Tab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    -- Store original properties
    local originalProps = {}

    local function storeOriginalProperties(part)
        if not originalProps[part] then
            originalProps[part] = {
                Size = part.Size,
                Transparency = part.Transparency,
                BrickColor = part.BrickColor,
                Material = part.Material,
                CanCollide = part.CanCollide
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
        part.BrickColor = props.BrickColor
        part.Material = props.Material
        part.CanCollide = props.CanCollide
        
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
    end

    local function resetHitboxes()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local character = player.Character
            if not character then continue end
            
            local head = character:FindFirstChild("Head")
            local torso = character:FindFirstChild("HumanoidRootPart")
            
            if head then resetPart(head) end
            if torso then resetPart(torso) end
        end
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
        part.BrickColor = BrickColor.new("Really blue")
        part.Material = "ForceField" -- Changed from Neon to ForceField for better visibility
        part.CanCollide = false
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
        if originalProps[player] then
            originalProps[player] = nil
        end
    end)

    RunService.RenderStepped:Connect(updateHitboxes)
end
