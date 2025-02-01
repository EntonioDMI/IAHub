return function(Modules)
    local Fluent = Modules.Fluent
    local SaveManager = Modules.SaveManager
    local InterfaceManager = Modules.InterfaceManager
    
    local Window = Fluent:CreateWindow({
        Title = "IAHub",
        SubTitle = "v1.0 Alpha by EntonioDMI",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local Tabs = {
        Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
        Hitboxes = Window:AddTab({ Title = "Hitboxes", Icon = "box" }),
        Highlight = Window:AddTab({ Title = "Highlight", Icon = "eye" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "settings-2" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    local Options = Fluent.Options

    -- Initialize settings
    _G.aimbotSettings = {
        enabled = false,
        teamCheck = false,
        fov = 100,
        drawFOV = false,
        triggerKey = Enum.UserInputType.MouseButton2,
        lockPart = "Head",
        wallCheck = false,
        aliveCheck = false,
        sensitivity = 1
    }

    _G.hitboxSettings = {
        enabled = false,
        targetPart = "Head",
        size = 8,
        transparency = 0.7
    }

    _G.highlightSettings = {
        enabled = false,
        teamCheck = false,
        autoTeamColor = false,
        fillColor = Color3.fromRGB(255, 0, 0),
        fillTransparency = 0.5,
        outlineColor = Color3.fromRGB(255, 255, 255),
        outlineTransparency = 0
    }

    do
        -- Aimbot Tab
        local AimbotEnabled = Tabs.Aimbot:AddToggle("AimbotEnabled", {
            Title = "Enabled",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.enabled = Value
            end
        })

        local AimbotTeam = Tabs.Aimbot:AddToggle("TeamCheck", {
            Title = "Team Check",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.teamCheck = Value
            end
        })

        local AimbotFOV = Tabs.Aimbot:AddToggle("ShowFOV", {
            Title = "Show FOV",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.drawFOV = Value
            end
        })

        local AimbotFOVSlider = Tabs.Aimbot:AddSlider("FOV", {
            Title = "FOV",
            Description = "Field of View radius",
            Default = 100,
            Min = 10,
            Max = 800,
            Rounding = 0,
            Callback = function(Value)
                _G.aimbotSettings.fov = Value
            end
        })

        local AimbotSensitivitySlider = Tabs.Aimbot:AddSlider("Sensitivity", {
            Title = "Sensitivity",
            Description = "Aim smoothness",
            Default = 1,
            Min = 0.1,
            Max = 2,
            Rounding = 2,
            Callback = function(Value)
                _G.aimbotSettings.sensitivity = Value
            end
        })

        local AimbotTargetPart = Tabs.Aimbot:AddDropdown("TargetPart", {
            Title = "Target Part",
            Values = {"Head", "Torso"},
            Default = "Head",
            Multi = false,
            Callback = function(Value)
                _G.aimbotSettings.lockPart = Value
            end
        })

        local AimbotWallCheck = Tabs.Aimbot:AddToggle("WallCheck", {
            Title = "Wall Check",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.wallCheck = Value
            end
        })

        local AimbotAliveCheck = Tabs.Aimbot:AddToggle("AliveCheck", {
            Title = "Alive Check",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.aliveCheck = Value
            end
        })

        -- Hitboxes Tab
        local HitboxEnabled = Tabs.Hitboxes:AddToggle("HitboxEnabled", {
            Title = "Enabled",
            Default = false,
            Callback = function(Value)
                _G.hitboxSettings.enabled = Value
            end
        })

        local HitboxTargetPart = Tabs.Hitboxes:AddDropdown("HitboxPart", {
            Title = "Target Part",
            Values = {"Head", "Torso"},
            Default = "Head",
            Multi = false,
            Callback = function(Value)
                _G.hitboxSettings.targetPart = Value
            end
        })

        local HitboxSize = Tabs.Hitboxes:AddSlider("HitboxSize", {
            Title = "Hitbox Size",
            Description = "Size multiplier",
            Default = 8,
            Min = 1,
            Max = 20,
            Rounding = 1,
            Callback = function(Value)
                _G.hitboxSettings.size = Value
            end
        })

        local HitboxTransparency = Tabs.Hitboxes:AddSlider("HitboxTransparency", {
            Title = "Transparency",
            Description = "Hitbox transparency",
            Default = 0.7,
            Min = 0,
            Max = 1,
            Rounding = 2,
            Callback = function(Value)
                _G.hitboxSettings.transparency = Value
            end
        })

        -- Highlight Tab
        local HighlightEnabled = Tabs.Highlight:AddToggle("HighlightEnabled", {
            Title = "Enabled",
            Default = false,
            Callback = function(Value)
                _G.highlightSettings.enabled = Value
                _G.updateHighlights()
            end
        })

        local HighlightTeam = Tabs.Highlight:AddToggle("HighlightTeamCheck", {
            Title = "Team Check",
            Default = false,
            Callback = function(Value)
                _G.highlightSettings.teamCheck = Value
                _G.updateHighlights()
            end
        })

        local HighlightTeamColor = Tabs.Highlight:AddToggle("AutoTeamColor", {
            Title = "Auto Team Color",
            Default = false,
            Callback = function(Value)
                _G.highlightSettings.autoTeamColor = Value
                _G.updateHighlights()
            end
        })

        local HighlightFillColor = Tabs.Highlight:AddColorpicker("FillColor", {
            Title = "Fill Color",
            Default = Color3.fromRGB(255, 0, 0),
            Callback = function(Value)
                _G.highlightSettings.fillColor = Value
                _G.updateHighlights()
            end
        })

        local HighlightFillTransparency = Tabs.Highlight:AddSlider("FillTransparency", {
            Title = "Fill Transparency",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Rounding = 2,
            Callback = function(Value)
                _G.highlightSettings.fillTransparency = Value
                _G.updateHighlights()
            end
        })

        local HighlightOutlineColor = Tabs.Highlight:AddColorpicker("OutlineColor", {
            Title = "Outline Color",
            Default = Color3.fromRGB(255, 255, 255),
            Callback = function(Value)
                _G.highlightSettings.outlineColor = Value
                _G.updateHighlights()
            end
        })

        local HighlightOutlineTransparency = Tabs.Highlight:AddSlider("OutlineTransparency", {
            Title = "Outline Transparency",
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

    -- Initialize modules with error handling
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

    -- Hand the library over to our managers
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)

    -- Ignore keys that are used by ThemeManager
    SaveManager:IgnoreThemeSettings()

    -- You can add indexes of elements the save manager should ignore
    SaveManager:SetIgnoreIndexes({})

    -- Set folders for configs
    InterfaceManager:SetFolder("IAHubConfig")
    SaveManager:SetFolder("IAHubConfig/GameSpecific")

    -- Build interface sections
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- Select first tab
    Window:SelectTab(1)

    -- Show loaded notification
    Fluent:Notify({
        Title = "IAHub Loaded",
        Content = "v1.0 Alpha by EntonioDMI",
        Duration = 5
    })

    -- Load auto save config
    SaveManager:LoadAutoloadConfig()
end
