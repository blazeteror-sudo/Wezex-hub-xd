-- WEZEX HUB v5.2 (LIFTING SIMULATOR)
-- КЛЮЧ: 38399923
local CG=game:GetService("CoreGui")
local PL=game:GetService("Players")
local LP=PL.LocalPlayer
local CAM=workspace.CurrentCamera
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local LGT=game:GetService("Lighting")
local VU=game:GetService("VirtualUser")

local W=loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ================= СОСТОЯНИЕ =================
local S={
    esp=false,
    fov=250,
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

-- ================= АВТОКЛИКЕР =================
local AC={
    enabled=false,
    interval=0.05
}

task.spawn(function()
    while task.wait(AC.interval) do
        if AC.enabled then
            pcall(function()
                VU:CaptureController()
                VU:ClickButton1(Vector2.new(0,0))
            end)
        end
    end
end)

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
        Title="Wezex Hub v5.2",
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
    es:Slider({Title="FOV",Value={Min=50,Max=1000,Default=250},Callback=function(v)S.fov=v end})

    local xs=vt:Section({Title="🎭 Анимации и Эмоции"})
    xs:Toggle({Title="Animation",Value=false,Callback=function(v)
        if v then loadAnimation() end
    end})
    xs:Toggle({Title="Emoji",Value=false,Callback=function(v)
        if v then loadEmoji() end
    end})

    -- ===== ПРОКАЧКА =====
    local pt=Wn:Tab({Title="Прокачка",Icon="solar:rocket-bold"})
    local acs=pt:Section({Title="🖱 АВТОКЛИКЕР"})
    acs:Toggle({Title="Включить автокликер",Value=false,Callback=function(v)
        AC.enabled=v
    end})
    acs:Slider({Title="Интервал клика (сек)",Value={Min=0.01,Max=2,Default=0.05},Callback=function(v)
        AC.interval=v
    end})
end

bU()
