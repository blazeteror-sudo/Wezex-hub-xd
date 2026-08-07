-- WEZEX HUB (WINDUI + NATIVE KEY SYSTEM) | STEEL BRAINROT (MOVEMENT EXPANSION)
-- КЛЮЧ: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = workspace
local Lighting = game:GetService("Lighting")

-- ====== ЗАГРУЗКА WINDUI ======
local WindUI
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok then
        WindUI = result
    else
        error("WindUI не загрузился")
    end
end

-- ====== КЛЮЧ ======
local CORRECT_KEY = "38399923"
local keyVerified = false

-- ====== СОСТОЯНИЯ ======
local State = {
    infJump = false,
    platform = false,
    float = false,
}

-- ====== ПОДКЛЮЧЕНИЯ ======
local infJumpConnection = nil
local platformConnection = nil
local platformPart = nil
local floatConnection = nil
local quickButtons = {}

-- ====== INFINITE JUMP ======
local function toggleInfJump()
    State.infJump = not State.infJump
    if State.infJump then
        if infJumpConnection then infJumpConnection:Disconnect() end
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConnection then
            infJumpConnection:Disconnect()
            infJumpConnection = nil
        end
    end
end

-- ====== ANTI-DEATH PLATFORM ======
local function startPlatform()
    State.platform = true
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(8, 1, 8)
    platformPart.Position = hrp.Position - Vector3.new(0, 2, 0)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.Transparency = 0.4
    platformPart.Material = Enum.Material.Neon
    platformPart.Color = Color3.fromRGB(0, 255, 255)
    platformPart.Parent = Workspace

    local light = Instance.new("PointLight")
    light.Parent = platformPart
    light.Color = Color3.fromRGB(0, 255, 255)
    light.Range = 15
    light.Brightness = 2

    platformConnection = RunService.RenderStepped:Connect(function()
        if not State.platform then return end
        local c = LocalPlayer.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        if not root then return end
        platformPart.Position = Vector3.new(root.Position.X, root.Position.Y - 1.5, root.Position.Z)
    end)
end

local function stopPlatform()
    State.platform = false
    if platformConnection then
        platformConnection:Disconnect()
        platformConnection = nil
    end
    if platformPart then
        platformPart:Destroy()
        platformPart = nil
    end
end

local function togglePlatform()
    if State.platform then
        stopPlatform()
    else
        startPlatform()
    end
end

-- ====== FLOAT / FREEZE ======
local function startFloat()
    State.float = true
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Сохраняем позицию, где зависли
    local frozenPos = hrp.Position

    floatConnection = RunService.RenderStepped:Connect(function()
        if not State.float then return end
        local c = LocalPlayer.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        if not root then return end
        -- Замораживаем в воздухе
        root.Velocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.new(root.Position.X, frozenPos.Y, root.Position.Z)
    end)
end

local function stopFloat()
    State.float = false
    if floatConnection then
        floatConnection:Disconnect()
        floatConnection = nil
    end
end

local function toggleFloat()
    if State.float then
        stopFloat()
    else
        startFloat()
    end
end

-- ====== БЫСТРЫЕ КНОПКИ (QUICK TOGGLES) ======
local function createQuickButton(label, stateKey, toggleFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 30)
    btn.Position = UDim2.new(0.85, 0, 0.1 + #quickButtons * 0.06, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.BackgroundTransparency = 0.2
    btn.Text = label .. ": OFF"
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = CoreGui
    Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
    btn.Visible = false

    btn.MouseButton1Click:Connect(function()
        toggleFunc()
        if State[stateKey] then
            btn.Text = label .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(80, 220, 160)
        else
            btn.Text = label .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)

    table.insert(quickButtons, {btn = btn, stateKey = stateKey, label = label})
    return btn
end

local function updateQuickButtons()
    for _, data in ipairs(quickButtons) do
        if State[data.stateKey] then
            data.btn.Visible = true
            data.btn.Text = data.label .. ": ON"
            data.btn.BackgroundColor3 = Color3.fromRGB(80, 220, 160)
        else
            data.btn.Visible = false
        end
    end
end

-- ====== ОКНО КЛЮЧА ======
local function showNativeKeyWindow()
    pcall(function()
        if CoreGui:FindFirstChild("KeySystem") then CoreGui.KeySystem:Destroy() end
    end)

    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    keyGui.ResetOnSpawn = false
    keyGui.IgnoreGuiInset = true

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 260, 0, 150)
    panel.Position = UDim2.new(0.5, -130, 0.5, -75)
    panel.BackgroundColor3 = Color3.fromRGB(15, 12, 30)
    panel.BackgroundTransparency = 0.15
    panel.Parent = keyGui
    Instance.new("UICorner").CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = panel

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 18)
    info.Position = UDim2.new(0, 0, 0, 42)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextColor3 = Color3.fromRGB(160, 160, 200)
    info.Text = "Введите ключ доступа"
    info.TextXAlignment = Enum.TextXAlignment.Center
    info.Parent = panel

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.6, 0, 0, 34)
    keyBox.Position = UDim2.new(0.2, 0, 0, 66)
    keyBox.BackgroundColor3 = Color3.fromRGB(30, 28, 50)
    keyBox.BackgroundTransparency = 0.3
    keyBox.Font = Enum.Font.GothamBold
    keyBox.TextSize = 16
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Text = ""
    keyBox.PlaceholderText = "Ключ"
    keyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 160)
    keyBox.ClearTextOnFocus = false
    keyBox.Parent = panel
    Instance.new("UICorner").CornerRadius = UDim.new(0, 10)

    local enterBtn = Instance.new("TextButton")
    enterBtn.Size = UDim2.new(0.35, 0, 0, 34)
    enterBtn.Position = UDim2.new(0.325, 0, 0, 106)
    enterBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    enterBtn.BackgroundTransparency = 0.2
    enterBtn.Text = "Войти"
    enterBtn.TextSize = 16
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.Parent = panel
    Instance.new("UICorner").CornerRadius = UDim.new(0, 10)

    local function checkKey()
        if keyBox.Text == CORRECT_KEY then
            keyVerified = true
            keyGui:Destroy()
            createMainUI()
        else
            keyBox.Text = ""
            keyBox.PlaceholderText = "Неверно!"
            keyBox.PlaceholderColor3 = Color3.fromRGB(255, 80, 80)
            task.wait(0.6)
            keyBox.PlaceholderText = "Ключ"
            keyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 160)
        end
    end

    enterBtn.MouseButton1Click:Connect(checkKey)
    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then checkKey() end
    end)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Return then checkKey() end
    end)
end

-- ====== GUI ======
function createMainUI()
    local Window = WindUI:CreateWindow({
        Title = "Wezex Hub v4.1",
        Folder = "WezexHub",
        Icon = "solar:folder-2-bold-duotone",
        OpenButton = {
            Title = "Wezex Hub",
            Color = ColorSequence.new(Color3.fromRGB(255, 100, 255), Color3.fromRGB(100, 200, 255)),
            Draggable = true,
            Scale = 0.5,
        },
    })

    -- ВКЛАДКА COMBAT (ПУСТАЯ)
    local CombatTab = Window:Tab({
        Title = "Combat",
        Icon = "solar:sword-bold",
    })
    local CombatSection = CombatTab:Section({
        Title = "⚔️ Combat Settings",
    })
    CombatSection:Label({
        Title = "Нет доступных функций",
        Desc = "Ожидайте обновления",
    })

    -- ВКЛАДКА MOVEMENT
    local MovementTab = Window:Tab({
        Title = "Movement",
        Icon = "solar:running-bold",
    })
    local MovementSection = MovementTab:Section({
        Title = "🏃 Movement Settings",
    })

    MovementSection:Toggle({
        Title = "Infinite Jump",
        Desc = "Бесконечные прыжки",
        Value = State.infJump,
        Callback = function(v)
            if v ~= State.infJump then
                toggleInfJump()
                updateQuickButtons()
            end
        end,
    })

    MovementSection:Toggle({
        Title = "Anti-Death Platform",
        Desc = "Платформа под ногами",
        Value = State.platform,
        Callback = function(v)
            if v ~= State.platform then
                togglePlatform()
                updateQuickButtons()
            end
        end,
    })

    MovementSection:Toggle({
        Title = "Float / Freeze",
        Desc = "Застыть в воздухе",
        Value = State.float,
        Callback = function(v)
            if v ~= State.float then
                toggleFloat()
                updateQuickButtons()
            end
        end,
    })

    -- ВКЛАДКА VISUALS (ПУСТАЯ)
    local VisualsTab = Window:Tab({
        Title = "Visuals",
        Icon = "solar:eye-bold",
    })
    local VisualsSection = VisualsTab:Section({
        Title = "👁️ Visual Settings",
    })
    VisualsSection:Label({
        Title = "Нет доступных функций",
        Desc = "Ожидайте обновления",
    })

    -- ВКЛАДКА ABOUT
    local AboutTab = Window:Tab({
        Title = "About",
        Icon = "solar:info-square-bold",
    })
    local AboutSection = AboutTab:Section({
        Title = "Wezex Hub v4.1",
    })
    AboutSection:Button({
        Title = "Destroy Window",
        Color = Color3.fromRGB(255, 50, 50),
        Callback = function()
            Window:Destroy()
        end,
    })

    -- БЫСТРЫЕ КНОПКИ
    createQuickButton("Platform", "platform", togglePlatform)
    createQuickButton("Float", "float", toggleFloat)

    -- Синхронизация
    if State.infJump then toggleInfJump() end
    if State.platform then startPlatform() end
    if State.float then startFloat() end
    updateQuickButtons()
end

-- ====== ЗАПУСК ======
showNativeKeyWindow()
