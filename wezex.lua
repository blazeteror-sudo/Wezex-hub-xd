local L=loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local PL=game:GetService("Players")local LP=PL.LocalPlayer local CAM=workspace.CurrentCamera local UIS=game:GetService("UserInputService")local RS=game:GetService("RunService")local LGT=game:GetService("Lighting")
local S={esp=false,aim=false,noclip=false,infjump=false,fov=250,part="Head",vis=true}
local W=L:CreateWindow({Title="Wezex Hub v5.4",Folder="WezexHub",Icon="solar:folder-2-bold-duotone",OpenButton={Title="Wezex Hub",Color=ColorSequence.new(Color3.fromRGB(255,100,255),Color3.fromRGB(100,200,255)),Draggable=true,Scale=0.5}})
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
local bx=Drawing.new("Square")bx.Thickness,bx.Filled,bx.Visible,bx.ZIndex=1.5,false,false,3
local sh=Drawing.new("Square")sh.Thickness,sh.Filled,sh.Visible,sh.ZIndex,sh.Color,sh.Transparency=3,false,false,2,Color3.new(),0.5
local nm=Drawing.new("Text")nm.Size,nm.Center,nm.Outline,nm.Visible,nm.ZIndex=15,true,true,false,6 nm.OutlineColor=Color3.new()
local nb=Drawing.new("Square")nb.Filled,nb.Transparency,nb.Visible,nb.ZIndex,nb.Color=true,0.6,false,5,Color3.new()
local ds=Drawing.new("Text")ds.Size,ds.Center,ds.Outline,ds.Visible,ds.ZIndex=13,true,true,false,6 ds.OutlineColor,ds.Color=Color3.new(),Color3.fromRGB(220,220,220)
local hb=Drawing.new("Square")hb.Filled,hb.Transparency,hb.Color,hb.Visible,hb.ZIndex=true,0.8,Color3.new(),false,3
local hp=Drawing.new("Square")hp.Filled,hp.Transparency,hp.Visible,hp.ZIndex=true,1,false,4
local tr=Drawing.new("Line")tr.Thickness,tr.Visible,tr.ZIndex,tr.Transparency=1,false,1,0.6
local cs={}for i=1,8 do cs[i]=Drawing.new("Line")cs[i].Thickness,cs[i].Visible,cs[i].ZIndex=2,false,4 end
E[p]={box=bx,shadow=sh,name=nm,nameBg=nb,dist=ds,hp=hp,hpBg=hb,tracer=tr,c1=cs[1],c2=cs[2],c3=cs[3],c4=cs[4],c5=cs[5],c6=cs[6],c7=cs[7],c8=cs[8]}end
local function rE(p)local d=E[p]if not d then return end for _,k in ipairs(K)do if d[k]then pcall(function()d[k]:Remove()end)end end E[p]=nil end
local function hA(d)for _,k in ipairs(K)do d[k].Visible=false end end
local function uE()
for _,p in ipairs(PL:GetPlayers())do if p~=LP then mE(p)end end local vp=CAM.ViewportSize
for p,d in pairs(E)do local c=p.Character local hr=c and c:FindFirstChild("HumanoidRootPart")local h=c and c:FindFirstChildOfClass("Humanoid")local hd=c and c:FindFirstChild("Head")
if hr and h and h.Health>0 and hd then local rp,os=CAM:WorldToViewportPoint(hr.Position)local h2=CAM:WorldToViewportPoint(hd.Position+Vector3.new(0,0.5,0))local fp=CAM:WorldToViewportPoint(hr.Position-Vector3.new(0,3,0))
if os then local H=math.abs(h2.Y-fp.Y)local W2=H*0.55 local x,y=rp.X-W2/2,h2.Y local di=(CAM.CFrame.Position-hr.Position).Magnitude
local tm=p.Team and LP.Team and p.Team==LP.Team local vs=hL(hd)local bc
if tm then bc=Color3.fromRGB(80,255,120)elseif vs then bc=Color3.fromRGB(255,70,70)else bc=Color3.fromRGB(255,180,60)end
local tc=bc:Lerp(Color3.new(1,1,1),0.15)
d.box.Color,d.box.Size,d.box.Position,d.box.Visible=bc,Vector2.new(W2,H),Vector2.new(x,y),true
d.shadow.Color,d.shadow.Size,d.shadow.Position,d.shadow.Visible=Color3.new(),Vector2.new(W2+2,H+2),Vector2.new(x-1,y-1),true
local cl=math.min(W2,H)*0.2 local corners={{x,y,x+cl,y},{x,y,x,y+cl},{x+W2,y,x+W2-cl,y},{x+W2,y,x+W2,y+cl},{x,y+H,x+cl,y+H},{x,y+H-cl,x,y+H},{x+W2,y+H,x+W2-cl,y+H},{x+W2,y+H-cl,x+W2,y+H}}
local ck={"c1","c2","c3","c4","c5","c6","c7","c8"}
for i,cd in ipairs(corners)do local cc=d[ck[i]]cc.From,cc.To,cc.Color,cc.Visible=Vector2.new(cd[1],cd[2]),Vector2.new(cd[3],cd[4]),tc,true end
d.name.Text,d.name.Position,d.name.Color,d.name.Visible=p.Name,Vector2.new(rp.X,y-26),tc,true
local nw=#p.Name*7 d.nameBg.Size,d.nameBg.Position,d.nameBg.Color,d.nameBg.Visible=Vector2.new(nw+8,18),Vector2.new(rp.X-(nw+8)/2,y-34),Color3.fromRGB(15,15,25),true
d.dist.Text,d.dist.Position,d.dist.Color,d.dist.Visible=string.format("%d studs",math.floor(di)),Vector2.new(rp.X,y+H+6),Color3.fromRGB(220,220,220),true
local r=math.clamp(h.Health/h.MaxHealth,0,1)local bxx=x-8
d.hpBg.Size,d.hpBg.Position,d.hpBg.Color,d.hpBg.Visible=Vector2.new(4,H),Vector2.new(bxx,y),Color3.fromRGB(20,20,20),true
d.hp.Size,d.hp.Position,d.hp.Color,d.hp.Visible=Vector2.new(4,H*r),Vector2.new(bxx,y+H*(1-r)),Color3.fromRGB(255*(1-r),255*r,80),true
d.tracer.From,d.tracer.To,d.tracer.Color,d.tracer.Visible=Vector2.new(vp.X/2,vp.Y),Vector2.new(rp.X,y+H),tc,true
else hA(d)end else hA(d)end end end
local function tE()S.esp=not S.esp if S.esp then cE()for _,p in ipairs(PL:GetPlayers())do mE(p)end eA=PL.PlayerAdded:Connect(mE)eR=PL.PlayerRemoving:Connect(rE)eC=RS.RenderStepped:Connect(uE)else cE()end end
local nC,oC=nil,{}
local function tN()S.noclip=not S.noclip if S.noclip then if nC then nC:Disconnect()end nC=RS.Stepped:Connect(function()local c=LP.Character if c then for _,p in ipairs(c:GetDescendants())do if p:IsA("BasePart")then if oC[p]==nil then oC[p]=p.CanCollide end p.CanCollide=false end end end end)else if nC then nC:Disconnect()nC=nil end local c=LP.Character if c then for _,p in ipairs(c:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=oC[p]~=nil and oC[p]or false end end end oC={}end end
local iC
local function tJ()S.infJump=not S.infJump if S.infJump then if iC then iC:Disconnect()end iC=UIS.JumpRequest:Connect(function()local c=LP.Character if c and c:FindFirstChildOfClass("Humanoid")then c:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)end end)else if iC then iC:Disconnect()iC=nil end end end
-- TP TO NEAREST PLAYER (WindUI-style button)
local tpEnabled=false
local tpCooldown=0
local TP_CD=1.0
local TP_OFFSET=2.5
local tpGui=nil
local tpBtn=nil
local function findNearestPlayer()
local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not hrp then return nil end
local myPos=hrp.Position
local best=nil
local bestDist=math.huge
for _,p in ipairs(PL:GetPlayers())do
if p~=LP and p.Character then
local h=p.Character:FindFirstChildOfClass("Humanoid")
local hr=p.Character:FindFirstChild("HumanoidRootPart")
if h and h.Health>0 and hr then
local d=(hr.Position-myPos).Magnitude
if d<bestDist then
best=hr
bestDist=d
end
end
end
end
return best
end
local function doTP()
if os.clock()<tpCooldown then return end
local target=findNearestPlayer()
local myHrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not target or not myHrp then return end
local pos=target.Position
local dir=(myHrp.Position-pos)
if dir.Magnitude>0.1 then
pos=pos+dir.Unit*TP_OFFSET
end
myHrp.CFrame=CFrame.new(pos)
tpCooldown=os.clock()+TP_CD
end
local function tTP(on)
tpEnabled=on
if on then
if tpGui then tpGui:Destroy() end
tpGui=Instance.new("ScreenGui")
tpGui.Name="TPBtnGui"
tpGui.ResetOnSpawn=false
tpGui.IgnoreGuiInset=true
pcall(function() tpGui.Parent=game:GetService("CoreGui") end)
if not tpGui.Parent then tpGui.Parent=LP:WaitForChild("PlayerGui") end
tpBtn=Instance.new("TextButton")
tpBtn.Size=UDim2.new(0,44,0,44)
tpBtn.Position=UDim2.new(0,20,0.5,-22)
tpBtn.BackgroundColor3=Color3.fromRGB(20,20,25)
tpBtn.BackgroundTransparency=0.1
tpBtn.Text=""
tpBtn.AutoButtonColor=true
tpBtn.Active=true
tpBtn.Parent=tpGui
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(1,0)
corner.Parent=tpBtn
local grad=Instance.new("UIGradient")
grad.Color=ColorSequence.new(Color3.fromRGB(255,100,255),Color3.fromRGB(100,200,255))
grad.Rotation=45
grad.Parent=tpBtn
local stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(255,255,255)
stroke.Thickness=1
stroke.Transparency=0.7
stroke.Parent=tpBtn
local icon=Instance.new("ImageLabel")
icon.Size=UDim2.new(0,24,0,24)
icon.Position=UDim2.new(0.5,-12,0.5,-12)
icon.BackgroundTransparency=1
icon.Image="rbxassetid://10734886055"
icon.ImageColor3=Color3.fromRGB(255,255,255)
icon.Parent=tpBtn
local dragging=false
local dragStart=nil
local startPos=nil
local tapStart=nil
tpBtn.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=true
dragStart=input.Position
startPos=tpBtn.Position
tapStart=input.Position
end
end)
tpBtn.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=false
if tapStart and (input.Position-tapStart).Magnitude<10 then
doTP()
end
tapStart=nil
end
end)
UIS.InputChanged:Connect(function(input)
if dragging and dragStart then
if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
local delta=input.Position-dragStart
tpBtn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
end
end
end)
else
if tpGui then tpGui:Destroy() tpGui=nil end
tpBtn=nil
end
end
-- FIREFLIES
local fFlies={}
local fConn=nil
local FLY_COUNT=80
local WORLD_RADIUS=350
local function tF(on)
if not on then
if fConn then fConn:Disconnect()fConn=nil end
for _,f in ipairs(fFlies)do if f.part then f.part:Destroy()end if f.light then f.light:Destroy()end end
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
part.Shape=Enum.PartType.Ball
part.Size=Vector3.new(0.55,0.55,0.55)
part.Material=Enum.Material.Neon
part.Color=Color3.fromRGB(255,240,140)
part.Anchored=true
part.CanCollide=false
part.CanQuery=false
part.CastShadow=false
part.CFrame=CFrame.new(randPos())
part.Parent=workspace
local light=Instance.new("PointLight")
light.Color=Color3.fromRGB(255,235,130)
light.Range=14
light.Brightness=3.5
light.Shadows=false
light.Parent=part
return{part=part,light=light,pos=part.Position,target=randPos(),speed=rng:NextNumber(8,22),turnSpeed=rng:NextNumber(0.4,1.4),phase=rng:NextNumber(0,10)}
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
f.part.CFrame=CFrame.new(newPos)
f.phase=f.phase+dt*f.turnSpeed
f.light.Brightness=3+math.sin(f.phase*2)*1.2
end
end
end)
end
local SK={["Cosmic Nebula"]={Bk="rbxassetid://169210090",Dn="rbxassetid://169210108",Ft="rbxassetid://169210121",Lf="rbxassetid://169210133",Rt="rbxassetid://169210143",Up="rbxassetid://169210149"}}
local function aS(n)local o=LGT:FindFirstChildOfClass("Sky")if o then o:Destroy()end if n=="Стандарт"then return end local d=SK[n]if not d then return end local s=Instance.new("Sky")s.SkyboxBk=d.Bk s.SkyboxDn=d.Dn s.SkyboxFt=d.Ft s.SkyboxLf=d.Lf s.SkyboxRt=d.Rt s.SkyboxUp=d.Up s.SunAngularSize=14 s.MoonAngularSize=14 s.StarCount=5000 s.CelestialBodiesShown=true s.Parent=LGT end
local shI={}
local shAnim=nil
local shOrig={}
local function tS(on)if on then for _,v in ipairs(shI)do v:Destroy()end shI={}
shOrig.Tech=LGT.Technology shOrig.Clock=LGT.ClockTime shOrig.Bright=LGT.Brightness
shOrig.Shad=LGT.GlobalShadows shOrig.Out=LGT.OutdoorAmbient
shOrig.EnvD=LGT.EnvironmentDiffuseScale shOrig.EnvS=LGT.EnvironmentSpecularScale
shOrig.Exp=LGT.ExposureCompensation
pcall(function()LGT.Technology=Enum.Technology.Future end)
LGT.ClockTime=17.4 LGT.GeographicLatitude=41.7 LGT.Brightness=2.4
LGT.GlobalShadows=true LGT.ShadowSoftness=0.15 LGT.ExposureCompensation=0.1
LGT.EnvironmentDiffuseScale=1 LGT.EnvironmentSpecularScale=1
LGT.OutdoorAmbient=Color3.fromRGB(75,70,85)
local a=LGT:FindFirstChildOfClass("Atmosphere")or Instance.new("Atmosphere")
a.Density,a.Offset,a.Color,a.Decay,a.Glare,a.Haze=0.32,0.25,Color3.fromRGB(195,170,155),Color3.fromRGB(105,115,130),0.4,2.1
a.Parent=LGT table.insert(shI,a)
local b=Instance.new("BloomEffect")b.Intensity,b.Size,b.Threshold=0.65,24,0.85 b.Parent=LGT table.insert(shI,b)
local c=Instance.new("ColorCorrectionEffect")c.Brightness,c.Contrast,c.Saturation,c.TintColor=0.03,0.22,0.18,Color3.fromRGB(255,248,242)c.Parent=LGT table.insert(shI,c)
local s=Instance.new("SunRaysEffect")s.Intensity,s.Spread=0.25,0.8 s.Parent=LGT table.insert(shI,s)
local d=Instance.new("DepthOfFieldEffect")d.FarIntensity,d.FocusDistance,d.InFocusRadius,d.NearIntensity=0.35,20,25,0.15 d.Parent=LGT table.insert(shI,d)
local t=0 if shAnim then shAnim:Disconnect()end
shAnim=RS.RenderStepped:Connect(function(dt)t=t+dt*0.5 if s and s.Parent then s.Intensity=0.22+math.sin(t)*0.05 end if b and b.Parent then b.Intensity=0.6+math.cos(t*0.8)*0.06 end end)
else for _,v in ipairs(shI)do v:Destroy()end shI={}
if shAnim then shAnim:Disconnect()shAnim=nil end
if shOrig.Tech then pcall(function()LGT.Technology=shOrig.Tech end)end
LGT.ClockTime=shOrig.Clock or 14 LGT.Brightness=shOrig.Bright or 2
LGT.GlobalShadows=shOrig.Shad~=false LGT.OutdoorAmbient=shOrig.Out or Color3.fromRGB(128,128,128)
LGT.EnvironmentDiffuseScale=shOrig.EnvD or 1 LGT.EnvironmentSpecularScale=shOrig.EnvS or 1
LGT.ExposureCompensation=shOrig.Exp or 0 end end
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
local function cV()tF(false)tS(false)tT(false)local s=LGT:FindFirstChildOfClass("Sky")if s then s:Destroy()end end
local ct=W:Tab({Title="Combat",Icon="solar:sword-bold"})local cs=ct:Section({Title="Aimbot"})
cs:Toggle({Title="Aimbot",Value=false,Callback=function(v)if v~=S.aim then tA()end end})
cs:Slider({Title="FOV",Value={Min=50,Max=1000,Default=250},Callback=function(v)S.fov=v uF()end})
cs:Dropdown({Title="Hit Part",Values={"Head","HumanoidRootPart","UpperTorso"},Value="Head",Callback=function(v)S.part=v end})
cs:Toggle({Title="Wall Check",Value=true,Callback=function(v)S.vis=v end})
local ts=ct:Section({Title="Teleport"})
ts:Toggle({Title="TP Button (Nearest)",Value=false,Callback=function(v)tTP(v)end})
ts:Slider({Title="TP Cooldown",Value={Min=1,Max=50,Default=10},Callback=function(v)TP_CD=v/10 end})
ts:Slider({Title="TP Distance",Value={Min=1,Max=10,Default=25},Callback=function(v)TP_OFFSET=v/10 end})
local mt=W:Tab({Title="Movement",Icon="solar:running-bold"})local ms=mt:Section({Title="Movement"})
ms:Toggle({Title="Noclip",Value=false,Callback=function(v)if v~=S.noclip then tN()end end})
ms:Toggle({Title="Infinity Jump",Value=false,Callback=function(v)if v~=S.infJump then tJ()end end})
local vt=W:Tab({Title="Visuals",Icon="solar:eye-bold"})
local vs=vt:Section({Title="ESP"})
vs:Toggle({Title="ESP (Stylish)",Value=false,Callback=function(v)if v~=S.esp then tE()end end})
local fx=vt:Section({Title="Effects"})
fx:Toggle({Title="Fireflies 3D",Value=false,Callback=function(v)tF(v)end})
fx:Dropdown({Title="Skybox",Values={"Стандарт","Cosmic Nebula"},Value="Стандарт",Callback=function(v)aS(v)end})
fx:Toggle({Title="Cinematic Shader",Value=false,Callback=function(v)tS(v)end})
fx:Toggle({Title="Spiral Trails",Value=false,Callback(function(v)tT(v)end)})
local at=W:Tab({Title="About",Icon="solar:info-square-bold"})
at:Section({Title="Wezex Hub v5.4"}):Button({Title="Destroy Window",Color=Color3.fromRGB(255,50,50),Callback=function()cE()cV()if aC then aC:Disconnect()end if tpGui then tpGui:Destroy()end pcall(function()fC:Remove()end)W:Destroy()end})
