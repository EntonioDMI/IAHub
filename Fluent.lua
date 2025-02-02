return function(Modules)
    if not Modules or not Modules.Fluent then
        warn("Required modules not loaded!")
        return
    end

    local Fluent = Modules.Fluent
    local SaveManager = Modules.SaveManager
    local InterfaceManager = Modules.InterfaceManager

    -- Initialize global settings
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
            targetPart = "Torso",
            npcEnabled = false,
            bossEnabled = false
        }
    end

    if not _G.highlightSettings then
        _G.highlightSettings = {
            enabled = false,
            fillColor = Color3.fromRGB(255, 0, 0),
            outlineColor = Color3.fromRGB(255, 255, 255),
            fillTransparency = 0.5,
            outlineTransparency = 0.5,
            teamCheck = false,
            autoTeamColor = false,
            npcEnabled = false,
            bossEnabled = false,
            npcColor = Color3.fromRGB(255, 165, 0),
            bossColor = Color3.fromRGB(255, 0, 0)
        }
    end

    if not _G.miscSettings then
        _G.miscSettings = {
            showItems = false
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
        Friends = Window:AddTab({ Title = "Friends", Icon = "users" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "sliders" })
    }

    -- Show warnings
    Tabs.Hitboxes:AddParagraph({
        Title = "⚠️ Warning",
        Content = "Head hitbox modification may not work correctly in many games. It's recommended to use Torso instead for better compatibility."
    })

    Tabs.Aimbot:AddParagraph({
        Title = "⚠️ Warning",
        Content = "Wall Check feature may cause performance issues in some games due to complex ray casting calculations. Disable it if you experience lag."
    })

    -- [Previous Aimbot Tab code remains unchanged]

    -- Hitboxes Tab
    local HitboxSection = Tabs.Hitboxes:AddSection("Player Hitboxes")
    
    local HitboxToggle = HitboxSection:AddToggle("HitboxEnabled", {
        Title = "Enable Player Hitboxes",
        Description = "Expand hit detection areas for players",
        Default = _G.hitboxSettings.enabled,
        Callback = function(Value)
            _G.hitboxSettings.enabled = Value
        end
    })

    local NPCHitboxSection = Tabs.Hitboxes:AddSection("NPC Hitboxes")
    
    local NPCHitboxToggle = NPCHitboxSection:AddToggle("NPCHitboxEnabled", {
        Title = "Enable NPC Hitboxes",
        Description = "Expand hit detection areas for regular NPCs",
        Default = _G.hitboxSettings.npcEnabled,
        Callback = function(Value)
            _G.hitboxSettings.npcEnabled = Value
        end
    })

    local BossHitboxToggle = NPCHitboxSection:AddToggle("BossHitboxEnabled", {
        Title = "Enable Boss Hitboxes",
        Description = "Expand hit detection areas for boss NPCs",
        Default = _G.hitboxSettings.bossEnabled,
        Callback = function(Value)
            _G.hitboxSettings.bossEnabled = Value
        end
    })

    -- [Previous Hitbox settings code remains unchanged]

    -- Visuals Tab
    local HighlightSection = Tabs.Visuals:AddSection("Player ESP")
    
    local HighlightToggle = HighlightSection:AddToggle("HighlightEnabled", {
        Title = "Enable Player ESP",
        Description = "Highlight players through walls",
        Default = _G.highlightSettings.enabled,
        Callback = function(Value)
            _G.highlightSettings.enabled = Value
            _G.updateHighlights()
        end
    })

    local NPCHighlightSection = Tabs.Visuals:AddSection("NPC ESP")
    
    local NPCHighlightToggle = NPCHighlightSection:AddToggle("NPCHighlightEnabled", {
        Title = "Enable NPC ESP",
        Description = "Highlight regular NPCs through walls",
        Default = _G.highlightSettings.npcEnabled,
        Callback = function(Value)
            _G.highlightSettings.npcEnabled = Value
            _G.updateHighlights()
        end
    })

    local NPCColorPicker = NPCHighlightSection:AddColorpicker("NPCColor", {
        Title = "NPC Color",
        Description = "Set the color for NPC highlights",
        Default = _G.highlightSettings.npcColor,
        Callback = function(Value)
            _G.highlightSettings.npcColor = Value
            _G.updateHighlights()
        end
    })

    local BossHighlightToggle = NPCHighlightSection:AddToggle("BossHighlightEnabled", {
        Title = "Enable Boss ESP",
        Description = "Highlight boss NPCs through walls",
        Default = _G.highlightSettings.bossEnabled,
        Callback = function(Value)
            _G.highlightSettings.bossEnabled = Value
            _G.updateHighlights()
        end
    })

    local BossColorPicker = NPCHighlightSection:AddColorpicker("BossColor", {
        Title = "Boss Color",
        Description = "Set the color for boss highlights",
        Default = _G.highlightSettings.bossColor,
        Callback = function(Value)
            _G.highlightSettings.bossColor = Value
            _G.updateHighlights()
        end
    })

    -- [Previous Highlight settings code remains unchanged]

    -- Misc Tab
    local ItemDisplayToggle = Tabs.Misc:AddToggle("ShowItems", {
        Title = "Show Player Items",
        Description = "Display items above players' heads",
        Default = _G.miscSettings.showItems,
        Callback = function(Value)
            _G.miscSettings.showItems = Value
            if _G.updateItemDisplay then
                _G.updateItemDisplay()
            end
        end
    })

    -- [Rest of the code remains unchanged]

    return Window
end
