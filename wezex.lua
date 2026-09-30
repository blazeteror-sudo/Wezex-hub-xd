-- WEZEX HUB v4.6 | КЛЮЧ: 38399923

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local WindUI
do
    local ok, r = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok then WindUI = r else error("WindUI не загрузился") end
end

local KEY = "38399923"
local State = {
    esp=false, aimbot=false, noclip=false, infJump=false, airJump=false, hitMarker=false,
    fov=250, part="Head", visCheck=true, showFov=true,
    hotkey="RightShift", showBtn=false, btnPos=UDim2.new(0.85,0,0.5,0),
}
local floatBtn, aimToggle

-- ===== ESP =====
local espD, espC = {}, nil
local function clearESP()
    for _,d in pairs(espD) do
        if d.box then pcall(function() d.box:Remove() end) end
        if d.name then pcall(function() d.name:Remove() end) end
        if d.dist then pcall(function() d.dist:Remove() end) end
        if d.hp then pcall(function() d.hp:Remove() end) end
        if d.hpBg then pcall(function() d.hpBg:Remove() end) end
    end
    espD = {}
    if espC then espC:Disconnect() espC = nil end
end
local function mkESP(p)
    if p == LP or espD[p] then return end
    local box=Drawing.new("Square"); box.Thickness,box.Filled,box.Visible,box.ZIndex=1,false,false,2
    local nm=Drawing.new("Text"); nm.Size,nm.Center,nm.Outline,nm.Visible,nm.ZIndex=14,true,true,false,3; nm.OutlineColor=Color3.new()
    local ds=Drawing.new("Text"); ds.Size,ds.Center,ds.Outline,ds.Visible,ds.ZIndex=12,true,true,false,3; ds.OutlineColor=Color3.new(); ds.Color=Color3.fromRGB(200,200,200)
    local hb=Drawing.new("Square"); hb.Filled,hb.Transparency,hb.Color,hb.Visible,hb.ZIndex=true,0.6,Color3.new(),false,3
    local hp=Drawing.new("Square"); hp.Filled,hp.Transparency,hp.Visible,hp.ZIndex=true,1,false,4
    espD[p]={box=box,name=nm,dist=ds,hp=hp,hpBg=hb}
end
local function rmESP(p)
    local d=espD[p]; if not d then return end
    pcall(function() d.box:Remove() end); pcall(function() d.name:Remove() end)
    pcall(function() d.dist:Remove() end); pcall(function() d.hp:Remove() end); pcall(function() d.hpBg:Remove() end)
    espD[p]=nil
end
local function updESP()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then mkESP(p) end end
    for p,d in pairs(espD) do
        local c=p.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
        local h=c and c:FindFirstChildOfClass("Humanoid"); local hd=c and c:FindFirstChild("Head")
        if hrp and h and h.Health>0 and hd then
            local rp,os=Camera:WorldToViewportPoint(hrp.Position)
            local hp2=Camera:WorldToViewportPoint(hd.Position+Vector3.new(0,0.5,0))
            local fp=Camera:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
            if os then
                local H=math.abs(hp2.Y-fp.Y); local W=H*0.6
                local x,y=rp.X-W/2,hp2.Y
                local dist=(Camera.CFrame.Position-hrp.Position).Magnitude
                local col=Color3.fromRGB(255,50,50)
                d.box.Color,d.box.Size,d.box.Position,d.box.Visible=col,Vector2.new(W,H),Vector2.new(x,y),true
                d.name.Text,d.name.Position,d.name.Color,d.name.Visible=p.Name,Vector2.new(rp.X,y-30),col,true
                d.dist.Text,d.dist.Position,d.dist.Visible=string.format("[%d]",math.floor(dist)),Vector2.new(rp.X,y-16),true
                local r=math.clamp(h.Health/h.MaxHealth,0,1); local bx=x-6
                d.hpBg.Size,d.hpBg.Position,d.hpBg.Visible=Vector2.new(3,H),Vector2.new(bx,y),true
                d.hp.Size,d.hp.Position=Vector2.new(3,H*r),Vector2.new(bx,y+H*(1-r))
                d.hp.Color,d.hp.Visible=Color3.fromRGB(255*(1-r),255*r,0),true
            else
                d.box.Visible,d.name.Visible,d.dist.Visible,d.hp.Visible,d.hpBg.Visible=false,false,false,false,false
            end
        else
            d.box.Visible,d.name.Visible,d.dist.Visible,d.hp.Visible,d.hpBg.Visible=false,false,false,false,false
        end
    end
end
local espA, espR
local function toggleESP()
    State.esp=not State.esp
    if State.esp then
        clearESP()
        for _,p in ipairs(Players:GetPlayers()) do mkESP(p) end
        espA=Players.PlayerAdded:Connect(mkESP); espR=Players.PlayerRemoving:Connect(rmESP)
        espC=RS.RenderStepped:Connect(updESP)
    else
        if espA then espA:Disconnect() end; if espR then espR:Disconnect() end
        clearESP()
    end
end

-- ===== AIMBOT =====
local aimConn, fovC = nil, Drawing.new("Circle")
fovC.Thickness,fovC.NumSides,fovC.Filled=1,60,false
fovC.Transparency,fovC.Color,fovC.Visible=0.5,Color3.new(1,1,1),false
local function updFov()
    if State.aimbot and State.showFov then
        fovC.Position,fovC.Radius,fovC.Visible=Camera.ViewportSize/2,State.fov,true
    else fovC.Visible=false end
end
local function hasLOS(part)
    if not State.visCheck then return true end
    local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances={LP.Character}
    local r=workspace:Raycast(Camera.CFrame.Position,part.Position-Camera.CFrame.Position,rp)
    return not r or r.Instance:IsDescendantOf(part.Parent)
end
local function getTgt()
    local best,bd=nil,State.fov
    local c=Camera.ViewportSize/2; local lk=Camera.CFrame.LookVector; local cp=Camera.CFrame.Position
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local h=p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 then
                if p.Team and LP.Team and p.Team==LP.Team then continue end
                local pt=p.Character:FindFirstChild(State.part) or p.Character:FindFirstChild("HumanoidRootPart")
                if pt then
                    if lk:Dot((pt.Position-cp).Unit)<=0 then continue end
                    local pos,os=Camera:WorldToViewportPoint(pt.Position)
                    if not os then continue end
                    local sd=(Vector2.new(pos.X,pos.Y)-c).Magnitude
                    if sd>State.fov then continue end
                    if not hasLOS(pt) then continue end
                    if sd<bd then best,bd=pt,sd end
                end
            end
        end
    end
    return best
end
local function updAim()
    updFov()
    if not State.aimbot then return end
    local t=getTgt()
    if t then Camera.CFrame=CFrame.new(Camera.CFrame.Position,t.Position) end
end
local function toggleAim()
    State.aimbot=not State.aimbot
    if State.aimbot then
        if aimConn then aimConn:Disconnect() end
        aimConn=RS.RenderStepped:Connect(updAim)
    else
        if aimConn then aimConn:Disconnect() aimConn=nil end
        fovC.Visible=false
    end
    if floatBtn and floatBtn.Parent then
        floatBtn.Text="AIM: "..(State.aimbot and "ON" or "OFF")
        floatBtn.BackgroundColor3=State.aimbot and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,50,50)
    end
    if aimToggle then pcall(function() aimToggle:Set(State.aimbot) end) end
end

-- ===== FLOAT BUTTON =====
local floatGui, dragging, dragStart, startPos
local function mkFloat()
    if floatGui then floatGui:Destroy() end
    local sg=Instance.new("ScreenGui"); sg.Name,sg.ResetOnSpawn,sg.IgnoreGuiInset="WezexFloat",false,true; sg.Parent=CoreGui
    floatGui=sg
    local b=Instance.new("TextButton")
    b.Size,b.Position=UDim2.new(0,70,0,30),State.btnPos
    b.BackgroundColor3=State.aimbot and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,50,50)
    b.BackgroundTransparency,b.Text,b.TextColor3,b.TextSize,b.Font=0.15,"AIM: "..(State.aimbot and "ON" or "OFF"),Color3.new(1,1,1),12,Enum.Font.GothamBold
    b.BorderSizePixel,b.Active,b.Parent=0,true,sg
    Instance.new("UICorner").CornerRadius=UDim.new(0,8)
    local st=Instance.new("UIStroke"); st.Color=Color3.new(1,1,1); st.Thickness=1; st.Parent=b
    floatBtn=b
    b.MouseButton1Down:Connect(function() dragging=false; dragStart=UIS:GetMouseLocation(); startPos=b.Position end)
    b.MouseButton1Click:Connect(function() if not dragging then toggleAim() end end)
    UIS.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement and dragStart and startPos then
            local cur=UIS:GetMouseLocation(); local d=cur-dragStart
            if math.abs(d.X)>3 or math.abs(d.Y)>3 then
                dragging=true
                b.Position=UDim2.new(0,startPos.X.Offset+d.X,0,startPos.Y.Offset+d.Y)
                State.btnPos=b.Position
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragStart,startPos=nil,nil
            task.delay(0.1,function() dragging=false end)
        end
    end)
end
local function rmFloat() if floatGui then floatGui:Destroy() floatGui=nil floatBtn=nil end end
local function toggleFloat()
    State.showBtn=not State.showBtn
    if State.showBtn then mkFloat() else rmFloat() end
end

-- ===== HOTKEY =====
UIS.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if State.hotkey and State.hotkey~="None" and i.KeyCode==Enum.KeyCode[State.hotkey] then toggleAim() end
end)

-- ===== HIT MARKER =====
local hmConns={}
local function toggleHM()
    State.hitMarker=not State.hitMarker
    if State.hitMarker then
        for _,c in ipairs(hmConns) do c:Disconnect() end; hmConns={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local h=p.Character:FindFirstChildOfClass("Humanoid")
                if h then
                    p:SetAttribute("WzHP",h.Health)
                    table.insert(hmConns,h.HealthChanged:Connect(function(n)
                        local l=p:GetAttribute("WzHP") or n
                        if n<l then
                            local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local pt=Instance.new("Part"); pt.Size,pt.Transparency,pt.Anchored,pt.CanCollide=Vector3.new(0.5,0.5,0.5),1,true,false
                                pt.CFrame,pt.Parent=hrp.CFrame,workspace
                                local em=Instance.new("ParticleEmitter")
                                em.Texture="rbxassetid://243660364"
                                em.Color=ColorSequence.new(Color3.fromRGB(255,50,50),Color3.fromRGB(255,150,50))
                                em.Size,em.Lifetime,em.Speed=NumberSequence.new(1,0),NumberRange.new(0.3,0.5),NumberRange.new(5,10)
                                em.SpreadAngle,em.Rate,em.Parent=Vector2.new(360,360),80,pt
                                task.delay(0.1,function() em.Enabled=false task.delay(0.6,function() pcall(function() pt:Destroy() end) end) end)
                            end
                        end
                        p:SetAttribute("WzHP",n)
                    end))
                end
            end
        end
    else
        for _,c in ipairs(hmConns) do c:Disconnect() end; hmConns={}
    end
end

-- ===== NOCLIP =====
local ncConn
local function toggleNC()
    State.noclip=not State.noclip
    if State.noclip then
        if ncConn then ncConn:Disconnect() end
        ncConn=RS.Stepped:Connect(function()
            local c=LP.Character
            if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
        end)
    else
        if ncConn then ncConn:Disconnect() ncConn=nil end
        local c=LP.Character
        if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
    end
end

-- ===== INF JUMP =====
local ijConn
local function toggleIJ()
    State.infJump=not State.infJump
    if State.infJump then
        if ijConn then ijConn:Disconnect() end
        ijConn=UIS.JumpRequest:Connect(function()
            local c=LP.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if ijConn then ijConn:Disconnect() ijConn=nil end
    end
end

-- ===== AIR JUMP =====
local ajConn, ajLeft, AJ_MAX = nil, 0, 3
local function toggleAJ()
    State.airJump=not State.airJump
    if State.airJump then
        if ajConn then ajConn:Disconnect() end
        ajLeft=AJ_MAX
        local c=LP.Character
        if c then
            local h=c:FindFirstChildOfClass("Humanoid")
            if h then h.StateChanged:Connect(function(_,n)
                if n==Enum.HumanoidStateType.Landed or n==Enum.HumanoidStateType.Running then ajLeft=AJ_MAX end
            end) end
        end
        ajConn=UIS.JumpRequest:Connect(function()
            local c=LP.Character
            if c then
                local h=c:FindFirstChildOfClass("Humanoid")
                if h and h:GetState()==Enum.HumanoidStateType.Freefall and ajLeft>0 then
                    ajLeft=ajLeft-1
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if ajConn then ajConn:Disconnect() ajConn=nil end
    end
end

-- ===== KEY SYSTEM =====
local function keyWin()
    pcall(function() if CoreGui:FindFirstChild("KeySystem") then CoreGui.KeySystem:Destroy() end end)
    local g=Instance.new("ScreenGui"); g.Name,g.Parent,g.ResetOnSpawn,g.IgnoreGuiInset="KeySystem",CoreGui,false,true
    local p=Instance.new("Frame"); p.Size,p.Position=UDim2.new(0,260,0,150),UDim2.new(0.5,-130,0.5,-75)
    p.BackgroundColor3,p.BackgroundTransparency,p.Parent=Color3.fromRGB(15,12,30),0.15,g
    Instance.new("UICorner").CornerRadius=UDim.new(0,16)
    local t=Instance.new("TextLabel"); t.Size,t.Position,t.BackgroundTransparency=UDim2.new(1,0,0,30),UDim2.new(0,0,0,6),1
    t.Font,t.TextSize,t.TextColor3,t.Text,t.TextXAlignment,t.Parent=Enum.Font.GothamBlack,20,Color3.fromRGB(200,150,255),"Wezex Hub",Enum.TextXAlignment.Center,p
    local inf=Instance.new("TextLabel"); inf.Size,inf.Position,inf.BackgroundTransparency=UDim2.new(1,0,0,18),UDim2.new(0,0,0,42),1
    inf.Font,inf.TextSize,inf.TextColor3,inf.Text,inf.TextXAlignment,inf.Parent=Enum.Font.Gotham,12,Color3.fromRGB(160,160,200),"Введите ключ",Enum.TextXAlignment.Center,p
    local kb=Instance.new("TextBox"); kb.Size,kb.Position=UDim2.new(0.6,0,0,34),UDim2.new(0.2,0,0,66)
    kb.BackgroundColor3,kb.BackgroundTransparency=Color3.fromRGB(30,28,50),0.3
    kb.Font,kb.TextSize,kb.TextColor3,kb.Text,kb.PlaceholderText,kb.PlaceholderColor3=Enum.Font.GothamBold,16,Color3.new(1,1,1),"","Ключ",Color3.fromRGB(120,120,160)
    kb.ClearTextOnFocus,kb.Parent=false,p
    Instance.new("UICorner").CornerRadius=UDim.new(0,10)
    local b=Instance.new("TextButton"); b.Size,b.Position=UDim2.new(0.35,0,0,34),UDim2.new(0.325,0,0,106)
    b.BackgroundColor3,b.BackgroundTransparency=Color3.fromRGB(150,100,255),0.2
    b.Text,b.TextSize,b.TextColor3,b.Font,b.Parent="Войти",16,Color3.new(1,1,1),Enum.Font.GothamBold,p
    Instance.new("UICorner").CornerRadius=UDim.new(0,10)
    local function chk()
        if kb.Text==KEY then g:Destroy() makeUI() else
            kb.Text=""; kb.PlaceholderText="Неверно!"; kb.PlaceholderColor3=Color3.fromRGB(255,80,80)
            task.wait(0.6); kb.PlaceholderText="Ключ"; kb.PlaceholderColor3=Color3.fromRGB(120,120,160)
        end
    end
    b.MouseButton1Click:Connect(chk)
    kb.FocusLost:Connect(function(e) if e then chk() end end)
end

-- ===== MAIN UI =====
function makeUI()
    local W=WindUI:CreateWindow({Title="Wezex Hub v4.6",Folder="WezexHub",Icon="solar:folder-2-bold-duotone",
        OpenButton={Title="Wezex Hub",Color=ColorSequence.new(Color3.fromRGB(255,100,255),Color3.fromRGB(100,200,255)),Draggable=true,Scale=0.5}})

    local CT=W:Tab({Title="Combat",Icon="solar:sword-bold"})
    local CS=CT:Section({Title="⚔️ Aimbot"})
    aimToggle=CS:Toggle({Title="Aimbot",Desc="Моментальная наводка",Value=State.aimbot,
        Callback=function(v) if v~=State.aimbot then toggleAim() end end})
    CS:Slider({Title="FOV",Desc="Радиус круга",Min=50,Max=1500,Value=State.fov,
        Callback=function(v) State.fov=v end})
    CS:Dropdown({Title="Часть тела",Values={"Head","HumanoidRootPart","UpperTorso","Torso"},Value=State.part,
        Callback=function(v) State.part=v end})
    CS:Toggle({Title="Проверка видимости",Value=State.visCheck,
        Callback=function(v) State.visCheck=v end})
    CS:Toggle({Title="Показывать FOV",Value=State.showFov,
        Callback=function(v) State.showFov=v end})
    CS:Dropdown({Title="Горячая клавиша",Values={"None","RightShift","LeftShift","Q","E","F","G","H","Z","X","C","V","B"},
        Value=State.hotkey,Callback=function(v) State.hotkey=v end})
    CS:Toggle({Title="Плавающая кнопка",Desc="Таскай и жми для вкл/выкл",Value=State.showBtn,
        Callback=function(v) if v~=State.showBtn then toggleFloat() end end})

    local MT=W:Tab({Title="Movement",Icon="solar:running-bold"})
    local MS=MT:Section({Title="🏃 Movement"})
    MS:Toggle({Title="Noclip",Value=State.noclip,Callback=function(v) if v~=State.noclip then toggleNC() end end})
    MS:Toggle({Title="Infinity Jump",Value=State.infJump,Callback=function(v) if v~=State.infJump then toggleIJ() end end})
    MS:Toggle({Title="Air Jump",Value=State.airJump,Callback=function(v) if v~=State.airJump then toggleAJ() end end})

    local VT=W:Tab({Title="Visuals",Icon="solar:eye-bold"})
    local VS=VT:Section({Title="👁️ ESP"})
    VS:Toggle({Title="ESP",Desc="Безопасный Drawing",Value=State.esp,
        Callback=function(v) if v~=State.esp then toggleESP() end end})
    local HS=VT:Section({Title="🎯 Hit Marker"})
    HS:Toggle({Title="Hit Marker",Desc="Партиклы при попадании",Value=State.hitMarker,
        Callback=function(v) if v~=State.hitMarker then toggleHM() end end})

    local AT=W:Tab({Title="About",Icon="solar:info-square-bold"})
    AT:Section({Title="Wezex Hub v4.6"}):Button({Title="Destroy",Color=Color3.fromRGB(255,50,50),
        Callback=function() W:Destroy() end})

    if State.esp then toggleESP() end
    if State.aimbot then toggleAim() end
    if State.noclip then toggleNC() end
    if State.infJump then toggleIJ() end
    if State.airJump then toggleAJ() end
    if State.hitMarker then toggleHM() end
    if State.showBtn then mkFloat() end
end

keyWin()
