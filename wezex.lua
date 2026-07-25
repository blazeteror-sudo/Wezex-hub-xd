-- Wezex Hub Winter Edition by @Fanqwezex
-- KEY: 38399923

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

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

local CONFIG_FILE = "wezex_winter_config.json"

local function save()
    local cfg = {}
    for k, v in pairs(State) do cfg[k] = v end
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(cfg)) end)
end

local function load()
    if not isfile or not isfile(CONFIG_FILE) then return end
    local ok, raw = pcall(function() return readfile(CONFIG_FILE) end)
    if ok and raw then
        local ok2, cfg = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok2 and cfg then
            for k, v in pairs(cfg) do
                if State[k] ~= nil then State[k] = v end
            end
        end
    end
end

local function getChar() return LocalPlayer.Character end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChild("Humanoid")
end
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

-- ========== SPEED ==========
local function applySpeed()
    local h = getHum()
    if h then
        h.WalkSpeed = State.speedEnabled and State.speed or 16
    end
end

local function toggleSpeed()
    State.speedEnabled = not State.speedEnabled
    applySpeed()
    save()
end

local function setSpeed(v)
    State.speed = v
    applySpeed()
    save()
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applySpeed()
end)

-- ========== AIMBOT ==========
local aimbotConn = nil
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
    save()
end

-- ========== AUTO ATTACK ==========
local autoAttackConn = nil
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
    save()
end

-- ========== ESP ==========
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
                h.FillColor = Color3.fromRGB(100, 200, 255)
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
    save()
end

RunService.Heartbeat:Connect(function()
    if State.esp then updateESP() end
end)

-- ========== ЗИМНИЙ ФОН ==========
local function createWinterBackground(parent)
    local sky = Instance.new("Frame", parent)
    sky.Size = UDim2.new(1, 0, 1, 0)
    sky.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    sky.BackgroundTransparency = 0.1
    sky.ZIndex = 0

    local ground = Instance.new("Frame", parent)
    ground.Size = UDim2.new(1, 0, 0.2, 0)
    ground.Position = UDim2.new(0, 0, 0.8, 0)
    ground.BackgroundColor3 = Color3.fromRGB(200, 210, 220)
    ground.BackgroundTransparency = 0.2
    ground.ZIndex = 1

    for i = 1, 8 do
        local hill = Instance.new("Frame", parent)
        hill.Size = UDim2.new(0.15, 0, 0.08, 0)
        hill.Position = UDim2.new(i * 0.12 - 0.05, 0, 0.82, 0)
        hill.BackgroundColor3 = Color3.fromRGB(220, 230, 240)
        hill.BackgroundTransparency = 0.3
        hill.ZIndex = 2
        Instance.new("UICorner", hill).CornerRadius = UDim.new(1, 0)
    end

    for _, pos in ipairs({0.05, 0.15, 0.85, 0.92}) do
        local tree = Instance.new("Frame", parent)
        tree.Size = UDim2.new(0.04, 0, 0.1, 0)
        tree.Position = UDim2.new(pos, 0, 0.72, 0)
        tree.BackgroundColor3 = Color3.fromRGB(30, 70, 40)
        tree.BackgroundTransparency = 0.2
        tree.ZIndex = 3
        Instance.new("UICorner", tree).CornerRadius = UDim.new(0, 2)
    end

    for i = 1, 4 do
        local window = Instance.new("Frame", parent)
        window.Size = UDim2.new(0.02, 0, 0.04, 0)
        window.Position = UDim2.new(0.02 + i * 0.08, 0, 0.7, 0)
        window.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
        window.BackgroundTransparency = 0.3
        window.ZIndex = 2
        Instance.new("UICorner", window).CornerRadius = UDim.new(0, 1)
    end

    local snowflakes = {}
    for i = 1, 50 do
        local flake = Instance.new("Frame", parent)
        flake.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        flake.Position = UDim2.new(math.random() * 0.95, 0, math.random() * 0.95, 0)
        flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        flake.BackgroundTransparency = 0.2 + math.random() * 0.4
        flake.BorderSizePixel = 0
        flake.ZIndex = 10
        Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)
        flake.Rotation = math.random(-30, 30)
        local data = {
            obj = flake,
            speed = 0.3 + math.random() * 0.5,
            drift = 0.005 + math.random() * 0.01,
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
                    local driftX = flake.startX + math.sin(tick() * flake.drift + flake.phase) * 0.05
                    flake.obj.Position = UDim2.new(driftX, 0, newY, 0)
                end
                flake.obj.Rotation = flake.obj.Rotation + (0.5 + math.random() * 0.5)
            end
        end
    end)
end

-- ========== GUI ==========
local screenGui
local mainFrame
local openBtn

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
    panel.Size = UDim2.new(0, 360, 0, 220)
    panel.Position = UDim2.new(0.5, -180, 0.5, -110)
    panel.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    panel.BackgroundTransparency = 0.4
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 20)
    local stroke = Instance.new("UIStroke", panel)
    stroke.Color = Color3.fromRGB(150, 200, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 26
    title.TextColor3 = Color3.fromRGB(200, 230, 255)
    title.Text = "❄ Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local subtitle = Instance.new("TextLabel", panel)
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 55)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.TextColor3 = Color3.fromRGB(160, 190, 220)
    subtitle.Text = "by @Fanqwezex   |   Winter Edition"
    subtitle.TextXAlignment = Enum.TextXAlignment.Center

    local info = Instance.new("TextLabel", panel)
    info.Size = UDim2.new(1, 0, 0, 20)
    info.Position = UDim2.new(0, 0, 0, 85)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 13
    info.TextColor3 = Color3.fromRGB(180, 200, 220)
    info.Text = "Введите ключ для доступа"
    info.TextXAlignment = Enum.TextXAlignment.Center

    local keyBox = Instance.new("TextBox", panel)
    keyBox.Size = UDim2.new(0.6, 0, 0, 40)
    keyBox.Position = UDim2.new(0.2, 0, 0, 115)
    keyBox.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    keyBox.BackgroundTransparency = 0.3
    keyBox.BorderSizePixel = 0
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 10)
    keyBox.Font = Enum.Font.GothamBold
    keyBox.TextSize = 18
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
    enterBtn.Size = UDim2.new(0.35, 0, 0, 40)
    enterBtn.Position = UDim2.new(0.325, 0, 0, 168)
    enterBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    enterBtn.BackgroundTransparency = 0.2
    enterBtn.BorderSizePixel = 0
    Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 10)
    enterBtn.Text = "Войти ❄"
    enterBtn.TextSize = 16
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

function createMainGUI()
    pcall(function()
        if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    end)

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WezexHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    -- ========== КНОПКА ВОЗВРАТА МЕНЮ ==========
    openBtn = Instance.new("TextButton", screenGui)
    openBtn.Name = "OpenBtn"
    openBtn.Size = UDim2.new(0, 60, 0, 60)
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
    openBtn.TextSize = 24
    openBtn.TextColor3 = Color3.fromRGB(200, 230, 255)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.Visible = false

    openBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        openBtn.Visible = false
    end)

    -- ========== ОСНОВНОЕ МЕНЮ ==========
    mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 360, 0, 460)
    mainFrame.Position = UDim2.new(0.5, -180, 0.5, -230)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 24)
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(150, 200, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(200, 230, 255)
    title.Text = "❄ Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local subtitle = Instance.new("TextLabel", mainFrame)
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 55)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.TextColor3 = Color3.fromRGB(160, 190, 220)
    subtitle.Text = "by @Fanqwezex   |   Winter Edition"
    subtitle.TextXAlignment = Enum.TextXAlignment.Center

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.fromRGB(200, 230, 255)
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        openBtn.Visible = true
    end)

    local content = Instance.new("ScrollingFrame", mainFrame)
    content.Size = UDim2.new(1, -24, 1, -90)
    content.Position = UDim2.new(0, 12, 0, 80)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(150, 200, 255)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 10)

    local function createToggle(label, value, callback)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(30, 50, 70)
        frame.BackgroundTransparency = 0.3
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(220, 240, 255)
        lbl.Text = label
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 70, 0, 32)
        btn.Position = UDim2.new(1, -80, 0.5, -16)
        btn.BackgroundColor3 = value and Color3.fromRGB(100, 220, 180) or Color3.fromRGB(60, 80, 100)
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.Text = value and "ON" or "OFF"
        btn.TextSize = 12
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold

        local state = value
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(100, 220, 180) or Color3.fromRGB(60, 80, 100)
            btn.Text = state and "ON" or "OFF"
            callback(state)
        end)
    end

    local function createSlider(label, min, max, default, callback)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, 0, 0, 55)
        frame.BackgroundColor3 = Color3.fromRGB(30, 50, 70)
        frame.BackgroundTransparency = 0.3
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.7, 0, 0, 20)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(220, 240, 255)
        lbl.Text = label .. " (" .. default .. ")"
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local valueLbl = Instance.new("TextLabel", frame)
        valueLbl.Size = UDim2.new(0, 50, 0, 20)
        valueLbl.Position = UDim2.new(1, -55, 0, 0)
        valueLbl.BackgroundTransparency = 1
        valueLbl.Font = Enum.Font.GothamBold
        valueLbl.TextSize = 14
        valueLbl.TextColor3 = Color3.fromRGB(150, 200, 255)
        valueLbl.Text = tostring(default)
        valueLbl.
