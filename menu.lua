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
        Main = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
        Hitboxes = Window:AddTab({ Title = "Hitboxes", Icon = "square" }),
        Highlight = Window:AddTab({ Title = "Highlight", Icon = "palette" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
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

    -- Aimbot Section
    local AimbotSection = Tabs.Main:AddSection("Aimbot Settings")

    local AimbotToggle = AimbotSection:AddToggle("AimbotEnabled", {
        Title = "✨ Enabled",
        Default = false,
        Callback = function(Value)
            _G.aimbotSettings.enabled = Value
        end
    })

    local TeamCheckToggle = AimbotSection:AddToggle("TeamCheck", {
        Title = "👥 Team Check",
        Default = false,
        Callback = function(Value)
            _G.aimbotSettings.teamCheck = Value
        end
    })

    local WallCheckToggle = AimbotSection:AddToggle("WallCheck", {
        Title = "🧱 Wall Check",
        Default = false,
        Callback = function(Value)
            _G.aimbotSettings.wallCheck = Value
        end
    })

    local ShowFOVToggle = AimbotSection:AddToggle("ShowFOV", {
        Title = "👁️ Show FOV",
        Default = false,
        Callback = function(Value)
            _G.aimbotSettings.drawFOV = Value
        end
    })

    local FOVSlider = AimbotSection:AddSlider("FOVSize", {
        Title = "🎯 FOV Size",
        Default = 100,
        Min = 10,
        Max = 800,
        Rounding = 0,
        Callback = function(Value)
            _G.aimbotSettings.fov = Value
        end
    })

    local SensitivitySlider = AimbotSection:AddSlider("Sensitivity", {
        Title = "🔍 Sensitivity",
        Default = 0.5,
        Min = 0.1,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.aimbotSettings.sensitivity = Value
        end
    })

    local TriggerKeyDropdown = AimbotSection:AddDropdown("TriggerKey", {
        Title = "🔑 Trigger Key",
        Values = {"Left Click", "Right Click"},
        Default = "Right Click",
        Multi = false,
        Callback = function(Value)
            _G.aimbotSettings.triggerKey = Value == "Left Click" and 
                Enum.UserInputType.MouseButton1 or 
                Enum.UserInputType.MouseButton2
        end
    })

    local LockPartDropdown = AimbotSection:AddDropdown("LockPart", {
        Title = "🎯 Lock Part",
        Values = {"Head", "Torso"},
        Default = "Head",
        Multi = false,
        Callback = function(Value)
            _G.aimbotSettings.lockPart = Value
        end
    })

    -- Hitboxes Section
    local HitboxSection = Tabs.Hitboxes:AddSection("Hitbox Settings")

    local HitboxToggle = HitboxSection:AddToggle("HitboxEnabled", {
        Title = "📦 Enabled",
        Default = false,
        Callback = function(Value)
            _G.hitboxSettings.enabled = Value
        end
    })

    local HitboxPartDropdown = HitboxSection:AddDropdown("HitboxPart", {
        Title = "🎯 Target Part",
        Values = {"Head", "Torso"},
        Default = "Head",
        Multi = false,
        Callback = function(Value)
            _G.hitboxSettings.targetPart = Value
        end
    })

    local HitboxSizeSlider = HitboxSection:AddSlider("HitboxSize", {
        Title = "📏 Size",
        Default = 10,
        Min = 1,
        Max = 50,
        Rounding = 1,
        Callback = function(Value)
            _G.hitboxSettings.size = Value
        end
    })

    local HitboxTransparencySlider = HitboxSection:AddSlider("HitboxTransparency", {
        Title = "👻 Transparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.hitboxSettings.transparency = Value
        end
    })

    local HitboxColorPicker = HitboxSection:AddColorpicker("HitboxColor", {
        Title = "🎨 Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(Value)
            _G.hitboxSettings.color = Value
        end
    })

    -- Highlight Section
    local HighlightSection = Tabs.Highlight:AddSection("Highlight Settings")

    local HighlightToggle = HighlightSection:AddToggle("HighlightEnabled", {
        Title = "✨ Enabled",
        Default = false,
        Callback = function(Value)
            _G.highlightSettings.enabled = Value
            _G.updateHighlights()
        end
    })

    local HighlightTeamCheckToggle = HighlightSection:AddToggle("HighlightTeamCheck", {
        Title = "👥 Team Check",
        Default = false,
        Callback = function(Value)
            _G.highlightSettings.teamCheck = Value
            _G.updateHighlights()
        end
    })

    local AutoTeamColorToggle = HighlightSection:AddToggle("AutoTeamColor", {
        Title = "🎨 Auto Team Color",
        Default = true,
        Callback = function(Value)
            _G.highlightSettings.autoTeamColor = Value
            _G.updateHighlights()
        end
    })

    local FillColorPicker = HighlightSection:AddColorpicker("FillColor", {
        Title = "🎨 Fill Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(Value)
            _G.highlightSettings.fillColor = Value
            _G.updateHighlights()
        end
    })

    local OutlineColorPicker = HighlightSection:AddColorpicker("OutlineColor", {
        Title = "✏️ Outline Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            _G.highlightSettings.outlineColor = Value
            _G.updateHighlights()
        end
    })

    local FillTransparencySlider = HighlightSection:AddSlider("FillTransparency", {
        Title = "👻 Fill Transparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.highlightSettings.fillTransparency = Value
            _G.updateHighlights()
        end
    })

    local OutlineTransparencySlider = HighlightSection:AddSlider("OutlineTransparency", {
        Title = "👻 Outline Transparency",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.highlightSettings.outlineTransparency = Value
            _G.updateHighlights()
        end
    })

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

    -- Save Manager
    local SaveManager = Modules.SaveManager
    if SaveManager then
        SaveManager:SetLibrary(Fluent)
        SaveManager:SetFolder("IAHub")
        SaveManager:BuildConfigSection(Tabs.Settings)
    end

    -- Interface Manager
    local InterfaceManager = Modules.InterfaceManager
    if InterfaceManager then
        InterfaceManager:SetLibrary(Fluent)
        InterfaceManager:SetFolder("IAHub")
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    end

    -- Select Main Tab by default
    Window:SelectTab(1)
end
