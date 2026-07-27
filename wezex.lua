-- WEZEX HUB (WINDUI + NATIVE KEY SYSTEM) - FULL EXPANSION
-- КЛЮЧ: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local KnifeController
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

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

-- ====== КЛЮЧ ======
local CORRECT_KEY = "38399923"
local keyVerified = false

-- ====== СОСТОЯНИЯ ======
local State = {
    esp = false,
    knifeAim = false,
    noclip = false,
    knifeNoclip = false,
    infJump = false,
    knifeTrail = false,
    hitmarker = false,
    skyChange = false,
    bunnyHop = false,
    spinBot = false,
    thirdPerson = false,
}
local skyConnection = nil
local spinConnection = nil
local thirdPersonConnection = nil
local bunnyHopConnection = nil

-- ====== ESP ======
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

-- ====== SILENT AIM ======
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

-- ====== KNIFE NOCLIP ======
local knifeNoclipConnection = nil
local function toggleKnifeNoclip()
    State.knifeNoclip = not State.knifeNoclip
    if State.knifeNoclip then
        if knifeNoclipConnection then knifeNoclipConnection:Disconnect() end
        knifeNoclipConnection = RunService.Heartbeat:Connect(function()
            for _, knife in ipairs(workspace:GetDescendants()) do
                if knife:IsA("BasePart") and knife.Name and string.find(string.lower(knife.Name), "knife") then
                    pcall(function()
                        knife.CanCollide = false
                        knife.CanTouch = false
                    end)
                end
            end
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name and string.find(string.lower(part.Name), "knife") then
                        pcall(function()
                            part.CanCollide = false
                            part.CanTouch = false
                        end)
                    end
                end
            end
        end)
    else
        if knifeNoclipConnection then
            knifeNoclipConnection:Disconnect()
            knifeNoclipConnection = nil
        end
        for _, knife in ipairs(workspace:GetDescendants()) do
            if knife:IsA("BasePart") and knife.Name and string.find(string.lower(knife.Name), "knife") then
                pcall(function()
                    knife.CanCollide = true
                    knife.CanTouch = true
                end)
            end
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name and string.find(string.lower(part.Name), "knife") then
                    pcall(function()
                        part.CanCollide = true
                        part.CanTouch = true
                    end)
                end
            end
        end
    end
end

-- ====== INFINITE JUMP ======
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

-- ====== KNIFE TRAIL ======
local trailParts = {}
local trailConnections = {}

local function createTrail(knife)
    if not State.knifeTrail then return end
    if knife:FindFirstChild("WezexKnifeTrail") then return end
    
    local trail = Instance.new("Trail")
    trail.Name = "WezexKnifeTrail"
    trail.Parent = knife
    
    local att = Instance.new("Attachment")
    att.Parent = knife
    att.Position = Vector3.new(0, 0, 0)
    trail.Attachment0 = att
    
    trail.Lifetime = 0.4
    trail.MinLength = 0.3
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    })
    trail.Width = NumberSequence.new(0.2)
    
    table.insert(trailParts, trail)
end

local function clearTrails()
    for _, trail in ipairs(trailParts) do
        if trail and trail.Parent then
            trail:Destroy()
        end
    end
    trailParts = {}
end

local function toggleKnifeTrail()
    State.knifeTrail = not State.knifeTrail
    if State.knifeTrail then
        for _, conn in ipairs(trailConnections) do
            conn:Disconnect()
        end
        trailConnections = {}
        clearTrails()
        
        local function checkKnives()
            for _, knife in ipairs(workspace:GetDescendants()) do
                if knife:IsA("BasePart") and knife.Name and string.find(string.lower(knife.Name), "knife") then
                    if not knife:FindFirstChild("WezexKnifeTrail") then
                        createTrail(knife)
                    end
                end
            end
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name and string.find(string.lower(part.Name), "knife") then
                        if not part:FindFirstChild("WezexKnifeTrail") then
                            createTrail(part)
                        end
                    end
                end
            end
        end
        
        local conn = RunService.Heartbeat:Connect(checkKnives)
        table.insert(trailConnections, conn)
        
        local childConn = workspace.ChildAdded:Connect(function(child)
            task.wait(0.05)
            if child:IsA("BasePart") and child.Name and string.find(string.lower(child.Name), "knife") then
                if not child:FindFirstChild("WezexKnifeTrail") then
                    createTrail(child)
                end
            end
        end)
        table.insert(trailConnections, childConn)
        
        checkKnives()
    else
        for _, conn in ipairs(trailConnections) do
            conn:Disconnect()
        end
        trailConnections = {}
        clearTrails()
    end
end

-- ====== HITMARKERS ======
local hitmarkerParts = {}
local function createHitmarker(position)
    if not State.hitmarker then return end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "WezexHitmarker"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 30, 0, 30)
    frame.Position = UDim2.new(0.5, -15, 0.5, -15)
    frame.BackgroundTransparency = 1
    frame.Parent = gui
    
    local lines = {
        {1, 1, 0.3, 0.7},
        {0.7, 0.3, 1, 1},
        {0.3, 0.7, 1, 1},
        {0, 1, 0.3, 0.3},
    }
    
    for _, data in ipairs(lines) do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(data[1], 0, data[2], 0)
        line.Position = UDim2.new(data[3], 0, data[4], 0)
        line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        line.BackgroundTransparency = 0.2
        line.BorderSizePixel = 0
        line.Parent = frame
    end
    
    table.insert(hitmarkerParts, gui)
    
    -- Анимация исчезновения
    task.wait(0.2)
    for i = 1, 10 do
        frame.BackgroundTransparency = 0.2 + (i / 10) * 0.8
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("Frame") then
                child.BackgroundTransparency = 0.2 + (i / 10) * 0.8
            end
        end
        task.wait(0.02)
    end
    gui:Destroy()
end

local function toggleHitmarker()
    State.hitmarker = not State.hitmarker
    if State.hitmarker then
        -- Подключаемся к событию получения урона (если есть)
        pcall(function()
            LocalPlayer.CharacterAdded:Connect(function(char)
                local humanoid = char:WaitForChild("Humanoid")
                humanoid.HealthChanged:Connect(function(health)
                    if health < humanoid.MaxHealth then
                        createHitmarker()
                    end
                end)
            end)
        end)
    end
end

-- ====== CHANGE SKY ======
local skyColors = {
    {Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 200, 100)}, -- Закат
    {Color3.fromRGB(100, 100, 255), Color3.fromRGB(200, 200, 255)}, -- День
    {Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255)}, -- Радуга
    {Color3.fromRGB(0, 0, 0), Color3.fromRGB(50, 50, 80)}, -- Ночь
    {Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 255)}, -- Снег
}

local function toggleSky()
    State.skyChange = not State.skyChange
    if skyConnection then
        skyConnection:Disconnect()
        skyConnection = nil
    end
    
    if State.skyChange then
        local index = 1
        skyConnection = RunService.Heartbeat:Connect(function()
            local sky = skyColors[index]
            Lighting.Ambient = sky[1]
            Lighting.OutdoorAmbient = sky[2]
            Lighting.Brightness = 1
            index = index % #skyColors + 1
            task.wait(2)
        end)
    else
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
    end
end

-- ====== BUNNY HOP ======
local function toggleBunnyHop()
    State.bunnyHop = not State.bunnyHop
    if bunnyHopConnection then
        bunnyHopConnection:Disconnect()
        bunnyHopConnection = nil
    end
    
    if State.bunnyHop then
        bunnyHopConnection = RunService.Heartbeat:Connect(function()
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    local hum = char.Humanoid
                    if hum.FloorMaterial ~= Enum.Material.Air then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    end
end

-- ====== SPIN BOT (FPP) ======
local function toggleSpinBot()
    State.spinBot = not State.spinBot
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
    
    if State.spinBot then
        spinConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local current = root.Orientation
                root.Orientation = Vector3.new(current.X, current.Y + 3, current.Z)
            end
        end)
    end
end

-- ====== THIRD PERSON ======
local function toggleThirdPerson()
    State.thirdPerson = not State.thirdPerson
    if thirdPersonConnection then
        thirdPersonConnection:Disconnect()
        thirdPersonConnection = nil
    end
    
    if State.thirdPerson then
        thirdPersonConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local pos = root.Position + Vector3.new(0, 2, 5)
                Camera.CFrame = CFrame.new(pos, root.Position)
            end
        end)
    else
        Camera.CFrame = workspace.CurrentCamera.CFrame
    end
end

-- ====== КЛЮЧ-СИСТЕМА ======
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
    enterBtn.TextColor3 = Color3.
