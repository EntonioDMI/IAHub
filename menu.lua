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
        transparency = 0.7,
        color = Color3.fromRGB(0, 170, 255)
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
            Title = "🎯 Precision Mode",
            Description = "Unleash your inner pro gamer with pixel-perfect precision!",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.enabled = Value
            end
        })

        local AimbotTeam = Tabs.Aimbot:AddToggle("TeamCheck", {
            Title = "👥 Friend or Foe",
            Description = "Don't accidentally target your teammates, unless they deserve it 😉",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.teamCheck = Value
            end
        })

        local AimbotFOV = Tabs.Aimbot:AddToggle("ShowFOV", {
            Title = "👁️ Vision Circle",
            Description = "See your targeting zone, like a predator marking their territory",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.drawFOV = Value
            end
        })

        local AimbotFOVSlider = Tabs.Aimbot:AddSlider("FOV", {
            Title = "🎯 Targeting Range",
            Description = "How far can you see? Adjust your vision like a hawk!",
            Default = 100,
            Min = 10,
            Max = 800,
            Rounding = 0,
            Callback = function(Value)
                _G.aimbotSettings.fov = Value
            end
        })

        local AimbotSensitivitySlider = Tabs.Aimbot:AddSlider("Sensitivity", {
            Title = "🎮 Smoothness",
            Description = "From robot to human-like movements. Be sneaky!",
            Default = 1,
            Min = 0.1,
            Max = 2,
            Rounding = 2,
            Callback = function(Value)
                _G.aimbotSettings.sensitivity = Value
            end
        })

        local AimbotTargetPart = Tabs.Aimbot:AddDropdown("TargetPart", {
            Title = "🎯 Sweet Spot",
            Description = "Choose your target - head for pros, torso for consistency",
            Values = {"Head", "Torso"},
            Default = "Head",
            Multi = false,
            Callback = function(Value)
                _G.aimbotSettings.lockPart = Value
            end
        })

        local AimbotWallCheck = Tabs.Aimbot:AddToggle("WallCheck", {
            Title = "🧱 Wall Awareness",
            Description = "Don't be that person who shoots through walls!",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.wallCheck = Value
            end
        })

        local AimbotAliveCheck = Tabs.Aimbot:AddToggle("AliveCheck", {
            Title = "💀 Vitality Check",
            Description = "Stop shooting at corpses, they're already dead!",
            Default = false,
            Callback = function(Value)
                _G.aimbotSettings.aliveCheck = Value
            end
        })

        -- Hitboxes Tab
        local HitboxEnabled = Tabs.Hitboxes:AddToggle("HitboxEnabled", {
            Title = "📦 Hitbox Enhancement",
            Description = "Make those tiny targets not so tiny anymore!",
            Default = false,
            Callback = function(Value)
                _G.hitboxSettings.enabled = Value
            end
        })

        local HitboxTargetPart = Tabs.Hitboxes:AddDropdown("HitboxPart", {
            Title = "🎯 Target Zone",
            Description = "Pick your preferred hitting spot - choose wisely!",
            Values = {"Head", "Torso"},
            Default = "Head",
            Multi = false,
            Callback = function(Value)
                _G.hitboxSettings.targetPart = Value
            end
        })

        local HitboxSize = Tabs.Hitboxes:AddSlider("HitboxSize", {
            Title = "📏 Size Matters",
            Description = "From pixel to planet - how big do you want it?",
            Default = 8,
            Min = 1,
            Max = 20,
            Rounding = 1,
            Callback = function(Value)
                _G.hitboxSettings.size = Value
            end
        })

        local HitboxTransparency = Tabs.Hitboxes:AddSlider("HitboxTransparency", {
            Title = "👻 Ghost Mode",
            Description = "Make it invisible or show off your advantage!",
            Default = 0.7,
            Min = 0,
            Max = 1,
            Rounding = 2,
            Callback = function(Value)
                _G.hitboxSettings.transparency = Value
            end
        })

        local HitboxColor = Tabs.Hitboxes:AddColorpicker("HitboxColor", {
            Title = "🎨 Hitbox Color",
            Description = "Choose your favorite color for the hitbox!",
            Default = Color3.fromRGB(0, 170, 255),
            Callback = function(Value)
                _G.hitboxSettings.color = Value
            end
        })

        -- Highlight Tab
        local HighlightEnabled = Tabs.Highlight:AddToggle("HighlightEnabled", {
            Title = "✨ Glow Up",
            Description = "Make enemies shine like Christmas trees!",
            Default = false,
            Callback = function(Value)
                _G.highlightSettings.enabled = Value
                _G.updateHighlights()
            end
        })

        local HighlightTeam = Tabs.Highlight:AddToggle("HighlightTeamCheck", {
            Title = "🤝 Team Spirit",
            Description = "Don't make your teammates glow, they're already bright!",
            Default = false,
            Callback = function(Value)
                _G.highlightSettings.teamCheck = Value
                _G.updateHighlights()
            end
        })

        local HighlightTeamColor = Tabs.Highlight:AddToggle("AutoTeamColor", {
            Title = "🎨 Team Colors",
            Description = "Let the game decide the fashion show colors",
            Default = false,
            Callback = function(Value)
                _G.highlightSettings.autoTeamColor = Value
                _G.updateHighlights()
            end
        })

        local HighlightFillColor = Tabs.Highlight:AddColorpicker("FillColor", {
            Title = "🎨 Inner Glow",
            Description = "Paint your enemies in your favorite color!",
            Default = Color3.fromRGB(255, 0, 0),
            Callback = function(Value)
                _G.highlightSettings.fillColor = Value
                _G.updateHighlights()
            end
        })

        local HighlightFillTransparency = Tabs.Highlight:AddSlider("FillTransparency", {
            Title = "👻 Inner Ghost",
            Description = "Control how see-through the glow is",
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
            Title = "✏️ Outline Art",
            Description = "Give them a fancy border of your choice!",
            Default = Color3.fromRGB(255, 255, 255),
            Callback = function(Value)
                _G.highlightSettings.outlineColor = Value
                _G.updateHighlights()
            end
        })

        local HighlightOutlineTransparency = Tabs.Highlight:AddSlider("OutlineTransparency", {
            Title = "🌫️ Outline Fade",
            Description = "Make the outline pop or keep it subtle",
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
        Title = "✨ IAHub Loaded",
        Content = "Ready to rock! v1.0 Alpha by EntonioDMI",
        Duration = 5
    })

    -- Load auto save config
    SaveManager:LoadAutoloadConfig()
end
