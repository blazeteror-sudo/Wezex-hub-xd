-- WEZEX HUB (TOGGLE SWITCH STYLE)
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
local currentTab = "Combat"
local contentContainer = nil

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

-- ====== КРАСИВЫЙ ПЕРЕКЛЮЧАТЕЛЬ (TOGGLE SWITCH) ======
local function createToggleSwitch(label, stateKey, callback, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 28)
    frame.BackgroundColor3 = Color3.fromRGB(22, 18, 35)
    frame.BackgroundTransparency = 0.4
    frame.Parent = parent
    Instance.new("UICorner").CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0.04, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(220, 210, 255)
    lbl.Text = label
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    -- КОНТЕЙНЕР ДЛЯ СВИТЧА
    local switchContainer = Instance.new("Frame")
    switchContainer.Size = UDim2.new(0, 40, 0, 22)
    switchContainer.Position = UDim2.new(1, -46, 0.5, -11)
    switchContainer.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    switchContainer.BorderSizePixel = 0
    switchContainer.Parent = frame
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)

    -- КРУГЛАЯ РУЧКА
    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 18, 0, 18)
    handle.Position = UDim2.new(0, 2, 0.5, -9)
    handle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    handle.BorderSizePixel = 0
    handle.Text = ""
    handle.Parent = switchContainer
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)

    local function updateSwitch()
        if State[stateKey] then
            switchContainer.BackgroundColor3 = Color3.fromRGB(80, 220, 160)
            handle.Position = UDim2.new(0, 20, 0.5, -9)
            handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            switchContainer.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            handle.Position = UDim2.new(0, 2, 0.5, -9)
            handle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    updateSwitch()

    handle.MouseButton1Click:Connect(function()
        callback()
        updateSwitch()
    end)

    -- Клик по всему контейнеру тоже работает
    switchContainer.MouseButton1Click:Connect(function()
        callback()
        updateSwitch()
    end)
end

local function updateContent()
    if not contentContainer then return end
    for _, child in ipairs(contentContainer:GetChildren()) do
        child:Destroy()
    end

    if currentTab == "Combat" then
        createToggleSwitch("Silent Aim", "knifeAim", toggleKnifeAim, contentContainer)
    elseif currentTab == "Movement" then
        createToggleSwitch("Noclip", "noclip", toggleNoclip, contentContainer)
        createToggleSwitch("Infinity Jump", "infJump", toggleInfJump, contentContainer)
    elseif currentTab == "Visuals" then
        createToggleSwitch("ESP (Duels)", "esp", toggleESP, contentContainer)
    end
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

    openBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        openBtn.Visible = false
    end)

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 220, 0, 170)
    mainFrame.Position = UDim2.new(0.5, -110, 0.5, -85)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Parent = screenGui
    Instance.new("UICorner").CornerRadius = UDim.new(0, 14)
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = true

    -- ЗАГОЛОВОК
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 26)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame

    -- КНОПКА ЗАКРЫТИЯ
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Parent = mainFrame
    Instance.new("UICorner").CornerRadius = UDim.new(0, 6)

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        openBtn.Visible = true
    end)

    -- КОНТЕЙНЕР ТАБОВ
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -14, 0, 26)
    tabContainer.Position = UDim2.new(0, 7, 0, 34)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local tabs = {"Combat", "Movement", "Visuals"}
    local tabButtons = {}
    local tabWidth = 0.28

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(tabWidth, 0, 1, 0)
        btn.Position = UDim2.new(0.02 + (i - 1) * (tabWidth + 0.02), 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
        btn.BackgroundTransparency = 0.3
        btn.Text = name
        btn.TextSize = 10
        btn.TextColor3 = Color3.fromRGB(200, 200, 255)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabContainer
        Instance.new("UICorner").CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            currentTab = name
            updateContent()
            for _, b in ipairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(30, 25, 50)
                b.BackgroundTransparency = 0.3
            end
            btn.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
            btn.BackgroundTransparency = 0.2
        end)

        table.insert(tabButtons, btn)
    end

    tabButtons[1].BackgroundColor3 = Color3.fromRGB(100, 80, 200)
    tabButtons[1].BackgroundTransparency = 0.2
    currentTab = "Combat"

    -- КОНТЕЙНЕР ДЛЯ КНОПОК
    contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -10, 1, -68)
    contentContainer.Position = UDim2.new(0, 5, 0, 66)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.Parent = contentContainer

    updateContent()

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightBracket then
            if mainFrame.Visible then
                mainFrame.Visible = false
                openBtn.Visible = true
            else
                mainFrame.Visible = true
                openBtn.Visible = false
            end
        end
    end)

    task.wait(0.05)
    createSnow(mainFrame)

    mainFrame.Visible = true
    openBtn.Visible = false
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
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = panel

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.6, 0, 0, 34)
    keyBox.Position = UDim2.new(0.2, 0, 0, 66)
    keyBox.BackgroundColor3 = Color3.fromRGB(30, 28, 50)
    keyBox.BackgroundTransparency = 0.3
    keyBox.Font = Enum.Font.GothamBold
    keyBox.TextSize = 16
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
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
            keyGui:Destroy()
            createMainGUI()
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
end

showKeyWindow()
