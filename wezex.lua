-- Wezex Hub Final by @Fanqwezex
-- KEY: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

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

-- ========== SILENT AIM (твой код) ==========
local function getClosestPlayer()
    local closest = nil
    local shortestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = player.Character
                    end
                end
            end
        end
    end
    return closest
end

local oldRaycast
local function toggleSilentAim()
    State.silentAim = not State.silentAim
    if State.silentAim then
        oldRaycast = hookmetamethod(game, "__namecall", function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if self == workspace and method == "Raycast" then
                local target = getClosestPlayer()
                if target and target:FindFirstChild("Head") then
                    local origin = args[1]
                    args[2] = (target.Head.Position - origin).Unit * 1000
                end
            end
            return oldRaycast(self, unpack(args))
        end)
    else
        if oldRaycast then
            hookmetamethod(game, "__namecall", oldRaycast)
            oldRaycast = nil
        end
    end
end

-- ========== ESP (твой код) ==========
local FILL_COLOR = Color3.fromRGB(255, 0, 0)
local OUTLINE_COLOR = Color3.fromRGB(255, 255, 255)
local FILL_TRANSPARENCY = 0.5
local OUTLINE_TRANSPARENCY = 0

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
        local oldEsp = character:FindFirstChild("EspHighlight")
        if oldEsp then oldEsp:Destroy() end
        local highlight = Instance.new("Highlight")
        highlight.Name = "EspHighlight"
        highlight.FillColor = FILL_COLOR
        highlight.OutlineColor = OUTLINE_COLOR
        highlight.FillTransparency = FILL_TRANSPARENCY
        highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
        table.insert(espHighlights, highlight)
    end

    if player.Character then
        setupHighlight(player.Character)
    end
    local conn = player.CharacterAdded:Connect(setupHighlight)
    table.insert(espConnections, conn)
end

local function toggleESP()
    State.esp = not State.esp
    if State.esp then
        clearESP()
        for _, player in ipairs(Players:GetPlayers()) do
            applyESP(player)
        end
        local conn = Players.PlayerAdded:Connect(applyESP)
        table.insert(espConnections, conn)
    else
        clearESP()
    end
end

-- ========== КОМПАКТНОЕ ОКНО КЛЮЧА ==========
local function showKeyWindow()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    keyGui.ResetOnSpawn = false

    local main = Instance.new("Frame", keyGui)
    main.Size = UDim2.new(1, 0, 1, 0)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    main.BackgroundTransparency = 0.1

    local panel = Instance.new("Frame", main)
    panel.Size = UDim2.new(0, 240, 0, 140)
    panel.Position = UDim2.new(0.5, -120, 0.5, -70)
    panel.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    panel.BackgroundTransparency = 0.3
    panel.BorderSizePixel = 0
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", panel)
    title.Size = UDim2.new(1, 0, 0, 28)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "❄ Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local info = Instance.new("TextLabel", panel)
    info.Size = UDim2.new(1, 0, 0, 16)
    info.Position = UDim2.new(0, 0, 0, 38)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.TextColor3 = Color3.fromRGB(160, 160, 200)
    info.Text = "Введите ключ"
    info.TextXAlignment = Enum.TextXAlignment.Center

    local keyBox = Instance.new("TextBox", panel)
    keyBox.Size = UDim2.new(0.6, 0, 0, 32)
    keyBox.Position = UDim2.new(0.2, 0, 0, 62)
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
    enterBtn.Size = UDim2.new(0.4, 0, 0, 32)
    enterBtn.Position = UDim2.new(0.3, 0, 0, 102)
    enterBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
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

    -- Кнопка возврата
    openBtn = Instance.new("TextButton", screenGui)
    openBtn.Name = "OpenBtn"
    openBtn.Size = UDim2.new(0, 50, 0, 50)
    openBtn.Position = UDim2.new(0.02, 0, 0.04, 0)
    openBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    openBtn.BackgroundTransparency = 0.2
    openBtn.BorderSizePixel = 0
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    openBtn.Text = "❄"
    openBtn.TextSize = 20
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
    mainFrame.Size = UDim2.new(0, 220, 0, 150)
    mainFrame.Position = UDim2.new(0.5, -110, 0.5, -75)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 28)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0, 4)
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
    content.Size = UDim2.new(1, -12, 1, -48)
    content.Position = UDim2.new(0, 6, 0, 42)
    content.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 6)

    local function createToggle(label, value, callback)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, 0, 0, 30)
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
        btn.Size = UDim2.new(0, 48, 0, 20)
        btn.Position = UDim2.new(1, -54, 0.5, -10)
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

    if State.silentAim then toggleSilentAim() end
    if State.esp then toggleESP() end
end

showKeyWindow()
