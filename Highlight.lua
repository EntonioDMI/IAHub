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
    
    local function updateHighlightColors(highlight, player, isNPC, isBoss)
        if not highlight or not highlight.Parent then return end
        
        stopFriendAnimation(player)
        cancelTransitionTween(highlight)
        
        if player and _G.isFriend and _G.isFriend(player) then
            highlight.FillColor = friendColor
            highlight.OutlineColor = friendColor
            
            if not _G.highlightSettings.enabled then
                highlight.FillTransparency = 1
                highlight.OutlineTransparency = 0
                return
            end
            
            highlight.FillTransparency = _G.highlightSettings.fillTransparency
            highlight.OutlineTransparency = _G.highlightSettings.outlineTransparency
            
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
            local minFillTransparency = _G.highlightSettings.fillTransparency
            local minOutlineTransparency = _G.highlightSettings.outlineTransparency
            
            local tween = TweenService:Create(highlight, tweenInfo, {
                FillTransparency = math.min(0.8, minFillTransparency + 0.3),
                OutlineTransparency = math.min(0.8, minOutlineTransparency + 0.3)
            })
            
            friendAnimations[player] = tween
            tween:Play()
        else
            local targetFill = 1
            local targetOutline = 1
            
            if isNPC then
                if isBoss then
                    highlight.FillColor = _G.highlightSettings.bossColor
                    highlight.OutlineColor = _G.highlightSettings.bossColor
                    if _G.highlightSettings.bossEnabled then
                        targetFill = _G.highlightSettings.fillTransparency
                        targetOutline = _G.highlightSettings.outlineTransparency
                    end
                else
                    highlight.FillColor = _G.highlightSettings.npcColor
                    highlight.OutlineColor = _G.highlightSettings.npcColor
                    if _G.highlightSettings.npcEnabled then
                        targetFill = _G.highlightSettings.fillTransparency
                        targetOutline = _G.highlightSettings.outlineTransparency
                    end
                end
            else
                if _G.highlightSettings.enabled then
                    targetFill = _G.highlightSettings.fillTransparency
                    targetOutline = _G.highlightSettings.outlineTransparency
                    
                    if _G.highlightSettings.autoTeamColor then
                        highlight.FillColor = getTeamColor(player)
                    else
                        highlight.FillColor = _G.highlightSettings.fillColor
                    end
                    highlight.OutlineColor = _G.highlightSettings.outlineColor
                end
            end
            
            transitionTweens[highlight] = TweenService:Create(highlight, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                FillTransparency = targetFill,
                OutlineTransparency = targetOutline
            })
            transitionTweens[highlight]:Play()
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
        
        removeHighlight(player)
        
        local highlight = Instance.new("Highlight")
        updateHighlightColors(highlight, player, false, false)
        
        if player.Character then
            highlight.Parent = player.Character
            highlights[player] = highlight
        end
        
        local characterAddedConnection
        characterAddedConnection = player.CharacterAdded:Connect(function(character)
            if highlights[player] then
                queueHighlightCleanup(highlights[player])
            end
            
            highlight = Instance.new("Highlight")
            updateHighlightColors(highlight, player, false, false)
            highlight.Parent = character
            highlights[player] = highlight
        end)
        
        player.CharacterRemoving:Connect(function()
            if highlights[player] then
                queueHighlightCleanup(highlights[player])
                highlights[player] = nil
            end
        end)
        
        local teamChangedConnection
        teamChangedConnection = player:GetPropertyChangedSignal("Team"):Connect(function()
            if highlights[player] then
                if _G.highlightSettings.teamCheck and isTeamMate(player) and not (_G.isFriend and _G.isFriend(player)) then
                    removeHighlight(player)
                else
                    updateHighlightColors(highlights[player], player, false, false)
                end
            end
        end)
        
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
    
    -- Make updateHighlights function global
    _G.updateHighlights = function()
        -- Update player highlights
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if _G.highlightSettings.enabled then
                    createHighlight(player)
                else
                    removeHighlight(player)
                end
            end
        end
        
        -- Update NPC highlights
        local npcs = workspace:FindFirstChild("NPCs")
        if npcs then
            -- Regular NPCs
            for _, npc in ipairs(npcs:GetChildren()) do
                if npc:FindFirstChild("Humanoid") and not npc:IsDescendantOf(npcs.Boss) then
                    if _G.highlightSettings.npcEnabled then
                        local highlight = npc:FindFirstChild("Highlight") or Instance.new("Highlight")
                        highlight.Parent = npc
                        updateHighlightColors(highlight, nil, true, false)
                    else
                        local highlight = npc:FindFirstChild("Highlight")
                        if highlight then
                            highlight:Destroy()
                        end
                    end
                end
            end
            
            -- Boss NPCs
            local bossFolder = npcs:FindFirstChild("Boss")
            if bossFolder then
                for _, boss in ipairs(bossFolder:GetChildren()) do
                    if boss:FindFirstChild("Humanoid") then
                        local isPlayerBoss = Players:GetPlayerFromCharacter(boss) ~= nil
                        
                        if _G.highlightSettings.bossEnabled or isPlayerBoss then
                            local highlight = boss:FindFirstChild("Highlight") or Instance.new("Highlight")
                            highlight.Parent = boss
                            updateHighlightColors(highlight, nil, true, true)
                        else
                            local highlight = boss:FindFirstChild("Highlight")
                            if highlight then
                                highlight:Destroy()
                            end
                        end
                    end
                end
            end
        end
        
        processCleanupQueue()
    end
    
    -- Player events
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
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and highlights[player] then
                updateHighlightColors(highlights[player], player, false, false)
            end
        end
    end)
    
    -- Initial setup
    _G.updateHighlights()
end
