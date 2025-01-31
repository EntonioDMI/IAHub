local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Load modules
local AimbotModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/EntonioDMI/IAHub/refs/heads/main/aimbot.lua"))()
local HighlightModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/EntonioDMI/IAHub/refs/heads/main/highlight.lua"))()
local MiscModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/EntonioDMI/IAHub/refs/heads/main/misc.lua"))()

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
    Highlight = Window:AddTab({ Title = "Highlight", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings-2" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Make settings global first before creating UI elements
_G.highlightSettings = {
    enabled = false,
    teamCheck = true,
    autoTeamColor = true,
    fillColor = Color3.fromRGB(255, 0, 0),
    fillTransparency = 0.5,
    outlineColor = Color3.fromRGB(255, 255, 255),
    outlineTransparency = 0
}

-- Initialize highlight module first to set up the update function
HighlightModule(Fluent, Tabs.Highlight)

-- Aimbot Tab Elements
local Toggle = Tabs.Aimbot:AddToggle("Enabled", {
    Title = "Enable Aimbot",
    Default = _G.aimbotSettings.enabled,
    Callback = function(value)
        _G.aimbotSettings.enabled = value
        if not value then
            FOVCircle.Visible = false
        end
    end
})

local TeamCheck = Tabs.Aimbot:AddToggle("TeamCheck", {
    Title = "Team Check",
    Description = "Don't target teammates",
    Default = _G.aimbotSettings.teamCheck,
    Callback = function(value)
        _G.aimbotSettings.teamCheck = value
    end
})

local FOVSlider = Tabs.Aimbot:AddSlider("FOV", {
    Title = "FOV",
    Description = "Field of View radius",
    Default = _G.aimbotSettings.fov,
    Min = 10,
    Max = 800,
    Rounding = 0,
    Callback = function(value)
        _G.aimbotSettings.fov = value
    end
})

local DrawFOV = Tabs.Aimbot:AddToggle("DrawFOV", {
    Title = "Draw FOV",
    Description = "Show FOV circle",
    Default = _G.aimbotSettings.drawFOV,
    Callback = function(value)
        _G.aimbotSettings.drawFOV = value
        if not value then
            FOVCircle.Visible = false
        end
    end
})

local TriggerKeyDropdown = Tabs.Aimbot:AddDropdown("TriggerKey", {
    Title = "Trigger Key",
    Description = "Key to activate aimbot",
    Values = {"Mouse1", "Mouse2", "Mouse3", "Mouse4", "Mouse5"},
    Default = "Mouse2",
    Multi = false,
    Callback = function(value)
        local keyMap = {
            Mouse1 = Enum.UserInputType.MouseButton1,
            Mouse2 = Enum.UserInputType.MouseButton2,
            Mouse3 = Enum.UserInputType.MouseButton3,
            Mouse4 = Enum.UserInputType.MouseButton4,
            Mouse5 = Enum.UserInputType.MouseButton5
        }
        _G.aimbotSettings.triggerKey = keyMap[value]
    end
})

local LockPartDropdown = Tabs.Aimbot:AddDropdown("LockPart", {
    Title = "Lock Part",
    Description = "Body part to target",
    Values = {"Head", "Torso"},
    Default = "Head",
    Multi = false,
    Callback = function(value)
        _G.aimbotSettings.lockPart = value
    end
})

local WallCheck = Tabs.Aimbot:AddToggle("WallCheck", {
    Title = "Wall Check",
    Description = "Check if target is behind walls",
    Default = _G.aimbotSettings.wallCheck,
    Callback = function(value)
        _G.aimbotSettings.wallCheck = value
    end
})

local AliveCheck = Tabs.Aimbot:AddToggle("AliveCheck", {
    Title = "Alive Check",
    Description = "Only target alive players",
    Default = _G.aimbotSettings.aliveCheck,
    Callback = function(value)
        _G.aimbotSettings.aliveCheck = value
    end
})

local SensitivitySlider = Tabs.Aimbot:AddSlider("Sensitivity", {
    Title = "Sensitivity",
    Description = "Aiming speed",
    Default = _G.aimbotSettings.sensitivity,
    Min = 0.1,
    Max = 2,
    Rounding = 2,
    Callback = function(value)
        _G.aimbotSettings.sensitivity = value
    end
})

-- Highlight Tab Elements
local Toggle = Tabs.Highlight:AddToggle("Enabled", {
    Title = "Enable ESP",
    Default = _G.highlightSettings.enabled,
    Callback = function(value)
        _G.highlightSettings.enabled = value
    end
})

local TeamCheck = Tabs.Highlight:AddToggle("TeamCheck", {
    Title = "Team Check",
    Description = "Don't highlight teammates",
    Default = _G.highlightSettings.teamCheck,
    Callback = function(value)
        _G.highlightSettings.teamCheck = value
        if _G.updateHighlights then
            _G.updateHighlights()
        end
    end
})

local AutoTeamColor = Tabs.Highlight:AddToggle("AutoTeamColor", {
    Title = "Auto Team Color",
    Description = "Use team colors for highlights",
    Default = _G.highlightSettings.autoTeamColor,
    Callback = function(value)
        _G.highlightSettings.autoTeamColor = value
        if _G.updateHighlights then
            _G.updateHighlights()
        end
    end
})

-- Fill Color Settings
local FillColorPicker = Tabs.Highlight:AddColorpicker("FillColor", {
    Title = "Fill Color",
    Description = "Color for the highlight fill",
    Default = _G.highlightSettings.fillColor,
    Callback = function(value)
        _G.highlightSettings.fillColor = value
    end
})

local FillTransparencySlider = Tabs.Highlight:AddSlider("FillTransparency", {
    Title = "Fill Transparency",
    Description = "Adjust fill transparency",
    Default = _G.highlightSettings.fillTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        _G.highlightSettings.fillTransparency = value
    end
})

-- Outline Color Settings
local OutlineColorPicker = Tabs.Highlight:AddColorpicker("OutlineColor", {
    Title = "Outline Color",
    Description = "Color for the highlight outline",
    Default = _G.highlightSettings.outlineColor,
    Callback = function(value)
        _G.highlightSettings.outlineColor = value
    end
})

local OutlineTransparencySlider = Tabs.Highlight:AddSlider("OutlineTransparency", {
    Title = "Outline Transparency",
    Description = "Adjust outline transparency",
    Default = _G.highlightSettings.outlineTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        _G.highlightSettings.outlineTransparency = value
    end
})

-- Initialize other modules
AimbotModule(Fluent, Tabs.Aimbot)
MiscModule(Fluent, Tabs.Misc)

-- Settings Tab Configuration
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("IAHubConfig")
SaveManager:SetFolder("IAHubConfig/GameSpecific")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "IAHub Loaded",
    Content = "v1.0 Alpha by EntonioDMI",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
