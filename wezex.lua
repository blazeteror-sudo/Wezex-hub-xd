local L=loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local PL=game:GetService("Players")local LP=PL.LocalPlayer local CAM=workspace.CurrentCamera local UIS=game:GetService("UserInputService")local RS=game:GetService("RunService")local LGT=game:GetService("Lighting")
local S={esp=false,aim=false,noclip=false,infjump=false,fov=250,part="Head",vis=true}
local W=L:CreateWindow({Title="Wezex Hub v4.7",Folder="WezexHub",Icon="solar:folder-2-bold-duotone",OpenButton={Title="Wezex Hub",Color=ColorSequence.new(Color3.fromRGB(255,100,255),Color3.fromRGB(100,200,255)),Draggable=true,Scale=0.5}})
local aC,fC=nil,Drawing.new("Circle")fC.Thickness,fC.NumSides,fC.Filled=1,60,false fC.Transparency,fC.Color,fC.Visible=0.5,Color3.new(1,1,1),false
local function uF()fC.Visible=S.aim if S.aim then fC.Position=CAM.ViewportSize/2 fC.Radius=S.fov end end
local function hL(p)if not S.vis then return true end local rp=RaycastParams.new()rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={LP.Character}local r=workspace:Raycast(CAM.CFrame.Position,p.Position-CAM.CFrame.Position,rp)return not r or r.Instance:IsDescendantOf(p.Parent)end
local function gT()local b,bd=nil,S.fov local c,lk,cp=CAM.ViewportSize/2,CAM.CFrame.LookVector,CAM.CFrame.Position for _,p in ipairs(PL:GetPlayers())do if p~=LP and p.Character then local h=p.Character:FindFirstChildOfClass("Humanoid")if h and h.Health>0 then if p.Team and LP.Team and p.Team==LP.Team then continue end local pt=p.Character:FindFirstChild(S.part)or p.Character:FindFirstChild("HumanoidRootPart")if pt and lk:Dot((pt.Position-cp).Unit)>0 then local po,os=CAM:WorldToViewportPoint(pt.Position)if os then local d=(Vector2.new(po.X,po.Y)-c).Magnitude if d<=S.fov and d<bd and hL(pt)then b,bd=pt,d end end end end end end return b end
local function uA()uF()if S.aim then local t=gT()if t then CAM.CFrame=CFrame.new(CAM.CFrame.Position,t.Position)end end end
local function tA()S.aim=not S.aim if S.aim then if aC then aC:Disconnect()end aC=RS.RenderStepped:Connect(uA)else if aC then aC:Disconnect()aC=nil end fC.Visible=false end end
local E,eC,eA,eR={},nil,nil,nil
local K={"box","shadow","name","nameBg","dist","hp","hpBg","tracer","c1","c2","c3","c4","c5","c6","c7","c8"}
local function cE()for _,d in pairs(E)do for _,k in ipairs(K)do if d[k]then pcall(function()d[k]:Remove()end)end end end E={}if eC then eC:Disconnect()eC=nil end if eA then eA:Disconnect()eA=nil end if eR then eR:Disconnect()eR=nil end end
local function mE(p)if p==LP or E[p]then return end
local bx=Drawing.new("Square")bx.Thickness,bx.Filled,bx.Visible,bx.ZIndex=1.6,false,false,3
local sh=Drawing.new("Square")sh.Thickness,sh.Filled,sh.Visible,sh.ZIndex,sh.Color,sh.Transparency=6,false,false,2,Color3.new(),0.55
local nm=Drawing.new("Text")nm.Size,nm.Center,nm.Outline,nm.Visible,nm.ZIndex=15,true,true,false,6 nm.OutlineColor=Color3.new()
local nb=Drawing.new("Square")nb.Filled,nb.Transparency,nb.Visible,nb.ZIndex,nb.Color=true,0.35,false,5,Color3.fromRGB(10,10,18)
local ds=Drawing.new("Text")ds.Size,ds.Center,ds.Outline,ds.Visible,ds.ZIndex=13,true,true,false,6 ds.OutlineColor,ds.Color=Color3.new(),Color3.fromRGB(230,230,240)
local hb=Drawing.new("Square")hb.Filled,hb.Transparency,hb.Color,hb.Visible,hb.ZIndex=true,0.35,Color3.fromRGB(15,15,20),false,3
local hp=Drawing.new("Square")hp.Filled,hp.Transparency,hp.Visible,hp.ZIndex=true,0,false,4
local tr=Drawing.new("Line")tr.Thickness,tr.Visible,tr.ZIndex,tr.Transparency=1.4,false,1,0.25
local cs={}for i=1,8 do cs[i]=Drawing.new("Line")cs[i].Thickness,cs[i].Visible,cs[i].ZIndex=2.4,false,4 end
E[p]={box=bx,shadow=sh,name=nm,nameBg=nb,dist=ds,hp=hp,hpBg=hb,tracer=tr,c1=cs[1],c2=cs[2],c3=cs[3],c4=cs[4],c5=cs[5],c6=cs[6],c7=cs[7],c8=cs[8]}end
local function rE(p)local d=E[p]if not d then return end for _,k in ipairs(K)do if d[k]then pcall(function()d[k]:Remove()end)end end E[p]=nil end
local function hA(d)for _,k in ipairs(K)do d[k].Visible=false end end
local function uE()
for _,p in ipairs(PL:GetPlayers())do if p~=LP then mE(p)end end
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
local H=math.abs(h2.Y-fp.Y)local W2=H*0.55 local x,y=rp.X-W2/2,h2.Y
local di=(CAM.CFrame.Position-hr.Position).Magnitude
local tm=p.Team and LP.Team and p.Team==LP.Team
local vs=hL(hd)
local c1,c2
if tm then c1=Color3.fromRGB(60,255,140)c2=Color3.fromRGB(120,255,200)
elseif vs then c1=Color3.fromRGB(255,60,90)c2=Color3.fromRGB(255,140,60)
else c1=Color3.fromRGB(255,180,60)c2=Color3.fromRGB(255,120,200)end
local pulse=0.85+math.sin(os.clock()*3)*0.15
local tc=c1:Lerp(c2,pulse)
d.shadow.Color=Color3.new()d.shadow.Size=Vector2.new(W2+6,H+6)d.shadow.Position=Vector2.new(x-3,y-3)d.shadow.Visible=true
d.box.Color=tc d.box.Size=Vector2.new(W2,H)d.box.Position=Vector2.new(x,y)d.box.Visible=true
local cl=math.min(W2,H)*0.28
local corners={{x,y,x+cl,y},{x,y,x,y+cl},{x+W2,y,x+W2-cl,y},{x+W2,y,x+W2,y+cl},{x,y+H,x+cl,y+H},{x,y+H-cl,x,y+H},{x+W2,y+H,x+W2-cl,y+H},{x+W2,y+H-cl,x+W2,y+H}}
local ck={"c1","c2","c3","c4","c5","c6","c7","c8"}
for i,cd in ipairs(corners)do local cc=d[ck[i]]cc.From=Vector2.new(cd[1],cd[2])cc.To=Vector2.new(cd[3],cd[4])cc.Color=tc cc.Visible=true end
d.name.Text=p.Name d.name.Position=Vector2.new(rp.X,y-28)d.name.Color=tc d.name.Size=15 d.name.Visible=true
local nw=#p.Name*7.5 d.nameBg.Size=Vector2.new(nw+12,20)d.nameBg.Position=Vector2.new(rp.X-(nw+12)/2,y-38)d.nameBg.Visible=true
d.dist.Text=string.format("%d studs",math.floor(di))d.dist.Position=Vector2.new(rp.X,y+H+8)d.dist.Visible=true
local r=math.clamp(h.Health/h.MaxHealth,0,1)local bxx=x-10
d.hpBg.Size=Vector2.new(5,H)d.hpBg.Position=Vector2.new(bxx,y)d.hpBg.Visible=true
local hpCol=Color3.fromRGB(255*(1-r),255*r,90):Lerp(Color3.fromRGB(120,255,160),r*0.5)
d.hp.Size=Vector2.new(5,H*r)d.hp.Position=Vector2.new(bxx,y+H*(1-r))d.hp.Color=hpCol d.hp.Visible=true
d.tracer.From=Vector2.new(vp.X/2,vp.Y)d.tracer.To=Vector2.new(rp.X,y+H)d.tracer.Color=tc d.tracer.Visible=true
else hA(d)end else hA(d)end end end
local function tE()S.esp=not S.esp if S.esp then cE()for _,p in ipairs(PL:GetPlayers())do mE(p)end eA=PL.PlayerAdded:Connect(mE)eR=PL.PlayerRemoving:Connect(rE)eC=RS.RenderStepped:Connect(uE)else cE()end end
local nC,oC=nil,{}
local function tN()S.noclip=not S.noclip if S.noclip then if nC then nC:Disconnect()end nC=RS.Stepped:Connect(function()local c=LP.Character if c then for _,p in ipairs(c:GetDescendants())do if p:IsA("BasePart")then if oC[p]==nil then oC[p]=p.CanCollide end p.CanCollide=false end end end end)else if nC then nC:Disconnect()nC=nil end local c=LP.Character if c then for _,p in ipairs(c:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=oC[p]~=nil and oC[p]or false end end end oC={}end end
local iC
local function tJ()S.infJump=not S.infJump if S.infJump then if iC then iC:Disconnect()end iC=UIS.JumpRequest:Connect(function()local c=LP.Character if c and c:FindFirstChildOfClass("Humanoid")then c:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)end end)else if iC then iC:Disconnect()iC=nil end end end
local fFlies={}
local fConn=nil
local FLY_COUNT=80
local WORLD_RADIUS=350
local function tF(on)
if not on then
if fConn then fConn:Disconnect()fConn=nil end
for _,f in ipairs(fFlies)do if f.part then f.part:Destroy()end if f.light then f.light:Destroy()end if f.glow then f.glow:Destroy()end if f.trail then f.trail:Destroy()end end
fFlies={}return
end
if fConn then return end
local rng=Random.new()
local basePos=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")and LP.Character.HumanoidRootPart.Position or Vector3.new(0,50,0)
local function randPos()
local a=rng:NextNumber(0,math.pi*2)
local r=rng:NextNumber(30,WORLD_RADIUS)
local x=basePos.X+math.cos(a)*r
local z=basePos.Z+math.sin(a)*r
local y=basePos.Y+rng:NextNumber(-15,45)
return Vector3.new(x,y,z)
end
local function makeFly()
local part=Instance.new("Part")
part.Size=Vector3.new(0.22,0.22,1.6)
part.Material=Enum.Material.Neon
part.Color=Color3.fromRGB(255,240,140)
part.Anchored=true
part.CanCollide=false
part.CanQuery=false
part.CastShadow=false
part.Shape=Enum.PartType.Cylinder
part.CFrame=CFrame.new(randPos())
part.Parent=workspace
local light=Instance.new("PointLight")
light.Color=Color3.fromRGB(255,235,130)
light.Range=14
light.Brightness=3.5
light.Shadows=false
light.Parent=part
local glow=Instance.new("BillboardGui")
glow.Size=UDim2.new(0,70,0,70)
glow.AlwaysOnTop=false
glow.LightInfluence=0
glow.Parent=part
local img=Instance.new("ImageLabel")
img.BackgroundTransparency=1
img.Image="rbxassetid://243660364"
img.ImageColor3=Color3.fromRGB(255,240,150)
img.ImageTransparency=0.15
img.Size=UDim2.new(1,0,1,0)
img.Parent=glow
local a0=Instance.new("Attachment",part)a0.Position=Vector3.new(0,0,0.6)
local a1=Instance.new("Attachment",part)a1.Position=Vector3.new(0,0,-0.6)
local trail=Instance.new("Trail")
trail.Attachment0=a0
trail.Attachment1=a1
trail.Lifetime=0.6
trail.MinLength=0.05
trail.Texture="rbxassetid://243660364"
trail.TextureMode=Enum.TextureMode.Stretch
trail.LightEmission=1
trail.LightInfluence=0
trail.Color=ColorSequence.new(Color3.fromRGB(255,240,140))
trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,1)})
trail.Parent=part
return{
part=part,light=light,glow=glow,trail=trail,
pos=part.Position,
target=randPos(),
speed=rng:NextNumber(8,22),
turnSpeed=rng:NextNumber(0.4,1.4),
phase=rng:NextNumber(0,10),
}
end
for i=1,FLY_COUNT do table.insert(fFlies,makeFly())end
fConn=RS.Heartbeat:Connect(function(dt)
for _,f in ipairs(fFlies)do
if f.part and f.part.Parent then
local cur=f.part.Position
local dir=f.target-cur
local dist=dir.Magnitude
if dist<3 then f.target=randPos() end
local moveDir=dist>0.001 and dir.Unit or Vector3.new(0,1,0)
local newPos=cur+moveDir*f.speed*dt
local lookAt=newPos+moveDir
f.part.CFrame=CFrame.lookAt(newPos,lookAt)*CFrame.Angles(0,math.pi/2,0)
local wiggle=math.sin(f.phase+os.clock()*3)*0.35
f.part.CFrame=f.part.CFrame*CFrame.new(0,wiggle,0)
f.phase=f.phase+dt*f.turnSpeed
f.light.Brightness=3+math.sin(f.phase*2)*1.2
end
end
end)
end
local SK={["Galaxy"]={Bk="rbxassetid://159454299",Dn="rbxassetid://159454296",Ft="rbxassetid://159454293",Lf="rbxassetid://159454293",Rt="rbxassetid://159454293",Up="rbxassetid://159454293"},["Purple Nebula"]={Bk="rbxassetid://8107841671",Dn="rbxassetid://6444884785",Ft="rbxassetid://8107841671",Lf="rbxassetid://8107841671",Rt="rbxassetid://8107841671",Up="rbxassetid://8107849791"},["Aesthetic Mountains"]={Bk="rbxassetid://15470198023",Dn="rbxassetid://15470151245",Ft="rbxassetid://15470200128",Lf="rbxassetid://15470202648",Rt="rbxassetid://15470204862",Up="rbxassetid://15470207755"}}
local function aS(n)local o=LGT:FindFirstChildOfClass("Sky")if o then o:Destroy()end if n=="Стандарт"then return end local d=SK[n]if not d then return end local s=Instance.new("Sky")s.SkyboxBk=d.Bk s.SkyboxDn=d.Dn s.SkyboxFt=d.Ft s.SkyboxLf=d.Lf s.SkyboxRt=d.Rt s.SkyboxUp=d.Up s.SunAngularSize=21 s.MoonAngularSize=21 s.StarCount=5000 s.Parent=LGT end
local shI={}local shAnim=nil local shOrig={}
local function tS(on)if on then for _,v in ipairs(shI)do v:Destroy()end shI={}
shOrig.Tech=LGT.Technology shOrig.Clock=LGT.ClockTime shOrig.Bright=LGT.Brightness shOrig.Shad=LGT.GlobalShadows shOrig.Out=LGT.OutdoorAmbient shOrig.EnvD=LGT.EnvironmentDiffuseScale shOrig.EnvS=LGT.EnvironmentSpecularScale shOrig.Exp=LGT.ExposureCompensation
pcall(function()LGT.Technology=Enum.Technology.Future end)
LGT.ClockTime=17.4 LGT.GeographicLatitude=41.7 LGT.Brightness=2.4 LGT.GlobalShadows=true LGT.ShadowSoftness=0.15 LGT.ExposureCompensation=0.1 LGT.EnvironmentDiffuseScale=1 LGT.EnvironmentSpecularScale=1 LGT.OutdoorAmbient=Color3.fromRGB(75,70,85)
local a=LGT:FindFirstChildOfClass("Atmosphere")or Instance.new("Atmosphere")a.Density,a.Offset,a.Color,a.Decay,a.Glare,a.Haze=0.32,0.25,Color3.fromRGB(195,170,155),Color3.fromRGB(105,115,130),0.4,2.1 a.Parent=LGT table.insert(shI,a)
local b=Instance.new("BloomEffect")b.Intensity,b.Size,b.Threshold=0.65,24,0.85 b.Parent=LGT table.insert(shI,b)
local c=Instance.new("ColorCorrectionEffect")c.Brightness,c.Contrast,c.Saturation,c.TintColor=0.03,0.22,0.18,Color3.fromRGB(255,248,242)c.Parent=LGT table.insert(shI,c)
local s=Instance.new("SunRaysEffect")s.Intensity,s.Spread=0.25,0.8 s.Parent=LGT table.insert(shI,s)
local d=Instance.new("DepthOfFieldEffect")d.FarIntensity,d.FocusDistance,d.InFocusRadius,d.NearIntensity=0.35,20,25,0.15 d.Parent=LGT table.insert(shI,d)
local t=0 if shAnim then shAnim:Disconnect()end
shAnim=RS.RenderStepped:Connect(function(dt)t=t+dt*0.5 if s and s.Parent then s.Intensity=0.22+math.sin(t)*0.05 end if b and b.Parent then b.Intensity=0.6+math.cos(t*0.8)*0.06 end end)
else for _,v in ipairs(shI)do v:Destroy()end shI={}
if shAnim then shAnim:Disconnect()shAnim=nil end
if shOrig.Tech then pcall(function()LGT.Technology=shOrig.Tech end)end
LGT.ClockTime=shOrig.Clock or 14 LGT.Brightness=shOrig.Bright or 2 LGT.GlobalShadows=shOrig.Shad~=false LGT.OutdoorAmbient=shOrig.Out or Color3.fromRGB(128,128,128)LGT.EnvironmentDiffuseScale=shOrig.EnvD or 1 LGT.EnvironmentSpecularScale=shOrig.EnvS or 1 LGT.ExposureCompensation=shOrig.Exp or 0 end end
local TR={}
local function mT(c)if not c then return end local hr=c:FindFirstChild("HumanoidRootPart")or c:FindFirstChild("UpperTorso")or c:FindFirstChild("Torso")if not hr or TR[c]then return end
local atts={}local coils=3
for i=0,coils do local a=Instance.new("Attachment",hr)local ang=(i/coils)*math.pi*2 a.Position=Vector3.new(math.cos(ang)*0.9,0,math.sin(ang)*0.9)table.insert(atts,a)end
local trails={}
for i=1,#atts do local a0=atts[i]local a1=atts[(i%#atts)+1]
local t=Instance.new("Trail")t.Attachment0=a0 t.Attachment1=a1 t.Lifetime=1.1 t.MinLength=0.15 t.Texture="rbxassetid://18421838422"t.TextureMode=Enum.TextureMode.Stretch t.TextureLength=3.5 t.LightEmission=1 t.LightInfluence=0 t.FaceCamera=true
t.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(120,200,255)),ColorSequenceKeypoint.new(0.35,Color3.fromRGB(200,120,255)),ColorSequenceKeypoint.new(0.7,Color3.fromRGB(255,120,200)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,220,120))})
t.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(0.6,0.5),NumberSequenceKeypoint.new(1,1)})
t.Parent=c table.insert(trails,t)end
TR[c]={trails=trails,atts=atts}end
local function rT(c)local t=TR[c]if not t then return end for _,tr in ipairs(t.trails)do tr:Destroy()end for _,a in ipairs(t.atts)do a:Destroy()end TR[c]=nil end
local tC,tM={},nil
local function tT(on)if on then if tM then tM:Disconnect()end for _,p in ipairs(PL:GetPlayers())do if p.Character then mT(p.Character)end tC[p]={c=p.CharacterAdded:Connect(mT),r=p.CharacterRemoving:Connect(rT)}end tM=PL.PlayerAdded:Connect(function(p)tC[p]={c=p.CharacterAdded:Connect(mT),r=p.CharacterRemoving:Connect(rT)}end)
else if tM then tM:Disconnect()tM=nil end for _,c in pairs(tC)do if c.c then c.c:Disconnect()end if c.r then c.r:Disconnect()end end tC={}for ch,_ in pairs(TR)do rT(ch)end end end
local rA,rP,rC=nil,nil,nil
local function tR(on)if on then if rA then rA:Destroy()end if rP then rP:Destroy()end if rC then rC:Disconnect()rC=nil end
rA=Instance.new("Attachment")rA.Parent=CAM
rP=Instance.new("ParticleEmitter")rP.Texture="rbxassetid://106880360"rP.Color=ColorSequence.new(Color3.fromRGB(100,150,255))rP.LightEmission=0.2 rP.LightInfluence=0.5
rP.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.2,0.4),NumberSequenceKeypoint.new(0.8,0.8),NumberSequenceKeypoint.new(1,0)})
rP.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.8),NumberSequenceKeypoint.new(0.5,0.2),NumberSequenceKeypoint.new(1,0.8)})
rP.Lifetime=NumberRange.new(2,3)rP.Rate=150 rP.Speed=NumberRange.new(30,50)rP.SpreadAngle=Vector2.new(10,10)rP.Acceleration=Vector3.new(0,-40,0)rP.Drag=2 rP.EmissionDirection=Enum.NormalId.Back rP.RotSpeed=NumberRange.new(-20,20)rP.Rotation=NumberRange.new(0,360)rP.ZOffset=-5 rP.Parent=rA
rC=CAM:GetPropertyChangedSignal("CFrame"):Connect(function()if rA and rA.Parent~=CAM then tR(false)end end)
else if rC then rC:Disconnect()rC=nil end if rP then rP:Destroy()rP=nil end if rA then rA:Destroy()rA=nil end end end
local function cV()tF(false)tS(false)tT(false)tR(false)local s=LGT:FindFirstChildOfClass("Sky")if s then s:Destroy()end end
local ct=W:Tab({Title="Combat",Icon="solar:sword-bold"})local cs=ct:Section({Title="Aimbot"})
cs:Toggle({Title="Aimbot",Value=false,Callback=function(v)if v~=S.aim then tA()end end})
cs:Slider({Title="FOV",Value={Min=50,Max=1000,Default=250},Callback=function(v)S.fov=v uF()end})
cs:Dropdown({Title="Hit Part",Values={"Head","HumanoidRootPart","UpperTorso"},Value="Head",Callback=function(v)S.part=v end})
cs:Toggle({Title="Wall Check",Value=true,Callback=function(v)S.vis=v end})
local mt=W:Tab({Title="Movement",Icon="solar:running-bold"})local ms=mt:Section({Title="Movement"})
ms:Toggle({Title="Noclip",Value=false,Callback=function(v)if v~=S.noclip then tN()end end})
ms:Toggle({Title="Infinity Jump",Value=false,Callback=function(v)if v~=S.infJump then tJ()end end})
local vt=W:Tab({Title="Visuals",Icon="solar:eye-bold"})
local vs=vt:Section({Title="ESP"})
vs:Toggle({Title="ESP (Stylish)",Value=false,Callback=function(v)if v~=S.esp then tE()end end})
local fx=vt:Section({Title="Effects"})
fx:Toggle({Title="Fireflies 3D",Value=false,Callback=function(v)tF(v)end})
fx:Dropdown({Title="Skybox",Values={"Стандарт","Galaxy","Purple Nebula","Aesthetic Mountains"},Value="Стандарт",Callback=function(v)aS(v)end})
fx:Toggle({Title="Cinematic Shader",Value=false,Callback=function(v)tS(v)end})
fx:Toggle({Title="Spiral Trails",Value=false,Callback=function(v)tT(v)end})
fx:Toggle({Title="Shader Rain",Value=false,Callback=function(v)tR(v)end})
local at=W:Tab({Title="About",Icon="solar:info-square-bold"})
at:Section({Title="Wezex Hub v4.7"}):Button({Title="Destroy Window",Color=Color3.fromRGB(255,50,50),Callback=function()cE()cV()if aC then aC:Disconnect()end pcall(function()fC:Remove()end)W:Destroy()end})
