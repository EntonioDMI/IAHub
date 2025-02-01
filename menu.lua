return function(Modules)
    -- [Previous code remains unchanged until the toggles section]

    do
        -- Aimbot Tab
        local AimbotEnabled = Tabs.Aimbot:AddToggle("Enabled", {
            Title = "✨ Enabled",
            Description = "Activate the precision targeting system",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.enabled = Value
            end
        })

        local TeamCheck = Tabs.Aimbot:AddToggle("TeamCheck", {
            Title = "👥 Team Check",
            Description = "Prevent targeting teammates - keep the friendly fire at bay!",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.teamCheck = Value
            end
        })

        local ShowFOV = Tabs.Aimbot:AddToggle("ShowFOV", {
            Title = "👁️ Show FOV",
            Description = "Display your targeting range with a visual circle",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.drawFOV = Value
            end
        })

        -- [Rest of aimbot controls remain the same]

        -- Hitboxes Tab
        local HitboxEnabled = Tabs.Hitboxes:AddToggle("Enabled", {
            Title = "📦 Enabled",
            Description = "Enhance target hitboxes for better precision",
            Default = false,
            Callback = function(Value)
                _G.hitboxSettings.enabled = Value
            end
        })

        local HitboxPart = Tabs.Hitboxes:AddDropdown("HitboxPart", {
            Title = "🎯 Target Part",
            Description = "Select which part to enhance - choose your strategy!",
            Values = {"Head", "Torso"},
            Default = "Head",
            Multi = false,
            Callback = function(Value)
                _G.hitboxSettings.targetPart = Value
            end
        })

        -- [Rest of hitbox controls remain the same]

        -- Highlight Tab
        local HighlightEnabled = Tabs.Highlight:AddToggle("Enabled", {
            Title = "✨ Enabled",
            Description = "Make players more visible with a glowing outline",
            Default = false,
            Callback = function(Value)
                _G.highlightSettings.enabled = Value
                _G.updateHighlights()
            end
        })

        -- [Rest of the code remains unchanged]
    end
end
