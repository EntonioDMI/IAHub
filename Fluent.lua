return function(Modules)
    if not Modules or not Modules.Fluent then
        warn("Required modules not loaded!")
        return
    end

    local Fluent = Modules.Fluent
    local SaveManager = Modules.SaveManager
    local InterfaceManager = Modules.InterfaceManager

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
