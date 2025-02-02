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
    local bossColor = Color3.fromRGB(255, 0, 0)
    local npcColor = Color3.fromRGB(255, 165, 0)
    local friendAnimations = {}
    local transitionTweens = {}
    
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

    local function cancelTransitionTween(highlight)
        if transitionTweens[highlight] then
            transitionTweens[highlight]:Cancel()
            transitionTweens[highlight] = nil
        end
    end
    
    local function updateHighlightColors(highlight, model, isNPC, isBoss)
        if not highlight or not highlight.Parent then return end
        
        local player = not isNPC and not isBoss and Players:GetPlayerFromCharacter(model)
        
        stopFriendAnimation(player)
        cancelTransitionTween(highlight)
        
        -- Determine colors and settings based on type
        local fillColor, outlineColor
        local settings = _G.highlightSettings
        
        if player and _G.isFriend and _G.isFriend(player) then
            fillColor = friendColor
            outlineColor = friendColor
        elseif isBoss then
            fillColor = bossColor
            outlineColor = bossColor
        elseif isNPC then
            fillColor = npcColor
            outlineColor = npcColor
        else
            fillColor = settings.autoTeamColor and player and getTeamColor(player) or settings.fillColor
            outlineColor = settings.outlineColor
        end
        
        highlight.FillColor = fillColor
        highlight.OutlineColor = outlineColor
        
        -- Create smooth transition tween
        local enabled = (isNPC and settings.npcEnabled) or 
                       (isBoss and settings.bossEnabled) or 
                       (not isNPC and not isBoss and settings.enabled)
        
        local targetFill = enabled and settings.fillTransparency or 1
        local targetOutline = enabled and settings.outlineTransparency or 1
        
        transitionTweens[highlight] = TweenService:Create(highlight, 
            TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
            {
                FillTransparency = targetFill,
                OutlineTransparency = targetOutline
            }
        )
        transitionTweens[highlight]:Play()
        
        -- Special animation for friends
        if player and _G.isFriend and _G.isFriend(player) and settings.enabled then
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
            local minFillTransparency = settings.fillTransparency
            local minOutlineTransparency = settings.outlineTransparency
            
            local tween = TweenService:Create(highlight, tweenInfo, {
                FillTransparency = math.min(0.8, minFillTransparency + 0.3),
                OutlineTransparency = math.min(0.8, minOutlineTransparency + 0.3)
            })
            
            friendAnimations[player] = tween
            tween:Play()
        end
    end
    
    local function cleanupHighlight(highlight)
        cancelTransitionTween(highlight)
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    
    local function removeHighlight(model)
        local player = Players:GetPlayerFromCharacter(model)
        if player then
            stopFriendAnimation(player)
        end
        
        if highlights[model] then
            cleanupHighlight(highlights[model])
            highlights[model] = nil
        end
    end
    
    local function processCleanupQueue()
        for i = #cleanupQueue, 1, -1 do
            local item = cleanupQueue[i]
            if item.timestamp <= tick() then
                cleanupHighlight(item.highlight)
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
    
    local function createHighlight(model, isNPC, isBoss)
        if model == LocalPlayer.Character then return end
        
        local player = not isNPC and not isBoss and Players:GetPlayerFromCharacter(model)
        
        if player and _G.highlightSettings.teamCheck and isTeamMate(player) and 
           not (_G.isFriend and _G.isFriend(player)) then
            removeHighlight(model)
            return
        end
        
        removeHighlight(model)
        
        local highlight = Instance.new("Highlight")
        updateHighlightColors(highlight, model, isNPC, isBoss)
        highlight.Parent = model
        highlights[model] = highlight
        
        -- Character added/removing handlers for players
        if player then
            player.CharacterAdded:Connect(function(character)
                if highlights[model] then
                    queueHighlightCleanup(highlights[model])
                end
                
                highlight = Instance.new("Highlight")
                updateHighlightColors(highlight, character, false, false)
                highlight.Parent = character
                highlights[character] = highlight
            end)
            
            player.CharacterRemoving:Connect(function(character)
                if highlights[character] then
                    queueHighlightCleanup(highlights[character])
                    highlights[character] = nil
                end
            end)
            
            player:GetPropertyChangedSignal("Team"):Connect(function()
                if highlights[player.Character] then
                    if _G.highlightSettings.teamCheck and isTeamMate(player) and 
                       not (_G.isFriend and _G.isFriend(player)) then
                        removeHighlight(player.Character)
                    else
                        updateHighlightColors(highlights[player.Character], player.Character, false, false)
                    end
                end
            end)
        end
        
        -- Cleanup when model is removed
        model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                removeHighlight(model)
            end
        end)
    end
    
    local function updateHighlights()
        processCleanupQueue()
        
        -- Update players
        if _G.highlightSettings.enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    createHighlight(player.Character, false, false)
                end
            end
        end
        
        -- Update NPCs
        if _G.highlightSettings.npcEnabled then
            local npcs = workspace:FindFirstChild("NPCs")
            if npcs then
                for _, npc in ipairs(npcs:GetChildren()) do
                    if npc:IsA("Model") then
                        createHighlight(npc, true, false)
                    end
                end
            end
        end
        
        -- Update Bosses
        if _G.highlightSettings.bossEnabled then
            local bosses = workspace.NPCs:FindFirstChild("Boss")
            if bosses then
                for _, boss in ipairs(bosses:GetChildren()) do
                    if boss:IsA("Model") then
                        createHighlight(boss, false, true)
                    end
                end
            end
        end
    end
    
    -- Create UI elements
    local highlightSection = Tab:AddSection("ESP Settings")
    
    -- Player ESP
    local playerToggle = Tab:AddToggle("ESPEnabled", {
        Title = "Player ESP",
        Description = "Enable ESP for players",
        Default = false,
        Callback = function(Value)
            _G.highlightSettings.enabled = Value
            if not Value then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        removeHighlight(player.Character)
                    end
                end
            end
        end
    })
    
    -- NPC ESP
    local npcToggle = Tab:AddToggle("NPCESPEnabled", {
        Title = "NPC ESP",
        Description = "Enable ESP for NPCs",
        Default = false,
        Callback = function(Value)
            _G.highlightSettings.npcEnabled = Value
            if not Value then
                local npcs = workspace:FindFirstChild("NPCs")
                if npcs then
                    for _, npc in ipairs(npcs:GetChildren()) do
                        if npc:IsA("Model") then
                            removeHighlight(npc)
                        end
                    end
                end
            end
        end
    })
    
    -- Boss ESP
    local bossToggle = Tab:AddToggle("BossESPEnabled", {
        Title = "Boss ESP",
        Description = "Enable ESP for bosses",
        Default = false,
        Callback = function(Value)
            _G.highlightSettings.bossEnabled = Value
            if not Value then
                local bosses = workspace.NPCs:FindFirstChild("Boss")
                if bosses then
                    for _, boss in ipairs(bosses:GetChildren()) do
                        if boss:IsA("Model") then
                            removeHighlight(boss)
                        end
                    end
                end
            end
        end
    })
    
    -- Common Settings
    Tab:AddToggle("TeamCheck", {
        Title = "Team Check",
        Description = "Only show ESP for enemies",
        Default = true,
        Callback = function(Value)
            _G.highlightSettings.teamCheck = Value
        end
    })
    
    Tab:AddToggle("AutoTeamColor", {
        Title = "Auto Team Color",
        Description = "Use team colors for ESP",
        Default = true,
        Callback = function(Value)
            _G.highlightSettings.autoTeamColor = Value
        end
    })
    
    Tab:AddColorPicker("FillColor", {
        Title = "Fill Color",
        Description = "Choose ESP fill color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(Value)
            _G.highlightSettings.fillColor = Value
        end
    })
    
    Tab:AddColorPicker("OutlineColor", {
        Title = "Outline Color",
        Description = "Choose ESP outline color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            _G.highlightSettings.outlineColor = Value
        end
    })
    
    Tab:AddSlider("FillTransparency", {
        Title = "Fill Transparency",
        Description = "Adjust ESP fill transparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.highlightSettings.fillTransparency = Value
        end
    })
    
    Tab:AddSlider("OutlineTransparency", {
        Title = "Outline Transparency",
        Description = "Adjust ESP outline transparency",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.highlightSettings.outlineTransparency = Value
        end
    })
    
    -- Make updateHighlights function global
    _G.updateHighlights = updateHighlights
    
    -- Setup connections
    Players.PlayerAdded:Connect(function(player)
        if player.Character then
            createHighlight(player.Character, false, false)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if player.Character then
            removeHighlight(player.Character)
        end
    end)
    
    LocalPlayer:GetPropertyChangedSignal("Team"):Connect(updateHighlights)
    
    RunService.RenderStepped:Connect(function()
        processCleanupQueue()
        for model, highlight in pairs(highlights) do
            if model and highlight then
                local isNPC = model:IsDescendantOf(workspace.NPCs) and not model:IsDescendantOf(workspace.NPCs.Boss)
                local isBoss = model:IsDescendantOf(workspace.NPCs.Boss)
                updateHighlightColors(highlight, model, isNPC, isBoss)
            end
        end
    end)
    
    -- Initial setup
    updateHighlights()
end
