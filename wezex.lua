local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Mouse = game.Players.LocalPlayer:GetMouse()

local Blacklist = {Enum.KeyCode.Unknown, Enum.KeyCode.CapsLock, Enum.KeyCode.Escape, Enum.KeyCode.Tab, Enum.KeyCode.Return, Enum.KeyCode.Backspace, Enum.KeyCode.Space, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}

if CoreGui:FindFirstChild("Shaman") then
    CoreGui.Shaman:Destroy()
    CoreGui.Tooltips:Destroy()
end

local function CheckTable(table)
    local i = 0
    for _,v in pairs(table) do
        i = i + 1
    end
    return i
end

local TabSelected = nil
local EditOpened = false
local ColorElements = {}

task.spawn(function()
    while true do
        if EditOpened and CheckTable(ColorElements) > 0 then
            local hue = tick() % 7 / 7
            local color = Color3.fromHSV(hue, 1, 1)

            for frame, v in pairs(ColorElements) do
                if v.Enabled then
                    if frame.ClassName == "Frame" then
                        frame.BackgroundColor3 = color
                    else
                        frame.ImageColor3 = color
                    end
                end
            end
        end
        wait()
    end
end)

local library = {
    Flags = {}
}

local request = syn and syn.request or http and http.request or http_request or request or httprequest
local getcustomasset = getcustomasset or getsynasset
local isfolder = isfolder or syn_isfolder or is_folder
local makefolder = makefolder or make_folder or createfolder or create_folder

if not isfolder("Shaman") then
    local download = Instance.new("ScreenGui")
    download.Name = "Download"
    download.Enabled = true
    download.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    download.Parent = CoreGui

    local dMain = Instance.new("Frame")
    dMain.Name = "DMain"
    dMain.AnchorPoint = Vector2.new(0.5, 0.5)
    dMain.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    dMain.Position = UDim2.new(0.5, 0, 0.486, 0)
    dMain.Size = UDim2.new(0, 285, 0, 77)
    dMain.Parent = download

    local dUICorner = Instance.new("UICorner")
    dUICorner.Name = "DUICorner"
    dUICorner.CornerRadius = UDim.new(0, 5)
    dUICorner.Parent = dMain

    local dUIStroke = Instance.new("UIStroke")
    dUIStroke.Name = "DUIStroke"
    dUIStroke.Color = Color3.fromRGB(45, 45, 45)
    dUIStroke.Parent = dMain

    local dTopbar = Instance.new("Frame")
    dTopbar.Name = "DTopbar"
    dTopbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    dTopbar.Size = UDim2.new(0, 285, 0, 31)
    dTopbar.Parent = dMain

    local dUICorner1 = Instance.new("UICorner")
    dUICorner1.Name = "DUICorner"
    dUICorner1.CornerRadius = UDim.new(0, 5)
    dUICorner1.Parent = dTopbar

    local dFix = Instance.new("Frame")
    dFix.Name = "DFix"
    dFix.AnchorPoint = Vector2.new(0.5, 1)
    dFix.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    dFix.BorderSizePixel = 0
    dFix.Position = UDim2.new(0.5, 0, 1.02, 0)
    dFix.Size = UDim2.new(0, 284, 0, 1)
    dFix.ZIndex = 2
    dFix.Parent = dTopbar

    local dTitleText = Instance.new("TextLabel")
    dTitleText.Name = "DTitleText"
    dTitleText.Font = Enum.Font.GothamBold
    dTitleText.Text = "Downloading Assets"
    dTitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    dTitleText.TextSize = 12
    dTitleText.BackgroundColor3 = Color3.fromRGB(237, 237, 237)
    dTitleText.BackgroundTransparency = 1
    dTitleText.Position = UDim2.new(0.00132, 0, 0, 0)
    dTitleText.Size = UDim2.new(0, 284, 0, 30)
    dTitleText.ZIndex = 2
    dTitleText.Parent = dTopbar

    local dText = Instance.new("TextLabel")
    dText.Name = "DText"
    dText.Font = Enum.Font.GothamBold
    dText.Text = "Loading..."
    dText.TextColor3 = Color3.fromRGB(237, 237, 237)
    dText.TextSize = 11
    dText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dText.BackgroundTransparency = 1
    dText.Position = UDim2.new(0.00132, 0, 0.39, 0)
    dText.Size = UDim2.new(0, 284, 0, 46)
    dText.Parent = dMain

    makefolder("Shaman")

    local Circle = request({Url = "https://raw.githubusercontent.com/Rain-Design/Icons/main/Circle.png", Method = "GET"})
    writefile("Shaman/Circle.png", Circle.Body)
    dText.Text = "Downloaded: Circle.png"

    local ColorDropper = request({Url = "https://raw.githubusercontent.com/Rain-Design/Icons/main/ColorDropper.png", Method = "GET"})
    writefile("Shaman/ColorDropper.png", ColorDropper.Body)
    dText.Text = "Downloaded: ColorDropper.png"

    local Close = request({Url = "https://raw.githubusercontent.com/Rain-Design/Icons/main/Close.png", Method = "GET"})
    writefile("Shaman/Close.png", Close.Body)
    dText.Text = "Downloaded: Close.png"

    local CollapseArrow = request({Url = "https://raw.githubusercontent.com/Rain-Design/Icons/main/CollapseArrow.png", Method = "GET"})
    writefile("Shaman/CollapseArrow.png", CollapseArrow.Body)
    dText.Text = "Downloaded: CollapseArrow.png"

    local RadioButton = request({Url = "https://raw.githubusercontent.com/Rain-Design/Icons/main/RadioButton.png", Method = "GET"})
    writefile("Shaman/RadioButton.png", RadioButton.Body)
    dText.Text = "Downloaded: RadioButton.png"

    local RadioOuter = request({Url = "https://raw.githubusercontent.com/Rain-Design/Icons/main/RadioOuter.png", Method = "GET"})
    writefile("Shaman/RadioOuter.png", RadioOuter.Body)
    dText.Text = "Downloaded: RadioOuter.png"

    local RadioInner = request({Url = "https://raw.githubusercontent.com/Rain-Design/Icons/main/RadioInner.png", Method = "GET"})
    writefile("Shaman/RadioInner.png", RadioInner.Body)
    dText.Text = "Downloaded: RadioInner.png"

    download:Destroy()
end

function library:GetXY(GuiObject)
    local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
    local Px, Py = math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max), math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
    return Px/Max, Py/May
end

function library:Window(Info)
    Info.Text = Info.Text or "Shaman"

    local window = {}

    local shamanScreenGui = Instance.new("ScreenGui")
    shamanScreenGui.Name = "Shaman"
    shamanScreenGui.Parent = CoreGui

    local tooltipScreenGui = Instance.new("ScreenGui")
    tooltipScreenGui.Name = "Tooltips"
    tooltipScreenGui.Parent = CoreGui

    local function Tooltip(text)
        local tooltip = Instance.new("Frame")
        tooltip.Name = "Tooltip"
        tooltip.AnchorPoint = Vector2.new(0.5, 0)
        tooltip.BackgroundColor3 = Color3.fromRGB(79, 79, 79)
        tooltip.Visible = false
        tooltip.Position = UDim2.new(0.352, 0, 0.0741, 0)
        tooltip.Size = UDim2.new(0, 100, 0, 19)
        tooltip.ZIndex = 5
        tooltip.Parent = tooltipScreenGui

        local newuICorner = Instance.new("UICorner")
        newuICorner.Name = "UICorner"
        newuICorner.CornerRadius = UDim.new(0, 3)
        newuICorner.Parent = tooltip

        local newuIStroke = Instance.new("UIStroke")
        newuIStroke.Name = "UIStroke"
        newuIStroke.Color = Color3.fromRGB(98, 98, 98)
        newuIStroke.Parent = tooltip

        local tooltipText = Instance.new("TextLabel")
        tooltipText.Name = "TooltipText"
        tooltipText.Font = Enum.Font.GothamBold
        tooltipText.Text = text
        tooltipText.TextColor3 = Color3.fromRGB(217, 217, 217)
        tooltipText.TextSize = 11
        tooltipText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tooltipText.BackgroundTransparency = 1
        tooltipText.Size = UDim2.new(0, 100, 0, 19)
        tooltipText.Parent = tooltip
        tooltipText.ZIndex = 6

        local TextBounds = tooltipText.TextBounds

        tooltip.Size = UDim2.new(0, TextBounds.X + 10, 0, 19)
        tooltipText.Size = UDim2.new(0, TextBounds.X + 10, 0, 19)

        return tooltip
    end

    local function AddTooltip(element, text)
        local Tooltip = Tooltip(text)
        local Hovered = false

        local function Update()
            local MousePos = UserInputService:GetMouseLocation()
            local Viewport = workspace.CurrentCamera.ViewportSize

            Tooltip.Position = UDim2.new(MousePos.X / Viewport.X, 0, MousePos.Y / Viewport.Y, 0) + UDim2.new(0,0,0,-43)
        end

        element.MouseEnter:Connect(function()
            Hovered = true
            wait(.5)
            if Hovered then
                Tooltip.Visible = true
            end
        end)

        element.MouseLeave:Connect(function()
            Hovered = false
            Tooltip.Visible = false
        end)

        element.MouseMoved:Connect(function()
            Update()
        end)
    end

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Position = UDim2.new(0.361, 0, 0.308, 0)
    main.Size = UDim2.new(0, 450, 0, 321)
    main.Parent = shamanScreenGui

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0, 5)
    uICorner.Parent = main

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    topbar.Size = UDim2.new(0, 450, 0, 31)
    topbar.Parent = main
    topbar.ZIndex = 2

    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    local uICorner1 = Instance.new("UICorner")
    uICorner1.Name = "UICorner"
    uICorner1.Parent = topbar

    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(0, 0, 0.625, 0)
    frame.Size = UDim2.new(0, 450, 0, 11)
    frame.Parent = topbar

    local frame1 = Instance.new("Frame")
    frame1.Name = "Frame"
    frame1.AnchorPoint = Vector2.new(0.5, 1)
    frame1.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    frame1.BorderSizePixel = 0
    frame1.Position = UDim2.new(0.5, 0, 1, 0)
    frame1.Size = UDim2.new(0, 450, 0, 1)
    frame1.ZIndex = 2
    frame1.Parent = frame

    local uIGradient = Instance.new("UIGradient")
    uIGradient.Name = "UIGradient"
    uIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(183, 248, 219)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 167, 194)),
    })
    uIGradient.Enabled = false
    uIGradient.Parent = frame1

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TextLabel"
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = Info.Text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.BackgroundColor3 = Color3.fromRGB(237, 237, 237)
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0.015, 0, 0, 0)
    textLabel.Size = UDim2.new(0, 51, 0, 30)
    textLabel.ZIndex = 2
    textLabel.Parent = topbar

    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Image = getcustomasset("Shaman/Close.png")
    closeButton.ImageColor3 = Color3.fromRGB(237, 237, 237)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(0.947, 0, 0.194, 0)
    closeButton.Size = UDim2.new(0, 17, 0, 17)
    closeButton.ZIndex = 2
    closeButton.Parent = topbar

    closeButton.MouseButton1Click:Once(function()
        shamanScreenGui:Destroy()
        tooltipScreenGui:Destroy()
    end)

    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {ImageColor3 = Color3.fromRGB(217, 97, 99)}):Play()
    end)

    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {ImageColor3 = Color3.fromRGB(217, 217, 217)}):Play()
    end)

    local minimizeButton = Instance.new("ImageButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Image = "rbxassetid://10664064072"
    minimizeButton.ImageColor3 = Color3.fromRGB(237, 237, 237)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Position = UDim2.new(0.893, 0, 0.194, 0)
    minimizeButton.Size = UDim2.new(0, 17, 0, 17)
    minimizeButton.ZIndex = 2
    minimizeButton.Parent = topbar

    minimizeButton.MouseEnter:Connect(function()
        TweenService:Create(minimizeButton, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {ImageColor3 = Color3.fromRGB(194, 162, 76)}):Play()
    end)

    minimizeButton.MouseLeave:Connect(function()
        TweenService:Create(minimizeButton, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {ImageColor3 = Color3.fromRGB(217, 217, 217)}):Play()
    end)

    local Opened = true

    minimizeButton.MouseButton1Click:Connect(function()
        Opened = not Opened

        topbar.Frame.Visible = Opened
        task.spawn(function()
            if Opened then
                wait(.15)
            end
            for _,v in pairs(main:GetChildren()) do
                if v.Name == "TabContainer" then
                    v.Visible = Opened
                end
            end
            for _,v in pairs(main:GetChildren()) do
                if v.Name == "LeftContainer" or v.Name == "RightContainer" and v.Visible then
                    v.Size = Opened and UDim2.new(0, 168,0, 287) or UDim2.new(0, 168,0, 0)
                end
            end
        end)

        TweenService:Create(main, TweenInfo.new(.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = Opened and UDim2.new(0, 450,0, 321) or UDim2.new(0, 450,0, 30)}):Play()
    end)

    local editButton = Instance.new("ImageButton")
    editButton.Name = "EditButton"
    editButton.Image = getcustomasset("Shaman/ColorDropper.png")
    editButton.ImageColor3 = Color3.fromRGB(237, 237, 237)
    editButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    editButton.BackgroundTransparency = 1
    editButton.Position = UDim2.new(0.841, 0, 0.226, 0)
    editButton.Size = UDim2.new(0, 15, 0, 15)
    editButton.ZIndex = 2
    editButton.Parent = topbar

    local uiGradient = Instance.new("UIGradient")
    uiGradient.Name = "UIGradient"
    uiGradient.Enabled = false
    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.2,Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.4,Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.6,Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.8,Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,255)),
    }
    uiGradient.Parent = editButton

    task.spawn(function()
        while wait() do
            if uiGradient.Enabled then
                local loop = tick() % 2 / 2
                colors = {}
                for i = 1, 7 + 1, 1 do
                    z = Color3.fromHSV(loop - ((i - 1)/7), 1, 1)
                    if loop - ((i - 1) / 7) < 0 then
                        z = Color3.fromHSV((loop - ((i - 1) / 7)) + 1, 1, 1)
                    end
                    local d = ColorSequenceKeypoint.new((i - 1) / 7, z)
                    table.insert(colors, #colors + 1, d)
                end
                uiGradient.Color = ColorSequence.new(colors)
            end
        end
    end)

    editButton.MouseEnter:Connect(function()
        if not EditOpened then
            uiGradient.Enabled = true
        end
    end)

    editButton.MouseLeave:Connect(function()
        if not EditOpened then
            uiGradient.Enabled = false
        end
    end)

    editButton.MouseButton1Click:Connect(function()
        EditOpened = not EditOpened

        uiGradient.Enabled = EditOpened and true or false

        if not EditOpened then
            for frame, v in pairs(ColorElements) do
                if v.Enabled then
                    if frame.ClassName == "Frame" then
                        TweenService:Create(frame, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundColor3 = Color3.fromRGB(48, 207, 106)}):Play()
                    else
                        TweenService:Create(frame, TweenInfo.new(.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {ImageColor3 = Color3.fromRGB(48, 207, 106)}):Play()
                    end
                end
            end
        else
            for _,v in pairs(ColorElements) do
                if v.Type ~= "Toggle" then
                    v.Enabled = true
                end
            end
        end
    end)

    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabContainer.Position = UDim2.new(0, 0, 0.0935, 0)
    tabContainer.Size = UDim2.new(0, 114, 0, 291)
    tabContainer.Parent = main

    local uICorner2 = Instance.new("UICorner")
    uICorner2.Name = "UICorner"
    uICorner2.CornerRadius = UDim.new(0, 5)
    uICorner2.Parent = tabContainer

    local fix = Instance.new("Frame")
    fix.Name = "Fix"
    fix.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    fix.BorderSizePixel = 0
    fix.Position = UDim2.new(0.895, 0, 0, 0)
    fix.Size = UDim2.new(0, 11, 0, 285)
    fix.Parent = tabContainer

    local fix1 = Instance.new("Frame")
    fix1.Name = "Fix"
    fix1.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    fix1.BorderSizePixel = 0
    fix1.Position = UDim2.new(0, 0, -0.00351, 0)
    fix1.Size = UDim2.new(0, 11, 0, 79)
    fix1.Parent = tabContainer

    local scrollingContainer = Instance.new("ScrollingFrame")
    scrollingContainer.Name = "ScrollingContainer"
    scrollingContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingContainer.CanvasSize = UDim2.new()
    scrollingContainer.ScrollBarImageColor3 = Color3.fromRGB(56, 56, 56)
    scrollingContainer.ScrollBarThickness = 2
    scrollingContainer.Active = true
    scrollingContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scrollingContainer.BackgroundTransparency = 1
    scrollingContainer.BorderSizePixel = 0
    scrollingContainer.Size = UDim2.new(0, 114, 0, 285)
    scrollingContainer.ZIndex = 2
    scrollingContainer.Parent = tabContainer

    local tabs = {}
    local currentTab = nil

    function window:Tab(Info)
        Info.Text = Info.Text or "Tab"

        local tab = {}

        local tabButton = Instance.new("Frame")
        tabButton.Name = "TabButton"
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.Background
