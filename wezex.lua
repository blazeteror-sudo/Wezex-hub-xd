-- WEZEX HUB (WINDUI + NATIVE KEY SYSTEM)
-- КЛЮЧ: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ====== WINDUI ======
local WindUI
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok then WindUI = result else error("WindUI не загрузился") end
end

local CORRECT_KEY = "38399923"
local keyVerified = false

local State = {
    esp = false,
    aimbot = false,
    noclip = false,
    infJump = false,
    aimbotFOV = 250,
    aimbotPart = "Head",
    aimbotVisibleCheck = true,
    showFov = true,
}

-- ====== ESP (Drawing API) ======
local espDrawings, espConn = {}, nil

local function clearESP()
    for _, d in pairs(espDrawings) do
        if d.box then d.box:Remove() end
        if d.name then d.name:Remove() end
        if d.hpBar then d.hpBar:Remove() end
        if d.hpBarBg then d.hpBarBg:Remove() end
        if d.dist then d.dist:Remove() end
    end
    espDrawings = {}
    if espConn then espConn:Disconnect() espConn = nil end
end

local function createESP(plr)
    if plr == LocalPlayer or espDrawings[plr] then return end

    local box = Drawing.new("Square")
    box.Thickness, box.Filled, box.Visible, box.ZIndex = 1, false, false, 2
    local name = Drawing.new("Text")
    name.Size, name.Center, name.Outline, name.Visible, name.ZIndex = 14, true, true, false, 3
    name.OutlineColor = Color3.fromRGB(0, 0, 0)
    local dist = Drawing.new("Text")
    dist.Size, dist.Center, dist.Outline, dist.Visible, dist.ZIndex = 12, true, true, false, 3
    dist.OutlineColor = Color3.fromRGB(0, 0, 0)
    dist.Color = Color3.fromRGB(200, 200, 200)
    local hpBarBg = Drawing.new("Square")
    hpBarBg.Filled, hpBarBg.Transparency, hpBarBg.Color, hpBarBg.Visible, hpBarBg.ZIndex = true, 0.6, Color3.fromRGB(0, 0, 0), false, 3
    local hpBar = Drawing.new("Square")
    hpBar.Filled, hpBar.Transparency, hpBar.Visible, hpBar.ZIndex = true, 1, false, 4

    espDrawings[plr] = {box=box, name=name, dist=dist, hpBar=hpBar, hpBarBg=hpBarBg}
end

local function removeESP(plr)
    local d = espDrawings[plr]
    if not d then return end
    d.box:Remove() d.name:Remove() d.dist:Remove() d.hpBar:Remove() d.hpBarBg:Remove()
    espDrawings[plr] = nil
end

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then createESP(plr) end
    end

    for plr, d in pairs(espDrawings) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")

        if hrp and hum and hum.Health > 0 and head then
            local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local h = math.abs(headPos.Y - footPos.Y)
                local w = h * 0.6
                local x, y = rootPos.X - w/2, headPos.Y
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude

                local color = Color3.fromRGB(255, 50, 50)
                if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                    color = Color3.fromRGB(0, 255, 0)
                elseif not plr.Team or not LocalPlayer.Team then
                    color = Color3.fromRGB(255, 255, 0)
                end

                d.box.Color, d.box.Size, d.box.Position, d.box.Visible = color, Vector2.new(w, h), Vector2.new(x, y), true
                d.name.Text, d.name.Position, d.name.Color, d.name.Visible = plr.Name, Vector2.new(rootPos.X, y - 30), color, true
                d.dist.Text, d.dist.Position, d.dist.Visible = string.format("[%d studs]", math.floor(distance)), Vector2.new(rootPos.X, y - 16), true

                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local barX = x - 6
                d.hpBarBg.Size, d.hpBarBg.Position, d.hpBarBg.Visible = Vector2.new(3, h), Vector2.new(barX, y), true
                d.hpBar.Size, d.hpBar.Position = Vector2.new(3, h * hp), Vector2.new(barX, y + h * (1 - hp))
                d.hpBar.Color, d.hpBar.Visible = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0), true
            else
                d.box.Visible, d.name.Visible, d.dist.Visible, d.hpBar.Visible, d.hpBarBg.Visible = false, false, false, false, false
            end
        else
            d.box.Visible, d.name.Visible, d.dist.Visible, d.hpBar.Visible, d.hpBarBg.Visible = false, false, false, false, false
        end
    end
end

local espAdded, espRemoved

local function toggleESP()
    State.esp = not State.esp
    if State.esp then
        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
        espAdded = Players.PlayerAdded:Connect(createESP)
        espRemoved = Players.PlayerRemoving:Connect(removeESP)
        espConn = RunService.RenderStepped:Connect(updateESP)
    else
        if espAdded then espAdded:Disconnect() end
        if espRemoved then espRemoved:Disconnect() end
        clearESP()
    end
end

-- ====== AIMBOT (моментальный, без кнопки) ======
local aimbotConn = nil

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness, fovCircle.NumSides, fovCircle.Filled = 1, 60, false
fovCircle.Transparency, fovCircle.Color, fovCircle.Visible = 0.5, Color3.fromRGB(255, 255, 255), false

local function updateFovCircle()
    if State.aimbot and State.showFov then
        fovCircle.Position, fovCircle.Radius, fovCircle.Visible = Camera.ViewportSize / 2, State.aimbotFOV, true
    else
        fovCircle.Visible = false
    end
end

local function hasLOS(part)
    if not State.aimbotVisibleCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local result = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

local function getTarget()
    local best, bestDist = nil, State.aimbotFOV
    local center = Camera.ViewportSize / 2
    local look = Camera.CFrame.LookVector
    local camPos = Camera.CFrame.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
                local part = plr.Character:FindFirstChild(State.aimbotPart) or plr.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    if look:Dot((part.Position - camPos).Unit) <= 0 then continue end
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if not onScreen then continue end
                    local sd = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if sd > State.aimbotFOV then continue end
                    if not hasLOS(part) then continue end
                    if sd < bestDist then best, bestDist = part, sd end
                end
            end
        end
    end
    return best
end

local function updateAimbot()
    updateFovCircle()
    if not State.aimbot then return end
    local target = getTarget()
    if not target then return end
    -- Моментальная наводка (без плавности)
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
end

local function toggleAimbot()
    State.aimbot = not State.aimbot
    if State.aimbot then
        if aimbotConn then aimbotConn:Disconnect() end
        aimbotConn = RunService.RenderStepped:Connect(updateAimbot)
    else
        if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
        fovCircle.Visible = false
    end
end

-- ====== NOCLIP ======
local noclipConn = nil
local function toggleNoclip()
    State.noclip = not State.noclip
    if State.noclip then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

-- ====== INFINITY JUMP ======
local infJumpConn = nil
local function toggleInfJump()
    State.infJump = not State.infJump
    if State.infJump then
        if infJumpConn then infJumpConn:Disconnect() end
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    end
end

-- ====== КЛЮЧ-СИСТЕМА ======
local function showNativeKeyWindow()
    pcall(function()
        if CoreGui:FindFirstChild("KeySystem") then CoreGui.KeySystem:Destroy() end
    end)

    local keyGui = Instance.new("ScreenGui")
    keyGui.Name, keyGui.Parent, keyGui.ResetOnSpawn, keyGui.IgnoreGuiInset = "KeySystem", CoreGui, false, true

    local panel = Instance.new("Frame")
    panel.Size, panel.Position = UDim2.new(0, 260, 0, 150), UDim2.new(0.5, -130, 0.5, -75)
    panel.BackgroundColor3, panel.BackgroundTransparency, panel.Parent = Color3.fromRGB(15, 12, 30), 0.15, keyGui
    Instance.new("UICorner").CornerRadius = UDim.new(0, 16)

    local title = Instance.new("TextLabel")
    title.Size, title.Position, title.BackgroundTransparency = UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 6), 1
    title.Font, title.TextSize, title.TextColor3 = Enum.Font.GothamBlack, 20, Color3.fromRGB(200, 150, 255)
    title.Text, title.TextXAlignment, title.Parent = "Wezex Hub", Enum.TextXAlignment.Center, panel

    local info = Instance.new("TextLabel")
    info.Size, info.Position, info.BackgroundTransparency = UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 42), 1
    info.Font, info.TextSize, info.TextColor3 = Enum.Font.Gotham, 12, Color3.fromRGB(160, 160, 200)
    info.Text, info.TextXAlignment, info.Parent = "Введите ключ доступа", Enum.TextXAlignment.Center, panel

    local keyBox = Instance.new("TextBox")
    keyBox.Size, keyBox.Position = UDim2.new(0.6, 0, 0, 34), UDim2.new(0.2, 0, 0, 66)
    keyBox.BackgroundColor3, keyBox.BackgroundTransparency = Color3.fromRGB(30, 28, 50), 0.3
    keyBox.Font, keyBox.TextSize, keyBox.TextColor3 = Enum.Font.GothamBold, 16, Color3.fromRGB(255, 255, 255)
    keyBox.Text, keyBox.PlaceholderText, keyBox.PlaceholderColor3 = "", "Ключ", Color3.fromRGB(120, 120, 160)
    keyBox.ClearTextOnFocus, keyBox.Parent = false, panel
    Instance.new("UICorner").CornerRadius = UDim.new(0, 10)

    local btn = Instance.new("TextButton")
    btn.Size, btn.Position = UDim2.new(0.35, 0, 0, 34), UDim2.new(0.325, 0, 0, 106)
    btn.BackgroundColor3, btn.BackgroundTransparency = Color3.fromRGB(150, 100, 255), 0.2
    btn.Text, btn.TextSize, btn.TextColor3, btn.Font = "Войти", 16, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold
    btn.Parent = panel
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

    btn.MouseButton1Click:Connect(checkKey)
    keyBox.FocusLost:Connect(function(enter) if enter then checkKey() end end)
end

-- ====== ОСНОВНОЙ GUI ======
function createMainUI()
    local Window = WindUI:CreateWindow({
        Title = "Wezex Hub v4.4",
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
    local CombatTab = Window:Tab({Title = "Combat", Icon = "solar:sword-bold"})
    local CombatSection = CombatTab:Section({Title = "⚔️ Aimbot"})
    CombatSection:Toggle({Title = "Aimbot", Desc = "Моментальная наводка, работает сразу", Value = State.aimbot,
        Callback = function(v) if v ~= State.aimbot then toggleAimbot() end end})
    CombatSection:Slider({Title = "FOV (радиус захвата)", Desc = "Чем меньше — тем точнее",
        Min = 50, Max = 1000, Value = State.aimbotFOV,
        Callback = function(v) State.aimbotFOV = v end})
    CombatSection:Dropdown({Title = "Часть тела", Values = {"Head","HumanoidRootPart","UpperTorso","Torso"}, Value = State.aimbotPart,
        Callback = function(v) State.aimbotPart = v end})
    CombatSection:Toggle({Title = "Проверка видимости", Value = State.aimbotVisibleCheck,
        Callback = function(v) State.aimbotVisibleCheck = v end})
    CombatSection:Toggle({Title = "Показывать FOV круг", Value = State.showFov,
        Callback = function(v) State.showFov = v end})

    -- ===== MOVEMENT =====
    local MovementTab = Window:Tab({Title = "Movement", Icon = "solar:running-bold"})
    local MovementSection = MovementTab:Section({Title = "🏃 Movement"})
    MovementSection:Toggle({Title = "Noclip", Desc = "Проход сквозь стены", Value = State.noclip,
        Callback = function(v) if v ~= State.noclip then toggleNoclip() end end})
    MovementSection:Toggle({Title = "Infinity Jump", Desc = "Бесконечные прыжки", Value = State.infJump,
        Callback = function(v) if v ~= State.infJump then toggleInfJump() end end})

    -- ===== VISUALS =====
    local VisualsTab = Window:Tab({Title = "Visuals", Icon = "solar:eye-bold"})
    local VisualsSection = VisualsTab:Section({Title = "👁️ ESP"})
    VisualsSection:Toggle({Title = "ESP (Drawing)", Desc = "Безопасный ESP", Value = State.esp,
        Callback = function(v) if v ~= State.esp then toggleESP() end end})

    -- ===== ABOUT =====
    local AboutTab = Window:Tab({Title = "About", Icon = "solar:info-square-bold"})
    local AboutSection = AboutTab:Section({Title = "Wezex Hub v4.4"})
    AboutSection:Button({Title = "Destroy Window", Color = Color3.fromRGB(255, 50, 50),
        Callback = function() Window:Destroy() end})

    if State.esp then toggleESP() end
    if State.aimbot then toggleAimbot() end
    if State.noclip then toggleNoclip() end
    if State.infJump then toggleInfJump() end
end

-- ====== ЗАПУСК ======
showNativeKeyWindow()
