-- WEZEX HUB (WINDUI + NATIVE KEY SYSTEM)
-- КЛЮЧ: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local KnifeController

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
    esp = false,
    knifeAim = false,
    noclip = false,
    infJump = false,
}

-- ====== НАШИ ФУНКЦИИ ======
-- ESP
local espHighlights = {}
local espConnections = {}

local function clearESP()
    for _, h in ipairs(espHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    espHighlights = {}
    for _, c in ipairs(espConnections) do
        if c then c:Disconnect() end
    end
    espConnections = {}
end

local function applyESP(player)
    if player == LocalPlayer then return end
    local function setup(char)
        local old = char:FindFirstChild("WezexESP")
        if old then old:Destroy() end
        local targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not targetPart then return end
        local h = Instance.new("Highlight")
        h.Name = "WezexESP"
        h.Adornee = targetPart
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            h.FillColor = Color3.fromRGB(0, 255, 0)
        elseif player.Team and LocalPlayer.Team and player.Team ~= LocalPlayer.Team then
            h.FillColor = Color3.fromRGB(255, 50, 50)
        else
            h.FillColor = Color3.fromRGB(255, 255, 0)
        end
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.FillTransparency = 0.3
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char
        table.insert(espHighlights, h)
    end
    if player.Character then setup(player.Character) end
    local conn = player.CharacterAdded:Connect(setup)
    table.insert(espConnections, conn)
end

local function toggleESP()
    State.esp = not State.esp
    if State.esp then
        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do
            applyESP(p)
        end
        table.insert(espConnections, Players.PlayerAdded:Connect(applyESP))
    else
        clearESP()
    end
end

-- Silent Aim
getgenv().KnifeConfig = { Enabled = false, HitPart = "Head", FOV = 450 }
local originalThrow = nil

local function getClosestTarget()
    local best, bestFOV = nil, getgenv().KnifeConfig.FOV
    local center = Camera.ViewportSize / 2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local part = plr.Character:FindFirstChild(getgenv().KnifeConfig.HitPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if d < bestFOV then best, bestFOV = plr, d end
                end
            end
        end
    end
    return best
end

local function applyKnifeAim()
    if not KnifeController then
        local success, result = pcall(function()
            return require(LocalPlayer.PlayerScripts:WaitForChild("Controllers"):WaitForChild("Combat"):WaitForChild("KnifeController"))
        end)
        if success then
            KnifeController = result
        else
            return
        end
    end

    if State.knifeAim then
        if not originalThrow then
            originalThrow = KnifeController._GetThrowDirection
        end
        KnifeController._GetThrowDirection = function(self, origin)
            if getgenv().KnifeConfig.Enabled then
                local target = getClosestTarget()
                if target and target.Character then
                    local part = target.Character:FindFirstChild(getgenv().KnifeConfig.HitPart) or target.Character:FindFirstChild("HumanoidRootPart")
                    if part then
                        return (part.Position - origin.Position).Unit
                    end
                end
            end
            return originalThrow(self, origin)
        end
    else
        if originalThrow and KnifeController then
            KnifeController._GetThrowDirection = originalThrow
            originalThrow = nil
        end
    end
end

local function toggleKnifeAim()
    State.knifeAim = not State.knifeAim
    getgenv().KnifeConfig.Enabled = State.knifeAim
    applyKnifeAim()
end

-- Noclip
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

-- Infinity Jump
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
end

-- ====== НАША РОДНАЯ КЛЮЧ-СИСТЕМА (ОКНО) ======
local function showNativeKeyWindow()
    -- Очистка
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

-- ====== ТВОЙ GUI НА WINDUI ======
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
        Title = "Silent Aim",
        Desc = "Автоматическая наводка на голову",
        Value = State.knifeAim,
        Callback = function(v)
            if v ~= State.knifeAim then
                toggleKnifeAim()
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

    -- ВКЛАДКА VISUALS
    local VisualsTab = Window:Tab({
        Title = "Visuals",
        Icon = "solar:eye-bold",
    })
    local VisualsSection = VisualsTab:Section({
        Title = "👁️ Visual Settings",
    })
    VisualsSection:Toggle({
        Title = "ESP (Duels)",
        Desc = "Подсветка игроков",
        Value = State.esp,
        Callback = function(v)
            if v ~= State.esp then
                toggleESP()
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
    if State.esp then toggleESP() end
    if State.knifeAim then toggleKnifeAim() end
    if State.noclip then toggleNoclip() end
    if State.infJump then toggleInfJump() end
end

-- ====== ЗАПУСК ======
showNativeKeyWindow()
