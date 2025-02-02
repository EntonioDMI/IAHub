return function(Fluent, Tab)
    -- [Previous service declarations and variables remain unchanged]
    
    local function updateHighlightColors(highlight, player, isNPC, isBoss)
        if not highlight or not highlight.Parent then return end
        
        stopFriendAnimation(player)
        cancelTransitionTween(highlight)
        
        if player and _G.isFriend and _G.isFriend(player) then
            -- [Previous friend highlight code remains unchanged]
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
    
    -- [Previous event connections remain unchanged]
end
