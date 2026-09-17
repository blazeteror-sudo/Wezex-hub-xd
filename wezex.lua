-- WEZEX HUB v4.2 - FIXED LAUNCH
-- КЛЮЧ: 38399923

-- ====== ЗАЩИТА ОТ ПАДЕНИЙ ======
local function log(...)
    print("[WezexHub]", ...)
end
local function warnLog(...)
    warn("[WezexHub]", ...)
end

-- ====== СЕРВИСЫ ======
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace

-- ====== РОДИТЕЛЬ GUI ======
local function getGuiParent()
    -- пробуем gethui
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    -- пробуем CoreGui
    local ok, cg = pcall(function() return CoreGui end)
    if ok and cg then return cg end
    -- fallback
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ====== КЛЮЧ ======
local CORRECT_KEY = "38399923"
local keyVerified = false

-- ====== СОСТОЯНИЯ ======
local State = {
    laser = false, fling = false, infJump = false,
    platform = false, esp = false, float = false,
}
local laserOn, flingOn, infJumpOn, platformOn, floatOn, espOn =
    false, false, false, false, false, false

local laserConn, flingConn, infJumpConn = nil, nil, nil
local espHLs = {}
local platformConnection, platformPart, floatConnection = nil, nil, nil
local bindButtons = {}
local WindUI = nil

-- ====== ЗАГРУЗКА WINDUI ======
local function loadWindUI()
    log("Загрузка WindUI...")
    local ok, result = pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
        log("Скачано байт:", #src)
        return loadstring(src)()
    end)
    if ok and type(result) == "table" and result.CreateWindow then
        log("WindUI загружен успешно")
        return result
    end
    warnLog("Основной источник не сработал, пробую резервный...")
    local ok2, result2 = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if ok2 and type(result2) == "table" and result2.CreateWindow then
        log("WindUI загружен с резерва")
        return result2
    end
    warnLog("Не удалось загрузить WindUI")
    return nil
end

-- ====== ЭКРАННЫЕ БИНДЫ ======
local function createBindButton(label, stateKey, toggleFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 32)
    btn.Position = UDim2.new(0.85, 0, 0.1 + #bindButtons * 0.055, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.BackgroundTransparency = 0.15
    btn.Text = label .. ": OFF"
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = getGuiParent()
    btn.Visible = false
    btn.ZIndex = 999
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        toggleFunc()
        if State[stateKey] then
            btn.Text = label .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(80, 220, 160)
        else
            btn.Text = label .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)

    table.insert(bindButtons, {btn = btn, stateKey = stateKey, label = label})
end

local function updateBindButtons()
    for _, data in ipairs(bindButtons) do
        data.btn.Visible = State[data.stateKey] and true or false
        if State[data.stateKey] then
            data.btn.Text = data.label .. ": ON"
            data.btn.BackgroundColor3 = Color3.fromRGB(80, 220, 160)
        end
    end
end

-- ====== ФУНКЦИИ ======

-- LASER
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
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local h2 = p.Character:FindFirstChild("Humanoid")
                if hrp and h2 and h2.Health > 0 then
                    local d = (handle.Position - hrp.Position).Magnitude
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
                if mouse then
                    pcall(function()
                        mouse.Button1Down:Fire(); task.wait(0.05); mouse.Button1Up:Fire()
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

-- FLING
local function toggleFling()
    flingOn = not flingOn
    State.fling = flingOn
    if flingOn then
        pcall(function()
            local h2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            if h2 then h2.AutoJumpEnabled = false end
        end)
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
                r.Velocity = v * 10000 + Vector3.new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                r.Velocity = v
                RunService.Stepped:Wait()
                r.Velocity = v + Vector3.new(0, 0.1, 0)
            end
        end)
    else
        if flingConn then flingConn:Disconnect(); flingConn = nil end
    end
end

-- INF JUMP
local function startInfJump()
    if infJumpConn then infJumpConn:Disconnect() end
    infJumpOn = true
    State.infJump = true
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        local c = LocalPlayer.Character
        if c then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local h2 = c:FindFirstChild("Humanoid")
            if hrp and h2 and h2:GetState() ~= Enum.HumanoidStateType.Dead then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            end
        end
    end)
end
local function stopInfJump()
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    infJumpOn = false
    State.infJump = false
end

-- PLATFORM
local function startPlatform()
    platformOn = true
    State.platform = true
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        platformOn = false; State.platform = false; return
    end
    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(6, 1, 6)
    platformPart.Position = char.HumanoidRootPart.Position - Vector3.new(0, 2, 0)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.Transparency = 0.4
    platformPart.Material = Enum.Material.Neon
    platformPart.Color = Color3.fromRGB(0, 255, 255)
    platformPart.Parent = Workspace
    local light = Instance.new("PointLight")
    light.Parent = platformPart
    light.Color = Color3.fromRGB(0, 255, 255)
    light.Range = 12
    light.Brightness = 2

    platformConnection = RunService.RenderStepped:Connect(function()
        if not platformOn or not platformPart then return end
        local c = LocalPlayer.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        platformPart.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 1.5, hrp.Position.Z)
    end)

    task.spawn(function()
        while platformOn do task.wait(0.5) end
        if platformPart then platformPart:Destroy(); platformPart = nil end
        if platformConnection then platformConnection:Disconnect(); platformConnection = nil end
    end)
end
local function stopPlatform()
    platformOn = false
    State.platform = false
    if platformPart then platformPart:Destroy(); platformPart = nil end
    if platformConnection then platformConnection:Disconnect(); platformConnection = nil end
end

-- FLOAT
local function startFloat()
    floatOn = true
    State.float = true
    local char = LocalPlayer.Character
    if not char then floatOn = false; State.float = false; return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then floatOn = false; State.float = false; return end
    local frozenY = hrp.Position.Y
    floatConnection = RunService.RenderStepped:Connect(function()
        if not floatOn then return end
        local c = LocalPlayer.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        if not root then return end
        root.Velocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.new(root.Position.X, frozenY, root.Position.Z)
    end)
end
local function stopFloat()
    floatOn = false
    State.float = false
    if floatConnection then floatConnection:Disconnect(); floatConnection = nil end
end

-- ESP
local function startESP()
    espOn = true
    State.esp = true
    local function updateESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                if not char:FindFirstChild("WezexESP") then
                    local hl = Instance.new("Highlight")
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
    end
    updateESP()
    table.insert(espHLs, Players.PlayerAdded:Connect(function() task.wait(0.5); updateESP() end))
    table.insert(espHLs, Workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child:FindFirstChild("Humanoid") then
            task.wait(0.3); updateESP()
        end
    end))
    table.insert(espHLs, RunService.Heartbeat:Connect(updateESP))
end
local function stopESP()
    espOn = false
    State.esp = false
    for _, obj in ipairs(espHLs) do
        pcall(function()
            if obj.Disconnect then obj:Disconnect()
            elseif obj.Destroy then obj:Destroy() end
        end)
    end
    espHLs = {}
end

-- ====== ГЛАВНОЕ МЕНЮ ======
local function createMainUI()
    log("Создание главного меню...")

    if not WindUI then
        warnLog("WindUI отсутствует!")
        return
    end

    local ok, err = pcall(function()
        local Window = WindUI:CreateWindow({
            Title = "Wezex Hub v4.2",
            Folder = "WezexHub",
            Icon = "solar:folder-2-bold-duotone",
            KeySystem = false,
            OpenButton = {
                Title = "Wezex Hub",
                Color = ColorSequence.new(Color3.fromRGB(255, 100, 255), Color3.fromRGB(100, 200, 255)),
                Draggable = true,
                Scale = 0.5,
            },
        })

        -- COMBAT
        local CombatTab = Window:Tab({ Title = "Combat", Icon = "solar:sword-bold" })
        local CombatSection = CombatTab:Section({ Title = "Combat Settings" })
        CombatSection:Toggle({
            Title = "Laser Aimbot",
            Desc = "Автострельба лазером",
            Value = State.laser,
            Callback = function(v)
                if v ~= State.laser then
                    if v then startLaser() else stopLaser() end
                    updateBindButtons()
                end
            end,
        })
        CombatSection:Toggle({
            Title = "Touch Fling",
            Desc = "Вылет из карты",
            Value = State.fling,
            Callback = function(v)
                if v ~= State.fling then toggleFling(); updateBindButtons() end
            end,
        })

        -- MOVEMENT
        local MovementTab = Window:Tab({ Title = "Movement", Icon = "solar:running-bold" })
        local MovementSection = MovementTab:Section({ Title = "Movement Settings" })
        MovementSection:Toggle({
            Title = "Infinite Jump",
            Desc = "Бесконечный прыжок",
            Value = State.infJump,
            Callback = function(v)
                if v ~= State.infJump then
                    if v then startInfJump() else stopInfJump() end
                    updateBindButtons()
                end
            end,
        })
        MovementSection:Toggle({
            Title = "Anti-Death Platform",
            Desc = "Платформа под ногами",
            Value = State.platform,
            Callback = function(v)
                if v ~= State.platform then
                    if v then startPlatform() else stopPlatform() end
                    updateBindButtons()
                end
            end,
        })
        MovementSection:Toggle({
            Title = "Float",
            Desc = "Зависание в воздухе",
            Value = State.float,
            Callback = function(v)
                if v ~= State.float then
                    if v then startFloat() else stopFloat() end
                    updateBindButtons()
                end
            end,
        })

        -- VISUALS
        local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "solar:eye-bold" })
        local VisualsSection = VisualsTab:Section({ Title = "Visual Settings" })
        VisualsSection:Toggle({
            Title = "ESP",
            Desc = "Подсветка игроков",
            Value = State.esp,
            Callback = function(v)
                if v ~= State.esp then
                    if v then startESP() else stopESP() end
                    updateBindButtons()
                end
            end,
        })

        -- ABOUT
        local AboutTab = Window:Tab({ Title = "About", Icon = "solar:info-square-bold" })
        local AboutSection = AboutTab:Section({ Title = "Wezex Hub v4.2" })
        AboutSection:Button({
            Title = "Destroy Window",
            Color = Color3.fromRGB(255, 50, 50),
            Callback = function() Window:Destroy() end,
        })

        -- ЭКРАННЫЕ БИНДЫ
        createBindButton("Float", "float", function()
            if State.float then stopFloat() else startFloat() end
            updateBindButtons()
        end)
        createBindButton("Platform", "platform", function()
            if State.platform then stopPlatform() else startPlatform() end
            updateBindButtons()
        end)

        updateBindButtons()
        log("Главное меню создано успешно!")
    end)

    if not ok then
        warnLog("Ошибка создания меню:", err)
    end
end

-- ====== ОКНО КЛЮЧА ======
local function showKeyWindow()
    log("Показ окна ключа...")

    pcall(function()
        local parent = getGuiParent()
        local old = parent:FindFirstChild("WezexKeySystem")
        if old then old:Destroy() end
    end)

    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "WezexKeySystem"
    keyGui.Parent = getGuiParent()
    keyGui.ResetOnSpawn = false
    keyGui.IgnoreGuiInset = true
    keyGui.DisplayOrder = 9999

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 280, 0, 160)
    panel.Position = UDim2.new(0.5, -140, 0.5, -80)
    panel.BackgroundColor3 = Color3.fromRGB(15, 12, 30)
    panel.BackgroundTransparency = 0.1
    panel.Parent = keyGui
    Instance.new("UICorner").CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.Position = UDim2.new(0, 0, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Text = "Wezex Hub"
    title.Parent = panel

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 18)
    info.Position = UDim2.new(0, 0, 0, 46)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextColor3 = Color3.fromRGB(160, 160, 200)
    info.Text = "Введите ключ доступа"
    info.Parent = panel

    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0.7, 0, 0, 36)
    keyBox.Position = UDim2.new(0.15, 0, 0, 70)
    keyBox.BackgroundColor3 = Color3.fromRGB(30, 28, 50)
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
    enterBtn.Size = UDim2.new(0.4, 0, 0, 36)
    enterBtn.Position = UDim2.new(0.3, 0, 0, 114)
    enterBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    enterBtn.Text = "Войти"
    enterBtn.TextSize = 16
    enterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enterBtn.Font = Enum.Font.GothamBold
    enterBtn.Parent = panel
    Instance.new("UICorner").CornerRadius = UDim.new(0, 10)

    local checking = false
    local function checkKey()
        if checking then return end
        checking = true
        if keyBox.Text == CORRECT_KEY then
            keyVerified = true
            keyGui:Destroy()
            log("Ключ верный, запускаю меню...")
            -- Загружаем WindUI только после верного ключа
            WindUI = loadWindUI()
            if WindUI then
                createMainUI()
            else
                warnLog("WindUI не загрузился")
            end
        else
            keyBox.Text = ""
            keyBox.PlaceholderText = "Неверно!"
            keyBox.PlaceholderColor3 = Color3.fromRGB(255, 80, 80)
            task.wait(0.7)
            keyBox.PlaceholderText = "Ключ"
            keyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 160)
        end
        checking = false
    end

    enterBtn.MouseButton1Click:Connect(checkKey)
    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then checkKey() end
    end)

    log("Окно ключа показано")
end

-- ====== ЗАПУСК ======
log("=== Wezex Hub v4.2 запуск ===")
log("Executor info:")
log("  loadstring:", type(loadstring))
log("  gethui:", type(gethui))
log("  HttpGet:", type(game.HttpGet))

local ok, err = pcall(showKeyWindow)
if not ok then
    warnLog("Критическая ошибка:", err)
    -- Аварийное окно с ошибкой
    local sg = Instance.new("ScreenGui")
    sg.Parent = getGuiParent()
    local lbl = Instance.new
