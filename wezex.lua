-- Wezex Hub by @Fanqwezex (FIXED + SNOW)
-- KEY: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local KnifeController

pcall(function()
    if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    if CoreGui:FindFirstChild("KeySystem") then CoreGui.KeySystem:Destroy() end
end)

local CORRECT_KEY = "38399923"
local State = {
    esp = false,
    knifeAim = false,
}
local screenGui, mainFrame, openBtn, isOpen = nil, nil, nil, false
local snowParticles = {} -- таблица для снежинок

-- ========== ESP ДЛЯ ДУЭЛЕЙ ==========
local espHighlights = {}
local espConnections = {}

local function clearESP()
    for _, h in ipairs(espHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    espHighlights = {}
    for _, c in ipairs(espConnections) do
        if c then c:Disconnect() end
    end
    espConnections = {}
end

local function applyESP(player)
    if player == LocalPlayer then return end
    local function setup(char)
        local old = char:FindFirstChild("WezexESP")
        if old then old:Destroy() end
        local targetPart = char:FindFirstChild("Head")
        if not targetPart then
            targetPart = char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
        end
        if not targetPart then return end
        local h = Instance.new("Highlight")
        h.Name = "WezexESP"
        h.Adornee = targetPart
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            h.FillColor = Color3.fromRGB(0, 255, 0)
        elseif player.Team and LocalPlayer.Team and player.Team ~= LocalPlayer.Team then
            h.FillColor = Color3.fromRGB(255, 50, 50)
        else
            h.FillColor = Color3.fromRGB(255, 255, 0)
        end
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.FillTransparency = 0.3
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char
        table.insert(espHighlights, h)
    end
    if player.Character then setup(player.Character) end
    local conn = player.CharacterAdded:Connect(setup)
    table.insert(espConnections, conn)
end

local function toggleESP()
    State.esp = not State.esp
    if State.esp then
        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do
            applyESP(p)
        end
        table.insert(espConnections, Players.PlayerAdded:Connect(applyESP))
    else
        clearESP()
    end
end

-- ========== SILENT AIM ==========
getgenv().KnifeConfig = { Enabled = false, HitPart = "Head", FOV = 450 }
local originalThrow = nil

local function getClosestTarget()
    local best, bestFOV = nil, getgenv().KnifeConfig.FOV
    local center = Camera.ViewportSize / 2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local part = plr.Character:FindFirstChild(getgenv().KnifeConfig.HitPart)
            if not part then part = plr.Character:FindFirstChild("HumanoidRootPart") end
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if d < bestFOV then best, bestFOV = plr, d end
                end
            end
        end
    end
    return best
end

local function applyKnifeAim()
    if not KnifeController then
        local success, result = pcall(function()
            return require(LocalPlayer.PlayerScripts:WaitForChild("Controllers"):WaitForChild("Combat"):WaitForChild("KnifeController"))
        end)
        if success then
            KnifeController = result
        else
            return
        end
    end

    if State.knifeAim then
        if not originalThrow then
            originalThrow = KnifeController._GetThrowDirection
        end
        KnifeController._GetThrowDirection = function(self, origin)
            if getgenv().KnifeConfig.Enabled then
                local target = getClosestTarget()
                if target and target.Character then
                    local part = target.Character:FindFirstChild(getgenv().KnifeConfig.HitPart)
                    if not part then part = target.Character:FindFirstChild("HumanoidRootPart") end
                    if part then
                        return (part.Position - origin.Position).Unit
                    end
                end
            end
            return originalThrow(self, origin)
        end
    else
        if originalThrow and KnifeController then
            KnifeController._GetThrowDirection = originalThrow
            originalThrow = nil
        end
    end
end

local function toggleKnifeAim()
    State.knifeAim = not State.knifeAim
    getgenv().KnifeConfig.Enabled = State.knifeAim
    applyKnifeAim()
end

-- ========== СИСТЕМА СНЕГОПАДА (внутри меню) ==========
local function createSnow(parentFrame)
    -- Удаляем старые снежинки
    for _, v in ipairs(snowParticles) do
        if v and v.Parent then v:Destroy() end
    end
    snowParticles = {}

    local frameSize = parentFrame.AbsoluteSize
    if frameSize.X == 0 or frameSize.Y == 0 then
        -- Если фрейм ещё не отрендерился, ждём
        task.wait(0.1)
        frameSize = parentFrame.AbsoluteSize
    end

    local count = 35 -- количество снежинок
    for i = 1, count do
        local snow = Instance.new("Frame")
        snow.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        snow.Position = UDim2.new(
            math.random() * 0.9 + 0.05, 
            0, 
            math.random() * 0.9 + 0.05, 
            0
        )
        snow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        snow.BackgroundTransparency = 0.2 + math.random() * 0.3
        snow.BorderSizePixel = 0
        snow.ClipsDescendants = false -- важно для корректного отображения краёв
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = snow
        snow.Parent = parentFrame

        -- Сохраняем параметры анимации
        local data = {
            frame = snow,
            speed = 0.2 + math.random() * 0.4, -- скорость падения (медленно)
            drift = math.random(-1, 1) * 0.3, -- горизонтальное отклонение
            startX = snow.Position.X.Scale,
            startY = snow.Position.Y.Scale,
            phase = math.random() * 2 * math.pi, -- для волнообразного движения
            size = snow.Size
        }
        table.insert(snowParticles, data)
    end

    -- Запускаем анимацию
    RunService:Stepped:Connect(function()
        if not parentFrame or not parentFrame.Parent then return end
        local size = parentFrame.AbsoluteSize
        if size.X == 0 or size.Y == 0 then return end

        for _, data in ipairs(snowParticles) do
            if data and data.frame and data.frame.Parent then
                -- Двигаем вниз с волнообразным смещением
                data.startY = data.startY + data.speed * 0.002
                data.phase = data.phase + 0.02

                -- Волнообразное смещение по X
                local wave = math.sin(data.phase) * 0.015
                local xPos = data.startX + wave + data.drift * 0.002

                -- Сброс вверх, если вышло за границу
                if data.startY > 0.95 then
                    data.startY = -0.05
                    data.startX = math.random() * 0.9 + 0.05
                    data.speed = 0.15 + math.random() * 0.35
                    data.drift = math.random(-1, 1) * 0.3
                end

                -- Ограничиваем, чтобы не выходило за рамки
                xPos = math.clamp(xPos, 0.02, 0.98)
                local yPos = math.clamp(data.startY, -0.02, 0.95)

                data.frame.Position = UDim2.new(xPos, 0, yPos, 0)
            end
        end
    end)
end

-- ========== GUI ==========
local function showKeyWindow()
    local keyGui = Instance.new("ScreenGui", CoreGui)
    keyGui.Name = "KeySystem"
    keyGui.ResetOnSpawn = false

    local panel = Instance.new("Frame", keyGui)
    panel.Size = UDim2.new(0, 240, 0, 130)
    panel.Position = UDim2.new(0.5, -120, 0.5, -65)
    panel.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    panel.BackgroundTransparency = 0.3
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 26)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local info = Instance.new("TextLabel", panel)
    info.Size = UDim2.new(1, 0, 0, 16)
    info.Position = UDim2.new(0, 0, 0, 36)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.TextColor3 = Color3.fromRGB(160, 160, 200)
    info.Text = "Введите ключ"
    info.TextXAlignment = Enum.TextXAlignment.Center

    local keyBox = Instance.new("TextBox", panel)
    keyBox.Size = UDim2.new(0.6, 0, 0, 30)
    keyBox.Position = UDim2.new(0.2, 0, 0, 58)
    keyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    keyBox.BackgroundTransparency = 0.3
    keyBox.BorderSizePixel = 0
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    keyBox.Font = Enum.Font.GothamBold
    keyBox.TextSize = 14
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Text = ""
    keyBox.PlaceholderText = "Ключ"
    keyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 160)
    keyBox.ClearTextOnFocus = false

    local enterBtn = Instance.new("TextButton", panel)
    enterBtn.Size = UDim2.new(0.4, 0, 0, 30)
    enterBtn.Position = UDim2.new(0.3, 0, 0, 94)
    enterBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    enterBtn.BackgroundTransparency = 0.2
    enterBtn.BorderSizePixel = 0
    Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 8)
    enterBtn.Text = "Войти"
    enterBtn.TextSize = 14
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.Font = Enum.Font.GothamBold

    enterBtn.MouseButton1Click:Connect(function()
        if keyBox.Text == CORRECT_KEY then
            keyGui:Destroy()
            createMainGUI()
        else
            keyBox.Text = ""
            keyBox.PlaceholderText = "Неверно!"
            keyBox.PlaceholderColor3 = Color3.fromRGB(255, 80, 80)
            task.wait(0.5)
            keyBox.PlaceholderText = "Ключ"
            keyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 160)
        end
    end)
    keyBox.FocusLost:Connect(function(enterPressed) if enterPressed then enterBtn.MouseButton1Click:Fire() end end)
    UserInputService.InputBegan:Connect(function(input) if input.KeyCode == Enum.KeyCode.Return then enterBtn.MouseButton1Click:Fire() end end)
end

function createMainGUI()
    pcall(function() if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end end)

    screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "WezexHub"
    screenGui.ResetOnSpawn = false

    openBtn = Instance.new("TextButton", screenGui)
    openBtn.Size = UDim2.new(0, 48, 0, 48)
    openBtn.Position = UDim2.new(0.02, 0, 0.04, 0)
    openBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 160)
    openBtn.BackgroundTransparency = 0.2
    openBtn.BorderSizePixel = 0
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    openBtn.Text = "W"
    openBtn.TextSize = 22
    openBtn.TextColor3 = Color3.fromRGB(200, 150, 255)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.Visible = false
    openBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        openBtn.Visible = false
        isOpen = true
    end)

    mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 220, 0, 160) -- увеличено под снег
    mainFrame.Position = UDim2.new(0.5, -110, 0.5, -80)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    mainFrame.ClipsDescendants = true -- снежинки не выходят за рамки

    -- СНЕГОПАД (запускаем после рендера)
    task.wait(0.05)
    createSnow(mainFrame)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 26)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub ❄️"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        openBtn.Visible = true
        isOpen = false
    end)

    local content = Instance.new("Frame", mainFrame)
    content.Size = UDim2.new(1, -12, 1, -44)
    content.Position = UDim2.new(0, 6, 0, 40)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = false

    -- ФУНКЦИЯ СОЗДАНИЯ ПЕРЕКЛЮЧАТЕЛЯ (ИСПРАВЛЕНА)
    local function createToggle(label, stateRef, callback)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, 0, 0, 28)
        frame.BackgroundColor3 = Color3.fromRGB(22, 18, 35)
        frame.BackgroundTransparency = 0.4
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextColor3 = Color3.fromRGB(220, 210, 255)
        lbl.Text = label
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 44, 0, 18)
        btn.Position = UDim2.new(1, -50, 0.5, -9)
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.Text = stateRef and "ON" or "OFF"
        btn.TextSize = 9
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold

        -- УСТАНАВЛИВАЕМ ЦВЕТ СОГЛАСНО ТЕКУЩЕМУ СОСТОЯНИЮ
        local function updateButton()
            if stateRef then
                btn.BackgroundColor3 = Color3.fromRGB(80, 220, 160) -- ЗЕЛЕНЫЙ = ВКЛ
                btn.Text = "ON"
            else
                btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- КРАСНЫЙ = ВЫКЛ
                btn.Text = "OFF"
            end
        end
        updateButton()

        btn.MouseButton1Click:Connect(function()
            stateRef = not stateRef
            callback(stateRef) -- Вызываем функцию, которая обновляет глобальное состояние
            updateButton()
        end)

        -- ВОЗВРАЩАЕМ stateRef, чтобы использовать для синхронизации
        return stateRef
    end

    -- СОЗДАЁМ ПЕРЕКЛЮЧАТЕЛИ С ПРАВИЛЬНЫМИ ССЫЛКАМИ
    createToggle("ESP (Duels)", State.esp, function(v)
        State.esp = v
        toggleESP()
    end)

    createToggle("Silent Aim", State.knifeAim, function(v)
        State.knifeAim = v
        toggleKnifeAim()
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightBracket then
            if mainFrame.Visible then
                mainFrame.Visible = false
                openBtn.Visible = true
                isOpen = false
            else
                mainFrame.Visible = true
                openBtn.Visible = false
                isOpen = true
                -- Перезапускаем снег при открытии (опционально)
            end
        end
    end)

    -- Если функции были включены до создания GUI, синхронизируем
    if State.esp then toggleESP() end
    if State.knifeAim then toggleKnifeAim() end
end

showKeyWindow()
