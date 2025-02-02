return function(Fluent, Tab)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    local DrawingLib = Drawing.new
    local FOVCircle = DrawingLib("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Visible = false
    
    -- Track current target
    local currentTarget = nil
    local isAiming = false
    
    local function isTeamMate(player)
        if not player or not LocalPlayer then return false end
        if not LocalPlayer.Team then
            return player.Team == nil
        end
        return player.Team == LocalPlayer.Team
    end
    
    local function isAlive(character)
        if not character then return false end
        local humanoid = character:FindFirstChild("Humanoid")
        return humanoid and humanoid.Health > 0
    end
    
    local function getLockPart(character)
        if not character then return nil end
        
        if _G.aimbotSettings.lockPart == "Head" then
            return character:FindFirstChild("Head")
        else
            local upperTorso = character:FindFirstChild("UpperTorso")
            if upperTorso then
                return upperTorso
            end
            return character:FindFirstChild("Torso")
        end
    end
    
    local function isVisible(part)
        if not part or not _G.aimbotSettings.wallCheck then return true end
        if not Camera then return false end
        
        local origin = Camera.CFrame.Position
        local targetPos = part.Position
        local direction = (targetPos - origin)
        local distance = direction.Magnitude
        
        if distance <= 0 then return false end
        direction = direction.Unit
        
        -- Create ray parameters
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        local ignoreList = {
            LocalPlayer.Character,
            part.Parent
        }
        
        -- Add all player hitboxes to ignore list
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                table.insert(ignoreList, player.Character)
            end
        end
        
        -- Add accessories and transparent parts to ignore list
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Accessory") or obj:IsA("Tool") or 
               (obj:IsA("BasePart") and obj.Transparency > 0.9) then
                table.insert(ignoreList, obj)
            end
        end
        
        rayParams.FilterDescendantsInstances = ignoreList
        rayParams.IgnoreWater = true
        
        -- Cast the ray
        local result = workspace:Raycast(origin, direction * distance, rayParams)
        
        -- Return true if no obstacle or hit target
        return not result or (result.Instance and result.Instance:IsDescendantOf(part.Parent))
    end
    
    local function getClosestPlayerInFOV()
        if not Camera then return nil end
        
        -- If we have a current target and still aiming, prioritize it
        if currentTarget and isAiming then
            local character = currentTarget.Character
            if character then
                local part = getLockPart(character)
                if part and isVisible(part) then
                    if _G.aimbotSettings.teamCheck and isTeamMate(currentTarget) then
                        currentTarget = nil
                    else
                        return part
                    end
                end
            end
        end
        
        local closest = nil
        local maxDistance = _G.aimbotSettings.fov
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, player in ipairs(Players:GetPlayers()) do
            if not player or player == LocalPlayer then continue end
            if _G.aimbotSettings.teamCheck and isTeamMate(player) then continue end
            
            local character = player.Character
            if not character then continue end
            if _G.aimbotSettings.aliveCheck and not isAlive(character) then continue end
            
            local part = getLockPart(character)
            if not part then continue end
            if not isVisible(part) then continue end
            
            local partPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            
            local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(partPos.X, partPos.Y)).Magnitude
            if distance <= maxDistance then
                maxDistance = distance
                closest = part
                currentTarget = player
            end
        end
        
        if not closest then
            currentTarget = nil
        end
        
        return closest
    end
    
    local function updateFOVCircle()
        if not _G.aimbotSettings.drawFOV then
            FOVCircle.Visible = false
            return
        end
        
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = _G.aimbotSettings.fov
        FOVCircle.Visible = true
    end
    
    -- Handle input
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == _G.aimbotSettings.triggerKey then
            isAiming = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == _G.aimbotSettings.triggerKey then
            isAiming = false
            currentTarget = nil
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not Camera then return end
        
        updateFOVCircle()
        
        if not _G.aimbotSettings.enabled then return end
        if not isAiming then return end
        
        local target = getClosestPlayerInFOV()
        if not target then return end
        
        local targetPos = target.Position
        local cameraPos = Camera.CFrame.Position
        local newCFrame = CFrame.new(cameraPos, targetPos)
        
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, _G.aimbotSettings.sensitivity)
    end)
end
