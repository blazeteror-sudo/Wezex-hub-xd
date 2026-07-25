-- Wezex Hub by @Fanqwezex
-- KEY: 38399923

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

pcall(function()
    if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
end)

local CORRECT_KEY = "38399923"

local function showKeyWindow()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    keyGui.ResetOnSpawn = false
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local main = Instance.new("Frame", keyGui)
    main.Size = UDim2.new(0, 320, 0, 180)
    main.Position = UDim2.new(0.5, -160, 0.5, -90)
    main.BackgroundColor3 = Color3.fromRGB(8, 5, 15)
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

    local gradient = Instance.new("UIGradient", main)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 5, 25)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 10, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 20))
    })

    local border = Instance.new("UIStroke", main)
    border.Color = Color3.fromRGB(180, 80, 255)
    border.Thickness = 1.5
    border.Transparency = 0.3

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.TextYAlignment = Enum.TextYAlignment.Bottom

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

    local keyStroke = Instance.new("UIStroke", keyBox)
    keyStroke.Color = Color3.fromRGB(180, 80, 255)
    keyStroke.Thickness = 1
    keyStroke.Transparency = 0.5

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
            createGUI()
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

    -- Плавающие точки (превью)
    for i = 1, 12 do
        local dot = Instance.new("Frame", main)
        dot.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        dot.Position = UDim2.new(math.random() * 0.9, 0, math.random() * 0.8, 0)
        dot.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
        dot.BackgroundTransparency = 0.5
        dot.BorderSizePixel = 0
        dot.ZIndex = 1
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local startX = dot.Position.X.Scale
        local startY = dot.Position.Y.Scale
        local speed = 0.001 + math.random() * 0.003
        local phase = math.random() * math.pi * 2
        game:GetService("RunService").RenderStepped:Connect(function()
            if not dot.Parent then return end
            dot.Position = UDim2.new(startX + math.sin(tick() * speed + phase) * 0.05, 0, startY + math.cos(tick() * speed * 0.7 + phase) * 0.05, 0)
        end)
    end
end

-- ========== ОСНОВНОЙ GUI ==========
function createGUI()
    pcall(function()
        if CoreGui:FindFirstChild("WezexHub") then CoreGui.WezexHub:Destroy() end
    end)

    local State = {
        aimbot = false,
        autoAttack = false,
        esp = false,
        speedEnabled = false,
        speed = 16,
    }

    local CONFIG_FILE = "wezex_config.json"

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
        save()
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
        save()
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
        save()
    end

    RunService.Heartbeat:Connect(function()
        if State.esp then updateESP() end
    end)

    -- ========== GUI ==========
    local function getGuiParent()
        if gethui then return gethui() end
        return CoreGui
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WezexHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = getGuiParent()

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, -170, 0.5, -220)
    mainFrame.BackgroundColor3 = Color3.fromRGB(8, 5, 15)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 16)
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 340, 0, 440)}):Play()

    local gradient = Instance.new("UIGradient", mainFrame)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 5, 25)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 10, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 20))
    })

    local border = Instance.new("UIStroke", mainFrame)
    border.Color = Color3.fromRGB(180, 80, 255)
    border.Thickness = 1.5
    border.Transparency = 0.3

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.TextYAlignment = Enum.TextYAlignment.Bottom
    local glow = Instance.new("UIGradient", title)
    glow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 50, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 50, 255))
    })

    local subtitle = Instance.new("TextLabel", mainFrame)
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 35)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.TextColor3 = Color3.fromRGB(160, 120, 200)
    subtitle.Text = "by @Fanqwezex"
    subtitle.TextXAlignment = Enum.TextXAlignment.Center

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 80)
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.3)
        screenGui:Destroy()
    end)

    local content = Instance.new("ScrollingFrame", mainFrame)
    content.Size = UDim2.new(1, -20, 1, -70)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(150, 80, 255)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ZIndex = 2

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 8)

    local function createToggle(label, value, callback)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.BackgroundColor3 = Color3.fromRGB(25, 15, 40)
        frame.BackgroundTransparency = 0.5
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        frame.ClipsDescendants = true
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 50)}):Play()

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.55, 0, 1, 0)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(230, 210, 255)
        lbl.Text = label
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 70, 0, 30)
        btn.Position = UDim2.new(1, -78, 0.5, -15)
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
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.BackgroundColor3 = Color3.fromRGB(25, 15, 40)
        frame.BackgroundTransparency = 0.5
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        frame.ClipsDescendants = true
        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 65)}):Play()

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.7, 0, 0, 20)
        lbl.Position = UDim2.new(0.04, 0, 0.05, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(230, 210, 255)
        lbl.Text = label .. " (" .. default .. ")"
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local valueLbl = Instance.new("TextLabel", frame)
        valueLbl.Size = UDim2.new(0, 50, 0, 20)
        valueLbl.Position = UDim2.new(1, -55, 0.05, 0)
        valueLbl.BackgroundTransparency = 1
        valueLbl.Font = Enum.Font.GothamBold
        valueLbl.TextSize = 14
        valueLbl.TextColor3 = Color3.fromRGB(180, 80, 255)
        valueLbl.Text = tostring(default)
        valueLbl.TextXAlignment = Enum.TextXAlignment.Right

        local sliderBtn = Instance.new("TextButton", frame)
        sliderBtn.Size = UDim2.new(0.92, 0, 0, 8)
        sliderBtn.Position = UDim2.new(0.04, 0, 0.6, 0)
        sliderBtn.BackgroundColor3 = Color3.fromRGB(15, 8, 25)
        sliderBtn.BorderSizePixel = 0
        Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame", sliderBtn)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(180, 80, 255)
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

        local dragging = false
        local current = default

        sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
        sliderBtn.MouseButton1Up:Connect(function() dragging = false end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local pos = input.Position.X
            local absX = sliderBtn.AbsolutePosition.X
            local sizeX = sliderBtn.AbsoluteSize.X
            local pct = math.clamp((pos - absX) / sizeX, 0, 1)
            local val = math.floor(min + (max - min) * pct)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            lbl.Text = label .. " (" .. val .. ")"
            valueLbl.Text = tostring(val)
            current = val
            callback(val)
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
        State.
