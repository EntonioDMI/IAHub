return function(Fluent, Tab)
    local Options = Fluent.Options
    
    -- Services
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Variables
    local highlights = {}
    
    -- Functions
    local function getTeamColor(player)
        return player.Team and player.Team.TeamColor.Color or Color3.new(1, 0, 0)
    end
    
    local function isTeamMate(player)
        if not LocalPlayer.Team then return false end
        return player.Team == LocalPlayer.Team
    end
    
    local function updateHighlightColors(highlight, player)
        if Options.AutoTeamColor.Value then
            highlight.FillColor = getTeamColor(player)
        else
            highlight.FillColor = Options.FillColor.Value
        end
        highlight.OutlineColor = Options.OutlineColor.Value
        highlight.FillTransparency = Options.FillTransparency.Value
        highlight.OutlineTransparency = Options.OutlineTransparency.Value
    end
    
    local function createHighlight(player)
        if player == LocalPlayer then return end
        
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
        
        -- Update colors when team changes
        player:GetPropertyChangedSignal("Team"):Connect(function()
            if highlights[player] then
                updateHighlightColors(highlights[player], player)
            end
        end)
    end
    
    local function removeHighlight(player)
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
    end
    
    local function updateHighlights()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if Options.Enabled.Value then
                    if Options.TeamCheck.Value and isTeamMate(player) then
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
    
    -- Connections for UI changes
    Options.Enabled:OnChanged(updateHighlights)
    Options.TeamCheck:OnChanged(updateHighlights)
    Options.AutoTeamColor:OnChanged(updateHighlights)
    Options.FillColor:OnChanged(updateHighlights)
    Options.OutlineColor:OnChanged(updateHighlights)
    Options.FillTransparency:OnChanged(updateHighlights)
    Options.OutlineTransparency:OnChanged(updateHighlights)
    
    -- Connections for player events
    Players.PlayerAdded:Connect(function(player)
        if Options.Enabled.Value and not (Options.TeamCheck.Value and isTeamMate(player)) then
            createHighlight(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        removeHighlight(player)
    end)
    
    -- Monitor LocalPlayer team changes
    LocalPlayer:GetPropertyChangedSignal("Team"):Connect(updateHighlights)
    
    -- Initial setup
    for _, player in ipairs(Players:GetPlayers()) do
        if Options.Enabled.Value and not (Options.TeamCheck.Value and isTeamMate(player)) then
            createHighlight(player)
        end
    end
end
