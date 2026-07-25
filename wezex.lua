-- Wezex Hub (фикс для Delta)
-- KEY: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
end)

local CORRECT_KEY = "38399923"

-- ========== СОСТОЯНИЕ ==========
local State = {
    aimbot = false,
    autoAttack = false,
    esp = false,
    speedEnabled = false,
    speed = 16,
}

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
end

local function setSpeed(v)
    State.speed = v
    applySpeed()
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

-- ========== GUI (простое, без анимаций) ==========
local screenGui
local mainFrame
local isOpen = true

local function createMainGUI()
    pcall(function()
        if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    end)

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WezexHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 280, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 20)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local subtitle = Instance.new("TextLabel", mainFrame)
    subtitle.Size = UDim2.new(1, 0, 0, 16)
    subtitle.Position = UDim2.new(0, 0, 0, 44)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 10
    subtitle.TextColor3 = Color3.fromRGB(150, 120, 200)
    subtitle.Text = "by @Fanqwezex"
    subtitle.TextXAlignment = Enum.TextXAlignment.Center

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -32, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    local content = Instance.new("ScrollingFrame", mainFrame)
    content.Size = UDim2.new(1, -16, 1, -70)
    content.Position = UDim2.new(0, 8, 0, 65)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 2
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 6)

    local function createToggle(label, value, callback)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, 0, 0, 36)
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
        btn.Size = UDim2.new(0, 56, 0, 24)
        btn.Position = UDim2.new(1, -64, 0.5, -12)
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

    local function createSlider(label, min, max, default, callback)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, 0, 0, 46)
        frame.BackgroundColor3 = Color3.fromRGB(22, 18, 35)
        frame.BackgroundTransparency = 0.4
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.7, 0, 0, 16)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(220, 210, 255)
        lbl.Text = label .. " (" .. default .. ")"
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local valueLbl = Instance.new("TextLabel", frame)
        valueLbl.Size = UDim2.new(0, 36, 0, 16)
        valueLbl.Position = UDim2.new(1, -42, 0, 0)
        valueLbl.BackgroundTransparency = 1
        valueLbl.Font = Enum.Font.GothamBold
        valueLbl.TextSize = 12
        valueLbl.TextColor3 = Color3.fromRGB(200, 150, 255)
        valueLbl.Text = tostring(default)
        valueLbl.TextXAlignment = Enum.TextXAlignment.Right

        local track = Instance.new("Frame", frame)
        track.Size = UDim2.new(0.92, 0, 0, 6)
        track.Position = UDim2.new(0.04, 0, 0.6, 0)
        track.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(200, 150, 255)
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

    -- Применяем сохранённые состояния
    if State.speedEnabled then toggleSpeed() end
    if State.aimbot then toggleAimbot() end
    if State.autoAttack then toggleAutoAttack() end
    if State.esp then toggleESP() end
end

-- ========== ЗАПУСК ==========
print("Запуск Wezex Hub...")
createMainGUI()
print("Готово!")
