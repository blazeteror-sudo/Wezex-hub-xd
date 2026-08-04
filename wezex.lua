-- WEZEX HUB (FINAL: ORBS ONLY)
-- КЛЮЧ: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace

-- ====== СОСТОЯНИЯ ======
local State = {
    laser = false,
    fling = false,
    infJump = false,
    orbs = false,
}

-- ====== ПОДКЛЮЧЕНИЯ ======
local laserConn, flingConn, infJumpConn = nil, nil, nil
local orbConnections = {}
local laserOn, flingOn, infJumpOn, orbsOn = false, false, false, false

-- ====== ORB ПЕРЕМЕННЫЕ ======
local orbs = {}
local orbLights = {}

-- ====== КЛЮЧ ======
local CORRECT_KEY = "38399923"

-- ====== ФУНКЦИИ ======

-- 1. LASER AIMBOT
local function startLaser()
    if laserConn then laserConn:Disconnect() end
    laserOn = true
    State.laser = true
    laserConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or not tool.Name:lower():find("laser") then return end
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end
        local best, bestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local h2 = p.Character:FindFirstChild("Humanoid")
                if h2 and h2.Health > 0 then
                    local d = (handle.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < bestDist then bestDist = d; best = p end
                end
            end
        end
        if best and best.Character then
            local target = best.Character:FindFirstChild("HumanoidRootPart")
            if target then
                local dir = (target.Position - handle.Position).Unit
                handle.CFrame = CFrame.lookAt(handle.Position, handle.Position + dir * 100)
                local remote = RepStorage:FindFirstChild("LaserRemote") or RepStorage:FindFirstChild("ShootRemote")
                if remote then pcall(function() remote:FireServer(target.Position, target) end) end
                local mouse = LocalPlayer:GetMouse()
                if mouse then pcall(function() mouse.Button1Down:Fire(); task.wait(0.05); mouse.Button1Up:Fire() end) end
            end
        end
    end)
end

local function stopLaser()
    if laserConn then laserConn:Disconnect(); laserConn = nil end
    laserOn = false
    State.laser = false
end

-- 2. TOUCH FLING
local function toggleFling()
    flingOn = not flingOn
    State.fling = flingOn
    if flingOn then
        pcall(function() local h2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid"); if h2 then h2.AutoJumpEnabled = false end end)
        if not RepStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
            local m = Instance.new("Decal")
            m.Name = "juisdfj0i32i0eidsuf0iok"
            m.Parent = RepStorage
        end
        flingConn = RunService.Heartbeat:Connect(function()
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r then
                local v = r.Velocity
                r.Velocity = v * 10000 + Vector3.new(0,10000,0)
                RunService.RenderStepped:Wait()
                r.Velocity = v
                RunService.Stepped:Wait()
                r.Velocity = v + Vector3.new(0,0.1,0)
            end
        end)
    else
        if flingConn then flingConn:Disconnect(); flingConn = nil end
    end
end

-- 3. INFINITE JUMP
local function startInfJump()
    if infJumpConn then infJumpConn:Disconnect() end
    infJumpOn = true
    State.infJump = true
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Humanoid") then
            if c.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                c.HumanoidRootPart.Velocity = Vector3.new(c.HumanoidRootPart.Velocity.X, 50, c.HumanoidRootPart.Velocity.Z)
            end
        end
    end)
end

local function stopInfJump()
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    infJumpOn = false
    State.infJump = false
end

-- 4. ORBS (СВЕТЯЩИЕСЯ ШАРЫ СО ШЛЕЙФОМ)
local function createOrb(parent, color, offset)
    local orb = Instance.new("Part")
    orb.Size = Vector3.new(1, 1, 1)
    orb.Shape = Enum.PartType.Ball
    orb.Material = Enum.Material.Neon
    orb.Color = color
    orb.Anchored = true
    orb.CanCollide = false
    orb.Parent = parent

    -- Шлейф (Trail) для шарика
    local trail = Instance.new("Trail")
    trail.Parent = orb
    trail.Attachment0 = Instance.new("Attachment", orb)
    trail.Lifetime = 0.4
    trail.MinLength = 0.2
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, color)
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Width = NumberSequence.new(1.2)

    -- Свет от шара
    local light = Instance.new("PointLight")
    light.Parent = orb
    light.Color = color
    light.Range = 18
    light.Brightness = 2.5
    table.insert(orbLights, light)

    return orb
end

local function startOrbs()
    orbsOn = true
    State.orbs = true

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0)}
    local offsets = {Vector3.new(3, 0, 0), Vector3.new(-3, 0, 0), Vector3.new(0, 0, 3)}

    for i = 1, 3 do
        local orb = createOrb(hrp, colors[i], offsets[i])
        table.insert(orbs, orb)
        local conn = RunService.RenderStepped:Connect(function()
            if not orbsOn or not hrp.Parent then return end
            local time = tick() * 1.5
            local offset = Vector3.new(
                math.sin(time + i * 2.09) * 4.5,
                math.cos(time + i * 1.57) * 3.5 + 2.5,
                math.cos(time + i * 1.05) * 4.5
            )
            orb.Position = hrp.Position + offset
        end)
        table.insert(orbConnections, conn)
    end
end

local function stopOrbs()
    orbsOn = false
    State.orbs = false
    for _, conn in ipairs(orbConnections) do conn:Disconnect() end
    orbConnections = {}
    for _, orb in ipairs(orbs) do orb:Destroy() end
    orbs = {}
    for _, light in ipairs(orbLights) do light:Destroy() end
    orbLights = {}
end

-- ====== МЕНЮ ======
local screenGui, mainFrame, openBtn = nil, nil, nil

local function createMenu()
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
    mainFrame.Size = UDim2.new(0, 240, 0, 240)
    mainFrame.Position = UDim2.new(0.5, -120, 0.5, -120)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Parent = screenGui
    Instance.new("UICorner").CornerRadius = UDim.new(0, 14)
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = true

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame

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
    end)

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -14, 1, -48)
    content.Position = UDim2.new(0, 7, 0, 40)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarThickness = 4
    content.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.Parent = content

    local function makeToggle(label, stateKey, onFunc, offFunc)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0.95, 0, 0, 30)
        f.BackgroundColor3 = Color3.fromRGB(22, 18, 35)
        f.BackgroundTransparency = 0.4
        f.Parent = content
        Instance.new("UICorner").CornerRadius = UDim.new(0, 10)

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.55, 0, 1, 0)
        l.Position = UDim2.new(0.04, 0, 0, 0)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.TextSize = 11
        l.TextColor3 = Color3.fromRGB(220, 210, 255)
        l.Text = label
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f

        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 48, 0, 20)
        b.Position = UDim2.new(1, -54, 0.5, -10)
        b.BorderSizePixel = 0
        b.TextSize = 9
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.Parent = f
        Instance.new("UICorner").CornerRadius = UDim.new(0, 8)

        local function update()
            if State[stateKey] then
                b.BackgroundColor3 = Color3.fromRGB(80, 220, 160)
                b.Text = "ON"
            else
                b.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                b.Text = "OFF"
            end
        end
        update()

        b.MouseButton1Click:Connect(function()
            if State[stateKey] then
                if offFunc then offFunc() end
            else
                if onFunc then onFunc() end
            end
            update()
        end)
    end

    makeToggle("Laser Aimbot", "laser", startLaser, stopLaser)
    makeToggle("Touch Fling", "fling", toggleFling, toggleFling)
    makeToggle("Infinite Jump", "infJump", startInfJump, stopInfJump)
    makeToggle("Orbs", "orbs", startOrbs, stopOrbs)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    UserInputService.InputBegan:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.RightBracket then
            if mainFrame.Visible then
                mainFrame.Visible = false
                openBtn.Visible = true
            else
                mainFrame.Visible = true
                openBtn.Visible = false
            end
        end
    end)

    mainFrame.Visible = true
    openBtn.Visible = false
end

-- ====== КЛЮЧ-СИСТЕМА ======
local function showKeyWindow()
    pcall(function()
        if CoreGui:FindFirstChild("KeySystem") then CoreGui.KeySystem:Destroy() end
    end)

    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.Parent = CoreGui
    keyGui.ResetOnSpawn = false
    keyGui.IgnoreGuiInset = true

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

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 18)
    info.Position = UDim2.new(0, 0, 0, 42)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextColor3 = Color3.fromRGB(160, 160, 200)
    info.Text = "Введите ключ доступа"
    info.TextXAlignment = Enum.TextXAlignment.Center
    info.Parent = panel

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.6, 0, 0, 34)
    keyBox.Position = UDim2.new(0.2, 0, 0, 66)
    keyBox.BackgroundColor3 = Color3.fromRGB(30, 28, 50)
    keyBox.BackgroundTransparency = 0.3
    keyBox.Font = Enum.Font.GothamBold
    keyBox.TextSize = 16
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Text = ""
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
            createMenu()
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
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Return then checkKey() end
    end)
end

showKeyWindow()
