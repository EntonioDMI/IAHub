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

    -- Aimbot Tab
    do
        local AimbotTab = Tabs.Aimbot
        local Toggle = AimbotTab:AddToggle("AimbotEnabled", {Title = "Enabled", Default = false })
        Toggle:OnChanged(function()
            _G.aimbotSettings.enabled = Options.AimbotEnabled.Value
        end)

        local TeamToggle = AimbotTab:AddToggle("TeamCheck", {Title = "Team Check", Default = false})
        TeamToggle:OnChanged(function()
            _G.aimbotSettings.teamCheck = Options.TeamCheck.Value
        end)

        local FOVToggle = AimbotTab:AddToggle("ShowFOV", {Title = "Show FOV", Default = false})
        FOVToggle:OnChanged(function()
            _G.aimbotSettings.drawFOV = Options.ShowFOV.Value
        end)

        local FOVSlider = AimbotTab:AddSlider("FOV", {
            Title = "FOV",
            Description = "Field of View radius",
            Default = 100,
            Min = 10,
            Max = 800,
            Rounding = 0,
        })

        FOVSlider:OnChanged(function()
            _G.aimbotSettings.fov = Options.FOV.Value
        end)

        local SensitivitySlider = AimbotTab:AddSlider("Sensitivity", {
            Title = "Sensitivity",
            Description = "Aim smoothness",
            Default = 1,
            Min = 0.1,
            Max = 2,
            Rounding = 2,
        })

        SensitivitySlider:OnChanged(function()
            _G.aimbotSettings.sensitivity = Options.Sensitivity.Value
        end)

        local TargetPartDropdown = AimbotTab:AddDropdown("TargetPart", {
            Title = "Target Part",
            Values = {"Head", "Torso"},
            Default = "Head",
        })

        TargetPartDropdown:OnChanged(function()
            _G.aimbotSettings.lockPart = Options.TargetPart.Value
        end)

        local WallCheckToggle = AimbotTab:AddToggle("WallCheck", {Title = "Wall Check", Default = false})
        WallCheckToggle:OnChanged(function()
            _G.aimbotSettings.wallCheck = Options.WallCheck.Value
        end)

        local AliveCheckToggle = AimbotTab:AddToggle("AliveCheck", {Title = "Alive Check", Default = false})
        AliveCheckToggle:OnChanged(function()
            _G.aimbotSettings.aliveCheck = Options.AliveCheck.Value
        end)
    end

    -- Hitboxes Tab
    do
        local HitboxTab = Tabs.Hitboxes
        local Toggle = HitboxTab:AddToggle("HitboxEnabled", {Title = "Enabled", Default = false})
        Toggle:OnChanged(function()
            _G.hitboxSettings.enabled = Options.HitboxEnabled.Value
        end)

        local TargetPartDropdown = HitboxTab:AddDropdown("HitboxPart", {
            Title = "Target Part",
            Values = {"Head", "Torso"},
            Default = "Head",
        })

        TargetPartDropdown:OnChanged(function()
            _G.hitboxSettings.targetPart = Options.HitboxPart.Value
        end)

        local SizeSlider = HitboxTab:AddSlider("HitboxSize", {
            Title = "Hitbox Size",
            Description = "Size multiplier",
            Default = 8,
            Min = 1,
            Max = 20,
            Rounding = 1,
        })

        SizeSlider:OnChanged(function()
            _G.hitboxSettings.size = Options.HitboxSize.Value
        end)

        local TransparencySlider = HitboxTab:AddSlider("HitboxTransparency", {
            Title = "Transparency",
            Description = "Hitbox transparency",
            Default = 0.7,
            Min = 0,
            Max = 1,
            Rounding = 2,
        })

        TransparencySlider:OnChanged(function()
            _G.hitboxSettings.transparency = Options.HitboxTransparency.Value
        end)
    end

    -- Highlight Tab
    do
        local HighlightTab = Tabs.Highlight
        local Toggle = HighlightTab:AddToggle("HighlightEnabled", {Title = "Enabled", Default = false})
        Toggle:OnChanged(function()
            _G.highlightSettings.enabled = Options.HighlightEnabled.Value
            _G.updateHighlights()
        end)

        local TeamToggle = HighlightTab:AddToggle("HighlightTeamCheck", {Title = "Team Check", Default = false})
        TeamToggle:OnChanged(function()
            _G.highlightSettings.teamCheck = Options.HighlightTeamCheck.Value
            _G.updateHighlights()
        end)

        local TeamColorToggle = HighlightTab:AddToggle("AutoTeamColor", {Title = "Auto Team Color", Default = false})
        TeamColorToggle:OnChanged(function()
            _G.highlightSettings.autoTeamColor = Options.AutoTeamColor.Value
            _G.updateHighlights()
        end)

        local FillColorPicker = HighlightTab:AddColorpicker("FillColor", {
            Title = "Fill Color",
            Default = Color3.fromRGB(255, 0, 0)
        })

        FillColorPicker:OnChanged(function()
            _G.highlightSettings.fillColor = Options.FillColor.Value
            _G.updateHighlights()
        end)

        local FillTransparencySlider = HighlightTab:AddSlider("FillTransparency", {
            Title = "Fill Transparency",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Rounding = 2,
        })

        FillTransparencySlider:OnChanged(function()
            _G.highlightSettings.fillTransparency = Options.FillTransparency.Value
            _G.updateHighlights()
        end)

        local OutlineColorPicker = HighlightTab:AddColorpicker("OutlineColor", {
            Title = "Outline Color",
            Default = Color3.fromRGB(255, 255, 255)
        })

        OutlineColorPicker:OnChanged(function()
            _G.highlightSettings.outlineColor = Options.OutlineColor.Value
            _G.updateHighlights()
        end)

        local OutlineTransparencySlider = HighlightTab:AddSlider("OutlineTransparency", {
            Title = "Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Rounding = 2,
        })

        OutlineTransparencySlider:OnChanged(function()
            _G.highlightSettings.outlineTransparency = Options.OutlineTransparency.Value
            _G.updateHighlights()
        end)
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

    -- Setup save manager and interface manager
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("IAHubConfig")
    SaveManager:SetFolder("IAHubConfig/GameSpecific")

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
