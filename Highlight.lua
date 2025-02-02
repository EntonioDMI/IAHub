return function(Fluent, Tab)
    -- Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    
    -- Variables
    local highlights = {}
    local defaultColor = Color3.fromRGB(150, 150, 150)
    local cleanupQueue = {}
    local friendColor = Color3.fromRGB(0, 255, 0)
    local friendAnimations = {}
    
    -- Functions
    local function getTeamColor(player)
        if player.Team and player.Team.TeamColor then
            return player.Team.TeamColor.Color
        end
        return defaultColor
    end
    
    local function isTeamMate(player)
        if not LocalPlayer.Team then
            return player.Team == nil
        end
        return player.Team == LocalPlayer.Team
    end
    
    local function stopFriendAnimation(player)
        if friendAnimations[player] then
            friendAnimations[player]:Cancel()
            friendAnimations[player] = nil
        end
    end
    
    local function updateHighlightColors(highlight, player)
        if not highlight or not highlight.Parent then return end
        
        stopFriendAnimation(player)
        
        if _G.isFriend and _G.isFriend(player) then
            -- Set base colors for friend
            highlight.FillColor = friendColor
            highlight.OutlineColor = friendColor
            
            -- Keep friend highlight visible even when ESP is off
            if not _G.highlightSettings.enabled then
                highlight.FillTransparency = 1
                highlight.OutlineTransparency = 0
                return
            end
            
            -- Create pulsing animation for friends when ESP is on
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
            local minFillTransparency = _G.highlightSettings.fillTransparency
            local minOutlineTransparency = _G.highlightSettings.outlineTransparency
            
            highlight.FillTransparency = minFillTransparency
            highlight.OutlineTransparency = minOutlineTransparency
            
            local tween = TweenService:Create(highlight, tweenInfo, {
                FillTransparency = math.min(0.8, minFillTransparency + 0.3),
                OutlineTransparency = math.min(0.8, minOutlineTransparency + 0.3)
            })
            
            friendAnimations[player] = tween
            tween:Play()
        else
            if not _G.highlightSettings.enabled then
                highlight.FillTransparency = 1
                highlight.OutlineTransparency = 1
                return
            end
            
            if _G.highlightSettings.autoTeamColor then
                highlight.FillColor = getTeamColor(player)
            else
                highlight.FillColor = _G.highlightSettings.fillColor
            end
            highlight.OutlineColor = _G.highlightSettings.outlineColor
            highlight.FillTransparency = _G.highlightSettings.fillTransparency
            highlight.OutlineTransparency = _G.highlightSettings.outlineTransparency
        end
    end
    
    local function cleanupHighlight(highlight)
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    
    local function removeHighlight(player)
        stopFriendAnimation(player)
        if highlights[player] then
            cleanupHighlight(highlights[player])
            highlights[player] = nil
        end
    end
    
    local function processCleanupQueue()
        for i = #cleanupQueue, 1, -1 do
            local item = cleanupQueue[i]
            if item.timestamp <= tick() then
                if item.highlight and item.highlight.Parent then
                    item.highlight:Destroy()
                end
                table.remove(cleanupQueue, i)
            end
        end
    end
    
    local function queueHighlightCleanup(highlight)
        table.insert(cleanupQueue, {
            highlight = highlight,
            timestamp = tick() + 1
        })
    end
    
    local function createHighlight(player)
        if player == LocalPlayer then return end
        
        if _G.highlightSettings.teamCheck and isTeamMate(player) and not (_G.isFriend and _G.isFriend(player)) then
            removeHighlight(player)
            return
        end
        
        -- Remove existing highlight if any
        removeHighlight(player)
        
        -- Create new highlight
        local highlight = Instance.new("Highlight")
        updateHighlightColors(highlight, player)
        
        if player.Character then
            highlight.Parent = player.Character
            highlights[player] = highlight
        end
        
        -- Character added handler
        local characterAddedConnection
        characterAddedConnection = player.CharacterAdded:Connect(function(character)
            if highlights[player] then
                queueHighlightCleanup(highlights[player])
            end
            
            highlight = Instance.new("Highlight")
            updateHighlightColors(highlight, player)
            highlight.Parent = character
            highlights[player] = highlight
        end)
        
        -- Character removing handler
        player.CharacterRemoving:Connect(function()
            if highlights[player] then
                queueHighlightCleanup(highlights[player])
                highlights[player] = nil
            end
        end)
        
        -- Team changed handler
        local teamChangedConnection
        teamChangedConnection = player:GetPropertyChangedSignal("Team"):Connect(function()
            if highlights[player] then
                if _G.highlightSettings.teamCheck and isTeamMate(player) and not (_G.isFriend and _G.isFriend(player)) then
                    removeHighlight(player)
                else
                    updateHighlightColors(highlights[player], player)
                end
            end
        end)
        
        -- Cleanup connections when player leaves
        player.AncestryChanged:Connect(function(_, parent)
            if not parent then
                if characterAddedConnection then
                    characterAddedConnection:Disconnect()
                end
                if teamChangedConnection then
                    teamChangedConnection:Disconnect()
                end
                removeHighlight(player)
            end
        end)
    end
    
    -- Make updateHighlights function global so it can be called from UI callbacks
    _G.updateHighlights = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createHighlight(player)
            end
        end
        
        processCleanupQueue()
    end
    
    -- Connections for player events
    Players.PlayerAdded:Connect(function(player)
        createHighlight(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        removeHighlight(player)
    end)
    
    -- Monitor LocalPlayer team changes
    LocalPlayer:GetPropertyChangedSignal("Team"):Connect(_G.updateHighlights)
    
    -- Process cleanup queue and update highlights
    RunService.RenderStepped:Connect(function()
        processCleanupQueue()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and highlights[player] then
                updateHighlightColors(highlights[player], player)
            end
        end
    end)
    
    -- Initial setup
    _G.updateHighlights()
end
