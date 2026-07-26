-- Wezex Hub Final by @Fanqwezex
-- KEY: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

pcall(function()
    if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    if CoreGui:FindFirstChild("KeySystem") then CoreGui.KeySystem:Destroy() end
end)

local CORRECT_KEY = "38399923"
local State = {
    knifeAim = false,
    esp = false,
}

local screenGui
local mainFrame
local openBtn
local isOpen = false

-- ========== KNIFE AIM ==========
getgenv().KnifeConfig = {
    Enabled = false,
    HitPart = "Head",
    FOV = 450
}

local KnifeController = pcall(function()
    return require(LocalPlayer.PlayerScripts:WaitForChild("Controllers"):WaitForChild("Combat"):WaitForChild("KnifeController"))
end)

local function getClosestTarget()
    local bestTarget = nil
    local bestFOV = getgenv().KnifeConfig.FOV
    local center = Camera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hitPart = player.Character:FindFirstChild(getgenv().KnifeConfig.HitPart)
            if hitPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < bestFOV then
                        bestTarget = player
                        bestFOV = dist
                    end
                end
            end
        end
    end
    return bestTarget
end

local originalThrow = nil
local function toggleKnifeAim()
    State.knifeAim = not State.knifeAim
    getgenv().KnifeConfig.Enabled = State.knifeAim
    if State.knifeAim then
        if not originalThrow and KnifeController then
            originalThrow = KnifeController._GetThrowDirection
            KnifeController._GetThrowDirection = function(self, origin)
                if getgenv().KnifeConfig.Enabled then
                    local target = getClosestTarget()
                    if target and target.Character then
                        local hitPart = target.Character:FindFirstChild(getgenv().KnifeConfig.HitPart)
                        if hitPart then
                            return (hitPart.Position - origin.Position).Unit
                        end
                    end
                end
                return originalThrow(self, origin)
            end
        end
    else
        if originalThrow and KnifeController then
            KnifeController._GetThrowDirection = originalThrow
            originalThrow = nil
        end
    end
end

-- ========== ESP ==========
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
    local function setupHighlight(character)
        local old = character:FindFirstChild("WezexESP")
        if old then old:Destroy() end
        local h = Instance.new("Highlight")
        h.Name = "WezexESP"
        h.FillColor = Color3.fromRGB(255, 0, 0)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.FillTransparency = 0.4
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = character
        table.insert(espHighlights, h)
    end
    if player.Character then setupHighlight(player.Character) end
    local conn = player.CharacterAdded:Connect(setupHighlight)
    table.insert(espConnections, conn)
end

local function toggleESP()
    State.esp = not State.esp
    if State.esp then
        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
        local conn = Players.PlayerAdded:Connect(applyESP)
        table.insert(espConnections, conn)
    else
        clearESP()
    end
end

-- ========== СНЕЖИНКИ ==========
local function createSnowflakes(parent)
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

-- ========== ОКНО КЛЮЧА ==========
local function showKeyWindow()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    keyGui.ResetOnSpawn = false

    local main = Instance.new("Frame", keyGui)
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    main.BackgroundTransparency = 0.1

    createSnowflakes(main)

    local panel = Instance.new("Frame", main)
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

    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then enterBtn.MouseButton1Click:Fire() end
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

    createSnowflakes(screenGui)

    -- Кнопка возврата (W)
    openBtn = Instance.new("TextButton", screenGui)
    openBtn.Name = "OpenBtn"
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

    -- Основное меню
    mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 200, 0, 130)
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -65)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 26)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
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

    local function createToggle(label, value, callback)
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
        btn.BackgroundColor3 = value and Color3.fromRGB(80, 220, 160) or Color3.fromRGB(50, 30, 70)
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.Text = value and "ON" or "OFF"
        btn.TextSize = 9
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

    createToggle("Knife Aim", State.knifeAim, function(v)
        State.knifeAim = v
        toggleKnifeAim()
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

    if State.knifeAim then toggleKnifeAim() end
    if State.esp then toggleESP() end
end

showKeyWindow()
