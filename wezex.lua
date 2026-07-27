-- WEZEX HUB (RAINBOW + DRAGGABLE + WELCOME)
-- KEY: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Очистка
pcall(function()
    if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    if CoreGui:FindFirstChild("KeySystem") then CoreGui.KeySystem:Destroy() end
    if CoreGui:FindFirstChild("SplashScreen") then CoreGui.SplashScreen:Destroy() end
end)

local CORRECT_KEY = "38399923"
local State = {
    esp = false,
    knifeAim = false,
    noclip = false,
    infJump = false,
}
local screenGui, mainFrame, openBtn = nil, nil, nil
local snowParticles = {}
local snowConnection = nil
local noclipConnection = nil
local infJumpConnection = nil
local espHighlights = {}
local espConnections = {}
local originalThrow = nil
local KnifeController = nil
local rainbowConnection = nil
local dragging = false
local dragStart, startPos = nil, nil

-- ====== ESP ======
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
        local targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
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

-- ====== SILENT AIM ======
getgenv().KnifeConfig = { Enabled = false, HitPart = "Head", FOV = 450 }

local function getClosestTarget()
    local best, bestFOV = nil, getgenv().KnifeConfig.FOV
    local center = Camera.ViewportSize / 2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local part = plr.Character:FindFirstChild(getgenv().KnifeConfig.HitPart) or plr.Character:FindFirstChild("HumanoidRootPart")
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
                    local part = target.Character:FindFirstChild(getgenv().KnifeConfig.HitPart) or target.Character:FindFirstChild("HumanoidRootPart")
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

-- ====== NOCLIP ======
local function toggleNoclip()
    State.noclip = not State.noclip
    if State.noclip then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

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

-- ====== РАДУЖНЫЙ ЦВЕТ ======
local function getRainbowColor(offset)
    local time = tick() * 0.3
    local r = math.sin(time + offset) * 0.5 + 0.5
    local g = math.sin(time + offset + 2.09) * 0.5 + 0.5
    local b = math.sin(time + offset + 4.18) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

-- ====== ПЕРЕТАСКИВАНИЕ (ДЛЯ ТЕЛЕФОНА) ======
local function makeDraggable(frame)
    local dragging = false
    local dragStart, startPos = nil, nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ====== СНЕГ ======
local function stopSnow()
    if snowConnection then
        snowConnection:Disconnect()
        snowConnection = nil
    end
    for _, data in ipairs(snowParticles) do
        if data and data.frame and data.frame.Parent then
            data.frame:Destroy()
        end
    end
    snowParticles = {}
end

local function createSnow(parentFrame)
    stopSnow()
    if parentFrame.AbsoluteSize.X == 0 or parentFrame.AbsoluteSize.Y == 0 then
        parentFrame:WaitForChild("Size")
        task.wait(0.1)
    end

    local count = 20
    for i = 1, count do
        local snow = Instance.new("Frame")
        snow.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        snow.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, math.random() * 0.9 + 0.05, 0)
        snow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        snow.BackgroundTransparency = 0.2 + math.random() * 0.4
        snow.BorderSizePixel = 0
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = snow
        snow.Parent = parentFrame

        local data = {
            frame = snow,
            speed = 0.15 + math.random() * 0.35,
            drift = (math.random() - 0.5) * 0.5,
            startX = snow.Position.X.Scale,
            startY = snow.Position.Y.Scale,
            phase = math.random() * 2 * math.pi,
        }
        table.insert(snowParticles, data)
    end

    snowConnection = RunService.Stepped:Connect(function()
        if not parentFrame or not parentFrame.Parent or not parentFrame.Visible then return end
        local size = parentFrame.AbsoluteSize
        if size.X == 0 or size.Y == 0 then return end

        for _, data in ipairs(snowParticles) do
            if data and data.frame and data.frame.Parent then
                data.startY = data.startY + data.speed * 0.003
                data.phase = data.phase + 0.02
                local wave = math.sin(data.phase) * 0.015
                local xPos = data.startX + wave + data.drift * 0.002
                if data.startY > 0.95 then
                    data.startY = -0.05
                    data.startX = math.random() * 0.9 + 0.05
                    data.speed = 0.15 + math.random() * 0.35
                    data.drift = (math.random() - 0.5) * 0.5
                end
                xPos = math.clamp(xPos, 0.02, 0.98)
                local yPos = math.clamp(data.startY, -0.02, 0.95)
                data.frame.Position = UDim2.new(xPos, 0, yPos, 0)
            end
        end
    end)
end

-- ====== ГЛАВНОЕ МЕНЮ ======
function createMainGUI()
    pcall(function()
        if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    end)

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WezexHub"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Enabled = true

    -- РАДУЖНАЯ ОБВОДКА (GLOW)
    local glowFrame = Instance.new("Frame")
    glowFrame.Size = UDim2.new(0, 224, 0, 184)
    glowFrame.Position = UDim2.new(0.5, -112, 0.5, -92)
    glowFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    glowFrame.BackgroundTransparency = 0.2
    glowFrame.BorderSizePixel = 0
    glowFrame.Parent = screenGui
    Instance.new("UICorner").CornerRadius = UDim.new(0, 14)

    -- Анимация радужной обводки
    local glowBlur = Instance.new("BlurEffect")
    glowBlur.Size = 10
    glowBlur.Parent = glowFrame

    rainbowConnection = RunService.RenderStepped:Connect(function()
        glowFrame.BackgroundColor3 = getRainbowColor(0)
    end)

    -- КНОПКА ОТКРЫТИЯ
    openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 50, 0, 50)
    openBtn.Position = UDim2.new(0.02, 0, 0.04, 0)
    openBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 160)
    openBtn.BackgroundTransparency = 0.15
    openBtn.Text = "W"
    openBtn.TextSize = 24
    openBtn.TextColor3 = Color3.fromRGB(200, 150, 255)
    openBtn.Font = Enum.Font.GothamBold
    openBtn.Parent = screenGui
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
    openBtn.Visible = false
    makeDraggable(openBtn)

    openBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        openBtn.Visible = false
        glowFrame.Visible = true
    end)

    -- ОСНОВНОЕ МЕНЮ
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 220, 0, 180)
    mainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Parent = screenGui
    Instance.new("UICorner").CornerRadius = UDim.new(0, 14)
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = true
    makeDraggable(mainFrame)

    -- РАДУЖНЫЙ ЗАГОЛОВОК
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame

    -- Анимация радужного заголовка
    RunService.RenderStepped:Connect(function()
        title.TextColor3 = getRainbowColor(0.5)
    end)

    -- КНОПКА ЗАКРЫТИЯ
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = mainFrame
    Instance.new("UICorner").CornerRadius = UDim.new(0, 6)

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        openBtn.Visible = true
        glowFrame.Visible = false
    end)

    -- КОНТЕЙНЕР
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -14, 1, -48)
    content.Position = UDim2.new(0, 7, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.Parent = content

    -- ФУНКЦИЯ СОЗДАНИЯ ПЕРЕКЛЮЧАТЕЛЯ (С РАДУЖНЫМИ ЦВЕТАМИ)
    local function createToggle(label, stateKey, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 28)
        frame.BackgroundColor3 = Color3.fromRGB(22, 18, 35)
        frame.BackgroundTransparency = 0.4
        frame.Parent = content
        Instance.new("UICorner").CornerRadius = UDim.new(0, 10)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.55, 0, 1, 0)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextColor3 = Color3.fromRGB(220, 210, 255)
        lbl.Text = label
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        -- Радужный цвет для текста
        RunService.RenderStepped:Connect(function()
            lbl.TextColor3 = getRainbowColor(1.0)
        end)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 48, 0, 20)
        btn.Position = UDim2.new(1, -54, 0.5, -10)
        btn.TextSize = 9
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = frame
        Instance.new("UICorner").CornerRadius = UDim.new(0, 8)

        local function updateButton()
            if State[stateKey] then
                btn.BackgroundColor3 = getRainbowColor(0)
                btn.Text = "ON"
            else
                btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                btn.Text = "OFF"
            end
        end
        updateButton()

        btn.MouseButton1Click:Connect(function()
            callback()
            updateButton()
        end)
    end

    createToggle("ESP (Duels)", "esp", toggleESP)
    createToggle("Silent Aim", "knifeAim", toggleKnifeAim)
    createToggle("Noclip", "noclip", toggleNoclip)
    createToggle("Infinity Jump", "infJump", toggleInfJump)

    -- КЛАВИША ]
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightBracket then
            if mainFrame.Visible then
                mainFrame.Visible = false
                openBtn.Visible = true
                glowFrame.Visible = false
            else
                mainFrame.Visible = true
                openBtn.Visible = false
                glowFrame.Visible = true
            end
        end
    end)

    task.wait(0.05)
    createSnow(mainFrame)

    mainFrame.Visible = true
    openBtn.Visible = false
    glowFrame.Visible = true
end

-- ====== ПРИВЕТСТВИЕ ======
local function showWelcome()
    local splashGui = Instance.new("ScreenGui")
    splashGui.Name = "SplashScreen"
    splashGui.Parent = CoreGui
    splashGui.ResetOnSpawn = false
    splashGui.IgnoreGuiInset = true

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.Parent = splashGui

    local mainText = Instance.new("TextLabel")
    mainText.Size = UDim2.new(1, 0, 0, 70)
    mainText.Position = UDim2.new(0, 0, 0.3, 0)
    mainText.BackgroundTransparency = 1
    mainText.Font = Enum.Font.GothamBlack
    mainText.TextSize = 50
    mainText.Text = "ДОБРО ПОЖАЛОВАТЬ"
    mainText.TextXAlignment = Enum.TextXAlignment.Center
    mainText.TextYAlignment = Enum.TextYAlignment.Center
    mainText.Parent = splashGui

    local subText = Instance.new("TextLabel")
    subText.Size = UDim2.new(1, 0, 0, 40)
    subText.Position = UDim2.new(0, 0, 0.45, 0)
    subText.BackgroundTransparency = 1
    subText.Font = Enum.Font.GothamBold
    subText.TextSize = 28
    subText.Text = "Wezex Hub v4.1"
    subText.TextXAlignment = Enum.TextXAlignment.Center
    subText.TextYAlignment = Enum.TextYAlignment.Center
    subText.Parent = splashGui

    -- Анимация радужного текста
    RunService.RenderStepped:Connect(function()
        mainText.TextColor3 = getRainbowColor(0)
        subText.TextColor3 = getRainbowColor(1.5)
    end)

    task.wait(2)

    for i = 0, 10 do
        local alpha = 1 - (i / 10)
        overlay.BackgroundTransparency = 1 - alpha * 0.5
        mainText.TextTransparency = 1 - alpha
        subText.TextTransparency = 1 - alpha
        task.wait(0.05)
    end

    splashGui:Destroy()
    showKeyWindow()
end

-- ====== ОКНО КЛЮЧА ======
local function showKeyWindow()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    keyGui.ResetOnSpawn = false

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
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = panel

    -- Радужный заголовок в окне ключа
    Run
