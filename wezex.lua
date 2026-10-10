-- WEZEX HUB v4.8 (LIFTING SIMULATOR)
-- КЛЮЧ: 38399923
local CG=game:GetService("CoreGui")
local PL=game:GetService("Players")
local LP=PL.LocalPlayer
local CAM=workspace.CurrentCamera
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local LGT=game:GetService("Lighting")
local VIM=game:GetService("VirtualInputManager")

local W=loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ================= СОСТОЯНИЕ =================
local S={
    esp=false,
    fov=250,
    part="Head",
    vis=true
}

-- ================= ESP =================
local E={}
local K={"box","shadow","name","nameBg","dist","hp","hpBg","tracer","c1","c2","c3","c4","c5","c6","c7","c8"}
local eC,eA,eR

local function cE()
    for _,d in pairs(E)do
        for _,k in ipairs(K)do
            if d[k]then pcall(function()d[k]:Remove()end)end
        end
    end
    E={}
    if eC then eC:Disconnect() eC=nil end
    if eA then eA:Disconnect() eA=nil end
    if eR then eR:Disconnect() eR=nil end
end

local function hL(p)
    if not S.vis then return true end
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances={LP.Character}
    local r=workspace:Raycast(CAM.CFrame.Position,p.Position-CAM.CFrame.Position,rp)
    return not r or r.Instance:IsDescendantOf(p.Parent)
end

local function mE(p)
    if p==LP or E[p]then return end
    local bx=Drawing.new("Square") bx.Thickness,bx.Filled,bx.Visible,bx.ZIndex=1.5,false,false,3
    local sh=Drawing.new("Square") sh.Thickness,sh.Filled,sh.Visible,sh.ZIndex,sh.Color,sh.Transparency=3,false,false,2,Color3.new(),0.5
    local nm=Drawing.new("Text") nm.Size,nm.Center,nm.Outline,nm.Visible,nm.ZIndex=15,true,true,false,6 nm.OutlineColor=Color3.new()
    local nb=Drawing.new("Square") nb.Filled,nb.Transparency,nb.Visible,nb.ZIndex,nb.Color=true,0.6,false,5,Color3.new()
    local ds=Drawing.new("Text") ds.Size,ds.Center,ds.Outline,ds.Visible,ds.ZIndex=13,true,true,false,6 ds.OutlineColor,ds.Color=Color3.new(),Color3.fromRGB(220,220,220)
    local hb=Drawing.new("Square") hb.Filled,hb.Transparency,hb.Color,hb.Visible,hb.ZIndex=true,0.8,Color3.new(),false,3
    local hp=Drawing.new("Square") hp.Filled,hp.Transparency,hp.Visible,hp.ZIndex=true,1,false,4
    local tr=Drawing.new("Line") tr.Thickness,tr.Visible,tr.ZIndex,tr.Transparency=1,false,1,0.6
    local cs={}
    for i=1,8 do
        cs[i]=Drawing.new("Line")
        cs[i].Thickness,cs[i].Visible,cs[i].ZIndex=2,false,4
    end
    E[p]={box=bx,shadow=sh,name=nm,nameBg=nb,dist=ds,hp=hp,hpBg=hb,tracer=tr,c1=cs[1],c2=cs[2],c3=cs[3],c4=cs[4],c5=cs[5],c6=cs[6],c7=cs[7],c8=cs[8]}
end

local function rE(p)
    local d=E[p]
    if not d then return end
    for _,k in ipairs(K)do
        if d[k]then pcall(function()d[k]:Remove()end)end
    end
    E[p]=nil
end

local function hA(d)
    for _,k in ipairs(K)do d[k].Visible=false end
end

local function uE()
    for _,p in ipairs(PL:GetPlayers())do
        if p~=LP then mE(p)end
    end
    local vp=CAM.ViewportSize
    for p,d in pairs(E)do
        local c=p.Character
        local hr=c and c:FindFirstChild("HumanoidRootPart")
        local h=c and c:FindFirstChildOfClass("Humanoid")
        local hd=c and c:FindFirstChild("Head")
        if hr and h and h.Health>0 and hd then
            local rp,os=CAM:WorldToViewportPoint(hr.Position)
            local h2=CAM:WorldToViewportPoint(hd.Position+Vector3.new(0,0.5,0))
            local fp=CAM:WorldToViewportPoint(hr.Position-Vector3.new(0,3,0))
            if os then
                local H=math.abs(h2.Y-fp.Y)
                local W2=H*0.55
                local x,y=rp.X-W2/2,h2.Y
                local di=(CAM.CFrame.Position-hr.Position).Magnitude
                local tm=p.Team and LP.Team and p.Team==LP.Team
                local vs=hL(hd)
                local bc
                if tm then bc=Color3.fromRGB(80,255,120)
                elseif vs then bc=Color3.fromRGB(255,70,70)
                else bc=Color3.fromRGB(255,180,60)end
                local tc=bc:Lerp(Color3.new(1,1,1),0.15)
                d.box.Color,d.box.Size,d.box.Position,d.box.Visible=bc,Vector2.new(W2,H),Vector2.new(x,y),true
                d.shadow.Color,d.shadow.Size,d.shadow.Position,d.shadow.Visible=Color3.new(),Vector2.new(W2+2,H+2),Vector2.new(x-1,y-1),true
                local cl=math.min(W2,H)*0.2
                local corners={
                    {x,y,x+cl,y},{x,y,x,y+cl},
                    {x+W2,y,x+W2-cl,y},{x+W2,y,x+W2,y+cl},
                    {x,y+H,x+cl,y+H},{x,y+H-cl,x,y+H},
                    {x+W2,y+H,x+W2-cl,y+H},{x+W2,y+H-cl,x+W2,y+H}
                }
                local ck={"c1","c2","c3","c4","c5","c6","c7","c8"}
                for i,cd in ipairs(corners)do
                    local cc=d[ck[i]]
                    cc.From,cc.To,cc.Color,cc.Visible=Vector2.new(cd[1],cd[2]),Vector2.new(cd[3],cd[4]),tc,true
                end
                d.name.Text,d.name.Position,d.name.Color,d.name.Visible=p.Name,Vector2.new(rp.X,y-26),tc,true
                local nw=#p.Name*7
                d.nameBg.Size,d.nameBg.Position,d.nameBg.Color,d.nameBg.Visible=Vector2.new(nw+8,18),Vector2.new(rp.X-(nw+8)/2,y-34),Color3.fromRGB(15,15,25),true
                d.dist.Text,d.dist.Position,d.dist.Color,d.dist.Visible=string.format("%d studs",math.floor(di)),Vector2.new(rp.X,y+H+6),Color3.fromRGB(220,220,220),true
                local r=math.clamp(h.Health/h.MaxHealth,0,1)
                local bxx=x-8
                d.hpBg.Size,d.hpBg.Position,d.hpBg.Color,d.hpBg.Visible=Vector2.new(4,H),Vector2.new(bxx,y),Color3.fromRGB(20,20,20),true
                d.hp.Size,d.hp.Position,d.hp.Color,d.hp.Visible=Vector2.new(4,H*r),Vector2.new(bxx,y+H*(1-r)),Color3.fromRGB(255*(1-r),255*r,80),true
                d.tracer.From,d.tracer.To,d.tracer.Color,d.tracer.Visible=Vector2.new(vp.X/2,vp.Y),Vector2.new(rp.X,y+H),tc,true
            else hA(d)end
        else hA(d)end
    end
end

local function tE()
    S.esp=not S.esp
    if S.esp then
        cE()
        for _,p in ipairs(PL:GetPlayers())do mE(p)end
        eA=PL.PlayerAdded:Connect(mE)
        eR=PL.PlayerRemoving:Connect(rE)
        eC=RS.RenderStepped:Connect(uE)
    else
        cE()
    end
end

-- ================= FIREFLIES =================
local fA,fP
local function tF(on)
    if on then
        if fA then fA:Destroy()end
        if fP then fP:Destroy()end
        fA=Instance.new("Attachment") fA.Parent=CAM
        fP=Instance.new("ParticleEmitter")
        fP.Texture="rbxassetid://243660364"
        fP.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,240,120)),
            ColorSequenceKeypoint.new(0.5,Color3.fromRGB(180,255,120)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(255,200,80))
        })
        fP.LightEmission,fP.LightInfluence=1,0
        fP.Size=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0),
            NumberSequenceKeypoint.new(0.5,1.4),
            NumberSequenceKeypoint.new(1,0)
        })
        fP.Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(0.3,0),
            NumberSequenceKeypoint.new(0.7,0),
            NumberSequenceKeypoint.new(1,1)
        })
        fP.Lifetime=NumberRange.new(6,10)
        fP.Rate=80
        fP.Speed=NumberRange.new(1,3)
        fP.SpreadAngle=Vector2.new(180,180)
        fP.Acceleration=Vector3.new(0,0.5,0)
        fP.Drag=2
        fP.Rotation=NumberRange.new(0,360)
        fP.RotSpeed=NumberRange.new(-50,50)
        fP.ZOffset=2
        fP.Parent=fA
    else
        if fP then fP:Destroy() fP=nil end
        if fA then fA:Destroy() fA=nil end
    end
end

-- ================= SKYBOX =================
local SK={
    ["Galaxy"]={Bk="rbxassetid://159454299",Dn="rbxassetid://159454296",Ft="rbxassetid://159454293",Lf="rbxassetid://159454293",Rt="rbxassetid://159454293",Up="rbxassetid://159454293"},
    ["Purple Nebula"]={Bk="rbxassetid://8107841671",Dn="rbxassetid://6444884785",Ft="rbxassetid://8107841671",Lf="rbxassetid://8107841671",Rt="rbxassetid://8107841671",Up="rbxassetid://8107849791"},
    ["Aesthetic Mountains"]={Bk="rbxassetid://15470198023",Dn="rbxassetid://15470151245",Ft="rbxassetid://15470200128",Lf="rbxassetid://15470202648",Rt="rbxassetid://15470204862",Up="rbxassetid://15470207755"}
}

local function aS(n)
    local o=LGT:FindFirstChildOfClass("Sky")
    if o then o:Destroy()end
    if n=="Стандарт"then return end
    local d=SK[n]
    if not d then return end
    local s=Instance.new("Sky")
    s.SkyboxBk=d.Bk
    s.SkyboxDn=d.Dn
    s.SkyboxFt=d.Ft
    s.SkyboxLf=d.Lf
    s.SkyboxRt=d.Rt
    s.SkyboxUp=d.Up
    s.SunAngularSize=21
    s.MoonAngularSize=21
    s.StarCount=5000
    s.Parent=LGT
end

-- ================= SHADER (CINEMATIC) =================
local shI={}
local shAnim=nil
local shOrig={}

local function tS(on)
    if on then
        for _,v in ipairs(shI)do v:Destroy()end
        shI={}
        shOrig.Tech=LGT.Technology
        shOrig.Clock=LGT.ClockTime
        shOrig.Bright=LGT.Brightness
        shOrig.Shad=LGT.GlobalShadows
        shOrig.Out=LGT.OutdoorAmbient
        shOrig.EnvD=LGT.EnvironmentDiffuseScale
        shOrig.EnvS=LGT.EnvironmentSpecularScale
        shOrig.Exp=LGT.ExposureCompensation
        pcall(function()LGT.Technology=Enum.Technology.Future end)
        LGT.ClockTime=17.4
        LGT.GeographicLatitude=41.7
        LGT.Brightness=2.4
        LGT.GlobalShadows=true
        LGT.ShadowSoftness=0.15
        LGT.ExposureCompensation=0.1
        LGT.EnvironmentDiffuseScale=1
        LGT.EnvironmentSpecularScale=1
        LGT.OutdoorAmbient=Color3.fromRGB(75,70,85)
        local a=LGT:FindFirstChildOfClass("Atmosphere")or Instance.new("Atmosphere")
        a.Density,a.Offset,a.Color,a.Decay,a.Glare,a.Haze=0.32,0.25,Color3.fromRGB(195,170,155),Color3.fromRGB(105,115,130),0.4,2.1
        a.Parent=LGT
        table.insert(shI,a)
        local b=Instance.new("BloomEffect")
        b.Intensity,b.Size,b.Threshold=0.65,24,0.85
        b.Parent=LGT
        table.insert(shI,b)
        local c=Instance.new("ColorCorrectionEffect")
        c.Brightness,c.Contrast,c.Saturation,c.TintColor=0.03,0.22,0.18,Color3.fromRGB(255,248,242)
        c.Parent=LGT
        table.insert(shI,c)
        local s=Instance.new("SunRaysEffect")
        s.Intensity,s.Spread=0.25,0.8
        s.Parent=LGT
        table.insert(shI,s)
        local d=Instance.new("DepthOfFieldEffect")
        d.FarIntensity,d.FocusDistance,d.InFocusRadius,d.NearIntensity=0.35,20,25,0.15
        d.Parent=LGT
        table.insert(shI,d)
        local t=0
        if shAnim then shAnim:Disconnect()end
        shAnim=RS.RenderStepped:Connect(function(dt)
            t=t+dt*0.5
            if s and s.Parent then s.Intensity=0.22+math.sin(t)*0.05 end
            if b and b.Parent then b.Intensity=0.6+math.cos(t*0.8)*0.06 end
        end)
    else
        for _,v in ipairs(shI)do v:Destroy()end
        shI={}
        if shAnim then shAnim:Disconnect() shAnim=nil end
        if shOrig.Tech then pcall(function()LGT.Technology=shOrig.Tech end)end
        LGT.ClockTime=shOrig.Clock or 14
        LGT.Brightness=shOrig.Bright or 2
        LGT.GlobalShadows=shOrig.Shad~=false
        LGT.OutdoorAmbient=shOrig.Out or Color3.fromRGB(128,128,128)
        LGT.EnvironmentDiffuseScale=shOrig.EnvD or 1
        LGT.EnvironmentSpecularScale=shOrig.EnvS or 1
        LGT.ExposureCompensation=shOrig.Exp or 0
    end
end

-- ================= CLEAR =================
local function cV()
    tF(false)
    tS(false)
    local s=LGT:FindFirstChildOfClass("Sky")
    if s then s:Destroy()end
end

-- ================= ПРОКАЧКА (UTILS) =================
local PK={}
PK.speedEnabled=false
PK.speedValue=16
PK.jumpEnabled=false
PK.jumpValue=50
PK.fullbright=false
PK.gravityEnabled=false
PK.gravityValue=196.2

local function applySpeed()
    local c=LP.Character
    if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=PK.speedEnabled and PK.speedValue or 16 end
end

local function applyJump()
    local c=LP.Character
    if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then
        h.UseJumpPower=true
        h.JumpPower=PK.jumpEnabled and PK.jumpValue or 50
    end
end

local function applyGravity()
    workspace.Gravity=PK.gravityEnabled and PK.gravityValue or 196.2
end

local function applyFullbright()
    if PK.fullbright then
        LGT.Ambient=Color3.fromRGB(255,255,255)
        LGT.OutdoorAmbient=Color3.fromRGB(255,255,255)
        LGT.Brightness=3
        LGT.ClockTime=12
        LGT.FogEnd=1e9
    else
        LGT.Ambient=Color3.fromRGB(70,70,70)
        LGT.OutdoorAmbient=Color3.fromRGB(128,128,128)
        LGT.Brightness=2
        LGT.FogEnd=100000
    end
end

local charConn
local function bindChar()
    if charConn then charConn:Disconnect()end
    applySpeed()
    applyJump()
    charConn=LP.CharacterAdded:Connect(function()
        task.wait(1)
        applySpeed()
        applyJump()
    end)
end

-- ================= АВТОКЛИКЕР (LIFTING SIMULATOR) =================
local AC={
    enabled=false,
    interval=0.05,
    thread=nil
}

local function doClick()
    local pos=UIS:GetMouseLocation()
    pcall(function()
        VIM:SendMouseButtonEvent(pos.X,pos.Y,0,true,game,1)
    end)
    pcall(function()
        VIM:SendMouseButtonEvent(pos.X,pos.Y,0,false,game,1)
    end)
end

local function clickerLoop()
    while AC.enabled do
        doClick()
        task.wait(AC.interval)
    end
end

local function startAC()
    if AC.enabled then return end
    AC.enabled=true
    AC.thread=task.spawn(clickerLoop)
end

local function stopAC()
    AC.enabled=false
    if AC.thread then
        pcall(function() task.cancel(AC.thread) end)
        AC.thread=nil
    end
end

-- ================= АНИМАЦИИ / ЭМОЦИИ =================
local ANIM={loaded=false}
local EMO={loaded=false}

local function loadAnimation()
    if ANIM.loaded then return end
    ANIM.loaded=true
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BeemTZy/Motiona/refs/heads/main/source.lua"))()
    end)
end

local function loadEmoji()
    if EMO.loaded then return end
    EMO.loaded=true
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
    end)
end

-- ================= UI =================
function bU()
    local Wn=W:CreateWindow({
        Title="Wezex Hub v4.8",
        Folder="WezexHub",
        Icon="solar:folder-2-bold-duotone",
        OpenButton={
            Title="Wezex Hub",
            Color=ColorSequence.new(Color3.fromRGB(255,100,255),Color3.fromRGB(100,200,255)),
            Draggable=true,
            Scale=0.5
        }
    })

    -- ===== VISUALS =====
    local vt=Wn:Tab({Title="Visuals",Icon="solar:eye-bold"})
    local es=vt:Section({Title="👁 ESP"})
    es:Toggle({Title="ESP",Value=false,Callback=function(v)
        if v~=S.esp then tE()end
    end})
    es:Toggle({Title="Wall Check",Value=true,Callback=function(v)S.vis=v end})
    es:Slider({Title="FOV (для ESP масштаб)",Value={Min=50,Max=1000,Default=250},Callback=function(v)S.fov=v end})

    local ss=vt:Section({Title="🌌 Skybox"})
    ss:Dropdown({
        Title="Skybox",
        Values={"Стандарт","Galaxy","Purple Nebula","Aesthetic Mountains"},
        Value="Стандарт",
        Callback=function(v)aS(v)end
    })

    local fs=vt:Section({Title="✨ Эффекты"})
    fs:Toggle({Title="Fireflies (Светлячки)",Value=false,Callback=function(v)tF(v)end})
    fs:Toggle({Title="Cinematic Shader",Value=false,Callback=function(v)tS(v)end})

    local xs=vt:Section({Title="🎭 Анимации и Эмоции"})
    xs:Toggle({
        Title="Animation",
        Desc="Запускает Motiona скрипт",
        Value=false,
        Callback=function(v)
            if v then loadAnimation() end
        end
    })
    xs:Toggle({
        Title="Emoji",
        Desc="Запускает Emotes скрипт",
        Value=false,
        Callback=function(v)
            if v then loadEmoji() end
        end
    })

    -- ===== ПРОКАЧКА =====
    local pt=Wn:Tab({Title="Прокачка",Icon="solar:rocket-bold"})
    local ps=pt:Section({Title="🏃 Движение"})
    ps:Toggle({Title="Speed Hack",Value=false,Callback=function(v)
        PK.speedEnabled=v
        applySpeed()
    end})
    ps:Slider({Title="Speed",Value={Min=16,Max=300,Default=16},Callback=function(v)
        PK.speedValue=v
        applySpeed()
    end})
    ps:Toggle({Title="Jump Power",Value=false,Callback=function(v)
        PK.jumpEnabled=v
        applyJump()
    end})
    ps:Slider({Title="Jump",Value={Min=50,Max=500,Default=50},Callback=function(v)
        PK.jumpValue=v
        applyJump()
    end})
    ps:Toggle({Title="Low Gravity",Value=false,Callback=function(v)
        PK.gravityEnabled=v
        applyGravity()
    end})
    ps:Slider({Title="Gravity",Value={Min=10,Max=196,Default=196},Callback=function(v)
        PK.gravityValue=v
        applyGravity()
    end})

    local vs=pt:Section({Title="🌍 Мир"})
    vs:Toggle({Title="Fullbright",Value=false,Callback=function(v)
        PK.fullbright=v
        applyFullbright()
    end})

    -- ===== АВТОКЛИКЕР =====
    local acs=pt:Section({Title="🖱 АВТОКЛИКЕР"})
    acs:Toggle({Title="Включить автокликер",Value=false,Callback=function(v)
        if v then startAC() else stopAC() end
    end})
    acs:Slider({Title="Интервал клика (сек)",Value={Min=0.01,Max=2,Default=0.05},Callback=function(v)
        AC.interval=v
    end})

    local cl=pt:Section({Title="🧹 Очистка"})
    cl:Button({Title="Сбросить всё",Callback=function()
        tE(); tF(false); tS(false); aS("Стандарт")
        stopAC()
        PK.speedEnabled=false; PK.jumpEnabled=false; PK.gravityEnabled=false; PK.fullbright=false
        applySpeed(); applyJump(); applyGravity(); applyFullbright()
    end})

    bindChar()
end

bU()
