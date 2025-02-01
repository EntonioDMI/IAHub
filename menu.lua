return function(Modules)
    local Fluent = Modules.Fluent
    if not Fluent then
        warn("Fluent UI module not found!")
        return
    end

    local SaveManager = Modules.SaveManager
    local InterfaceManager = Modules.InterfaceManager

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
        Main = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
        Hitboxes = Window:AddTab({ Title = "Hitboxes", Icon = "square" }),
        Highlight = Window:AddTab({ Title = "Highlight", Icon = "palette" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    local Options = Fluent.Options

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
        -- Aimbot Section
        local AimbotToggle = Tabs.Main:AddToggle("AimbotEnabled", {
            Title = "✨ Enabled",
            Default = false
        })

        AimbotToggle:OnChanged(function()
            _G.aimbotSettings.enabled = Options.AimbotEnabled.Value
        end)

        local TeamCheckToggle = Tabs.Main:AddToggle("TeamCheck", {
            Title = "👥 Team Check",
            Default = false
        })

        TeamCheckToggle:OnChanged(function()
            _G.aimbotSettings.teamCheck = Options.TeamCheck.Value
        end)

        local WallCheckToggle = Tabs.Main:AddToggle("WallCheck", {
            Title = "🧱 Wall Check",
            Default = false
        })

        WallCheckToggle:OnChanged(function()
            _G.aimbotSettings.wallCheck = Options.WallCheck.Value
        end)

        local ShowFOVToggle = Tabs.Main:AddToggle("ShowFOV", {
            Title = "👁️ Show FOV",
            Default = false
        })

        ShowFOVToggle:OnChanged(function()
            _G.aimbotSettings.drawFOV = Options.ShowFOV.Value
        end)

        local FOVSlider = Tabs.Main:AddSlider("FOVSize", {
            Title = "🎯 FOV Size",
            Default = 100,
            Min = 10,
            Max = 800,
            Rounding = 0
        })

        FOVSlider:OnChanged(function()
            _G.aimbotSettings.fov = Options.FOVSize.Value
        end)

        local SensitivitySlider = Tabs.Main:AddSlider("Sensitivity", {
            Title = "🔍 Sensitivity",
            Default = 0.5,
            Min = 0.1,
            Max = 1,
            Rounding = 2
        })

        SensitivitySlider:OnChanged(function()
            _G.aimbotSettings.sensitivity = Options.Sensitivity.Value
        end)

        local TriggerKeyDropdown = Tabs.Main:AddDropdown("TriggerKey", {
            Title = "🔑 Trigger Key",
            Values = {"Left Click", "Right Click"},
            Default = "Right Click",
            Multi = false
        })

        TriggerKeyDropdown:OnChanged(function()
            _G.aimbotSettings.triggerKey = Options.TriggerKey.Value == "Left Click" and 
                Enum.UserInputType.MouseButton1 or 
                Enum.UserInputType.MouseButton2
        end)

        local LockPartDropdown = Tabs.Main:AddDropdown("LockPart", {
            Title = "🎯 Lock Part",
            Values = {"Head", "Torso"},
            Default = "Head",
            Multi = false
        })

        LockPartDropdown:OnChanged(function()
            _G.aimbotSettings.lockPart = Options.LockPart.Value
        end)

        -- Hitboxes Section
        local HitboxToggle = Tabs.Hitboxes:AddToggle("HitboxEnabled", {
            Title = "📦 Enabled",
            Default = false
        })

        HitboxToggle:OnChanged(function()
            _G.hitboxSettings.enabled = Options.HitboxEnabled.Value
        end)

        local HitboxPartDropdown = Tabs.Hitboxes:AddDropdown("HitboxPart", {
            Title = "🎯 Target Part",
            Values = {"Head", "Torso"},
            Default = "Head",
            Multi = false
        })

        HitboxPartDropdown:OnChanged(function()
            _G.hitboxSettings.targetPart = Options.HitboxPart.Value
        end)

        local HitboxSizeSlider = Tabs.Hitboxes:AddSlider("HitboxSize", {
            Title = "📏 Size",
            Default = 10,
            Min = 1,
            Max = 50,
            Rounding = 1
        })

        HitboxSizeSlider:OnChanged(function()
            _G.hitboxSettings.size = Options.HitboxSize.Value
        end)

        local HitboxTransparencySlider = Tabs.Hitboxes:AddSlider("HitboxTransparency", {
            Title = "👻 Transparency",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Rounding = 2
        })

        HitboxTransparencySlider:OnChanged(function()
            _G.hitboxSettings.transparency = Options.HitboxTransparency.Value
        end)

        local HitboxColorPicker = Tabs.Hitboxes:AddColorpicker("HitboxColor", {
            Title = "🎨 Color",
            Default = Color3.fromRGB(255, 0, 0)
        })

        HitboxColorPicker:OnChanged(function()
            _G.hitboxSettings.color = Options.HitboxColor.Value
        end)

        -- Highlight Section
        local HighlightToggle = Tabs.Highlight:AddToggle("HighlightEnabled", {
            Title = "✨ Enabled",
            Default = false
        })

        HighlightToggle:OnChanged(function()
            _G.highlightSettings.enabled = Options.HighlightEnabled.Value
            _G.updateHighlights()
        end)

        local HighlightTeamCheckToggle = Tabs.Highlight:AddToggle("HighlightTeamCheck", {
            Title = "👥 Team Check",
            Default = false
        })

        HighlightTeamCheckToggle:OnChanged(function()
            _G.highlightSettings.teamCheck = Options.HighlightTeamCheck.Value
            _G.updateHighlights()
        end)

        local AutoTeamColorToggle = Tabs.Highlight:AddToggle("AutoTeamColor", {
            Title = "🎨 Auto Team Color",
            Default = true
        })

        AutoTeamColorToggle:OnChanged(function()
            _G.highlightSettings.autoTeamColor = Options.AutoTeamColor.Value
            _G.updateHighlights()
        end)

        local FillColorPicker = Tabs.Highlight:AddColorpicker("FillColor", {
            Title = "🎨 Fill Color",
            Default = Color3.fromRGB(255, 0, 0)
        })

        FillColorPicker:OnChanged(function()
            _G.highlightSettings.fillColor = Options.FillColor.Value
            _G.updateHighlights()
        end)

        local OutlineColorPicker = Tabs.Highlight:AddColorpicker("OutlineColor", {
            Title = "✏️ Outline Color",
            Default = Color3.fromRGB(255, 255, 255)
        })

        OutlineColorPicker:OnChanged(function()
            _G.highlightSettings.outlineColor = Options.OutlineColor.Value
            _G.updateHighlights()
        end)

        local FillTransparencySlider = Tabs.Highlight:AddSlider("FillTransparency", {
            Title = "👻 Fill Transparency",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Rounding = 2
        })

        FillTransparencySlider:OnChanged(function()
            _G.highlightSettings.fillTransparency = Options.FillTransparency.Value
            _G.updateHighlights()
        end)

        local OutlineTransparencySlider = Tabs.Highlight:AddSlider("OutlineTransparency", {
            Title = "👻 Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Rounding = 2
        })

        OutlineTransparencySlider:OnChanged(function()
            _G.highlightSettings.outlineTransparency = Options.OutlineTransparency.Value
            _G.updateHighlights()
        end)

        -- Load modules
        if Modules.Aimbot then
            Modules.Aimbot(Fluent, Tabs.Main)
        end

        if Modules.Hitboxes then
            Modules.Hitboxes(Fluent, Tabs.Hitboxes)
        end

        if Modules.Highlight then
            Modules.Highlight(Fluent, Tabs.Highlight)
        end

        if Modules.Misc then
            Modules.Misc(Fluent, Tabs.Settings)
        end
    end

    -- Save Manager
    if SaveManager then
        SaveManager:SetLibrary(Fluent)
        SaveManager:SetFolder("IAHub")
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        SaveManager:BuildConfigSection(Tabs.Settings)
    end

    -- Interface Manager
    if InterfaceManager then
        InterfaceManager:SetLibrary(Fluent)
        InterfaceManager:SetFolder("IAHub")
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    end

    -- Select Main Tab by default
    Window:SelectTab(1)

    -- Show welcome notification
    Fluent:Notify({
        Title = "IAHub",
        Content = "The script has been loaded.",
        Duration = 8
    })

    -- Load auto save config
    if SaveManager then
        SaveManager:LoadAutoloadConfig()
    end
end
