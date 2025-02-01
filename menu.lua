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
