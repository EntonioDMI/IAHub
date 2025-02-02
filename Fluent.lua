return function(Modules)
    local Fluent = Modules.Fluent
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
        MinimizeKey = Enum.KeyCode.End
    })

    -- Create tabs
    local Tabs = {
        Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
        Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
        Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- Initialize settings
    _G.aimbotSettings = {
        enabled = false,
        teamCheck = true,
        aliveCheck = true,
        wallCheck = false,
        lockPart = "Head",
        fov = 100,
        sensitivity = 0.5,
        triggerKey = Enum.UserInputType.MouseButton2,
        drawFOV = true
    }

    _G.hitboxSettings = {
        enabled = false,
        npcEnabled = false,
        bossEnabled = false,
        teamCheck = true,
        targetPart = "HumanoidRootPart",
        size = 10,
        transparency = 0.5,
        color = Color3.fromRGB(255, 0, 0)
    }

    _G.highlightSettings = {
        enabled = false,
        npcEnabled = false,
        bossEnabled = false,
        teamCheck = true,
        fillColor = Color3.fromRGB(255, 0, 0),
        outlineColor = Color3.fromRGB(255, 255, 255),
        fillTransparency = 0.5,
        outlineTransparency = 0,
        autoTeamColor = true
    }

    -- Load modules
    Modules.Aimbot(Fluent, Tabs.Combat)
    Modules.Hitboxes(Fluent, Tabs.Combat)
    Modules.Highlight(Fluent, Tabs.Visuals)
    Modules.Friends(Fluent, Tabs.Visuals)
    Modules.Misc(Fluent, Tabs.Movement)

    -- Setup SaveManager and InterfaceManager
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)

    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})

    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    Window:SelectTab(1)

    -- Load autoload config
    SaveManager:LoadAutoloadConfig()
end
