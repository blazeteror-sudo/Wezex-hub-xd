-- WEZEX HUB (WINDUI + NATIVE KEY SYSTEM) | STEEL BRAINROT (FINAL)
-- КЛЮЧ: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace
local Lighting = game:GetService("Lighting")

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

-- ====== СОСТОЯНИЯ ======
local State = {
    laser = false,
    fling = false,
    infJump = false,
    platform = false,
    esp = false,
    night = false,
    orbs = false,
}

-- ====== ПОДКЛЮЧЕНИЯ ======
local laserConn, flingConn, infJumpConn = nil, nil, nil
local espHLs = {}
local orbConnections = {}
local platformConnection = nil
local platformPart = nil

local laserOn, flingOn, infJumpOn, platformOn, espOn, nightOn, orbsOn = false, false, false, false, false, false, false

-- ====== ORB ПЕРЕМЕННЫЕ ======
local orbs = {}
local orbLights = {}

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

-- 4. ANTI-DEATH PLATFORM
local function startPlatform()
    platformOn = true
    State.platform = true

    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(10, 1, 10)
    platformPart.Position = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.Transparency = 0.5
    platformPart.Material = Enum.Material.Neon
    platformPart.Color = Color3.fromRGB(0, 255, 255)
    platformPart.Parent = Workspace

    local light = Instance.new("PointLight")
    light.Parent = platformPart
    light.Color = Color3.fromRGB(0, 255, 255)
    light.Range = 15
    light.Brightness = 2

    platformConnection = RunService.RenderStepped:Connect(function()
        if not platformOn then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        platformPart.Position = hrp.Position - Vector3.new(0, 3, 0)
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            platformPart.Position = hrp.Position - Vector3.new(0, 2, 0)
        end
    end)

    task.spawn(function()
        while platformOn do
            task.wait(0.5)
        end
        if platformPart then
            platformPart:Destroy()
            platformPart = nil
        end
        if platformConnection then
            platformConnection:Disconnect()
            platformConnection = nil
        end
    end)
end

local function stopPlatform()
    platformOn = false
    State.platform = false

    if platformPart then
        platformPart:Destroy()
        platformPart = nil
    end
    if platformConnection then
        platformConnection:Disconnect()
        platformConnection = nil
    end
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

-- 6. НОЧЬ
local function toggleNight()
    nightOn = not nightOn
    State.night = nightOn
    if nightOn then
        Lighting.Ambient = Color3.fromRGB(10, 10, 20)
        Lighting.Brightness = 0.2
        Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 20)
    else
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end
end

-- 7. ORBS (СВЕТЯЩИЕСЯ ШАРЫ СО ШЛЕЙФОМ, БЕЗ РАЗМЫТИЯ)
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
    trail.Lifetime = 0.5
    trail.MinLength = 0.2
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(0.5, color),
        ColorSequenceKeypoint.new(1, color)
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Width = NumberSequence.new(1.5)

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
    local offsets = {Vector3.new(3.5, 0, 0), Vector3.new(-3.5, 0, 0), Vector3.new(0, 0, 3.5)}

    for i = 1, 3 do
        local orb = createOrb(hrp, colors[i], offsets[i])
        table.insert(orbs, orb)

        local conn = RunService.RenderStepped:Connect(function()
            if not orbsOn or not hrp.Parent then return end
            local time = tick() * 1.2
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

-- ====== ОКНО КЛЮЧА ======
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

-- ====== GUI ======
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
        Title = "Infinite Jump",
        Desc = "Бесконечные прыжки",
        Value = State.infJump,
        Callback = function(v)
            if v ~= State.infJump then
                if v then startInfJump() else stopInfJump() end
            end
        end,
    })
    MovementSection:Toggle({
        Title = "Anti-Death Platform",
        Desc = "Платформа под ногами, чтобы не убили",
        Value = State.platform,
        Callback = function(v)
            if v ~= State.platform then
                if v then startPlatform() else stopPlatform() end
            end
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
    VisualsSection:Toggle({
        Title = "Night Mode",
        Desc = "Делает ночь в игре",
        Value = State.night,
        Callback = function(v)
            if v ~= State.night then
                toggleNight()
            end
        end,
    })
    VisualsSection:Toggle({
        Title = "Orbs",
        Desc = "Парящие шары со шлейфом и освещением",
        Value = State.orbs,
        Callback = function(v)
            if v ~= State.orbs then
                if v then startOrbs() else stopOrbs() end
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
    if State.laser then startLaser() end
    if State.fling then toggleFling() end
    if State.infJump then startInfJump() end
    if State.platform then startPlatform() end
    if State.esp then startESP() end
    if State.night then toggleNight() end
    if State.orbs then startOrbs() end
end

-- ====== ЗАПУСК ======
showNativeKeyWindow()
