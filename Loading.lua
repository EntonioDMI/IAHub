local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- Проверяем и удаляем существующий GUI
local existingGui = CoreGui:FindFirstChild("LoadingScreen")
if existingGui then
    existingGui:Destroy()
end

-- Check if modules are already loaded
if _G.IAHubModulesLoaded then
    -- Skip loading screen and load menu directly
    local success, Menu = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/EntonioDMI/IAHub/main/Fluent.lua"))()
    end)
    if not success then
        warn("Failed to load Menu:", Menu)
        return
    end
    Menu(_G.IAHubModules)
    return
end

local function showLoadingScreen()
    -- Создаем ScreenGui с максимальным приоритетом
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingScreen"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.DisplayOrder = 999999999
    screenGui.IgnoreGuiInset = true -- Игнорируем отступы интерфейса Roblox
    screenGui.Parent = CoreGui

    -- Создаем основной фон на весь экран
    local mainBackground = Instance.new("Frame")
    mainBackground.Size = UDim2.new(1, 0, 1, 0)
    mainBackground.Position = UDim2.new(0, 0, 0, 0)
    mainBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainBackground.BackgroundTransparency = 1
    mainBackground.BorderSizePixel = 0
    mainBackground.ZIndex = 1000
    mainBackground.Parent = screenGui

    -- Создаем градиентный фон
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 17, 17)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
    })
    gradient.Rotation = 45
    gradient.Parent = mainBackground

    -- Эффект размытия
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting

    -- Контейнер для элементов загрузки
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 300, 0, 150)
    container.Position = UDim2.new(0.5, -150, 0.5, -75)
    container.BackgroundTransparency = 1
    container.ZIndex = 1001
    container.Parent = screenGui

    -- Создаем эффект свечения
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://7509457766" -- ID изображения свечения
    glow.ImageColor3 = Color3.fromRGB(0, 170, 255)
    glow.ImageTransparency = 1
    glow.ZIndex = 1000
    glow.Parent = container

    -- Логотип
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 40)
    logo.Position = UDim2.new(0, 0, 0, 0)
    logo.BackgroundTransparency = 1
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 32
    logo.Font = Enum.Font.GothamBold
    logo.Text = "IAHub"
    logo.TextTransparency = 1
    logo.ZIndex = 1002
    logo.Parent = container

    -- Текст загрузки
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 20)
    loadingText.Position = UDim2.new(0, 0, 0, 50)
    loadingText.BackgroundTransparency = 1
    loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
    loadingText.TextSize = 16
    loadingText.Font = Enum.Font.Gotham
    loadingText.Text = "Initializing..."
    loadingText.TextTransparency = 1
    loadingText.ZIndex = 1002
    loadingText.Parent = container

    -- Создаем контейнер для прогресс-бара
    local progressContainer = Instance.new("Frame")
    progressContainer.Size = UDim2.new(1, 0, 0, 4)
    progressContainer.Position = UDim2.new(0, 0, 0, 80)
    progressContainer.BackgroundTransparency = 1
    progressContainer.ZIndex = 1002
    progressContainer.Parent = container

    -- Фон прогресс-бара с закругленными углами
    local progressBG = Instance.new("Frame")
    progressBG.Size = UDim2.new(1, 0, 1, 0)
    progressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    progressBG.BorderSizePixel = 0
    progressBG.BackgroundTransparency = 1
    progressBG.ZIndex = 1002
    progressBG.Parent = progressContainer

    local progressBGCorner = Instance.new("UICorner")
    progressBGCorner.CornerRadius = UDim.new(1, 0)
    progressBGCorner.Parent = progressBG

    -- Прогресс-бар с закругленными углами
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    progressBar.BorderSizePixel = 0
    progressBar.BackgroundTransparency = 1
    progressBar.ZIndex = 1003
    progressBar.Parent = progressBG

    local progressBarCorner = Instance.new("UICorner")
    progressBarCorner.CornerRadius = UDim.new(1, 0)
    progressBarCorner.Parent = progressBar

    -- Процент загрузки
    local percentage = Instance.new("TextLabel")
    percentage.Size = UDim2.new(1, 0, 0, 20)
    percentage.Position = UDim2.new(0, 0, 0, 90)
    percentage.BackgroundTransparency = 1
    percentage.TextColor3 = Color3.fromRGB(200, 200, 200)
    percentage.TextSize = 14
    percentage.Font = Enum.Font.Gotham
    percentage.Text = "0%"
    percentage.TextTransparency = 1
    percentage.ZIndex = 1002
    percentage.Parent = container

    -- Анимация появления
    local function fadeIn()
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        
        -- Анимация фона
        TweenService:Create(mainBackground, tweenInfo, {
            BackgroundTransparency = 0
        }):Play()
        
        -- Анимация свечения
        TweenService:Create(glow, tweenInfo, {
            ImageTransparency = 0.7
        }):Play()
        
        -- Анимация размытия
        TweenService:Create(blur, tweenInfo, {
            Size = 24
        }):Play()
        
        -- Анимация элементов интерфейса
        local elements = {logo, loadingText, percentage, progressBG, progressBar}
        for _, element in ipairs(elements) do
            TweenService:Create(element, tweenInfo, {
                BackgroundTransparency = element:IsA("TextLabel") and 1 or 0,
                TextTransparency = element:IsA("TextLabel") and 0 or nil
            }):Play()
        end

        -- Анимация пульсации свечения
        spawn(function()
            while mainBackground.Parent do
                TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Size = UDim2.new(1.7, 0, 1.7, 0)
                }):Play()
                wait(2)
                TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Size = UDim2.new(1.5, 0, 1.5, 0)
                }):Play()
                wait(2)
            end
        end)
    end

    fadeIn()

    local function cleanup()
        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
        
        -- Анимация исчезновения фона
        TweenService:Create(mainBackground, tweenInfo, {
            BackgroundTransparency = 1
        }):Play()
        
        -- Анимация исчезновения свечения
        TweenService:Create(glow, tweenInfo, {
            ImageTransparency = 1
        }):Play()
        
        -- Анимация исчезновения текста с эффектом скольжения вверх
        local elements = {logo, loadingText, percentage}
        for _, element in ipairs(elements) do
            TweenService:Create(element, tweenInfo, {
                TextTransparency = 1,
                Position = element.Position + UDim2.new(0, 0, -0.2, 0)
            }):Play()
        end
        
        -- Анимация исчезновения прогресс-бара
        TweenService:Create(progressContainer, tweenInfo, {
            Position = progressContainer.Position + UDim2.new(0, 0, -0.2, 0)
        }):Play()
        
        TweenService:Create(progressBG, tweenInfo, {
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(progressBar, tweenInfo, {
            BackgroundTransparency = 1
        }):Play()
        
        -- Анимация уменьшения размытия
        TweenService:Create(blur, tweenInfo, {
            Size = 0
        }):Play()
        
        wait(0.8)
        blur:Destroy()
        screenGui:Destroy()
    end

    local function updateProgress(step, total, text)
        local progress = step / total
        
        -- Анимация прогресс-бара
        TweenService:Create(progressBar, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = UDim2.new(progress, 0, 1, 0)
        }):Play()
        
        -- Анимация текста
        local currentText = loadingText.Text
        if currentText ~= text then
            TweenService:Create(loadingText, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
                TextTransparency = 1,
                Position = loadingText.Position + UDim2.new(0, 0, -0.1, 0)
            }):Play()
            
            wait(0.2)
            loadingText.Text = text
            loadingText.Position = UDim2.new(0, 0, 0, 60)
            
            TweenService:Create(loadingText, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
                TextTransparency = 0,
                Position = UDim2.new(0, 0, 0, 50)
            }):Play()
        end
        
        -- Анимация процентов
        local targetPercent = math.floor(progress * 100)
        local currentPercent = tonumber(percentage.Text:match("%d+"))
        
        TweenService:Create(percentage, TweenInfo.new(0.3), {
            TextTransparency = 0.5
        }):Play()
        
        spawn(function()
            local start = currentPercent or 0
            for i = start, targetPercent do
                percentage.Text = i .. "%"
                wait(0.02)
            end
            
            TweenService:Create(percentage, TweenInfo.new(0.2), {
                TextTransparency = 0
            }):Play()
        end)
        
        if progress >= 1 then
            wait(0.5)
            cleanup()
        end
    end

    return updateProgress
end

local updateLoadingProgress = showLoadingScreen()
local totalSteps = 7
local currentStep = 0

local function nextStep(text)
    currentStep = currentStep + 1
    updateLoadingProgress(currentStep, totalSteps, text)
end

-- Load required modules with pcall для обработки ошибок
local Modules = {}

-- Загружаем Fluent UI
nextStep("Loading Fluent UI...")
local success, FluentUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)
if not success then
    warn("Failed to load Fluent UI:", FluentUI)
    return
end
Modules.Fluent = FluentUI

-- Загружаем Save Manager
nextStep("Loading Save Manager...")
local success, SaveManager = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
end)
if not success then
    warn("Failed to load Save Manager:", SaveManager)
    return
end
Modules.SaveManager = SaveManager

-- Загружаем Interface Manager
nextStep("Loading Interface Manager...")
local success, InterfaceManager = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)
if not success then
    warn("Failed to load Interface Manager:", InterfaceManager)
    return
end
Modules.InterfaceManager = InterfaceManager

-- Загружаем Aimbot Module
nextStep("Loading Aimbot Module...")
local success, AimbotModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/EntonioDMI/IAHub/main/Aimbot.lua"))()
end)
if not success then
    warn("Failed to load Aimbot Module:", AimbotModule)
    return
end
Modules.Aimbot = AimbotModule

-- Загружаем Hitboxes Module
nextStep("Loading Hitboxes Module...")
local success, HitboxesModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/EntonioDMI/IAHub/main/Hitboxes.lua"))()
end)
if not success then
    warn("Failed to load Hitboxes Module:", HitboxesModule)
    return
end
Modules.Hitboxes = HitboxesModule

-- Загружаем Highlight Module
nextStep("Loading Highlight Module...")
local success, HighlightModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/EntonioDMI/IAHub/main/Highlight.lua"))()
end)
if not success then
    warn("Failed to load Highlight Module:", HighlightModule)
    return
end
Modules.Highlight = HighlightModule

-- Загружаем Misc Module
nextStep("Loading Misc Module...")
local success, MiscModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/EntonioDMI/IAHub/main/Misc.lua"))()
end)
if not success then
    warn("Failed to load Misc Module:", MiscModule)
    return
end
Modules.Misc = MiscModule

-- Set the flag and store modules
_G.IAHubModulesLoaded = true
_G.IAHubModules = Modules

-- Загружаем меню
local success, Menu = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/EntonioDMI/IAHub/main/Fluent.lua"))()
end)
if not success then
    warn("Failed to load Menu:", Menu)
    return
end

-- Инициализируем меню с загруженными модулями
Menu(Modules)
