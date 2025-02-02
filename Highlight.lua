return function(Fluent, Tab)
    -- Services
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Variables
    local highlights = {}
    local defaultColor = Color3.fromRGB(150, 150, 150)
    
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
        if _G.highlightSettings.autoTeamColor then
            highlight.FillColor = getTeamColor(player)
        else
            highlight.FillColor = _G.highlightSettings.fillColor
        end
        highlight.OutlineColor = _G.highlightSettings.outlineColor
        highlight.FillTransparency = _G.highlightSettings.fillTransparency
        highlight.OutlineTransparency = _G.highlightSettings.outlineTransparency
    end
    
    local function removeHighlight(player)
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
    end
    
    local function createHighlight(player)
        if player == LocalPlayer then return end
        
        if _G.highlightSettings.teamCheck and isTeamMate(player) then
            removeHighlight(player)
            return
        end
        
        local highlight = Instance.new("Highlight")
        updateHighlightColors(highlight, player)
        
        if player.Character then
            highlight.Parent = player.Character
            highlights[player] = highlight
        end
        
        player.CharacterAdded:Connect(function(character)
            highlight.Parent = character
            highlights[player] = highlight
            updateHighlightColors(highlight, player)
        end)
        
        player:GetPropertyChangedSignal("Team"):Connect(function()
            if highlights[player] then
                if _G.highlightSettings.teamCheck and isTeamMate(player) then
                    removeHighlight(player)
                else
                    updateHighlightColors(highlights[player], player)
                end
            end
        end)
    end
    
    -- Make updateHighlights function global so it can be called from UI callbacks
    _G.updateHighlights = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if _G.highlightSettings.enabled then
                    if _G.highlightSettings.teamCheck and isTeamMate(player) then
                        removeHighlight(player)
                    else
                        if not highlights[player] then
                            createHighlight(player)
                        else
                            updateHighlightColors(highlights[player], player)
                        end
                    end
                else
                    removeHighlight(player)
                end
            end
        end
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
    
    -- Initial setup
    for _, player in ipairs(Players:GetPlayers()) do
        if _G.highlightSettings.enabled then
            createHighlight(player)
        end
    end
end
