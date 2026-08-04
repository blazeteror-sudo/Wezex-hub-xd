-- WEZEX HUB | STEEL BRAINROT (ИДЕАЛЬНАЯ БАЗА)
-- МЕНЮ КАК В НОЖЕВЫХ ДУЭЛЯХ

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = workspace

-- ====== СОСТОЯНИЯ ======
local State = {
    ws = false,
    wsSpeed = 80,
    ij = false,
    bj = false,
    bjStrength = 150,
    esp = false,
    laser = false,
    fling = false,
}

-- ====== ПОДКЛЮЧЕНИЯ ======
local wsConn, ijConn, laserConn, flingConn = nil, nil, nil, nil
local bjConns = {}
local espHLs = {}
local wsOn, ijOn, bjOn, laserOn, flingOn, espOn = false, false, false, false, false, false

-- ====== WALKSPEED ======
local function stopWS()
    if wsConn then wsConn:Disconnect(); wsConn = nil end
    local c = LP.Character
    if c and c:FindFirstChild("Humanoid") then
        c.Humanoid.WalkSpeed = 16
    end
    wsOn = false
    State.ws = false
end

local function startWS()
    stopWS()
    wsOn = true
    State.ws = true
    wsConn = RS.Heartbeat:Connect(function()
        local c = LP.Character
        if c and c:FindFirstChild("Humanoid") then
            c.Humanoid.WalkSpeed = State.wsSpeed
        end
    end)
end

-- ====== INFINITE JUMP ======
local function startIJ()
    if ijConn then ijConn:Disconnect() end
    ijOn = true
    State.ij = true
    ijConn = UIS.JumpRequest:Connect(function()
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Humanoid") then
            if c.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                c.HumanoidRootPart.Velocity = Vector3.new(c.HumanoidRootPart.Velocity.X, 50, c.HumanoidRootPart.Velocity.Z)
            end
        end
    end)
end

local function stopIJ()
    if ijConn then ijConn:Disconnect(); ijConn = nil end
    ijOn = false
    State.ij = false
end

-- ====== BOOST JUMP ======
local function startBJ()
    for _, v in pairs(bjConns) do v:Disconnect() end
    bjConns = {}
    bjOn = true
    State.bj = true
    local canBoost = true
    bjConns[1] = RS.Stepped:Connect(function()
        local c = LP.Character
        if c and c:FindFirstChild("Humanoid") then
            local s = c.Humanoid:GetState()
            canBoost = s == Enum.HumanoidStateType.Running
                or s == Enum.HumanoidStateType.RunningNoPhysics
                or s == Enum.HumanoidStateType.Landed
                or s == Enum.HumanoidStateType.Seated
                or s == Enum.HumanoidStateType.PlatformStanding
        end
    end)
    bjConns[2] = UIS.JumpRequest:Connect(function()
        if not canBoost then return end
        local c = LP.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        local v = Vector3.new(0, State.bjStrength, 0)
        if r.Velocity.Magnitude > 1 then
            v = v + r.CFrame.LookVector * 50
        end
        r.Velocity = v
        canBoost = false
    end)
end

local function stopBJ()
    for _, v in pairs(bjConns) do v:Disconnect() end
    bjConns = {}
    bjOn = false
    State.bj = false
end

-- ====== LASER AIMBOT ======
local function startLaser()
    if laserConn then laserConn:Disconnect() end
    laserOn = true
    State.laser = true
    laserConn = RS.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or not tool.Name:lower():find("laser") then return end
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end
        local best, bestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local h2 = p.Character:FindFirstChild("Humanoid")
                if h2 and h2.Health > 0 then
                    local d = (handle.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = p
                    end
                end
            end
        end
        if best and best.Character then
            local target = best.Character:FindFirstChild("HumanoidRootPart")
            if target then
                local dir = (target.Position - handle.Position).Unit
                handle.CFrame = CFrame.lookAt(handle.Position, handle.Position + dir * 100)
                local remote = RepStorage:FindFirstChild("LaserRemote") or RepStorage:FindFirstChild("ShootRemote")
                if remote then
                    pcall(function() remote:FireServer(target.Position, target) end)
                end
                local mouse = LP:GetMouse()
                if mouse then
                    pcall(function()
                        mouse.Button1Down:Fire()
                        task.wait(0.05)
                        mouse.Button1Up:Fire()
                    end)
                end
            end
        end
    end)
end

local function stopLaser()
    if laserConn then laserConn:Disconnect(); laserConn = nil end
    laserOn = false
    State.laser = false
end

-- ====== ESP ======
local function startESP()
    espOn = true
    State.esp = true
    local function updateESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            local char = p.Character
            if not char then continue end
            local hl = char:FindFirstChild("WezexESP")
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "WezexESP"
                hl.Adornee = char
                hl.FillColor = Color3.fromRGB(255, 50, 50)
                hl.FillTransparency = 0.2
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0.1
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
                table.insert(espHLs, hl)
            end
        end
    end
    updateESP()
    local conn1 = Players.PlayerAdded:Connect(function()
        task.wait(0.5)
        updateESP()
    end)
    table.insert(espHLs, conn1)
    local conn2 = Workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child:FindFirstChild("Humanoid") then
            task.wait(0.3)
            updateESP()
        end
    end)
    table.insert(espHLs, conn2)
    local conn3 = RS.Heartbeat:Connect(updateESP)
    table.insert(espHLs, conn3)
end

local function stopESP()
    espOn = false
    State.esp = false
    for _, obj in ipairs(espHLs) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espHLs = {}
end

-- ====== TOUCH FLING ======
local function toggleFling()
    flingOn = not flingOn
    State.fling = flingOn
    if flingOn then
        if wsOn then stopWS() end
        pcall(function()
            local h2 = LP.Character and LP.Character:FindFirstChildWhichIsA("Humanoid")
            if h2 then h2.AutoJumpEnabled = false end
        end)
        if not RepStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
            local m = Instance.new("Decal")
            m.Name = "juisdfj0i32i0eidsuf0iok"
            m.Parent = RepStorage
        end
        flingConn = RS.Heartbeat:Connect(function()
            local c = LP.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r then
                local v = r.Velocity
                r.Velocity = v * 10000 + Vector3.new(0,10000,0)
                RS.RenderStepped:Wait()
                r.Velocity = v
                RS.Stepped:Wait()
                r.Velocity = v + Vector3.new(0,0.1,0)
            end
        end)
    else
        if flingConn then flingConn:Disconnect(); flingConn = nil end
    end
end

-- ====== МЕНЮ (ИДЕАЛЬНОЕ) ======
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
    mainFrame.Size = UDim2.new(0, 240, 0, 340)
    mainFrame.Position = UDim2.new(0.5, -120, 0.5, -170)
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

    local function createToggle(label, stateKey, onFunc, offFunc)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 30)
        frame.BackgroundColor3 = Color3.fromRGB(22, 18, 35)
        frame.BackgroundTransparency = 0.4
        frame.Parent = content
        Instance.new("UICorner").CornerRadius = UDim.new(0, 10)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.55, 0, 1, 0)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(220, 210, 255)
        lbl.Text = label
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 48, 0, 20)
        btn.Position = UDim2.new(1, -54, 0.5, -10)
        btn.BorderSizePixel = 0
        btn.TextSize = 10
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.Parent = frame
        Instance.new("UICorner").CornerRadius = UDim.new(0, 8)

        local function updateButton()
            if State[stateKey] then
                btn.BackgroundColor3 = Color3.fromRGB(80, 220, 160)
                btn.Text = "ON"
            else
                btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                btn.Text = "OFF"
            end
        end
        updateButton()

        btn.MouseButton1Click:Connect(function()
            if State[stateKey] then
                if offFunc then offFunc() end
            else
                if onFunc then onFunc() end
            end
            updateButton()
        end)
    end

    local function createSlider(label, stateKey, min, max, step)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(22, 18, 35)
        frame.BackgroundTransparency = 0.4
        frame.Parent = content
        Instance.new("UICorner").CornerRadius = UDim.new(0, 10)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0.04, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextColor3 = Color3.fromRGB(220, 210, 255)
        lbl.Text = label
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame

        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0.2, 0, 1, 0)
        val.Position = UDim2.new(0.76, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Font = Enum.Font.GothamBold
        val.TextSize = 12
        val.TextColor3 = Color3.fromRGB(255, 255, 255)
        val.Text = tostring(State[stateKey])
        val.TextXAlignment = Enum.TextXAlignment.Right
        val.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.6, 0, 0, 6)
        slider.Position = UDim2.new(0.04, 0, 0.7, 0)
        slider.BackgroundColor3 = Color3.fromRGB(50, 40, 70)
        slider.Parent = frame
        Instance.new("UICorner").CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((State[stateKey] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        Instance.new("UICorner").CornerRadius = UDim.new(1, 0)

        local dragging = false
        local sliderBtn = Instance.new("TextButton")
        sliderBtn.Size = UDim2.new(1, 0, 1, 0)
        sliderBtn.BackgroundTransparency = 1
        sliderBtn.Text = ""
        sliderBtn.Parent = slider

        sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((i.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                local v = min + (max - min) * pos
                v = math.round(v / step) * step
                State[stateKey] = v
                fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
                val.Text = tostring(v)
                if stateKey == "wsSpeed" and wsOn then
                    local c = LP.Character
                    if c and c:FindFirstChild("Humanoid") then
                        c.Humanoid.WalkSpeed = v
                    end
                end
            end
        end)
    end

    -- ====== ЭЛЕМЕНТЫ МЕНЮ ======
    createToggle("Walkspeed", "ws", startWS, stopWS)
    createSlider("Speed", "wsSpeed", 50, 120, 1)

    createToggle("Infinite Jump", "ij", startIJ, stopIJ)
    createToggle("Boost Jump", "bj", startBJ, stopBJ)
    createSlider("Boost Str", "bjStrength", 50, 300, 5)

    createToggle("Laser Aimbot", "laser", startLaser, stopLaser)
    createToggle("ESP", "esp", startESP, stopESP)
    createToggle("Touch Fling", "fling", toggleFling, toggleFling)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    UIS.InputBegan:Connect(function(i)
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

createMenu()
