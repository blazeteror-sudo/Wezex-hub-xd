-- Wezex Hub Winter Edition by @Fanqwezex
-- KEY: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    if CoreGui:FindFirstChild("KeySystem") then CoreGui.KeySystem:Destroy() end
end)

local CORRECT_KEY = "38399923"
local State = {
    silentAim = false,
    esp = false,
}

local screenGui
local mainFrame
local openBtn
local isOpen = false

local function getChar() return LocalPlayer.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getClosestPlayer()
    local hrp = getHRP()
    if not hrp then return nil end
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local t = plr.Character:FindFirstChild("HumanoidRootPart")
            if t then
                local d = (t.Position - hrp.Position).Magnitude
                if d < dist then
                    closest, dist = plr, d
                end
            end
        end
    end
    return closest
end

local function getTool()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Tool")
end

local function attack()
    local tool = getTool()
    if tool then tool:Activate() end
end

-- ========== SILENT AIM ==========
local silentAimConn = nil
local function toggleSilentAim()
    State.silentAim = not State.silentAim
    if silentAimConn then silentAimConn:Disconnect(); silentAimConn = nil end
    if State.silentAim then
        silentAimConn = RunService.Heartbeat:Connect(function()
            if not State.silentAim then return end
            local target = getClosestPlayer()
            if target and target.Character then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Silent Aim: направляем оружие, а не камеру
                    local char = getChar()
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            local handle = tool:FindFirstChild("Handle") or tool
                            local cf = handle.CFrame
                            handle.CFrame = CFrame.new(cf.Position, hrp.Position)
                        end
                    end
                end
            end
        end)
    end
end

-- ========== ESP (оптимизированный) ==========
local espHighlights = {}
local espConnections = {}
local espUpdateCooldown = 0

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

local function updateESP()
    if not State.esp then
        clearESP()
        return
    end
    clearESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local c = plr.Character
            if c then
                local h = Instance.new("Highlight")
                h.Adornee = c
                h.FillColor = Color3.fromRGB(0, 200, 255)
                h.FillTransparency = 0.25
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.OutlineTransparency = 0.15
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = c
                table.insert(espHighlights, h)
            end
        end
    end
end

local function toggleESP()
    State.esp = not State.esp
    if State.esp then
        updateESP()
        local conn1 = Players.PlayerAdded:Connect(function() updateESP() end)
        local conn2 = Players.PlayerRemoving:Connect(function() updateESP() end)
        table.insert(espConnections, conn1)
        table.insert(espConnections, conn2)
    else
        clearESP()
    end
end

-- Обновление ESP с задержкой для оптимизации
RunService.Heartbeat:Connect(function()
    if State.esp then
        espUpdateCooldown = espUpdateCooldown + 1
        if espUpdateCooldown >= 10 then
            espUpdateCooldown = 0
            updateESP()
        end
    end
end)

-- ========== ЗИМНИЙ ФОН (ДЛЯ ОКНА КЛЮЧА) ==========
local function createWinterBackground(parent)
    local sky = Instance.new("Frame", parent)
    sky.Size = UDim2.new(1, 0, 1, 0)
    sky.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    sky.BackgroundTransparency = 0.1
    sky.ZIndex = 0

    local ground = Instance.new("Frame", parent)
    ground.Size = UDim2.new(1, 0, 0.15, 0)
    ground.Position = UDim2.new(0, 0, 0.85, 0)
    ground.BackgroundColor3 = Color3.fromRGB(200, 210, 220)
    ground.BackgroundTransparency = 0.2
    ground.ZIndex = 1

    for i = 1, 6 do
        local hill = Instance.new("Frame", parent)
        hill.Size = UDim2.new(0.15, 0, 0.06, 0)
        hill.Position = UDim2.new(i * 0.14 - 0.05, 0, 0.86, 0)
        hill.BackgroundColor3 = Color3.fromRGB(220, 230, 240)
        hill.BackgroundTransparency = 0.3
        hill.ZIndex = 2
        Instance.new("UICorner", hill).CornerRadius = UDim.new(1, 0)
    end

    local snowflakes = {}
    for i = 1, 35 do
        local flake = Instance.new("Frame", parent)
        flake.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        flake.Position = UDim2.new(math.random() * 0.95, 0, math.random() * 0.95, 0)
        flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        flake.BackgroundTransparency = 0.2 + math.random() * 0.4
        flake.BorderSizePixel = 0
        flake.ZIndex = 10
        Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)
        flake.Rotation = math.random(-30, 30)
        local data = {
            obj = flake,
            speed = 0.2 + math.random() * 0.4,
            drift = 0.003 + math.random() * 0.008,
            phase = math.random() * math.pi * 2,
            startX = flake.Position.X.Scale,
        }
        table.insert(snowflakes, data)
    end

    RunService.RenderStepped:Connect(function()
        for _, flake in ipairs(snowflakes) do
            if flake.obj and flake.obj.Parent then
                local newY = flake.obj.Position.Y.Scale + flake.speed * 0.002
                if newY > 1 then
                    newY = -0.05
                    flake.obj.Position = UDim2.new(math.random() * 0.95, 0, newY, 0)
                    flake.startX = flake.obj.Position.X.Scale
                else
                    local driftX = flake.startX + math.sin(tick() * flake.drift + flake.phase) * 0.04
                    flake.obj.Position = UDim2.new(driftX, 0, newY, 0)
                end
                flake.obj.Rotation = flake.obj.Rotation + (0.3 + math.random() * 0.5)
            end
        end
    end)
end

-- ========== ОКНО ВВОДА КЛЮЧА ==========
local function showKeyWindow()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    keyGui.ResetOnSpawn = false

    local main = Instance.new("Frame", keyGui)
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
    main.BackgroundTransparency = 0.1

    createWinterBackground(main)

    local panel = Instance.new("Frame", main)
    panel.Size = UDim2.new(0, 320, 0, 200)
    panel.Position = UDim2.new(0.5, -160, 0.5, -100)
    panel.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    panel.BackgroundTransparency = 0.4
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)
    local stroke = Instance.new("UIStroke", panel)
    stroke.Color = Color3.fromRGB(150, 200, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(200, 230, 255)
    title.Text = "❄ Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local subtitle = Instance.new("TextLabel", panel)
    subtitle.Size = UDim2.new(1, 0, 0, 18)
    subtitle.Position = UDim2.new(0, 0, 0, 44)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 10
    subtitle.TextColor3 = Color3.fromRGB(160, 190, 220)
    subtitle.Text = "by @Fanqwezex"
    subtitle.TextXAlignment = Enum.TextXAlignment.Center

    local info = Instance.new("TextLabel", panel)
    info.Size = UDim2.new(1, 0, 0, 18)
    info.Position = UDim2.new(0, 0, 0, 72)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextColor3 = Color3.fromRGB(180, 200, 220)
    info.Text = "Введите ключ для доступа"
    info.TextXAlignment = Enum.TextXAlignment.Center

    local keyBox = Instance.new("TextBox", panel)
    keyBox.Size = UDim2.new(0.6, 0, 0, 36)
    keyBox.Position = UDim2.new(0.2, 0, 0, 100)
    keyBox.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    keyBox.BackgroundTransparency = 0.3
    keyBox.BorderSizePixel = 0
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    keyBox.Font = Enum.Font.GothamBold
    keyBox.TextSize = 16
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Text = ""
    keyBox.PlaceholderText = "Введите ключ"
    keyBox.PlaceholderColor3 = Color3.fromRGB(120, 150, 180)
    keyBox.ClearTextOnFocus = false
    local keyStroke = Instance.new("UIStroke", keyBox)
    keyStroke.Color = Color3.fromRGB(150, 200, 255)
    keyStroke.Thickness = 1
    keyStroke.Transparency = 0.3

    local enterBtn = Instance.new("TextButton", panel)
    enterBtn.Size = UDim2.new(0.3, 0, 0, 36)
    enterBtn.Position = UDim2.new(0.35, 0, 0, 148)
    enterBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    enterBtn.BackgroundTransparency = 0.2
    enterBtn.BorderSizePixel = 0
    Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 8)
    enterBtn.Text = "Войти ❄"
    enterBtn.TextSize = 14
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.Font = Enum.Font.GothamBold
    local enterStroke = Instance.new("UIStroke", enterBtn)
    enterStroke.Color = Color3.fromRGB(150, 200, 255)
    enterStroke.Thickness = 1
    enterStroke.Transparency = 0.3

    enterBtn.MouseButton1Click:Connect(function()
        if keyBox.Text == CORRECT_KEY then
            keyGui:Destroy()
            createMainGUI()
        else
            keyBox.Text = ""
            keyBox.PlaceholderText = "Неверный ключ!"
            keyBox.PlaceholderColor3 = Color3.fromRGB(255, 80, 80)
            enterBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            task.wait(0.5)
            enterBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
            keyBox.PlaceholderText = "Введите ключ"
            keyBox.PlaceholderColor3 = Color3.fromRGB(120, 150, 180)
        end
    end)

    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            enterBtn.MouseButton1Click:Fire()
        end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Return then
            enterBtn.MouseButton1Click:Fire()
        end
    end)
end

-- ========== ОСНОВНОЕ МЕНЮ ==========
function createMainGUI()
    pcall(function()
        if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    end)

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WezexHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    -- ========== КНОПКА ВОЗВРАТА ==========
    openBtn = Instance.new("TextButton", screenGui)
    openBtn.Name = "OpenBtn"
    openBtn.Size = UDim2.new(0, 55, 0, 55)
    openBtn.Position = UDim2.new(0.02, 0, 0.04, 0)
    openBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    openBtn.BackgroundTransparency = 0.2
    openBtn.BorderSizePixel = 0
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    local btnStroke = Instance.new("UIStroke", openBtn)
    btnStroke.Color = Color3.fromRGB(150, 200, 255)
    btnStroke.Thickness = 1.5
    btnStroke.Transparency = 0.3
    openBtn.Text = "❄"
    openBtn.TextSize = 22
    openBtn.TextColor3 = Color3.fromRGB(200, 230, 255)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.Visible = false

    openBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        openBtn.Visible = false
        isOpen = true
    end)

    -- ========== ОСНОВНОЕ МЕНЮ ==========
    mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 260, 0, 220)
    mainFrame.Position = UDim2.new(0.5, -130, 0.5, -110)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 32)
    title.Position = UDim2.new(0, 0, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local subtitle = Instance.new("TextLabel", mainFrame)
    subtitle.Size = UDim2.new(1, 0, 0, 16)
    subtitle.Position = UDim2.new(0, 0, 0, 38)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 10
    subtitle.TextColor3 = Color3.fromRGB(150, 120, 200)
    subtitle.Text = "by @Fanqwezex"
    subtitle.TextXAlignment = Enum.TextXAlignment.Center

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -32, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        openBtn.Visible = true
        isOpen = false
    end)

    local content = Instance.new("Frame", mainFrame)
    content.Size = UDim2.new(1, -16, 1, -70)
    content.Position = UDim2.new(0, 8, 0, 60)
    content.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 8)

    local function createToggle(label, value, callback)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, 0, 0, 34)
        frame.BackgroundColor3 = Color3.fromRGB(22, 18, 35)
        frame.BackgroundTransparency = 0.4
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.55, 0, 1, 0)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(220, 210, 255)
        lbl.Text = label
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 54, 0, 22)
        btn.Position = UDim2.new(1, -62, 0.5, -11)
        btn.BackgroundColor3 = value and Color3.fromRGB(80, 220, 160) or Color3.fromRGB(50, 30, 70)
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.Text = value and "ON" or "OFF"
        btn.TextSize = 10
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold

        local state = value
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(80, 220, 160) or Color3.fromRGB(50, 30, 70)
            btn.Text = state and "ON" or "OFF"
            callback(state)
        end)
    end

    createToggle("Silent Aim", State.silentAim, function(v)
        State.silentAim = v
        toggleSilentAim()
    end)

    createToggle("Player ESP", State.esp, function(v)
        State.esp = v
        toggleESP()
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
            end
        end
    end)

    -- Применяем состояния
    if State.silentAim then toggleSilentAim() end
    if State.esp then toggleESP() end
end

-- ========== ЗАПУСК ==========
showKeyWindow()
