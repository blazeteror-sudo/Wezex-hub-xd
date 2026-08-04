-- WEZEX HUB (WINDUI + NATIVE KEY SYSTEM) | STEEL BRAINROT
-- КЛЮЧ: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace

-- ====== ЗАГРУЗКА WINDUI ======
local WindUI
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok then
        WindUI = result
    else
        error("WindUI не загрузился")
    end
end

-- ====== НАША РОДНАЯ КЛЮЧ-СИСТЕМА ======
local CORRECT_KEY = "38399923"
local keyVerified = false

-- ====== НАШИ СОСТОЯНИЯ ======
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

-- ====== НОВЫЕ ФУНКЦИИ ======

-- 1. WALKSPEED
local function stopWS()
    if wsConn then wsConn:Disconnect(); wsConn = nil end
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 16 end
    wsOn = false
    State.ws = false
end

local function startWS()
    stopWS()
    wsOn = true
    State.ws = true
    wsConn = RunService.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = State.wsSpeed end
    end)
end

-- 2. INFINITE JUMP
local function startIJ()
    if ijConn then ijConn:Disconnect() end
    ijOn = true
    State.ij = true
    ijConn = UserInputService.JumpRequest:Connect(function()
        local c = LocalPlayer.Character
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

-- 3. BOOST JUMP
local function startBJ()
    for _, v in pairs(bjConns) do v:Disconnect() end
    bjConns = {}
    bjOn = true
    State.bj = true
    local canBoost = true
    bjConns[1] = RunService.Stepped:Connect(function()
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("Humanoid") then
            local s = c.Humanoid:GetState()
            canBoost = s == Enum.HumanoidStateType.Running
                or s == Enum.HumanoidStateType.RunningNoPhysics
                or s == Enum.HumanoidStateType.Landed
                or s == Enum.HumanoidStateType.Seated
                or s == Enum.HumanoidStateType.PlatformStanding
        end
    end)
    bjConns[2] = UserInputService.JumpRequest:Connect(function()
        if not canBoost then return end
        local c = LocalPlayer.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        local v = Vector3.new(0, State.bjStrength, 0)
        if r.Velocity.Magnitude > 1 then v = v + r.CFrame.LookVector * 50 end
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

-- 4. LASER AIMBOT
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

-- 5. ESP (ОБХОД НЕВИДИМОСТИ)
local function startESP()
    espOn = true
    State.esp = true
    local function updateESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
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
    local conn1 = Players.PlayerAdded:Connect(function() task.wait(0.5); updateESP() end)
    table.insert(espHLs, conn1)
    local conn2 = Workspace.ChildAdded:Connect(function(child) if child:IsA("Model") and child:FindFirstChild("Humanoid") then task.wait(0.3); updateESP() end end)
    table.insert(espHLs, conn2)
    local conn3 = RunService.Heartbeat:Connect(updateESP)
    table.insert(espHLs, conn3)
end

local function stopESP()
    espOn = false
    State.esp = false
    for _, obj in ipairs(espHLs) do if obj and obj.Parent then obj:Destroy() end end
    espHLs = {}
end

-- 6. TOUCH FLING
local function toggleFling()
    flingOn = not flingOn
    State.fling = flingOn
    if flingOn then
        if wsOn then stopWS() end
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

-- ====== НАША РОДНАЯ КЛЮЧ-СИСТЕМА (ОКНО) ======
local function showNativeKeyWindow()
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
            keyVerified = true
            keyGui:Destroy()
            createMainUI()
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

-- ====== ТВОЙ GUI НА WINDUI (С НОВЫМИ ФУНКЦИЯМИ) ======
function createMainUI()
    local Window = WindUI:CreateWindow({
        Title = "Wezex Hub v4.1",
        Folder = "WezexHub",
        Icon = "solar:folder-2-bold-duotone",
        OpenButton = {
            Title = "Wezex Hub",
            Color = ColorSequence.new(Color3.fromRGB(255, 100, 255), Color3.fromRGB(100, 200, 255)),
            Draggable = true,
            Scale = 0.5,
        },
    })

    -- ВКЛАДКА COMBAT
    local CombatTab = Window:Tab({
        Title = "Combat",
        Icon = "solar:sword-bold",
    })
    local CombatSection = CombatTab:Section({
        Title = "⚔️ Combat Settings",
    })
    CombatSection:Toggle({
        Title = "Laser Aimbot",
        Desc = "Автострельба лазером по игрокам",
        Value = State.laser,
        Callback = function(v)
            if v ~= State.laser then
                if v then startLaser() else stopLaser() end
            end
        end,
    })
    CombatSection:Toggle({
        Title = "Touch Fling",
        Desc = "Вылетает из карты",
        Value = State.fling,
        Callback = function(v)
            if v ~= State.fling then
                toggleFling()
            end
        end,
    })

    -- ВКЛАДКА MOVEMENT
    local MovementTab = Window:Tab({
        Title = "Movement",
        Icon = "solar:running-bold",
    })
    local MovementSection = MovementTab:Section({
        Title = "🏃 Movement Settings",
    })
    MovementSection:Toggle({
        Title = "Walkspeed",
        Desc = "Увеличенная скорость",
        Value = State.ws,
        Callback = function(v)
            if v ~= State.ws then
                if v then startWS() else stopWS() end
            end
        end,
    })
    MovementSection:Slider({
        Title = "Speed",
        Desc = "Скорость бега",
        Value = State.wsSpeed,
        Min = 50,
        Max = 120,
        Rounding = 1,
        Callback = function(v)
            State.wsSpeed = v
            if wsOn then
                local c = LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid.WalkSpeed = v
                end
            end
        end,
    })
    MovementSection:Toggle({
        Title = "Infinite Jump",
        Desc = "Бесконечные прыжки",
        Value = State.ij,
        Callback = function(v)
            if v ~= State.ij then
                if v then startIJ() else stopIJ() end
            end
        end,
    })
    MovementSection:Toggle({
        Title = "Boost Jump",
        Desc = "Усиленный прыжок",
        Value = State.bj,
        Callback = function(v)
            if v ~= State.bj then
                if v then startBJ() else stopBJ() end
            end
        end,
    })
    MovementSection:Slider({
        Title = "Boost Strength",
        Desc = "Сила усиленного прыжка",
        Value = State.bjStrength,
        Min = 50,
        Max = 300,
        Rounding = 5,
        Callback = function(v)
            State.bjStrength = v
        end,
    })

    -- ВКЛАДКА VISUALS
    local VisualsTab = Window:Tab({
        Title = "Visuals",
        Icon = "solar:eye-bold",
    })
    local VisualsSection = VisualsTab:Section({
        Title = "👁️ Visual Settings",
    })
    VisualsSection:Toggle({
        Title = "ESP",
        Desc = "Подсветка игроков (сквозь стены)",
        Value = State.esp,
        Callback = function(v)
            if v ~= State.esp then
                if v then startESP() else stopESP() end
            end
        end,
    })

    -- ВКЛАДКА ABOUT
    local AboutTab = Window:Tab({
        Title = "About",
        Icon = "solar:info-square-bold",
    })
    local AboutSection = AboutTab:Section({
        Title = "Wezex Hub v4.1",
    })
    AboutSection:Button({
        Title = "Destroy Window",
        Color = Color3.fromRGB(255, 50, 50),
        Callback = function()
            Window:Destroy()
        end,
    })

    -- Синхронизация
    if State.ws then startWS() end
    if State.ij then startIJ() end
    if State.bj then startBJ() end
    if State.esp then startESP() end
    if State.laser then startLaser() end
    if State.fling then toggleFling() end
end

-- ====== ЗАПУСК ======
showNativeKeyWindow()
