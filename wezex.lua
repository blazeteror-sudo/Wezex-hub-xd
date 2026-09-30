-- WEZEX HUB v4.2 (COMPACT)
-- КЛЮЧ: 38399923

local CG = game:GetService("CoreGui")
local PL = game:GetService("Players")
local LP = PL.LocalPlayer
local CAM = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local LGT = game:GetService("Lighting")

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local KEY = "38399923"
local S = { esp=false, aim=false, noclip=false, infjump=false, fov=250, part="Head", vis=true }
local V = {}

-- ===== AIMBOT =====
local aimConn, fovC = nil, Drawing.new("Circle")
fovC.Thickness, fovC.NumSides, fovC.Filled = 1, 60, false
fovC.Transparency, fovC.Color, fovC.Visible = 0.5, Color3.new(1,1,1), false

local function updFov()
    fovC.Visible = S.aim
    if S.aim then fovC.Position = CAM.ViewportSize/2 fovC.Radius = S.fov end
end

local function hasLOS(p)
    if not S.vis then return true end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { LP.Character }
    local r = workspace:Raycast(CAM.CFrame.Position, p.Position - CAM.CFrame.Position, rp)
    return not r or r.Instance:IsDescendantOf(p.Parent)
end

local function getTgt()
    local best, bd = nil, S.fov
    local c, lk, cp = CAM.ViewportSize/2, CAM.CFrame.LookVector, CAM.CFrame.Position
    for _, p in ipairs(PL:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then
                if p.Team and LP.Team and p.Team == LP.Team then continue end
                local pt = p.Character:FindFirstChild(S.part) or p.Character:FindFirstChild("HumanoidRootPart")
                if pt and lk:Dot((pt.Position - cp).Unit) > 0 then
                    local pos, os = CAM:WorldToViewportPoint(pt.Position)
                    if os then
                        local d = (Vector2.new(pos.X, pos.Y) - c).Magnitude
                        if d <= S.fov and d < bd and hasLOS(pt) then best, bd = pt, d end
                    end
                end
            end
        end
    end
    return best
end

local function updAim()
    updFov()
    if S.aim then
        local t = getTgt()
        if t then CAM.CFrame = CFrame.new(CAM.CFrame.Position, t.Position) end
    end
end

local function toggleAim()
    S.aim = not S.aim
    if S.aim then
        if aimConn then aimConn:Disconnect() end
        aimConn = RS.RenderStepped:Connect(updAim)
    else
        if aimConn then aimConn:Disconnect() aimConn = nil end
        fovC.Visible = false
    end
end

-- ===== ESP DRAWING =====
local E, eC, eA, eR = {}, nil, nil, nil

local function clearESP()
    for _, d in pairs(E) do
        for _, k in ipairs({"box","name","dist","hp","hpBg"}) do
            if d[k] then pcall(function() d[k]:Remove() end) end
        end
    end
    E = {}
    if eC then eC:Disconnect() eC = nil end
    if eA then eA:Disconnect() eA = nil end
    if eR then eR:Disconnect() eR = nil end
end

local function mkESP(p)
    if p == LP or E[p] then return end
    local box = Drawing.new("Square")
    box.Thickness, box.Filled, box.Visible, box.ZIndex = 1, false, false, 2
    local nm = Drawing.new("Text")
    nm.Size, nm.Center, nm.Outline, nm.Visible, nm.ZIndex = 14, true, true, false, 3
    nm.OutlineColor = Color3.new()
    local ds = Drawing.new("Text")
    ds.Size, ds.Center, ds.Outline, ds.Visible, ds.ZIndex = 12, true, true, false, 3
    ds.OutlineColor, ds.Color = Color3.new(), Color3.fromRGB(200,200,200)
    local hb = Drawing.new("Square")
    hb.Filled, hb.Transparency, hb.Color, hb.Visible, hb.ZIndex = true, 0.6, Color3.new(), false, 3
    local hp = Drawing.new("Square")
    hp.Filled, hp.Transparency, hp.Visible, hp.ZIndex = true, 1, false, 4
    E[p] = {box=box, name=nm, dist=ds, hp=hp, hpBg=hb}
end

local function rmESP(p)
    local d = E[p]
    if not d then return end
    for _, k in ipairs({"box","name","dist","hp","hpBg"}) do
        if d[k] then pcall(function() d[k]:Remove() end) end
    end
    E[p] = nil
end

local function hideAll(d)
    for _, k in ipairs({"box","name","dist","hp","hpBg"}) do d[k].Visible = false end
end

local function updESP()
    for _, p in ipairs(PL:GetPlayers()) do if p ~= LP then mkESP(p) end end
    for p, d in pairs(E) do
        local c = p.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local hd = c and c:FindFirstChild("Head")
        if hrp and h and h.Health > 0 and hd then
            local rp, os = CAM:WorldToViewportPoint(hrp.Position)
            local hp2 = CAM:WorldToViewportPoint(hd.Position + Vector3.new(0,0.5,0))
            local fp = CAM:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
            if os then
                local H = math.abs(hp2.Y - fp.Y)
                local W = H * 0.6
                local x, y = rp.X - W/2, hp2.Y
                local dist = (CAM.CFrame.Position - hrp.Position).Magnitude
                local col = Color3.fromRGB(255,50,50)
                d.box.Color, d.box.Size, d.box.Position, d.box.Visible = col, Vector2.new(W,H), Vector2.new(x,y), true
                d.name.Text, d.name.Position, d.name.Color, d.name.Visible = p.Name, Vector2.new(rp.X, y-30), col, true
                d.dist.Text, d.dist.Position, d.dist.Visible = "["..math.floor(dist).."]", Vector2.new(rp.X, y-16), true
                local r = math.clamp(h.Health/h.MaxHealth, 0, 1)
                local bx = x - 6
                d.hpBg.Size, d.hpBg.Position, d.hpBg.Visible = Vector2.new(3,H), Vector2.new(bx,y), true
                d.hp.Size, d.hp.Position = Vector2.new(3,H*r), Vector2.new(bx, y+H*(1-r))
                d.hp.Color, d.hp.Visible = Color3.fromRGB(255*(1-r), 255*r, 0), true
            else hideAll(d) end
        else hideAll(d) end
    end
end

local function toggleESP()
    S.esp = not S.esp
    if S.esp then
        clearESP()
        for _, p in ipairs(PL:GetPlayers()) do mkESP(p) end
        eA = PL.PlayerAdded:Connect(mkESP)
        eR = PL.PlayerRemoving:Connect(rmESP)
        eC = RS.RenderStepped:Connect(updESP)
    else clearESP() end
end

-- ===== NOCLIP =====
local ncConn, origCol = nil, {}
local function toggleNoclip()
    S.noclip = not S.noclip
    if S.noclip then
        if ncConn then ncConn:Disconnect() end
        ncConn = RS.Stepped:Connect(function()
            local c = LP.Character
            if c then for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    if origCol[p] == nil then origCol[p] = p.CanCollide end
                    p.CanCollide = false
                end
            end end
        end)
    else
        if ncConn then ncConn:Disconnect() ncConn = nil end
        local c = LP.Character
        if c then for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = origCol[p] ~= nil and origCol[p] or false end
        end end
        origCol = {}
    end
end

-- ===== INF JUMP =====
local ijConn
local function toggleInfJump()
    S.infJump = not S.infJump
    if S.infJump then
        if ijConn then ijConn:Disconnect() end
        ijConn = UIS.JumpRequest:Connect(function()
            local c = LP.Character
            if c and c:FindFirstChildOfClass("Humanoid") then
                c:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if ijConn then ijConn:Disconnect() ijConn = nil end
    end
end

-- ===== CLEAR VISUALS =====
local function clearVis()
    for _, k in ipairs({"sparklesInst","trailInst","fireInst","fireAtt","snowInst","snowAtt"}) do
        if V[k] then V[k]:Destroy() V[k] = nil end
    end
    if V.amb then
        LGT.Ambient = V.oA or Color3.fromRGB(70,70,70)
        LGT.OutdoorAmbient = V.oO or Color3.fromRGB(128,128,128)
        LGT.Brightness = V.oB or 2
    end
    if V.fog then
        LGT.FogEnd = V.oFE or 100000
        LGT.FogColor = V.oFC or Color3.fromRGB(192,192,192)
    end
    local sky = LGT:FindFirstChildOfClass("Sky")
    if sky then sky:Destroy() end
end

-- ===== KEY UI =====
local function showKey()
    pcall(function() if CG:FindFirstChild("KeySystem") then CG.KeySystem:Destroy() end end)
    local g = Instance.new("ScreenGui")
    g.Name, g.ResetOnSpawn, g.IgnoreGuiInset = "KeySystem", false, true
    if not pcall(function() g.Parent = CG end) then g.Parent = LP:WaitForChild("PlayerGui") end

    local f = Instance.new("Frame")
    f.Size, f.Position, f.BackgroundColor3, f.BackgroundTransparency = UDim2.new(0,260,0,150), UDim2.new(0.5,-130,0.5,-75), Color3.fromRGB(15,12,30), 0.15
    f.Parent = g
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,16)

    local t = Instance.new("TextLabel", f)
    t.Size, t.Position, t.BackgroundTransparency = UDim2.new(1,0,0,30), UDim2.new(0,0,0,6), 1
    t.Font, t.TextSize, t.TextColor3, t.Text = Enum.Font.GothamBlack, 20, Color3.fromRGB(200,150,255), "Wezex Hub"
    t.TextXAlignment = Enum.TextXAlignment.Center

    local i = Instance.new("TextLabel", f)
    i.Size, i.Position, i.BackgroundTransparency = UDim2.new(1,0,0,18), UDim2.new(0,0,0,42), 1
    i.Font, i.TextSize, i.TextColor3, i.Text = Enum.Font.Gotham, 12, Color3.fromRGB(160,160,200), "Введите ключ"
    i.TextXAlignment = Enum.TextXAlignment.Center

    local b = Instance.new("TextBox", f)
    b.Size, b.Position, b.BackgroundColor3, b.BackgroundTransparency = UDim2.new(0.6,0,0,34), UDim2.new(0.2,0,0,66), Color3.fromRGB(30,28,50), 0.3
    b.Font, b.TextSize, b.TextColor3, b.Text = Enum.Font.GothamBold, 16, Color3.fromRGB(255,255,255), ""
    b.PlaceholderText, b.PlaceholderColor3, b.ClearTextOnFocus = "Ключ", Color3.fromRGB(120,120,160), false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

    local btn = Instance.new("TextButton", f)
    btn.Size, btn.Position, btn.BackgroundColor3, btn.BackgroundTransparency = UDim2.new(0.35,0,0,34), UDim2.new(0.325,0,0,106), Color3.fromRGB(150,100,255), 0.2
    btn.Text, btn.TextSize, btn.TextColor3, btn.Font = "Войти", 16, Color3.fromRGB(255,255,255), Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

    local conn
    local function check()
        if b.Text == KEY then
            if conn then conn:Disconnect() end
            g:Destroy()
            buildUI()
        else
            b.Text = "" b.PlaceholderText = "Неверно!" b.PlaceholderColor3 = Color3.fromRGB(255,80,80)
            task.wait(0.6)
            b.PlaceholderText, b.PlaceholderColor3 = "Ключ", Color3.fromRGB(120,120,160)
        end
    end
    btn.MouseButton1Click:Connect(check)
    b.FocusLost:Connect(function(e) if e then check() end end)
    conn = UIS.InputBegan:Connect(function(inp, gp) if not gp and inp.KeyCode == Enum.KeyCode.Return then check() end end)
end

-- ===== MAIN UI =====
function buildUI()
    local W = WindUI:CreateWindow({
        Title = "Wezex Hub v4.2", Folder = "WezexHub", Icon = "solar:folder-2-bold-duotone",
        OpenButton = { Title = "Wezex Hub", Color = ColorSequence.new(Color3.fromRGB(255,100,255), Color3.fromRGB(100,200,255)), Draggable = true, Scale = 0.5 },
    })

    -- COMBAT
    local ct = W:Tab({ Title = "Combat", Icon = "solar:sword-bold" })
    local cs = ct:Section({ Title = "⚔️ Aimbot" })
    cs:Toggle({ Title = "Aimbot", Desc = "Наведение камеры", Value = false, Callback = function(v) if v ~= S.aim then toggleAim() end end })
    cs:Slider({ Title = "FOV", Value = { Min = 50, Max = 1000, Default = 250 }, Callback = function(v) S.fov = v updFov() end })
    cs:Dropdown({ Title = "Hit Part", Values = {"Head","HumanoidRootPart","UpperTorso"}, Value = "Head", Callback = function(v) S.part = v end })
    cs:Toggle({ Title = "Wall Check", Value = true, Callback = function(v) S.vis = v end })

    -- MOVEMENT
    local mt = W:Tab({ Title = "Movement", Icon = "solar:running-bold" })
    local ms = mt:Section({ Title = "🏃 Movement" })
    ms:Toggle({ Title = "Noclip", Value = false, Callback = function(v) if v ~= S.noclip then toggleNoclip() end end })
    ms:Toggle({ Title = "Infinity Jump", Value = false, Callback = function(v) if v ~= S.infJump then toggleInfJump() end end })

    -- VISUALS
    local vt = W:Tab({ Title = "Visuals", Icon = "solar:eye-bold" })
    local vs = vt:Section({ Title = "👁️ Visual Settings" })
    vs:Toggle({ Title = "ESP (Drawing)", Value = false, Callback = function(v) if v ~= S.esp then toggleESP() end end })

    local fx = vt:Section({ Title = "✨ Visual Effects" })
    local skies = { ["Матрица"] = "rbxassetid://191546360", ["Космос"] = "rbxassetid://159331075", ["Закат"] = "rbxassetid://160811234" }
    fx:Dropdown({
        Title = "Skybox", Values = {"Стандарт","Матрица","Космос","Закат"}, Value = "Стандарт",
        Callback = function(v)
            local o = LGT:FindFirstChildOfClass("Sky")
            if o then o:Destroy() end
            if v == "Стандарт" then return end
            local id = skies[v]
            if not id then return end
            local sk = Instance.new("Sky")
            sk.SkyboxBk = id sk.SkyboxDn = id sk.SkyboxFt = id
            sk.SkyboxLf = id sk.SkyboxRt = id sk.SkyboxUp = id
            sk.Parent = LGT
        end,
    })

    fx:Toggle({ Title = "Sparkles", Value = false, Callback = function(v)
        local c = LP.Character if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        if v then
            if V.sparklesInst then V.sparklesInst:Destroy() end
            V.sparklesInst = Instance.new("Sparkles", hrp)
            V.sparklesInst.SparkleColor = Color3.fromRGB(255,255,255)
        else if V.sparklesInst then V.sparklesInst:Destroy() V.sparklesInst = nil end end
    end })

    fx:Toggle({ Title = "Trail", Value = false, Callback = function(v)
        local c = LP.Character if not c then return end
        if v then
            local h, hrp = c:FindFirstChild("Head"), c:FindFirstChild("HumanoidRootPart")
            if not h or not hrp then return end
            if V.trailInst then V.trailInst:Destroy() end
            V.trailInst = Instance.new("Trail")
            V.trailInst.Attachment0 = Instance.new("Attachment", h)
            V.trailInst.Attachment1 = Instance.new("Attachment", hrp)
            V.trailInst.Lifetime, V.trailInst.TextureLength = 2, 3
            V.trailInst.Texture = "rbxassetid://18421838422"
            V.trailInst.Transparency = NumberSequence.new(0.2, 1)
            V.trailInst.Parent = c
        else if V.trailInst then V.trailInst:Destroy() V.trailInst = nil end end
    end })

    fx:Toggle({ Title = "Fire Particles", Value = false, Callback = function(v)
        local c = LP.Character if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        if v then
            if V.fireInst then V.fireInst:Destroy() end
            if V.fireAtt then V.fireAtt:Destroy() end
            V.fireAtt = Instance.new("Attachment", hrp)
            V.fireInst = Instance.new("ParticleEmitter")
            V.fireInst.Texture = "rbxassetid://241936182"
            V.fireInst.Color = ColorSequence.new(Color3.fromRGB(255,100,0), Color3.fromRGB(255,0,0))
            V.fireInst.LightEmission, V.fireInst.Rate = 1, 50
            V.fireInst.Transparency = NumberSequence.new(0,1)
            V.fireInst.Size = NumberSequence.new(3,0)
            V.fireInst.Lifetime = NumberRange.new(0.6,1.2)
            V.fireInst.Speed = NumberRange.new(5,10)
            V.fireInst.Parent = V.fireAtt
        else
            if V.fireInst then V.fireInst:Destroy() V.fireInst = nil end
            if V.fireAtt then V.fireAtt:Destroy() V.fireAtt = nil end
        end
    end })

    fx:Toggle({ Title = "Snow Particles", Value = false, Callback = function(v)
        local c = LP.Character if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        if v then
            if V.snowInst then V.snowInst:Destroy() end
            if V.snowAtt then V.snowAtt:Destroy() end
            V.snowAtt = Instance.new("Attachment", hrp)
            V.snowInst = Instance.new("ParticleEmitter")
            V.snowInst.Texture = "rbxassetid://1266170131"
            V.snowInst.Color = ColorSequence.new(Color3.new(1,1,1))
            V.snowInst.LightEmission, V.snowInst.Rate = 0.5, 30
            V.snowInst.Transparency = NumberSequence.new(0,0.5)
            V.snowInst.Size = NumberSequence.new(1.5,0.5)
            V.snowInst.Lifetime = NumberRange.new(1,2)
            V.snowInst.Speed = NumberRange.new(2,5)
            V.snowInst.SpreadAngle = Vector2.new(180,180)
            V.snowInst.Parent = V.snowAtt
        else
            if V.snowInst then V.snowInst:Destroy() V.snowInst = nil end
            if V.snowAtt then V.snowAtt:Destroy() V.snowAtt = nil end
        end
    end })

    fx:Toggle({ Title = "Neon Ambient", Value = false, Callback = function(v)
        V.amb = v
        if v then
            V.oA, V.oO, V.oB = LGT.Ambient, LGT.OutdoorAmbient, LGT.Brightness
            LGT.Ambient = Color3.fromRGB(120,80,255)
            LGT.OutdoorAmbient = Color3.fromRGB(80,40,180)
            LGT.Brightness = 3
        else
            LGT.Ambient = V.oA or Color3.fromRGB(70,70,70)
            LGT.OutdoorAmbient = V.oO or Color3.fromRGB(128,128,128)
            LGT.Brightness = V.oB or 2
        end
    end })

    fx:Toggle({ Title = "Neon Fog", Value = false, Callback = function(v)
        V.fog = v
        if v then
            V.oFE, V.oFC = LGT.FogEnd, LGT.FogColor
            LGT.FogEnd, LGT.FogColor = 300, Color3.fromRGB(80,40,160)
        else
            LGT.FogEnd = V.oFE or 100000
            LGT.FogColor = V.oFC or Color3.fromRGB(192,192,192)
        end
    end })

    -- ABOUT
    local at = W:Tab({ Title = "About", Icon = "solar:info-square-bold" })
    at:Section({ Title = "Wezex Hub v4.2" }):Button({
        Title = "Destroy Window", Color = Color3.fromRGB(255,50,50),
        Callback = function()
            clearESP() clearVis()
            if aimConn then aimConn:Disconnect() end
            pcall(function() fovC:Remove() end)
            W:Destroy()
        end,
    })
end

showKey()
