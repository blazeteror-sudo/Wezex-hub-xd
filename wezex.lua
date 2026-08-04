-- WEZEX HUB | STEEL BRAINROT (NO KEY)
-- ВСЕ ФУНКЦИИ + ИДЕАЛЬНОЕ МЕНЮ

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = workspace
local TweenService = game:GetService("TweenService")

-- ====== СОСТОЯНИЯ ======
local State = {
    wsEnabled = false,
    wsSpeed = 80,
    ijEnabled = false,
    bjEnabled = false,
    bjStrength = 150,
    espEnabled = false,
    timerEsp = false,
    webAim = false,
    antiTrap = false,
    antiHit = false,
    hvEsp = false,
    fling = false,
}

-- ====== ПОДКЛЮЧЕНИЯ ======
local wsConn = nil
local flingConn = nil
local espConns = {}
local espBBs = {}
local timerConns = {}
local webConn = nil
local ijConn = nil
local bjConns = {}
local atConn = nil
local hvBase, hvGui = nil, nil
local wsOn = false
local flingOn = false
local espOn = false
local timerOn = false
local webOn = false
local ijOn = false
local bjOn = false
local atOn = false
local ahOn = false
local hvOn = false

-- ====== WALKSPEED ======
local function stopWS()
    if wsConn then wsConn:Disconnect(); wsConn = nil end
    local c = LocalPlayer.Character
    if c then
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then
            local vf = r:FindFirstChild("ConstantMoveForce")
            if vf then vf:Destroy() end
            local at = r:FindFirstChildOfClass("Attachment")
            if at then at:Destroy() end
        end
    end
    wsOn = false
    State.wsEnabled = false
end

local function startWS()
    stopWS()
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = c:WaitForChild("HumanoidRootPart")
    local h = c:WaitForChild("Humanoid")

    local cloak = LocalPlayer.Backpack:FindFirstChild("Invisibility Cloak") or c:FindFirstChild("Invisibility Cloak")
    if cloak and cloak:IsA("Tool") then
        if cloak.Parent ~= c then cloak.Parent = c; task.wait(0.1) end
        cloak:Activate()
    end

    local att = Instance.new("Attachment", root)
    local vf = Instance.new("VectorForce")
    vf.Name = "ConstantMoveForce"
    vf.Attachment0 = att
    vf.RelativeTo = Enum.ActuatorRelativeTo.World
    vf.ApplyAtCenterOfMass = true
    vf.Force = Vector3.zero
    vf.Parent = root

    wsConn = RunService.RenderStepped:Connect(function()
        local dir = h.MoveDirection
        if dir.Magnitude > 0 then
            local want = dir.Unit * State.wsSpeed
            local vel = root.Velocity
            local flat = Vector3.new(vel.X, 0, vel.Z)
            local fix = (want - flat) * 100 - flat * 0.9
            vf.Force = Vector3.new(fix.X, 0, fix.Z)
        else
            vf.Force = Vector3.zero
        end
    end)

    wsOn = true
    State.wsEnabled = true
end

-- ====== INFINITE JUMP ======
local function startIJ()
    if ijConn then ijConn:Disconnect() end
    ijOn = true
    State.ijEnabled = true
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
    State.ijEnabled = false
end

-- ====== BOOST JUMP ======
local function startBJ()
    for _, v in pairs(bjConns) do v:Disconnect() end
    bjConns = {}
    bjOn = true
    State.bjEnabled = true

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
        if r.Velocity.Magnitude > 1 then
            v = v + r.CFrame.LookVector * 50
        end
        r.Velocity = v
        canBoost = false
    end)
end

local function stopBJ()
    for _, v in pairs(bjConns) do v:Disconnect() end
    bjConns = {}
    bjOn = false
    State.bjEnabled = false
end

-- ====== ANTI TRAP ======
local function startAT()
    if atConn then atConn:Disconnect() end
    atOn = true
    State.antiTrap = true
    atConn = RunService.Heartbeat:Connect(function()
        local trap = Workspace:FindFirstChild("Trap")
        if trap and trap:IsA("Model") then trap:Destroy() end
    end)
end

local function stopAT()
    if atConn then atConn:Disconnect(); atConn = nil end
    atOn = false
    State.antiTrap = false
end

-- ====== ANTI HIT ======
local function startAH()
    ahOn = true
    State.antiHit = true

    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rem = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/UseItem")
    local buyRem = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/CoinsShopService/RequestBuy")

    local function getWeb()
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name == "Web Slinger" then return t end
        end
    end

    local function ensureWeb()
        if not getWeb() then buyRem:InvokeServer("Web Slinger") end
    end

    local function equipWeb()
        local cur = c:FindFirstChildOfClass("Tool")
        if cur and cur.Name ~= "Web Slinger" then cur.Parent = LocalPlayer.Backpack end
        local t = getWeb()
        if t then t.Parent = c end
    end

    local function useWeb()
        local t = c:FindFirstChild("Web Slinger")
        if t and t:FindFirstChild("Handle") then
            rem:FireServer(Vector3.new(-391.2, -7.29, 124.8), c:WaitForChild("UpperTorso"))
        end
    end

    local last = 0
    RunService.Heartbeat:Connect(function()
        if not ahOn then return end
        if tick() - last >= 3.5 then
            last = tick()
            ensureWeb()
            task.wait(0.3)
            equipWeb()
            task.wait(3.5)
            useWeb()
        end
    end)

    task.defer(function()
        RunService.RenderStepped:Connect(function()
            if not ahOn then return end
            local h2 = c:FindFirstChildOfClass("Humanoid")
            if h2 and h2.PlatformStand then h2.PlatformStand = false end
        end)
    end)
end

local function stopAH()
    ahOn = false
    State.antiHit = false
end

-- ====== WEB SLINGER AIM ======
local function startWeb()
    if webConn then webConn:Disconnect() end
    local tool = LocalPlayer.Backpack:FindFirstChild("Web Slinger") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Web Slinger"))
    if not tool then
        pcall(function()
            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/CoinsShopService/RequestBuy"):InvokeServer("Web Slinger")
        end)
        task.wait(1)
        tool = LocalPlayer.Backpack:FindFirstChild("Web Slinger") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Web Slinger"))
        if not tool then return end
    end

    webOn = true
    State.webAim = true

    local handle = tool:WaitForChild("Handle")

    webConn = tool.Activated:Connect(function()
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
            local tp = best.Character:FindFirstChild("HumanoidRootPart")
            if tp then
                local pos = tp.Position
                ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/UseItem"):FireServer(
                    Vector3.new(pos.X, pos.Y, pos.Z), tp, handle
                )
            end
        end
    end)
end

local function stopWeb()
    if webConn then webConn:Disconnect(); webConn = nil end
    webOn = false
    State.webAim = false
end

-- ====== ESP ======
local function addHL(p2)
    if p2 == LocalPlayer or not p2.Character then return end
    local col = Color3.fromRGB(math.random(50,255), math.random(50,255), math.random(50,255))
    local hl = Instance.new("Highlight")
    hl.Name = "ZHL"
    hl.FillColor = col
    hl.OutlineColor = col
    hl.FillTransparency = 0.3
    hl.OutlineTransparency = 0
    hl.Adornee = p2.Character
    hl.Parent = p2.Character

    local bb = Instance.new("BillboardGui")
    bb.Name = "ZHBB"
    bb.Adornee = p2.Character:FindFirstChild("Head")
    bb.Size = UDim2.new(0,100,0,50)
    bb.StudsOffset = Vector3.new(0,2,0)
    bb.AlwaysOnTop = true
    bb.Parent = p2.Character

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1,0,0.5,0)
    nl.BackgroundTransparency = 1
    nl.Text = p2.Name
    nl.TextColor3 = Color3.new(1,1,1)
    nl.TextScaled = true
    nl.Font = Enum.Font.GothamBold
    nl.Parent = bb

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1,0,0.5,0)
    dl.Position = UDim2.new(0,0,0.5,0)
    dl.BackgroundTransparency = 1
    dl.Text = p2.DisplayName
    dl.TextColor3 = Color3.fromRGB(200,200,200)
    dl.TextScaled = true
    dl.Font = Enum.Font.Gotham
    dl.Parent = bb

    espBBs[p2] = bb
end

local function clearHL(p2)
    if p2.Character then
        local hl = p2.Character:FindFirstChild("ZHL")
        if hl then hl:Destroy() end
    end
    if espBBs[p2] then espBBs[p2]:Destroy(); espBBs[p2] = nil end
end

local function startESP()
    for _, p2 in pairs(Players:GetPlayers()) do clearHL(p2) end
    for _, c2 in pairs(espConns) do c2:Disconnect() end
    espConns = {}
    espOn = true
    State.espEnabled = true
    for _, p2 in pairs(Players:GetPlayers()) do addHL(p2) end
    espConns[1] = Players.PlayerAdded:Connect(function(p2)
        p2.CharacterAdded:Connect(function() addHL(p2) end)
    end)
    espConns[2] = Players.PlayerRemoving:Connect(function(p2)
        clearHL(p2)
    end)
end

local function stopESP()
    espOn = false
    State.espEnabled = false
    for _, p2 in pairs(Players:GetPlayers()) do clearHL(p2) end
    for _, c2 in pairs(espConns) do c2:Disconnect() end
    espConns = {}
end

-- ====== TIMER ESP ======
local function setBillboard(part, txt, show)
    local ex = part:FindFirstChild("ZTimerBB")
    if show then
        if not ex then
            local bb = Instance.new("BillboardGui")
            bb.Name = "ZTimerBB"
            bb.Adornee = part
            bb.Size = UDim2.new(0,200,0,50)
            bb.StudsOffset = Vector3.new(0,5,0)
            bb.AlwaysOnTop = true
            bb.Parent = part
            local lbl = Instance.new("TextLabel")
            lbl.Name = "T"
            lbl.Size = UDim2.new(1,0,1,0)
            lbl.BackgroundTransparency = 1
            lbl.TextScaled = true
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.TextStrokeTransparency = 0.2
            lbl.Font = Enum.Font.GothamBold
            lbl.Text = txt
            lbl.Parent = bb
        else
            local lbl = ex:FindFirstChild("T")
            if lbl then lbl.Text = txt end
        end
    else
        if ex then ex:Destroy() end
    end
end

local function getLowest(purchases)
    local res, resY = nil, nil
    for _, p2 in pairs(purchases:GetChildren()) do
        local m = p2:FindFirstChild("Main")
        local g = m and m:FindFirstChild("BillboardGui")
        local rt = g and g:FindFirstChild("RemainingTime")
        local lk = g and g:FindFirstChild("Locked")
        if m and rt and lk and rt:IsA("TextLabel") and lk:IsA("GuiObject") and lk.Visible then
            local y = m.Position.Y
            if not resY or y < resY then
                res = {rt=rt, lk=lk, m=m}
                resY = y
            end
        end
    end
    return res
end

local function scanTimers()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, plot in pairs(plots:GetChildren()) do
        local purch = plot:FindFirstChild("Purchases")
        if purch then
            local sel = getLowest(purch)
            for _, p2 in pairs(purch:GetChildren()) do
                local m = p2:FindFirstChild("Main")
                local g = m and m:FindFirstChild("BillboardGui")
                local rt = g and g:FindFirstChild("RemainingTime")
                local lk = g and g:FindFirstChild("Locked")
                if m and rt and lk and rt:IsA("TextLabel") and lk:IsA("GuiObject") then
                    local isit = sel and rt == sel.rt
                    setBillboard(m, rt.Text, isit)
                    local key = rt:GetDebugId()
                    if isit and not timerConns[key] then
                        local function refresh()
                            local still = (getLowest(purch) or {}).rt == rt
                            setBillboard(m, rt.Text, still and lk.Visible)
                        end
                        timerConns[key] = {
                            rt:GetPropertyChangedSignal("Text"):Connect(refresh),
                            lk:GetPropertyChangedSignal("Visible"):Connect(refresh)
                        }
                    end
                end
            end
        end
    end
end

local function startTimer()
    timerOn = true
    State.timerEsp = true
    task.spawn(function()
        while timerOn do
            pcall(scanTimers)
            task.wait(5)
        end
    end)
end

local function stopTimer()
    timerOn = false
    State.timerEsp = false
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in pairs(plots:GetChildren()) do
            local purch = plot:FindFirstChild("Purchases")
            if purch then
                for _, p2 in pairs(purch:GetChildren()) do
                    local m = p2:FindFirstChild("Main")
                    if m then
                        local bb = m:FindFirstChild("ZTimerBB")
                        if bb then bb:Destroy() end
                    end
                end
            end
        end
    end
    for _, cs in pairs(timerConns) do
        for _, c2 in ipairs(cs) do c2:Disconnect() end
    end
    timerConns = {}
end

-- ====== HIGH VALUE ESP ======
local mutColors = {
    Gold = Color3.fromRGB(255,215,0),
    Diamond = Color3.fromRGB(0,255,255),
    Lava = Color3.fromRGB(255,100,0),
    Bloodrot = Color3.fromRGB(255,0,0),
}

local function parseNum(str)
    if not str then return 0 end
    local s = str:match("%$(.-)/s")
    if not s then return 0 end
    s = s:gsub("%s","")
    local mult = 1
    if s:lower():find("k") then mult = 1000; s = s:gsub("[kK]","")
    elseif s:lower():find("m") then mult = 1e6; s = s:gsub("[mM]","")
    elseif s:lower():find("b") then mult = 1e9; s = s:gsub("[bB]","") end
    return (tonumber(s) or 0) * mult
end

local function getMut(mut)
    if not mut or not mut.Visible or mut.Text == "" then return "Default", Color3.new(1,1,1), false end
    if mut.Text == "Rainbow" then return "Rainbow", Color3.new(1,1,1), true end
    return mut.Text, mutColors[mut.Text] or Color3.new(1,1,1), false
end

local function makeBB(base2, overhead, info)
    if base2:FindFirstChild("ZHV") then base2.ZHV:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ZHV"
    bb.Size = UDim2.new(0,200,0,60)
    bb.StudsOffset = Vector3.new(0,3,0)
    bb.AlwaysOnTop = true
    bb.Adornee = base2
    bb.Parent = base2

    local lbls = {}
    local function mkLabel(i, txt)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,0,0.25,0)
        l.Position = UDim2.new(0,0,0.25*(i-1),0)
        l.BackgroundTransparency = 1
        l.TextScaled = true
        l.Font = Enum.Font.SourceSansBold
        l.TextStrokeTransparency = 0.5
        l.Text = txt or "?"
        l.TextColor3 = Color3.new(1,1,1)
        l.Parent = bb
        table.insert(lbls, l)
    end

    mkLabel(1, info.name)
    mkLabel(2, info.gen)
    mkLabel(3, info.mut)
    mkLabel(4, info.rar)

    if info.mut == "Rainbow" then
        local t = 0
        RunService.RenderStepped:Connect(function(dt)
            if bb.Parent == nil then return end
            t = t + dt * 0.2
            local rc = Color3.fromHSV(t % 1, 1, 1)
            for _, l in ipairs(lbls) do l.TextColor3 = rc end
        end)
    else
        local col = mutColors[info.mut] or Color3.new(1,1,1)
        for _, l in ipairs(lbls) do l.TextColor3 = col end
    end
end

local function getPodiums()
    local res = {}
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return res end
    for _, plot in pairs(plots:GetChildren()) do
        local ap = plot:FindFirstChild("AnimalPodiums")
        if ap then
            for _, pod in pairs(ap:GetChildren()) do
                local b = pod:FindFirstChild("Base")
                if b and b:FindFirstChild("Spawn") then
                    local att = b.Spawn:FindFirstChild("Attachment")
                    if att and att:FindFirstChild("AnimalOverhead") then
                        table.insert(res, att.AnimalOverhead)
                    end
                end
            end
        end
    end
    return res
end

local function startHV()
    hvOn = true
    State.hvEsp = true
    task.spawn(function()
        while hvOn do
            local bestOH, bestVal, bestInfo, bestBase = nil, -math.huge, nil, nil
            for _, oh in pairs(getPodiums()) do
                local b2 = oh.Parent.Parent.Parent
                if b2 and (b2:IsA("BasePart") or b2:IsA("Model")) then
                    local gl = oh:FindFirstChild("Generation")
                    if gl then
                        local v = parseNum(gl.Text)
                        if v > bestVal then
                            bestVal = v
                            bestOH = oh
                            bestBase = b2
                            local mutLbl = oh:FindFirstChild("Mutation")
                            local mutTxt = getMut(mutLbl)
                            bestInfo = {
                                name = oh:FindFirstChild("DisplayName") and oh.DisplayName.Text or "?",
                                gen = gl.Text,
                                mut = mutTxt,
                                rar = oh:FindFirstChild("Rarity") and oh.Rarity.Text or "?"
                            }
                        end
                    end
                end
            end
            if bestOH and bestBase then
                if hvBase ~= bestBase then
                    if hvGui and hvGui.Parent then hvGui:Destroy() end
                    hvBase = bestBase
                    makeBB(bestBase, bestOH, bestInfo)
                    hvGui = bestBase:FindFirstChild("ZHV")
                end
    
