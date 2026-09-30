-- WEZEX HUB (WINDUI + NATIVE KEY SYSTEM)
-- КЛЮЧ: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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

-- ====== КЛЮЧ-СИСТЕМА ======
local CORRECT_KEY = "38399923"
local keyVerified = false

-- ====== СОСТОЯНИЯ ======
local State = {
    esp = false,
    aimbot = false,
    noclip = false,
    infJump = false,
    aimbotFOV = 250,
    aimbotSmooth = 0.25,
    aimbotPart = "Head",
    aimbotVisibleCheck = true,
    aimbotKey = "E",
    aimbotHold = true,
    showFov = true,
}-- ====== ESP (SAFE — Drawing API) ======
local espDrawings = {}
local espRenderConn = nil

local function clearESP()
    for _, data in pairs(espDrawings) do
        if data.box and data.box.Remove then data.box:Remove() end
        if data.name and data.name.Remove then data.name:Remove() end
        if data.hpBar and data.hpBar.Remove then data.hpBar:Remove() end
        if data.hpBarBg and data.hpBarBg.Remove then data.hpBarBg:Remove() end
        if data.dist and data.dist.Remove then data.dist:Remove() end
    end
    espDrawings = {}
    if espRenderConn then
        espRenderConn:Disconnect()
        espRenderConn = nil
    end
end

local function createDrawingFor(player)
    if player == LocalPlayer then return end
    if espDrawings[player] then return end

    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Transparency = 1
    box.Visible = false
    box.Color = Color3.fromRGB(255, 50, 50)
    box.ZIndex = 2

    local name = Drawing.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.OutlineColor = Color3.fromRGB(0, 0, 0)
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Visible = false
    name.ZIndex = 3

    local dist = Drawing.new("Text")
    dist.Size = 12
    dist.Center = true
    dist.Outline = true
    dist.OutlineColor = Color3.fromRGB(0, 0, 0)
    dist.Color = Color3.fromRGB(200, 200, 200)
    dist.Visible = false
    dist.ZIndex = 3

    local hpBarBg = Drawing.new("Square")
    hpBarBg.Filled = true
    hpBarBg.Transparency = 0.6
    hpBarBg.Color = Color3.fromRGB(0, 0, 0)
    hpBarBg.Visible = false
    hpBarBg.ZIndex = 3

    local hpBar = Drawing.new("Square")
    hpBar.Filled = true
    hpBar.Transparency = 1
    hpBar.Color = Color3.fromRGB(0, 255, 0)
    hpBar.Visible = false
    hpBar.ZIndex = 4

    espDrawings[player] = {
        box = box,
        name = name,
        dist = dist,
        hpBar = hpBar,
        hpBarBg = hpBarBg,
    }
endlocal function removeDrawingFor(player)
    local data = espDrawings[player]
    if not data then return end
    if data.box and data.box.Remove then data.box:Remove() end
    if data.name and data.name.Remove then data.name:Remove() end
    if data.dist and data.dist.Remove then data.dist:Remove() end
    if data.hpBar and data.hpBar.Remove then data.hpBar:Remove() end
    if data.hpBarBg and data.hpBarBg.Remove then data.hpBarBg:Remove() end
    espDrawings[player] = nil
end

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            createDrawingFor(plr)
        end
    end

    for plr, data in pairs(espDrawings) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")

        if hrp and humanoid and humanoid.Health > 0 and head then
            local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local height = math.abs(headPos.Y - footPos.Y)
                local width = height * 0.6
                local x = rootPos.X - width / 2
                local y = headPos.Y
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude

                local color = Color3.fromRGB(255, 50, 50)
                if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                    color = Color3.fromRGB(0, 255, 0)
                elseif not plr.Team or not LocalPlayer.Team then
                    color = Color3.fromRGB(255, 255, 0)
                end

                data.box.Color = color
                data.box.Size = Vector2.new(width, height)
                data.box.Position = Vector2.new(x, y)
                data.box.Visible = true

                data.name.Text = plr.Name
                data.name.Position = Vector2.new(rootPos.X, y - 30)
                data.name.Color = color
                data.name.Visible = true

                data.dist.Text = string.format("[%d studs]", math.floor(distance))
                data.dist.Position = Vector2.new(rootPos.X, y - 16)
                data.dist.Visible = true

                local hpRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local barW, barH = 3, height
                local barX = x - barW - 3
                data.hpBarBg.Size = Vector2.new(barW, barH)
                data.hpBarBg.Position = Vector2.new(barX, y)
                data.hpBarBg.Visible = true

                data.hpBar.Size = Vector2.new(barW, barH * hpRatio)
                data.hpBar.Position = Vector2.new(barX, y + barH * (1 - hpRatio))
                data.hpBar.Color = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 0)
                data.hpBar.Visible = true
            else
                data.box.Visible = false
                data.name.Visible = false
                data.dist.Visible = false
                data.hpBar.Visible = false
                data.hpBarBg.Visible = false
            end
        else
            data.box.Visible = false
            data.name.Visible = false
            data.dist.Visible = false
            data.hpBar.Visible = false
            data.hpBarBg.Visible = false
        end
    end
end

local espPlayerAdded, espPlayerRemoving

local function toggleESP()
    State.esp = not State.esp
    if State.esp then
        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do
            createDrawingFor(p)
        end
        espPlayerAdded = Players.PlayerAdded:Connect(createDrawingFor)
        espPlayerRemoving = Players.PlayerRemoving:Connect(removeDrawingFor)
        espRenderConn = RunService.RenderStepped:Connect(updateESP)
    else
        if espPlayerAdded then espPlayerAdded:Disconnect() espPlayerAdded = nil end
        if espPlayerRemoving then espPlayerRemoving:Disconnect() espPlayerRemoving = nil end
        clearESP()
    end
    end-- ====== AIMBOT (FOV-based, работает только в поле зрения) ======
local aimbotHeld = false
local aimbotRenderConn = nil

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.NumSides = 60
fovCircle.Radius = State.aimbotFOV
fovCircle.Filled = false
fovCircle.Transparency = 0.5
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Visible = false

local function updateFovCircle()
    if State.aimbot and State.showFov then
        fovCircle.Position = Camera.ViewportSize / 2
        fovCircle.Radius = State.aimbotFOV
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end

local function hasLineOfSight(targetPart)
    if not State.aimbotVisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local result = workspace:Raycast(origin, dir, params)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function getClosestTarget()
    local best, bestDist = nil, State.aimbotFOV
    local center = Camera.ViewportSize / 2
    local cameraLook = Camera.CFrame.LookVector
    local camPos = Camera.CFrame.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                    continue
                end

                local part = plr.Character:FindFirstChild(State.aimbotPart)
                    or plr.Character:FindFirstChild("HumanoidRootPart")

                if part then
                    local dirToTarget = (part.Position - camPos).Unit
                    local dot = cameraLook:Dot(dirToTarget)
                    if dot <= 0 then
                        continue
                    end

                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if not onScreen then
                        continue
                    end

                    local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if screenDist > State.aimbotFOV then
                        continue
                    end

                    if not hasLineOfSight(part) then
                        continue
                    end

                    if screenDist < bestDist then
                        best = part
                        bestDist = screenDist
                    end
                end
            end
        end
    end
    return best
end

local function updateAimbot()
    updateFovCircle()

    if not State.aimbot then return end
    if State.aimbotHold and not aimbotHeld then return end

    local target = getClosestTarget()
    if not target then return end

    local currentCF = Camera.CFrame
    local targetCF = CFrame.new(currentCF.Position, target.Position)
    local smooth = math.clamp(State.aimbotSmooth, 0.01, 1)
    Camera.CFrame = currentCF:Lerp(targetCF, smooth)
end

local function startAimbot()
    if aimbotRenderConn then aimbotRenderConn:Disconnect() end
    aimbotRenderConn = RunService.RenderStepped:Connect(updateAimbot)
end

local function stopAimbot()
    if aimbotRenderConn then
        aimbotRenderConn:Disconnect()
        aimbotRenderConn = nil
    end
    fovCircle.Visible = false
end

local function toggleAimbot()
    State.aimbot = not State.aimbot
    if State.aimbot then
        startAimbot()
    else
        stopAimbot()
    end
        endUserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if State.aimbotHold and State.aimbot then
        if (State.aimbotKey == "MouseButton2" and input.UserInputType == Enum.UserInputType.MouseButton2) or
           (State.aimbotKey == "MouseButton1" and input.UserInputType == Enum.UserInputType.MouseButton1) or
           (State.aimbotKey ~= "MouseButton1" and State.aimbotKey ~= "MouseButton2" and input.KeyCode == Enum.KeyCode[State.aimbotKey]) then
            aimbotHeld = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if State.aimbotHold and State.aimbot then
        if (State.aimbotKey == "MouseButton2" and input.UserInputType == Enum.UserInputType.MouseButton2) or
           (State.aimbotKey == "MouseButton1" and input.UserInputType == Enum.UserInputType.MouseButton1) or
           (State.aimbotKey ~= "MouseButton1" and State.aimbotKey ~= "MouseButton2" and input.KeyCode == Enum.KeyCode[State.aimbotKey]) then
            aimbotHeld = false
        end
    end
end)

-- ====== NOCLIP ======
local noclipConnection = nil
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

-- ====== INFINITY JUMP ======
local infJumpConnection = nil
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
            end-- ====== КЛЮЧ-СИСТЕМА (ОКНО) ======
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
                end-- ====== ОСНОВНОЙ GUI ======
function createMainUI()
    local Window = WindUI:CreateWindow({
        Title = "Wezex Hub v4.3",
        Folder = "WezexHub",
        Icon = "solar:folder-2-bold-duotone",
        OpenButton = {
            Title = "Wezex Hub",
            Color = ColorSequence.new(Color3.fromRGB(255, 100, 255), Color3.fromRGB(100, 200, 255)),
            Draggable = true,
            Scale = 0.5,
        },
    })

    -- ===== COMBAT =====
    local CombatTab = Window:Tab({
        Title = "Combat",
        Icon = "solar:sword-bold",
    })
    local CombatSection = CombatTab:Section({
        Title = "⚔️ Aimbot (FOV-based)",
    })

    CombatSection:Toggle({
        Title = "Aimbot",
        Desc = "Наводится только на цели в поле зрения",
        Value = State.aimbot,
        Callback = function(v)
            if v ~= State.aimbot then
                toggleAimbot()
            end
        end,
    })

    CombatSection:Dropdown({
        Title = "Кнопка активации",
        Values = { "E", "Q", "F", "C", "V", "MouseButton2", "MouseButton1" },
        Value = State.aimbotKey,
        Callback = function(v)
            State.aimbotKey = v
        end,
    })

    CombatSection:Toggle({
        Title = "Удерживать кнопку",
        Desc = "Вкл — держать, Выкл — переключение",
        Value = State.aimbotHold,
        Callback = function(v)
            State.aimbotHold = v
        end,
    })

    CombatSection:Slider({
        Title = "FOV (радиус захвата)",
        Desc = "Чем меньше — тем точнее и незаметнее",
        Min = 50,
        Max = 800,
        Value = State.aimbotFOV,
        Callback = function(v)
            State.aimbotFOV = v
        end,
    })

    CombatSection:Slider({
        Title = "Smooth (плавность)",
        Desc = "0.05 — мгновенно, 1 — медленно",
        Min = 0.05,
        Max = 1,
        Value = State.aimbotSmooth,
        Callback = function(v)
            State.aimbotSmooth = v
        end,
    })

    CombatSection:Dropdown({
        Title = "Часть тела",
        Values = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" },
        Value = State.aimbotPart,
        Callback = function(v)
            State.aimbotPart = v
        end,
    })

    CombatSection:Toggle({
        Title = "Проверка видимости",
        Desc = "Наводиться только если цель видна (не через стены)",
        Value = State.aimbotVisibleCheck,
        Callback = function(v)
            State.aimbotVisibleCheck = v
        end,
    })

    CombatSection:Toggle({
        Title = "Показывать FOV круг",
        Desc = "Визуальный круг захвата на экране",
        Value = State.showFov,
        Callback = function(v)
            State.showFov = v
        end,
    })    -- ===== MOVEMENT =====
    local MovementTab = Window:Tab({
        Title = "Movement",
        Icon = "solar:running-bold",
    })
    local MovementSection = MovementTab:Section({
        Title = "🏃 Movement Settings",
    })
    MovementSection:Toggle({
        Title = "Noclip",
        Desc = "Проход сквозь стены",
        Value = State.noclip,
        Callback = function(v)
            if v ~= State.noclip then
                toggleNoclip()
            end
        end,
    })
    MovementSection:Toggle({
        Title = "Infinity Jump",
        Desc = "Бесконечные прыжки",
        Value = State.infJump,
        Callback = function(v)
            if v ~= State.infJump then
                toggleInfJump()
            end
        end,
    })

    -- ===== VISUALS =====
    local VisualsTab = Window:Tab({
        Title = "Visuals",
        Icon = "solar:eye-bold",
    })
    local VisualsSection = VisualsTab:Section({
        Title = "👁️ ESP Settings",
    })
    VisualsSection:Toggle({
        Title = "ESP (Drawing)",
        Desc = "Безопасный ESP через Drawing API",
        Value = State.esp,
        Callback = function(v)
            if v ~= State.esp then
                toggleESP()
            end
        end,
    })

    -- ===== ABOUT =====
    local AboutTab = Window:Tab({
        Title = "About",
        Icon = "solar:info-square-bold",
    })
    local AboutSection = AboutTab:Section({
        Title = "Wezex Hub v4.3",
    })
    AboutSection:Button({
        Title = "Destroy Window",
        Color = Color3.fromRGB(255, 50, 50),
        Callback = function()
            Window:Destroy()
        end,
    })

    if State.esp then toggleESP() end
    if State.aimbot then toggleAimbot() end
    if State.noclip then toggleNoclip() end
    if State.infJump then toggleInfJump() end
end

-- ====== ЗАПУСК ======
showNativeKeyWindow()
