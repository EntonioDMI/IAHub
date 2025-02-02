return function()
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

    -- Initialize settings if they don't exist
    if not _G.aimbotSettings then
        _G.aimbotSettings = {
            enabled = false,
            teamCheck = true,
            aliveCheck = true,
            wallCheck = true,
            triggerKey = Enum.UserInputType.MouseButton2,
            lockPart = "Head",
            sensitivity = 0.5,
            fov = 100,
            drawFOV = true
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
            teamCheck = true,
            fillColor = Color3.fromRGB(255, 0, 0),
            outlineColor = Color3.fromRGB(255, 255, 255),
            fillTransparency = 0.5,
            outlineTransparency = 0,
            autoTeamColor = true
        }
    end

    local Window = Fluent:CreateWindow({
        Title = "IAHub Professional",
        SubTitle = "by EntonioDMI",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl
    })

    -- Tabs
    local Tabs = {
        Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
        Hitboxes = Window:AddTab({ Title = "Hitboxes", Icon = "box" }),
        Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "sliders" })
    }

    -- Aimbot Tab
    local AimbotSection = Tabs.Aimbot:AddSection("Aimbot Configuration")

    AimbotSection:AddToggle("AimbotEnabled", {
        Title = "Enable Aimbot",
        Description = "Toggles the aimbot functionality",
        Default = _G.aimbotSettings.enabled,
        Callback = function(Value)
            _G.aimbotSettings.enabled = Value
        end
    })

    AimbotSection:AddToggle("TeamCheck", {
        Title = "Team Check",
        Description = "Prevents targeting teammates",
        Default = _G.aimbotSettings.teamCheck,
        Callback = function(Value)
            _G.aimbotSettings.teamCheck = Value
        end
    })

    AimbotSection:AddToggle("WallCheck", {
        Title = "Wall Check",
        Description = "Prevents targeting through walls",
        Default = _G.aimbotSettings.wallCheck,
        Callback = function(Value)
            _G.aimbotSettings.wallCheck = Value
        end
    })

    AimbotSection:AddDropdown("LockPart", {
        Title = "Target Part",
        Description = "Select which part to target",
        Values = {"Head", "Torso"},
        Default = _G.aimbotSettings.lockPart,
        Multi = false,
        Callback = function(Value)
            _G.aimbotSettings.lockPart = Value
        end
    })

    AimbotSection:AddSlider("Sensitivity", {
        Title = "Sensitivity",
        Description = "Adjust aimbot smoothness",
        Default = _G.aimbotSettings.sensitivity * 100,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            _G.aimbotSettings.sensitivity = Value / 100
        end
    })

    AimbotSection:AddSlider("FOV", {
        Title = "FOV Size",
        Description = "Adjust the Field of View size",
        Default = _G.aimbotSettings.fov,
        Min = 10,
        Max = 500,
        Rounding = 0,
        Callback = function(Value)
            _G.aimbotSettings.fov = Value
        end
    })

    AimbotSection:AddToggle("DrawFOV", {
        Title = "Show FOV Circle",
        Description = "Displays the FOV circle on screen",
        Default = _G.aimbotSettings.drawFOV,
        Callback = function(Value)
            _G.aimbotSettings.drawFOV = Value
        end
    })

    -- Hitboxes Tab
    local HitboxSection = Tabs.Hitboxes:AddSection("Hitbox Configuration")

    HitboxSection:AddToggle("HitboxEnabled", {
        Title = "Enable Hitboxes",
        Description = "Toggles custom hitbox sizes",
        Default = _G.hitboxSettings.enabled,
        Callback = function(Value)
            _G.hitboxSettings.enabled = Value
        end
    })

    HitboxSection:AddDropdown("HitboxPart", {
        Title = "Target Part",
        Description = "Select which part to modify",
        Values = {"Head", "Torso"},
        Default = _G.hitboxSettings.targetPart,
        Multi = false,
        Callback = function(Value)
            _G.hitboxSettings.targetPart = Value
        end
    })

    HitboxSection:AddSlider("HitboxSize", {
        Title = "Hitbox Size",
        Description = "Adjust the hitbox size",
        Default = _G.hitboxSettings.size,
        Min = 2,
        Max = 50,
        Rounding = 1,
        Callback = function(Value)
            _G.hitboxSettings.size = Value
        end
    })

    HitboxSection:AddSlider("HitboxTransparency", {
        Title = "Transparency",
        Description = "Adjust hitbox visibility",
        Default = _G.hitboxSettings.transparency * 100,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            _G.hitboxSettings.transparency = Value / 100
        end
    })

    HitboxSection:AddColorpicker("HitboxColor", {
        Title = "Hitbox Color",
        Description = "Change the hitbox color",
        Default = _G.hitboxSettings.color,
        Callback = function(Value)
            _G.hitboxSettings.color = Value
        end
    })

    -- Visuals Tab
    local VisualsSection = Tabs.Visuals:AddSection("ESP Configuration")

    VisualsSection:AddToggle("HighlightEnabled", {
        Title = "Enable ESP",
        Description = "Toggles player highlighting",
        Default = _G.highlightSettings.enabled,
        Callback = function(Value)
            _G.highlightSettings.enabled = Value
            if _G.updateHighlights then
                _G.updateHighlights()
            end
        end
    })

    VisualsSection:AddToggle("TeamCheck", {
        Title = "Team Check",
        Description = "Prevents highlighting teammates",
        Default = _G.highlightSettings.teamCheck,
        Callback = function(Value)
            _G.highlightSettings.teamCheck = Value
            if _G.updateHighlights then
                _G.updateHighlights()
            end
        end
    })

    VisualsSection:AddToggle("AutoTeamColor", {
        Title = "Auto Team Color",
        Description = "Uses team colors for highlighting",
        Default = _G.highlightSettings.autoTeamColor,
        Callback = function(Value)
            _G.highlightSettings.autoTeamColor = Value
            if _G.updateHighlights then
                _G.updateHighlights()
            end
        end
    })

    VisualsSection:AddColorpicker("FillColor", {
        Title = "Fill Color",
        Description = "Change the fill color",
        Default = _G.highlightSettings.fillColor,
        Callback = function(Value)
            _G.highlightSettings.fillColor = Value
            if _G.updateHighlights then
                _G.updateHighlights()
            end
        end
    })

    VisualsSection:AddColorpicker("OutlineColor", {
        Title = "Outline Color",
        Description = "Change the outline color",
        Default = _G.highlightSettings.outlineColor,
        Callback = function(Value)
            _G.highlightSettings.outlineColor = Value
            if _G.updateHighlights then
                _G.updateHighlights()
            end
        end
    })

    VisualsSection:AddSlider("FillTransparency", {
        Title = "Fill Transparency",
        Description = "Adjust fill transparency",
        Default = _G.highlightSettings.fillTransparency * 100,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            _G.highlightSettings.fillTransparency = Value / 100
            if _G.updateHighlights then
                _G.updateHighlights()
            end
        end
    })

    VisualsSection:AddSlider("OutlineTransparency", {
        Title = "Outline Transparency",
        Description = "Adjust outline transparency",
        Default = _G.highlightSettings.outlineTransparency * 100,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(Value)
            _G.highlightSettings.outlineTransparency = Value / 100
            if _G.updateHighlights then
                _G.updateHighlights()
            end
        end
    })

    -- Settings Tab
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
end
