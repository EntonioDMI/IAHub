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
    
    local function createHighlight(player)
        if player == LocalPlayer then return end
        
        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = Options.HighlightTransparency.Value
        highlight.OutlineTransparency = 1
        
        if Options.AutoTeamColor.Value then
            highlight.FillColor = getTeamColor(player)
        else
            highlight.FillColor = Options.HighlightColor.Value
        end
        
        if player.Character then
            highlight.Parent = player.Character
            highlights[player] = highlight
        end
        
        player.CharacterAdded:Connect(function(character)
            highlight.Parent = character
            highlights[player] = highlight
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
                            -- Update existing highlight
                            local highlight = highlights[player]
                            highlight.FillTransparency = Options.HighlightTransparency.Value
                            if Options.AutoTeamColor.Value then
                                highlight.FillColor = getTeamColor(player)
                            else
                                highlight.FillColor = Options.HighlightColor.Value
                            end
                        end
                    end
                else
                    removeHighlight(player)
                end
            end
        end
    end
    
    -- UI Elements
    local Toggle = Tab:AddToggle("Enabled", {
        Title = "Enable ESP",
        Default = false
    })
    
    local TeamCheck = Tab:AddToggle("TeamCheck", {
        Title = "Team Check",
        Description = "Don't highlight teammates",
        Default = true
    })
    
    local AutoTeamColor = Tab:AddToggle("AutoTeamColor", {
        Title = "Auto Team Color",
        Description = "Use team colors for highlights",
        Default = true
    })
    
    local ColorPicker = Tab:AddColorpicker("HighlightColor", {
        Title = "Highlight Color",
        Default = Color3.fromRGB(255, 0, 0)
    })
    
    local TransparencySlider = Tab:AddSlider("HighlightTransparency", {
        Title = "Highlight Transparency",
        Description = "Adjust highlight transparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2
    })
    
    -- Connections
    Toggle:OnChanged(updateHighlights)
    TeamCheck:OnChanged(updateHighlights)
    AutoTeamColor:OnChanged(updateHighlights)
    ColorPicker:OnChanged(updateHighlights)
    TransparencySlider:OnChanged(updateHighlights)
    
    Players.PlayerAdded:Connect(function(player)
        if Options.Enabled.Value then
            if not (Options.TeamCheck.Value and isTeamMate(player)) then
                createHighlight(player)
            end
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        removeHighlight(player)
    end)
    
    -- Initial setup
    for _, player in ipairs(Players:GetPlayers()) do
        if Options.Enabled.Value then
            if not (Options.TeamCheck.Value and isTeamMate(player)) then
                createHighlight(player)
            end
        end
    end
end
