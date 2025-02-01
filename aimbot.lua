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
        rayPara
