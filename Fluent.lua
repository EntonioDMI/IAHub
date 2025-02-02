return function(Modules)
    if not Modules or not Modules.Fluent then
        warn("Required modules not loaded!")
        return
    end

    local Fluent = Modules.Fluent
    local SaveManager = Modules.SaveManager
    local InterfaceManager = Modules.InterfaceManager

    -- Initialize global settings if they don't exist
    if not _G.aimbotSettings then
        _G.aimbotSettings = {
            enabled = false,
            fov = 100,
            sensitivity = 0.5,
            lockPart = "Head",
            teamCheck = false,
            aliveCheck = false,
            wallCheck = false,
            triggerKey = Enum.UserInputType.MouseButton2,
            drawFOV = false
        }
    end

    if not _G.hitboxSettings then
        _G.hitboxSettings = {
            enabled = false,
            size = 8,
            transparency = 0.5,
            color = Color3.fromRGB(255, 0, 0),
            targetPart = "Head"
        }
    end

    if not _G.highlightSettings then
        _G.highlightSettings = {
            enabled = false,
            fillColor = Color3.fromRGB(255, 0, 0),
            outlineColor = Color3.fromRGB(255, 255, 255),
            fillTransparency = 0.5,
            outlineTransparency = 0,
            teamCheck = false,
            autoTeamColor = false
        }
    end

    -- Create Window
    local Window = Fluent:CreateWindow({
        Title = "IAHub Professional",
        SubTitle = "by EntonioDMI",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl
    })

    -- Create Tabs
    local Tabs = {
        Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
        Hitboxes = Window:AddTab({ Title = "Hitboxes", Icon = "box" }),
        Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "sliders" })
    }

    -- Aimbot Tab
    local AimbotToggle = Tabs.Aimbot:AddToggle("AimbotEnabled", {
        Title = "Enable Aimbot",
        Description = "Enhance your accuracy with advanced target tracking",
        Default = _G.aimbotSettings.enabled,
        Callback = function(Value)
            _G.aimbotSettings.enabled = Value
        end
    })

    local AimbotFOV = Tabs.Aimbot:AddSlider("AimbotFOV", {
        Title = "FOV",
        Description = "Adjust the field of view for target acquisition",
        Default = _G.aimbotSettings.fov,
        Min = 10,
        Max = 800,
        Rounding = 0,
        Callback = function(Value)
            _G.aimbotSettings.fov = Value
        end
    })

    local AimbotSensitivity = Tabs.Aimbot:AddSlider("AimbotSensitivity", {
        Title = "Sensitivity",
        Description = "Fine-tune the smoothness of aim assistance",
        Default = _G.aimbotSettings.sensitivity,
        Min = 0.1,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.aimbotSettings.sensitivity = Value
        end
    })

    local AimbotPartDropdown = Tabs.Aimbot:AddDropdown("AimbotPart", {
        Title = "Target Part",
        Description = "Select which body part to target",
        Values = {"Head", "Torso"},
        Default = _G.aimbotSettings.lockPart,
        Callback = function(Value)
            _G.aimbotSettings.lockPart = Value
        end
    })

    local AimbotTeamCheck = Tabs.Aimbot:AddToggle("AimbotTeamCheck", {
        Title = "Team Check",
        Description = "Prevent targeting teammates",
        Default = _G.aimbotSettings.teamCheck,
        Callback = function(Value)
            _G.aimbotSettings.teamCheck = Value
        end
    })

    local AimbotWallCheck = Tabs.Aimbot:AddToggle("AimbotWallCheck", {
        Title = "Wall Check",
        Description = "Only target visible players",
        Default = _G.aimbotSettings.wallCheck,
        Callback = function(Value)
            _G.aimbotSettings.wallCheck = Value
        end
    })

    local AimbotDrawFOV = Tabs.Aimbot:AddToggle("AimbotDrawFOV", {
        Title = "Show FOV Circle",
        Description = "Visualize your targeting range",
        Default = _G.aimbotSettings.drawFOV,
        Callback = function(Value)
            _G.aimbotSettings.drawFOV = Value
        end
    })

    -- Hitboxes Tab
    local HitboxToggle = Tabs.Hitboxes:AddToggle("HitboxEnabled", {
        Title = "Enable Hitboxes",
        Description = "Expand hit detection areas for better accuracy",
        Default = _G.hitboxSettings.enabled,
        Callback = function(Value)
            _G.hitboxSettings.enabled = Value
        end
    })

    local HitboxSize = Tabs.Hitboxes:AddSlider("HitboxSize", {
        Title = "Hitbox Size",
        Description = "Adjust the size of expanded hitboxes",
        Default = _G.hitboxSettings.size,
        Min = 2,
        Max = 20,
        Rounding = 1,
        Callback = function(Value)
            _G.hitboxSettings.size = Value
        end
    })

    local HitboxTransparency = Tabs.Hitboxes:AddSlider("HitboxTransparency", {
        Title = "Transparency",
        Description = "Control hitbox visibility",
        Default = _G.hitboxSettings.transparency,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.hitboxSettings.transparency = Value
        end
    })

    local HitboxColor = Tabs.Hitboxes:AddColorpicker("HitboxColor", {
        Title = "Hitbox Color",
        Description = "Customize hitbox appearance",
        Default = _G.hitboxSettings.color,
        Callback = function(Value)
            _G.hitboxSettings.color = Value
        end
    })

    local HitboxPartDropdown = Tabs.Hitboxes:AddDropdown("HitboxPart", {
        Title = "Target Part",
        Description = "Select which body part to expand",
        Values = {"Head", "Torso"},
        Default = _G.hitboxSettings.targetPart,
        Callback = function(Value)
            _G.hitboxSettings.targetPart = Value
        end
    })

    -- Visuals Tab (Highlight)
    local HighlightToggle = Tabs.Visuals:AddToggle("HighlightEnabled", {
        Title = "Enable ESP",
        Description = "Highlight players through walls",
        Default = _G.highlightSettings.enabled,
        Callback = function(Value)
            _G.highlightSettings.enabled = Value
            _G.updateHighlights()
        end
    })

    local HighlightFillColor = Tabs.Visuals:AddColorpicker("HighlightFillColor", {
        Title = "Fill Color",
        Description = "Set the main highlight color",
        Default = _G.highlightSettings.fillColor,
        Callback = function(Value)
            _G.highlightSettings.fillColor = Value
            _G.updateHighlights()
        end
    })

    local HighlightOutlineColor = Tabs.Visuals:AddColorpicker("HighlightOutlineColor", {
        Title = "Outline Color",
        Description = "Set the outline highlight color",
        Default = _G.highlightSettings.outlineColor,
        Callback = function(Value)
            _G.highlightSettings.outlineColor = Value
            _G.updateHighlights()
        end
    })

    local HighlightFillTransparency = Tabs.Visuals:AddSlider("HighlightFillTransparency", {
        Title = "Fill Transparency",
        Description = "Adjust fill visibility",
        Default = _G.highlightSettings.fillTransparency,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.highlightSettings.fillTransparency = Value
            _G.updateHighlights()
        end
    })

    local HighlightOutlineTransparency = Tabs.Visuals:AddSlider("HighlightOutlineTransparency", {
        Title = "Outline Transparency",
        Description = "Adjust outline visibility",
        Default = _G.highlightSettings.outlineTransparency,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            _G.highlightSettings.outlineTransparency = Value
            _G.updateHighlights()
        end
    })

    local HighlightTeamCheck = Tabs.Visuals:AddToggle("HighlightTeamCheck", {
        Title = "Team Check",
        Description = "Don't highlight teammates",
        Default = _G.highlightSettings.teamCheck,
        Callback = function(Value)
            _G.highlightSettings.teamCheck = Value
            _G.updateHighlights()
        end
    })

    local HighlightTeamColor = Tabs.Visuals:AddToggle("HighlightTeamColor", {
        Title = "Use Team Colors",
        Description = "Color highlights based on team",
        Default = _G.highlightSettings.autoTeamColor,
        Callback = function(Value)
            _G.highlightSettings.autoTeamColor = Value
            _G.updateHighlights()
        end
    })

    -- Initialize modules with their respective tabs
    if Modules.Aimbot then
        Modules.Aimbot(Fluent, Tabs.Aimbot)
    end

    if Modules.Hitboxes then
        Modules.Hitboxes(Fluent, Tabs.Hitboxes)
    end

    if Modules.Highlight then
        Modules.Highlight(Fluent, Tabs.Visuals)
    end

    if Modules.Misc then
        Modules.Misc(Fluent, Tabs.Misc)
    end

    -- Setup SaveManager and InterfaceManager
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    
    InterfaceManager:SetFolder("IAHub")
    SaveManager:SetFolder("IAHub/Configs")
    
    SaveManager:BuildConfigSection(Tabs.Settings)
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)

    -- Load saved settings
    SaveManager:LoadAutoloadConfig()

    -- Select default tab
    Window:SelectTab(1)

    return Window
end
