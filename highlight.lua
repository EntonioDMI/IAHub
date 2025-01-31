return function(Fluent, Tab)
    local Options = Fluent.Options
    
    -- Services
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Variables
    local highlights = {}
    local defaultColor = Color3.fromRGB(150, 150, 150) -- Серый цвет по умолчанию
    
    -- Functions
    local function getTeamColor(player)
        -- Если у игрока есть команда и цвет команды
        if player.Team and player.Team.TeamColor then
            return player.Team.TeamColor.Color
        end
        return defaultColor -- Возвращаем серый цвет, если нет команды или цвета команды
    end
    
    local function isTeamMate(player)
        -- Если у локального игрока нет команды, проверяем есть ли команда у другого игрока
        if not LocalPlayer.Team then
            return player.Team == nil -- Если у обоих нет команды, значит они в одной команде
        end
        -- Если у обоих есть команда, сравниваем их
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
    
    local function createHighlight(player)
        if player == LocalPlayer then return end
        
        -- Check if we should create highlight based on team settings
        if _G.highlightSettings.teamCheck and isTeamMate(player) then
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
    
    local function removeHighlight(player)
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
    end
    
    local function updateHighlights()
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
    
    -- Watch for changes in the highlight settings
    local function watchSetting(name)
        spawn(function()
            local lastValue = _G.highlightSettings[name]
            while wait(0.1) do
                if _G.highlightSettings[name] ~= lastValue then
                    lastValue = _G.highlightSettings[name]
                    updateHighlights()
                end
            end
        end)
    end
    
    -- Watch all settings
    for setting, _ in pairs(_G.highlightSettings) do
        watchSetting(setting)
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
    LocalPlayer:GetPropertyChangedSignal("Team"):Connect(updateHighlights)
    
    -- Initial setup
    for _, player in ipairs(Players:GetPlayers()) do
        if _G.highlightSettings.enabled then
            createHighlight(player)
        end
    end
end
