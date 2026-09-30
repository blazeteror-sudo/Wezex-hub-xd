-- WEZEX HUB (WINDUI + NATIVE KEY SYSTEM + AIMBOT + DRAWING ESP)
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
    if ok and type(result) == "table" then
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
    fov = 250,
    part = "Head",
    visCheck = true,
}

-- ====== AIMBOT ======
local aimConn, fovC = nil, Drawing.new("Circle")
fovC.Thickness, fovC.NumSides, fovC.Filled = 1, 60, false
fovC.Transparency, fovC.Color, fovC.Visible = 0.5, Color3.new(1, 1, 1), false

local function updFov()
    if State.aimbot then
        fovC.Position = Camera.ViewportSize / 2
        fovC.Radius = State.fov
        fovC.Visible = true
    else
        fovC.Visible = false
    end
end

local function hasLOS(part)
    if not State.visCheck then return true end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { LocalPlayer.Character }
    local r = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rp)
    return not r or r.Instance:IsDescendantOf(part.Parent)
end

local function getTgt()
    local best, bd = nil, State.fov
    local c = Camera.ViewportSize / 2
    local lk = Camera.CFrame.LookVector
    local cp = Camera.CFrame.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then continue end
                local pt = p.Character:FindFirstChild(State.part) or p.Character:FindFirstChild("HumanoidRootPart")
                if pt then
                    if lk:Dot((pt.Position - cp).Unit) <= 0 then continue end
                    local pos, os = Camera:WorldToViewportPoint(pt.Position)
                    if not os then continue end
                    local sd = (Vector2.new(pos.X, pos.Y) - c).Magnitude
                    if sd > State.fov then continue end
                    if not hasLOS(pt) then continue end
                    if sd < bd then best, bd = pt, sd end
                end
            end
        end
    end
    return best
end

local function updAim()
    updFov()
    if not State.aimbot then return end
    local t = getTgt()
    if t then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
    end
end

local function toggleAim()
    State.aimbot = not State.aimbot
    if State.aimbot then
        if aimConn then aimConn:Disconnect() end
        aimConn = RunService.RenderStepped:Connect(updAim)
    else
        if aimConn then aimConn:Disconnect() aimConn = nil end
        fovC.Visible = false
    end
end

-- ====== ESP (Drawing API — НЕ БАНИТСЯ) ======
local espD, espC, espA, espR = {}, nil, nil, nil

local function clearESP()
    for _, d in pairs(espD) do
        if d.box then pcall(function() d.box:Remove() end) end
        if d.name then pcall(function() d.name:Remove() end) end
        if d.dist then pcall(function() d.dist:Remove() end) end
        if d.hp then pcall(function() d.hp:Remove() end) end
        if d.hpBg then pcall(function() d.hpBg:Remove() end) end
    end
    espD = {}
    if espC then espC:Disconnect() espC = nil end
    if espA then espA:Disconnect() espA = nil end
    if espR then espR:Disconnect() espR = nil end
end

local function mkESP(p)
    if p == LocalPlayer or espD[p] then return end
    local box = Drawing.new("Square")
    box.Thickness, box.Filled, box.Visible, box.ZIndex = 1, false, false, 2
    local nm = Drawing.new("Text")
    nm.Size, nm.Center, nm.Outline, nm.Visible, nm.ZIndex = 14, true, true, false, 3
    nm.OutlineColor = Color3.new()
    local ds = Drawing.new("Text")
    ds.Size, ds.Center, ds.Outline, ds.Visible, ds.ZIndex = 12, true, true, false, 3
    ds.OutlineColor = Color3.new()
    ds.Color = Color3.fromRGB(200, 200, 200)
    local hb = Drawing.new("Square")
    hb.Filled, hb.Transparency, hb.Color, hb.Visible, hb.ZIndex = true, 0.6, Color3.new(), false, 3
    local hp = Drawing.new("Square")
    hp.Filled, hp.Transparency, hp.Visible, hp.ZIndex = true, 1, false, 4
    espD[p] = {box=box, name=nm, dist=ds, hp=hp, hpBg=hb}
end

local function rmESP(p)
    local d = espD[p]
    if not d then return end
    pcall(function() d.box:Remove() end)
    pcall(function() d.name:Remove() end)
    pcall(function() d.dist:Remove() end)
    pcall(function() d.hp:Remove() end)
    pcall(function() d.hpBg:Remove() end)
    espD[p] = nil
end

local function updESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then mkESP(p) end
    end
    for p, d in pairs(espD) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local hd = c and c:FindFirstChild("Head")
        if hrp and h and h.Health > 0 and hd then
            local rp, os = Camera:WorldToViewportPoint(hrp.Position)
            local hp2 = Camera:WorldToViewportPoint(hd.Position + Vector3.new(0, 0.5, 0))
            local fp = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            if os then
                local H = math.abs(hp2.Y - fp.Y)
                local W = H * 0.6
                local x, y = rp.X - W/2, hp2.Y
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                local col = Color3.fromRGB(255, 50, 50)
                d.box.Color, d.box.Size, d.box.Position, d.box.Visible = col, Vector2.new(W, H), Vector2.new(x, y), true
                d.name.Text, d.name.Position, d.name.Color, d.name.Visible = p.Name, Vector2.new(rp.X, y - 30), col, true
                d.dist.Text, d.dist.Position, d.dist.Visible = string.format("[%d]", math.floor(dist)), Vector2.new(rp.X, y - 16), true
                local r = math.clamp(h.Health / h.MaxHealth, 0, 1)
                local bx = x - 6
                d.hpBg.Size, d.hpBg.Position, d.hpBg.Visible = Vector2.new(3, H), Vector2.new(bx, y), true
                d.hp.Size, d.hp.Position = Vector2.new(3, H * r), Vector2.new(bx, y + H * (1 - r))
                d.hp.Color, d.hp.Visible = Color3.fromRGB(255 * (1 - r), 255 * r, 0), true
            else
                d.box.Visible, d.name.Visible, d.dist.Visible, d.hp.Visible, d.hpBg.Visible = false, false, false, false, false
            end
        else
            d.box.Visible, d.name.Visible, d.dist.Visible, d.hp.Visible, d.hpBg.Visible = false, false, false, false, false
        end
    end
end

local function toggleESP()
    State.esp = not State.esp
    if State.esp then
        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do mkESP(p) end
        espA = Players.PlayerAdded:Connect(mkESP)
        espR = Players.PlayerRemoving:Connect(rmESP)
        espC = RunService.RenderStepped:Connect(updESP)
    else
        clearESP()
    end
end

-- ====== NOCLIP ======
local noclipConnection = nil
local originalCollide = {}

local function toggleNoclip()
    State.noclip = not State.noclip
    if State.noclip then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if originalCollide[part] == nil then
                            originalCollide[part] = part.CanCollide
                        end
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
                    part.CanCollide = originalCollide[part] ~= nil and originalCollide[part] or false
                end
            end
        end
        originalCollide = {}
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
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConnection then
            infJumpConnection:Disconnect()
            infJumpConnection = nil
        end
    end
end

-- ====== КЛЮЧ-СИСТЕМА (ОКНО) ======
local function showNativeKeyWindow()
    pcall(function()
        if CoreGui:FindFirstChild("KeySystem") then CoreGui.KeySystem:Destroy() end
    end)

    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeySystem"
    keyGui.ResetOnSpawn = false
    keyGui.IgnoreGuiInset = true
    local ok = pcall(function() keyGui.Parent = CoreGui end)
    if not ok then
        keyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

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

    local enterConn

    local function checkKey()
        if keyBox.Text == CORRECT_KEY then
            keyVerified = true
            if enterConn then enterConn:Disconnect() end
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
    enterConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Return then checkKey() end
    end)
end

-- ====== ОСНОВНОЙ UI ======
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

    -- ===== COMBAT =====
    local CombatTab = Window:Tab({
        Title = "Combat",
        Icon = "solar:sword-bold",
    })
    local CombatSection = CombatTab:Section({
        Title = "⚔️ Aimbot",
    })

    CombatSection:Toggle({
        Title = "Aimbot",
        Desc = "Наведение камеры на цель",
        Value = State.aimbot,
        Callback = function(v)
            if v ~= State.aimbot then toggleAim() end
        end,
    })

    CombatSection:Slider({
        Title = "Aimbot FOV",
        Desc = "Радиус поиска цели",
        Value = { Min = 50, Max = 1000, Default = State.fov },
        Callback = function(v)
            State.fov = v
            updFov()
        end,
    })

    CombatSection:Dropdown({
        Title = "Hit Part",
        Desc = "Часть тела для наводки",
        Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
        Value = State.part,
        Callback = function(v)
            State.part = v
        end,
    })

    CombatSection:Toggle({
        Title = "Wall Check",
        Desc = "Не наводиться через стены",
        Value = State.visCheck,
        Callback = function(v)
            State.visCheck = v
        end,
    })

    -- ===== MOVEMENT =====
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
            if v ~= State.noclip then toggleNoclip() end
        end,
    })

    MovementSection:Toggle({
        Title = "Infinity Jump",
        Desc = "Бесконечные прыжки",
        Value = State.infJump,
        Callback = function(v)
            if v ~= State.infJump then toggleInfJump() end
        end,
    })

    -- ===== VISUALS =====
    local VisualsTab = Window:Tab({
        Title = "Visuals",
        Icon = "solar:eye-bold",
    })
    local VisualsSection = VisualsTab:Section({
        Title = "👁️ Visual Settings",
    })

    VisualsSection:Toggle({
        Title = "ESP (Drawing)",
        Desc = "Безопасный ESP через Drawing API",
        Value = State.esp,
        Callback = function(v)
            if v ~= State.esp then toggleESP() end
        end,
    })

    -- ===== ABOUT =====
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
            clearESP()
            if fovC then pcall(function() fovC:Remove() end) end
            Window:Destroy()
        end,
    })
end

-- ====== ЗАПУСК ======
showNativeKeyWindow()
