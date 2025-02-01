return function(Modules)
    local Fluent = Modules.Fluent
    if not Fluent then
        warn("Fluent UI module not found!")
        return
    end

    -- Create window
    local Window = Fluent:CreateWindow({
        Title = "IAHub",
        SubTitle = "by EntonioDMI",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    -- Create tabs
    local Tabs = {
        Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
        Hitboxes = Window:AddTab({ Title = "Hitboxes", Icon = "square" }),
        Highlight = Window:AddTab({ Title = "Highlight", Icon = "palette" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
    }

    -- Initialize settings if they don't exist
    if not _G.aimbotSettings then
        _G.aimbotSettings = {
            enabled = false,
            teamCheck = false,
            wallCheck = false,
            drawFOV = false,
            fov = 100,
            sensitivity = 0.5,
            triggerKey = Enum.UserInputType.MouseButton2,
            lockPart = "Head"
        }
    end

    if not _G.hitboxSettings then
        _G.hitboxSettings = {
            enabled = false,
            targetPart = "Head",
            size = 10,
            transparency = 0.5,
            color = Color3.fromRGB(255, 0, 0)
        }
    end

    if not _G.highlightSettings then
        _G.highlightSettings = {
            enabled = false,
            teamCheck = false,
            autoTeamColor = true,
            fillColor = Color3.fromRGB(255, 0, 0),
            outlineColor = Color3.fromRGB(255, 255, 255),
            fillTransparency = 0.5,
            outlineTransparency = 0
        }
    end

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

        local WallCheck = Tabs.Aimbot:AddToggle("WallCheck", {
            Title = "🧱 Wall Check",
            Description = "Only target visible players",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.wallCheck = Value
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

        local FOVSize = Tabs.Aimbot:AddSlider("FOV", {
            Title = "🎯 FOV Size",
            Description = "Adjust your targeting field of view",
            Default = 100,
            Min = 10,
            Max = 800,
            Rounding = 0,
            Callback = function(Value)
                _G.aimbotSettings.fov = Value
            end
        })

        local Sensitivity = Tabs.Aimbot:AddSlider("Sensitivity", {
            Title = "🔍 Sensitivity",
            Description = "Adjust aim smoothness (lower = smoother)",
            Default = 0.5,
            Min = 0.1,
            Max = 1,
            Rounding = 2,
            Callback = function(Value)
                _G.aimbotSettings.sensitivity = Value
            end
        })

        local TriggerKey = Tabs.Aimbot:AddDropdown("TriggerKey", {
            Title = "🔑 Trigger Key",
            Description = "Select which mouse button activates the aimbot",
            Values = {"Left Click", "Right Click"},
            Default = "Right Click",
            Multi = false,
            Callback = function(Value)
                _G.aimbotSettings.triggerKey = Value == "Left Click" and 
                    Enum.UserInputType.MouseButton1 or 
                    Enum.UserInputType.MouseButton2
            end
        })

        local LockPart = Tabs.Aimbot:AddDropdown("LockPart", {
            Title = "🎯 Lock Part",
            Description = "Select which body part to target",
            Values = {"Head", "Torso"},
            Default = "Head",
            Multi = false,
            Callback = function(Value)
                _G.aimbotSettings.lockPart = Value
            end
        })

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
            Description = "Select which part to enhance",
            Values = {"Head", "Torso"},
            Default = "Head",
            Multi = false,
            Callback = function(Value)
                _G.hitboxSettings.targetPart = Value
            end
        })

        local HitboxSize = Tabs.Hitboxes:AddSlider("Size", {
            Title = "📏 Size",
            Description = "Adjust hitbox size",
            Default = 10,
            Min = 1,
            Max = 50,
            Rounding = 1,
            Callback = function(Value)
                _G.hitboxSettings.size = Value
            end
        })

        local HitboxTransparency = Tabs.Hitboxes:AddSlider("Transparency", {
            Title = "👻 Transparency",
            Description = "Adjust hitbox visibility",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Rounding = 2,
            Callback = function(Value)
                _G.hitboxSettings.transparency = Value
            end
        })

        local HitboxColor = Tabs.Hitboxes:AddColorPicker("Color", {
            Title = "🎨 Color",
            Description = "Choose hitbox color",
            Default = Color3.fromRGB(255, 0, 0),
            Callback = function(Value)
                _G.hitboxSettings.color = Value
            end
        })

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

        local HighlightTeamCheck = Tabs.Highlight:AddToggle("TeamCheck", {
            Title = "👥 Team Check",
            Description = "Don't highlight teammates",
            Default = false,
            Callback = function(Value)
                _G.highlightSettings.teamCheck = Value
                _G.updateHighlights()
            end
        })

        local AutoTeamColor = Tabs.Highlight:AddToggle("AutoTeamColor", {
            Title = "🎨 Auto Team Color",
            Description = "Use team colors for highlighting",
            Default = true,
            Callback = function(Value)
                _G.highlightSettings.autoTeamColor = Value
                _G.updateHighlights()
            end
        })

        local FillColor = Tabs.Highlight:AddColorPicker("FillColor", {
            Title = "🎨 Fill Color",
            Description = "Choose the fill color for highlights",
            Default = Color3.fromRGB(255, 0, 0),
            Callback = function(Value)
                _G.highlightSettings.fillColor = Value
                _G.updateHighlights()
            end
        })

        local OutlineColor = Tabs.Highlight:AddColorPicker("OutlineColor", {
            Title = "✏️ Outline Color",
            Description = "Choose the outline color for highlights",
            Default = Color3.fromRGB(255, 255, 255),
            Callback = function(Value)
                _G.highlightSettings.outlineColor = Value
                _G.updateHighlights()
            end
        })

        local FillTransparency = Tabs.Highlight:AddSlider("FillTransparency", {
            Title = "👻 Fill Transparency",
            Description = "Adjust fill transparency",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Rounding = 2,
            Callback = function(Value)
                _G.highlightSettings.fillTransparency = Value
                _G.updateHighlights()
            end
        })

        local OutlineTransparency = Tabs.Highlight:AddSlider("OutlineTransparency", {
            Title = "👻 Outline Transparency",
            Description = "Adjust outline transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Rounding = 2,
            Callback = function(Value)
                _G.highlightSettings.outlineTransparency = Value
                _G.updateHighlights()
            end
        })
    end

    -- Load modules
    if Modules.Aimbot then
        Modules.Aimbot(Fluent, Tabs.Aimbot)
    end

    if Modules.Hitboxes then
        Modules.Hitboxes(Fluent, Tabs.Hitboxes)
    end

    if Modules.Highlight then
        Modules.Highlight(Fluent, Tabs.Highlight)
    end

    if Modules.Misc then
        Modules.Misc(Fluent, Tabs.Misc)
    end

    -- Save Manager
    local SaveManager = Modules.SaveManager
    if SaveManager then
        SaveManager:SetLibrary(Fluent)
        SaveManager:SetFolder("IAHub")
        SaveManager:BuildConfigSection(Tabs.Misc)
    end

    -- Interface Manager
    local InterfaceManager = Modules.InterfaceManager
    if InterfaceManager then
        InterfaceManager:SetLibrary(Fluent)
        InterfaceManager:SetFolder("IAHub")
        InterfaceManager:BuildInterfaceSection(Tabs.Misc)
    end
end
