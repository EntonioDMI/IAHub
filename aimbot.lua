return function(Fluent, Tab)
    -- Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    -- Variables
    local DrawingLib = Drawing.new
    local FOVCircle = DrawingLib("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Visible = false
    
    -- Settings
    _G.aimbotSettings = {
        enabled = false,
        teamCheck = true,
        fov = 100,
        drawFOV = true,
        triggerKey = Enum.UserInputType.MouseButton2,
        lockPart = "Head",
        wallCheck = true,
        aliveCheck = true,
        sensitivity = 1
    }
    
    -- Functions
    local function isTeamMate(player)
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
            -- Check for R15
            local upperTorso = character:FindFirstChild("UpperTorso")
            if upperTorso then
                return upperTorso
            end
            -- Check for R6
            return character:FindFirstChild("Torso")
        end
    end
    
    local function isVisible(part)
        if not _G.aimbotSettings.wallCheck then return true end
        
        local origin = Camera.CFrame.Position
        local direction = (part.Position - origin).Unit
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
        
        local result = workspace:Raycast(origin, direction * 1000, rayParams)
        return not result
    end
    
    local function getClosestPlayerInFOV()
        local closest = nil
        local maxDistance = _G.aimbotSettings.fov
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
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
            end
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
    
    -- Main aimbot loop
    RunService.RenderStepped:Connect(function()
        updateFOVCircle()
        
        if not _G.aimbotSettings.enabled then return end
        if not UserInputService:IsMouseButtonPressed(_G.aimbotSettings.triggerKey) then return end
        
        local target = getClosestPlayerInFOV()
        if not target then return end
        
        local targetPos = target.Position
        local cameraPos = Camera.CFrame.Position
        local newCFrame = CFrame.new(cameraPos, targetPos)
        
        -- Smooth aim using sensitivity
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, _G.aimbotSettings.sensitivity)
    end)
end
