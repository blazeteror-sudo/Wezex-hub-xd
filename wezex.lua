-- Wezex Hub (исправленный, окно ключа гарантированно появляется)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

pcall(function()
    if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    if CoreGui:FindFirstChild("KeySystem") then CoreGui.KeySystem:Destroy() end
end)

local CORRECT_KEY = "38399923"
local State = {
    aimbot = false,
    autoAttack = false,
    esp = false,
    speedEnabled = false,
    speed = 16,
}

-- ========== ОКНО ВВОДА КЛЮЧА ==========
local function showKeyWindow()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    keyGui.ResetOnSpawn = false

    local main = Instance.new("Frame", keyGui)
    main.Size = UDim2.new(0, 320, 0, 180)
    main.Position = UDim2.new(0.5, -160, 0.5, -90)
    main.BackgroundColor3 = Color3.fromRGB(8, 5, 15)
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local subtitle = Instance.new("TextLabel", main)
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 35)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.TextColor3 = Color3.fromRGB(160, 120, 200)
    subtitle.Text = "by @Fanqwezex"
    subtitle.TextXAlignment = Enum.TextXAlignment.Center

    local info = Instance.new("TextLabel", main)
    info.Size = UDim2.new(1, 0, 0, 20)
    info.Position = UDim2.new(0, 0, 0, 65)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextColor3 = Color3.fromRGB(180, 160, 200)
    info.Text = "Введите ключ для доступа"
    info.TextXAlignment = Enum.TextXAlignment.Center

    local keyBox = Instance.new("TextBox", main)
    keyBox.Size = UDim2.new(0.7, 0, 0, 35)
    keyBox.Position = UDim2.new(0.15, 0, 0, 90)
    keyBox.BackgroundColor3 = Color3.fromRGB(20, 12, 32)
    keyBox.BorderSizePixel = 0
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    keyBox.Font = Enum.Font.GothamBold
    keyBox.TextSize = 16
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Text = ""
    keyBox.PlaceholderText = "Введите ключ"
    keyBox.PlaceholderColor3 = Color3.fromRGB(120, 100, 140)
    keyBox.ClearTextOnFocus = false

    local enterBtn = Instance.new("TextButton", main)
    enterBtn.Size = UDim2.new(0.4, 0, 0, 35)
    enterBtn.Position = UDim2.new(0.3, 0, 0, 135)
    enterBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
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
            keyBox.PlaceholderText = "Неверный ключ!"
            keyBox.PlaceholderColor3 = Color3.fromRGB(255, 50, 50)
            enterBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.wait(0.5)
            enterBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
            keyBox.PlaceholderText = "Введите ключ"
            keyBox.PlaceholderColor3 = Color3.fromRGB(120, 100, 140)
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

    -- Кнопка закрытия (выход)
    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 80)
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.MouseButton1Click:Connect(function()
        keyGui:Destroy()
    end)
end

-- ========== ОСНОВНОЙ GUI ==========
function createMainGUI()
    pcall(function()
        if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    end)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WezexHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 340, 0, 440)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -220)
    mainFrame.BackgroundColor3 = Color3.fromRGB(8, 5, 15)
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local subtitle = Instance.new("TextLabel", mainFrame)
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 40)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.TextColor3 = Color3.fromRGB(160, 120, 200)
    subtitle.Text = "by @Fanqwezex"
    subtitle.TextXAlignment = Enum.TextXAlignment.Center

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 80)
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    local content = Instance.new("ScrollingFrame", mainFrame)
    content.Size = UDim2.new(1, -20, 1, -80)
    content.Position = UDim2.new(0, 10, 0, 65)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 8)

    -- Переключатели
    local function createToggle(label, value, callback)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, 0, 0, 45)
        frame.BackgroundColor3 = Color3.fromRGB(25, 15, 40)
        frame.BackgroundTransparency = 0.5
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(230, 210, 255)
        lbl.Text = label
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 65, 0, 28)
        btn.Position = UDim2.new(1, -72, 0.5, -14)
        btn.BackgroundColor3 = value and Color3.fromRGB(100, 255, 180) or Color3.fromRGB(60, 30, 80)
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.Text = value and "ON" or "OFF"
        btn.TextSize = 12
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold

        local state = value
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(100, 255, 180) or Color3.fromRGB(60, 30, 80)
            btn.Text = state and "ON" or "OFF"
            callback(state)
        end)
    end

    local function createSlider(label, min, max, default, callback)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, 0, 0, 55)
        frame.BackgroundColor3 = Color3.fromRGB(25, 15, 40)
        frame.BackgroundTransparency = 0.5
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.7, 0, 0, 20)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(230, 210, 255)
        lbl.Text = label .. " (" .. default .. ")"
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local valueLbl = Instance.new("TextLabel", frame)
        valueLbl.Size = UDim2.new(0, 50, 0, 20)
        valueLbl.Position = UDim2.new(1, -55, 0, 0)
        valueLbl.BackgroundTransparency = 1
        valueLbl.Font = Enum.Font.GothamBold
        valueLbl.TextSize = 14
        valueLbl.TextColor3 = Color3.fromRGB(180, 80, 255)
        valueLbl.Text = tostring(default)
        valueLbl.TextXAlignment = Enum.TextXAlignment.Right

        local track = Instance.new("Frame", frame)
        track.Size = UDim2.new(0.92, 0, 0, 8)
        track.Position = UDim2.new(0.04, 0, 0.6, 0)
        track.BackgroundColor3 = Color3.fromRGB(15, 8, 25)
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

        local dragging = false
        local current = default

        track.MouseButton1Down:Connect(function()
            dragging = true
            local pos = UserInputService:GetMouseLocation().X
            local absX = track.AbsolutePosition.X
            local sizeX = track.AbsoluteSize.X
            local pct = math.clamp((pos - absX) / sizeX, 0, 1)
            current = math.floor(min + (max - min) * pct)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            lbl.Text = label .. " (" .. current .. ")"
            valueLbl.Text = tostring(current)
            callback(current)
        end)
        track.MouseButton1Up:Connect(function()
            dragging = false
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local pos = input.Position.X
            local absX = track.AbsolutePosition.X
            local sizeX = track.AbsoluteSize.X
            local pct = math.clamp((pos - absX) / sizeX, 0, 1)
            current = math.floor(min + (max - min) * pct)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            lbl.Text = label .. " (" .. current .. ")"
            valueLbl.Text = tostring(current)
            callback(current)
        end)
    end

    -- Функции
    local function getChar() return LocalPlayer.Character end
    local function getHum()
        local c = getChar()
        return c and c:FindFirstChild("Humanoid")
    end
    local function getHRP()
        local c = getChar()
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    local function applySpeed()
        local h = getHum()
        if h then h.WalkSpeed = State.speedEnabled and State.speed or 16 end
    end

    local function toggleSpeed()
        State.speedEnabled = not State.speedEnabled
        applySpeed()
    end

    local function setSpeed(v)
        State.speed = v
        applySpeed()
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        applySpeed()
    end)

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

    local aimbotConn, autoAttackConn

    local function toggleAimbot()
        State.aimbot = not State.aimbot
        if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
        if State.aimbot then
            aimbotConn = RunService.Heartbeat:Connect(function()
                if not State.aimbot then return end
                local target = getClosestPlayer()
                if target and target.Character then
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local root = getHRP()
                        if root then
                            root.CFrame = CFrame.new(root.Position, hrp.Position)
                        end
                    end
                end
            end)
        end
    end

    local function toggleAutoAttack()
        State.autoAttack = not State.autoAttack
        if autoAttackConn then autoAttackConn:Disconnect(); autoAttackConn = nil end
        if State.autoAttack then
            autoAttackConn = RunService.Heartbeat:Connect(function()
                if not State.autoAttack then return end
                local target = getClosestPlayer()
                if target and target.Character then
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    local root = getHRP()
                    if hrp and root then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist < 8 then
                            attack()
                        end
                    end
                end
            end)
        end
    end

    local espHighlights = {}
    local function clearESP()
        for _, h in ipairs(espHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        espHighlights = {}
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
                    h.FillTransparency = 0.3
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.OutlineTransparency = 0.2
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
            Players.PlayerAdded:Connect(function() updateESP() end)
            Players.PlayerRemoving:Connect(function() updateESP() end)
        else
            clearESP()
        end
    end

    RunService.Heartbeat:Connect(function()
        if State.esp then updateESP() end
    end)

    createToggle("Aimbot", State.aimbot, function(v)
        State.aimbot = v
        toggleAimbot()
    end)

    createToggle("Auto Attack", State.autoAttack, function(v)
        State.autoAttack = v
        toggleAutoAttack()
    end)

    createToggle("Player ESP", State.esp, function(v)
        State.esp = v
        toggleESP()
    end)

    createToggle("Speed", State.speedEnabled, function(v)
        State.speedEnabled = v
        toggleSpeed()
    end)

    createSlider("Speed", 16, 120, State.speed, function(v)
        setSpeed(v)
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightBracket then
            screenGui.Enabled = not screenGui.Enabled
        end
    end)

    if State.speedEnabled then toggleSpeed() end
    if State.aimbot then toggleAimbot() end
    if State.autoAttack then toggleAutoAttack() end
    if State.esp then toggleESP() end
end

-- ========== ЗАПУСК ==========
showKeyWindow()
