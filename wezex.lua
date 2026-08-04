-- WEZEX HUB (WINDUI) | STEEL BRAINROT (ULTIMATE + PLATFORM)
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
    esp = false,
    night = false,
    orbs = false,
    fireflies = false,
    shaders = false,
    skybox = false,
    platform = false,
}

-- ====== ПОДКЛЮЧЕНИЯ ======
local laserConn, flingConn, infJumpConn = nil, nil, nil
local espHLs = {}
local orbConnections = {}
local fireflyConnections = {}
local skyConnection = nil
local platformConnection = nil
local platformPart = nil

local laserOn, flingOn, infJumpOn, espOn, nightOn, orbsOn, firefliesOn, shadersOn, skyboxOn, platformOn = false, false, false, false, false, false, false, false, false, false

-- ====== ORB ПЕРЕМЕННЫЕ ======
local orbs = {}
local orbLights = {}
local fireflies = {}

-- ====== ФУНКЦИИ ======

-- 1. LASER AIMBOT (FIXED)
local function startLaser()
    if laserConn then laserConn:Disconnect() end
    laserOn = true
    State.laser = true

    laserConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end

        -- Проверяем, что лазер в руках
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or not tool.Name:lower():find("laser") then return end

        local handle = tool:FindFirstChild("Handle")
        if not handle then return end

        -- Находим ближайшего врага (не себя, не союзников)
        local best, bestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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
                -- Направляем лазер в цель
                local dir = (target.Position - handle.Position).Unit
                handle.CFrame = CFrame.lookAt(handle.Position, handle.Position + dir * 100)

                -- Стреляем (безопасно)
                local remote = RepStorage:FindFirstChild("LaserRemote") or RepStorage:FindFirstChild("ShootRemote")
                if remote then
                    pcall(function()
                        remote:FireServer(target.Position, target)
                    end)
                end

                -- Альтернатива: клик
                local mouse = LocalPlayer:GetMouse()
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

-- 4. ESP (ОБХОД НЕВИДИМОСТИ)
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

-- 5. НОЧЬ (ВСЕГДА)
local function toggleNight()
    nightOn = not nightOn
    State.night = nightOn
    if nightOn then
        Lighting.Ambient = Color3.fromRGB(10, 10, 20)
        Lighting.Brightness = 0.2
        Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 20)
        Lighting.TimeOfDay = "00:00:00"
        Lighting.ClockTime = 0
    else
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.TimeOfDay = "12:00:00"
        Lighting.ClockTime = 12
    end
end

-- 6. ORBS (С ШЛЕЙФОМ)
local function createOrb(parent, color, offset)
    local orb = Instance.new("Part")
    orb.Size = Vector3.new(1, 1, 1)
    orb.Shape = Enum.PartType.Ball
    orb.Material = Enum.Material.Neon
    orb.Color = color
    orb.Anchored = true
    orb.CanCollide = false
    orb.Parent = parent

    local trail = Instance.new("Trail")
    trail.Parent = orb
    trail.Attachment0 = Instance.new("Attachment", orb)
    trail.Lifetime = 0.3
    trail.MinLength = 0.2
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, color)
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Width = NumberSequence.new(1)

    local light = Instance.new("PointLight")
    light.Parent = orb
    light.Color = color
    light.Range = 15
    light.Brightness = 2
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
                math.sin(time + i * 2.09) * 4,
                math.cos(time + i * 1.57) * 3 + 2,
                math.cos(time + i * 1.05) * 4
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

-- 7. СВЕТЛЯЧКИ (ПО ВСЕЙ КАРТЕ)
local function startFireflies()
    firefliesOn = true
    State.fireflies = true

    for i = 1, 50 do
        local particle = Instance.new("Part")
        particle.Size = Vector3.new(0.3, 0.3, 0.3)
        particle.Shape = Enum.PartType.Ball
        particle.Material = Enum.Material.Neon
        particle.Color = Color3.fromRGB(math.random(200, 255), math.random(200, 255), math.random(200, 255))
        particle.Anchored = true
        particle.CanCollide = false
        particle.Parent = Workspace

        local light = Instance.new("PointLight")
        light.Parent = particle
        light.Color = particle.Color
        light.Range = 3
        light.Brightness = 0.5

        local startPos = Vector3.new(
            math.random(-50, 50),
            math.random(0, 20),
            math.random(-50, 50)
        )
        local speed = 0.5 + math.random() * 1.5
        local phase = math.random() * 100

        table.insert(fireflies, {
            part = particle,
            startPos = startPos,
            speed = speed,
            phase = phase,
            light = light
        })
    end

    local conn = RunService.RenderStepped:Connect(function()
        if not firefliesOn then return end
        local time = tick()
        for _, data in ipairs(fireflies) do
            local pos = data.startPos + Vector3.new(
                math.sin(time * data.speed + data.phase) * 5,
                math.sin(time * data.speed * 0.7 + data.phase * 2) * 3 + 2,
                math.cos(time * data.speed * 0.8 + data.phase * 1.5) * 5
            )
            data.part.Position = pos
            data.light.Brightness = 0.3 + math.sin(time * data.speed + data.phase) * 0.2
        end
    end)
    table.insert(fireflyConnections, conn)
end

local function stopFireflies()
    firefliesOn = false
    State.fireflies = false
    for _, conn in ipairs(fireflyConnections) do conn:Disconnect() end
    fireflyConnections = {}
    for _, data in ipairs(fireflies) do
        if data.part then data.part:Destroy() end
        if data.light then data.light:Destroy() end
    end
    fireflies = {}
end

-- 8. ШЕЙДЕРЫ
local function startShaders()
    shadersOn = true
    State.shaders = true

    Lighting.Ambient = Color3.fromRGB(80, 80, 100)
    Lighting.Brightness = 0.8
    Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 100)
    Lighting.ShadowSoftness = 1
    Lighting.ClockTime = 14

    if not Lighting:FindFirstChild("SunRays") then
        local sunRays = Instance.new("SunRaysEffect")
        sunRays.Name = "SunRays"
        sunRays.Parent = Lighting
        sunRays.Intensity = 0.5
        sunRays.Spread = 0.5
    end

    if not Lighting:FindFirstChild("ColorCorrection") then
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "ColorCorrection"
        colorCorrection.Parent = Lighting
        colorCorrection.Brightness = 0.1
        colorCorrection.Contrast = 0.1
        colorCorrection.Saturation = 0.2
    end

    Lighting.FogEnd = 100
    Lighting.FogStart = 20
    Lighting.FogColor = Color3.fromRGB(150, 180, 220)
end

local function stopShaders()
    shadersOn = false
    State.shaders = false

    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    Lighting.Brightness = 1
    Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    Lighting.ShadowSoftness = 0
    Lighting.FogEnd = 1000
    Lighting.FogStart = 0
    Lighting.FogColor = Color3.fromRGB(127, 127, 127)

    local sunRays = Lighting:FindFirstChild("SunRays")
    if sunRays then sunRays:Destroy() end
    local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
    if colorCorrection then colorCorrection:Destroy() end
end

-- 9. SKYBOX
local function startSkybox()
    skyboxOn = true
    State.skybox = true

    local sky = Instance.new("Sky")
    sky.Name = "WezexSky"
    sky.Parent = Lighting

    sky.SkyboxBk = Color3.fromRGB(40, 30, 60)
    sky.SkyboxDn = Color3.fromRGB(200, 100, 50)
    sky.SkyboxFt = Color3.fromRGB(100, 80, 150)
    sky.SkyboxLf = Color3.fromRGB(150, 100, 200)
    sky.SkyboxRt = Color3.fromRGB(150, 100, 200)
    sky.SkyboxUp = Color3.fromRGB(80, 40, 120)

    sky.StarCount = 5000
    sky.CelestialBodiesShown = true
    sky.SunAngularSize = 30
    sky.MoonAngularSize = 20
    sky.Clouds = Enum.Clouds.Smooth

    skyConnection = RunService.RenderStepped:Connect(function()
        if not skyboxOn then return end
        local time = tick() * 0.05
        local r = math.sin(time) * 0.1 + 0.9
        local g = math.sin(time + 1) * 0.1 + 0.9
        local b = math.sin(time + 2) * 0.1 + 0.9
        sky.SkyboxUp = Color3.new(0.3 * r, 0.2 * g, 0.5 * b)
    end)
end

local function stopSkybox()
    skyboxOn = false
    State.skybox = false

    if skyConnection then skyConnection:Disconnect(); skyConnection = nil end
    local sky = Lighting:FindFirstChild("WezexSky")
    if sky then sky:Destroy() end

    Lighting.StarCount = 0
    Lighting.CelestialBodiesShown = false
end

-- 10. ПЛАТФОРМА (АНТИ-СМЕРТЬ)
local function startPlatform()
    platformOn = true
    State.platform = true

    -- Создаём невидимую платформу под игроком
    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(10, 1, 10)
    platformPart.Position = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.Transparency = 0.5
    platformPart.Material = Enum.Material.Neon
    platformPart.Color = Color3.fromRGB(0, 255, 255)
    platformPart.Parent = Workspace

    -- Добавляем свет
    local light = Instance.new("PointLight")
    light.Parent = platformPart
    light.Color = Color3.fromRGB(0, 255, 255)
    light.Range = 15
    light.Brightness = 2

    -- Поднимаем платформу вместе с игроком
    platformConnection = RunService.RenderStepped:Connect(function()
        if not platformOn then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Платформа следует за игроком
        platformPart.Position = hrp.Position - Vector3.new(0, 3, 0)

        -- Проверяем, стоит ли игрок на платформе
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            if humanoid.FloorMaterial ~= Enum.Material.Air then
                -- Если игрок на земле, платформа поднимается выше
                platformPart.Position = hrp.Position - Vector3.new(0, 2, 0)
            end
        end
    end)

    -- Автоматическое исчезновение через 5 секунд после отключения
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
    enterBtn.TextColor3 = Color3.fromRGB(
