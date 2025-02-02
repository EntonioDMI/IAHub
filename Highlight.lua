return function(Fluent, Tab)
    -- Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    
    -- Variables
    local highlights = {}
    local defaultColor = Color3.fromRGB(150, 150, 150)
    local cleanupQueue = {}
    
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
    
    local function updateHighlightColors(highlight, player)
        if not highlight or not highlight.Parent then return end
        
        if _G.highlightSettings.autoTeamColor then
            highlight.FillColor = getTeamColor(player)
        else
            highlight.FillColor = _G.highlightSettings.fillColor
        end
        highlight.OutlineColor = _G.highlightSettings.outlineColor
        highlight.FillTransparency = _G.highlightSettings.fillTransparency
        highlight.OutlineTransparency = _G.highlightSettings.outlineTransparency
    end
    
    local function cleanupHighlight(highlight)
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    
    local function removeHighlight(player)
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
            timestamp = tick() + 1 -- Delay cleanup by 1 second
        })
    end
    
    local function createHighlight(player)
        if player == LocalPlayer then return end
        
        if _G.highlightSettings.teamCheck and isTeamMate(player) then
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
            -- Queue old highlight for cleanup if it exists
            if highlights[player] then
                queueHighlightCleanup(highlights[player])
            end
            
            -- Create new highlight
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
                if _G.highlightSettings.teamCheck and isTeamMate(player) then
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
        if _G.highlightSettings.enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    createHighlight(player)
                end
            end
        else
            for player, highlight in pairs(highlights) do
                removeHighlight(player)
            end
        end
        
        -- Process cleanup queue
        processCleanupQueue()
    end
    
    -- Connections for player events
    Players.PlayerAdded:Connect(function(player)
        if _G.highlightSettings.enabled then
            createHighlight(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        removeHighlight(player)
    end)
    
    -- Monitor LocalPlayer team changes
    LocalPlayer:GetPropertyChangedSignal("Team"):Connect(_G.updateHighlights)
    
    -- Process cleanup queue and update highlights
    RunService.RenderStepped:Connect(function()
        processCleanupQueue()
        if _G.highlightSettings.enabled then
            _G.updateHighlights()
        end
    end)
    
    -- Initial setup
    _G.updateHighlights()
end
