-- WEZEX HUB (WINDUI + NATIVE KEY SYSTEM) | STEEL BRAINROT (FULL FINAL)
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
    timerEsp = false,
    skybox = false,
    blueOrb = false,
}

-- ====== ПОДКЛЮЧЕНИЯ ======
local laserConn, flingConn, infJumpConn = nil, nil, nil
local espHLs = {}
local orbConnections = {}
local platformConnection = nil
local platformPart = nil
local skyConnection = nil
local blueOrbConn = nil
local blueOrbPart = nil
local blueOrbLight = nil

local laserOn, flingOn, infJumpOn, platformOn, espOn, nightOn, orbsOn, timerOn, skyOn, blueOrbOn = false, false, false, false, false, false, false, false, false, false

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

        if handle then
            handle.Material = Enum.Material.Neon
            handle.Color = Color3.fromRGB(255, 255, 255)
            local light = handle:FindFirstChild("LaserLight")
            if not light then
                light = Instance.new("PointLight")
                light.Name = "LaserLight"
                light.Parent = handle
                light.Color = Color3.fromRGB(255, 255, 255)
                light.Range = 30
                light.Brightness = 5
            end
        end

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
                local remote = RepStorage:FindFirstChild("LaserRemote") or RepStorage:FindFirstChild("ShootRemote")
                if remote then
                    pcall(function() remote:FireServer(target.Position, target) end)
                else
                    local mouse = LocalPlayer:GetMouse()
                    if mouse then
                        pcall(function()
                            local pos, onScreen = Camera:WorldToViewportPoint(target.Position)
                            if onScreen then
                                mouse.Move:Fire(Vector2.new(pos.X, pos.Y))
                            end
                            mouse.Button1Down:Fire()
                            task.wait(0.01)
                            mouse.Button1Up:Fire()
                        end)
                    end
                end
            end
        end
    end)
end

local function stopLaser()
    if laserConn then laserConn:Disconnect(); laserConn = nil end
    laserOn = false
    State.laser = false
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool.Name:lower():find("laser") then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                local light = handle:FindFirstChild("LaserLight")
                if light then light:Destroy() end
                handle.Material = Enum.Material.Plastic
                handle.Color = Color3.fromRGB(255, 255, 255)
            end
        end
    end
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

-- 4. ANTI-DEATH PLATFORM (БЫСТРЕЕ, НЕ ВЫШЕ 1 МЕТРА)
local function startPlatform()
    platformOn = true
    State.platform = true

    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(6, 1, 6)
    platformPart.Position = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 2, 0)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.Transparency = 0.4
    platformPart.Material = Enum.Material.Neon
    platformPart.Color = Color3.fromRGB(0, 255, 255)
    platformPart.Parent = Workspace

    local light = Instance.new("PointLight")
    light.Parent = platformPart
    light.Color = Color3.fromRGB(0, 255, 255)
    light.Range = 10
    light.Brightness = 2

    platformConnection = RunService.RenderStepped:Connect(function()
        if not platformOn then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local targetY = hrp.Position.Y - 1
        local currentY = platformPart.Position.Y
        if currentY < targetY then
            platformPart.Position = platformPart.Position + Vector3.new(0, math.min(0.3, targetY - currentY), 0)
        elseif currentY > targetY then
            platformPart.Position = platformPart.Position - Vector3.new(0, math.min(0.3, currentY - targetY), 0)
        end

        platformPart.Position = Vector3.new(hrp.Position.X, platformPart.Position.Y, hrp.Position.Z)
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

-- 5. ESP
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

-- 7. ORBS (КРАСНЫЙ, СИНИЙ, ЖЁЛТЫЙ)
local function createOrb(hrp, color, index)
    local orb = Instance.new("Part")
    orb.Size = Vector3.new(1, 1, 1)
    orb.Shape = Enum.PartType.Ball
    orb.Material = Enum.Material.Neon
    orb.Color = color
    orb.Anchored = true
    orb.CanCollide = false
    orb.Parent = hrp

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

    local function setupOrbs()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, orb in ipairs(orbs) do if orb and orb.Parent then orb:Destroy() end end
        orbs = {}
        for _, light in ipairs(orbLights) do if light and light.Parent then light:Destroy() end end
        orbLights = {}

        local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0)}
        for i = 1, 3 do
            local orb = createOrb(hrp, colors[i], i)
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

    setupOrbs()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        setupOrbs()
    end)
end

local function stopOrbs()
    orbsOn = false
    State.orbs = false

    for _, conn in ipairs(orbConnections) do conn:Disconnect() end
    orbConnections = {}
    for _, orb in ipairs(orbs) do if orb and orb.Parent then orb:Destroy() end end
    orbs = {}
    for _, light in ipairs(orbLights) do if light and light.Parent then light:Destroy() end end
    orbLights = {}
end

-- 8. СИНИЙ ШАРИК (СЗАДИ)
local function startBlueOrb()
    blueOrbOn = true
    State.blueOrb = true

    local function setupBlueOrb()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if blueOrbPart and blueOrbPart.Parent then
            blueOrbPart:Destroy()
            blueOrbPart = nil
        end
        if blueOrbLight then
            blueOrbLight:Destroy()
            blueOrbLight = nil
        end

        blueOrbPart = Instance.new("Part")
        blueOrbPart.Size = Vector3.new(0.8, 0.8, 0.8)
        blueOrbPart.Shape = Enum.PartType.Ball
        blueOrbPart.Material = Enum.Material.Neon
        blueOrbPart.Color = Color3.fromRGB(0, 100, 255)
        blueOrbPart.Anchored = true
        blueOrbPart.CanCollide = false
        blueOrbPart.Parent = hrp

        local trail = Instance.new("Trail")
        trail.Parent = blueOrbPart
        trail.Attachment0 = Instance.new("Attachment", blueOrbPart)
        trail.Lifetime = 0.4
        trail.MinLength = 0.2
        trail.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 255))
        })
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(0.5, 0.3),
            NumberSequenceKeypoint.new(1, 1)
        })
        trail.Width = NumberSequence.new(1.2)

        blueOrbLight = Instance.new("PointLight")
        blueOrbLight.Parent = blueOrbPart
        blueOrbLight.Color = Color3.fromRGB(0, 100, 255)
        blueOrbLight.Range = 15
        blueOrbLight.Brightness = 2.5

        blueOrbConn = RunService.RenderStepped:Connect(function()
            if not blueOrbOn or not hrp.Parent then return end
            local time = tick() * 0.5
            local offset = Vector3.new(
                math.sin(time) * 0.3,
                math.cos(time * 0.7) * 0.2 + 1.2,
                -3.5 + math.cos(time * 0.5) * 0.2
            )
            blueOrbPart.Position = hrp.Position + offset
        end)
    end

    setupBlueOrb()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        setupBlueOrb()
    end)
end

local function stopBlueOrb()
    blueOrbOn = false
    State.blueOrb = false
    if blueOrbConn then
        blueOrbConn:Disconnect()
        blueOrbConn = nil
    end
    if blueOrbPart then
        blueOrbPart:Destroy()
        blueOrbPart = nil
    end
    if blueOrbLight then
        blueOrbLight:Destroy()
        blueOrbLight = nil
    end
end

-- 9. TIMER ESP
local function startTimerESP()
    timerOn = true
    State.timerEsp = true

    task.spawn(function()
        while timerOn do
            pcall(function()
                local plots = Workspace:FindFirstChild("Plots")
                if not plots then return end

                for _, plot in ipairs(plots:GetChildren()) do
                    local purch = plot:FindFirstChild("Purchases")
                    if not purch then continue end

                    for _, p2 in ipairs(purch:GetChildren()) do
                        local main = p2:FindFirstChild("Main")
                        if main then
                            local billboard = main:FindFirstChild("BillboardGui")
                            if billboard then
                                local remainingTime = billboard:FindFirstChild("RemainingTime")
                                local locked = billboard:FindFirstChild("Locked")
                                if remainingTime and locked and locked.Visible then
                                    local timerBB = main:FindFirstChild("TimerESP")
                                    if not timerBB then
                                        timerBB = Instance.new("BillboardGui")
                                        timerBB.Name = "TimerESP"
                                        timerBB.Adornee = main
                                        timerBB.Size = UDim2.new(0, 150, 0, 30)
                                        timerBB.StudsOffset = Vector3.new(0, 5, 0)
                                        timerBB.AlwaysOnTop = true
                                        timerBB.Parent = main
                                        local lbl = Instance.new("TextLabel")
                                        lbl.Size = UDim2.new(1, 0, 1, 0)
                                        lbl.BackgroundTransparency = 1
                                        lbl.TextScaled = true
                                        lbl.Font = Enum.Font.GothamBold
                                        lbl.TextColor3 = Color3.fromRGB(0, 255, 0)
                                        lbl.Text = ""
                                        lbl.Parent = timerBB
                                    end
                                    local lbl = timerBB:FindFirstChildOfClass("TextLabel")
                                    if lbl then
                                        lbl.Text = remainingTime.Text
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

local function stopTimerESP()
    timerOn = false
    State.timerEsp = false

    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local purch = plot:FindFirstChild("Purchases")
            if purch then
                for _, p2 in ipairs(purch:GetChildren()) do
                    local main = p2:FindFirstChild("Main")
                    if main then
                        local timerBB = main:FindFirstChild("TimerESP")
                        if timerBB then timerBB:Destroy() end
              
