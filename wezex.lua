-- ====== ANTI-DEATH PLATFORM (БЫСТРЕЕ, НЕ ВЫШЕ 1 МЕТРА) ======
local function startPlatform()
    platformOn = true
    State.platform = true

    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(6, 1, 6)
    platformPart.Position = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 2, 0)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.Transparency = 0.4
    platformPart.Material = Enum.Material.Neon
    platformPart.Color = Color3.fromRGB(0, 255, 255)
    platformPart.Parent = Workspace

    local light = Instance.new("PointLight")
    light.Parent = platformPart
    light.Color = Color3.fromRGB(0, 255, 255)
    light.Range = 10
    light.Brightness = 2

    platformConnection = RunService.RenderStepped:Connect(function()
        if not platformOn then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Целевая высота: на 1 метр ниже игрока
        local targetY = hrp.Position.Y - 1

        -- Быстро поднимаемся к цели, но не выше неё
        local currentY = platformPart.Position.Y
        if currentY < targetY then
            platformPart.Position = platformPart.Position + Vector3.new(0, math.min(0.3, targetY - currentY), 0)
        elseif currentY > targetY then
            platformPart.Position = platformPart.Position - Vector3.new(0, math.min(0.3, currentY - targetY), 0)
        end

        -- Следуем за игроком по X и Z
        platformPart.Position = Vector3.new(hrp.Position.X, platformPart.Position.Y, hrp.Position.Z)
    end)

    task.spawn(function()
        while platformOn do
            task.wait(0.5)
        end
        if platformPart then
            platformPart:Destroy()
            platformPart = nil
        end
        if platformConnection then
            platformConnection:Disconnect()
            platformConnection = nil
        end
    end)
end

local function stopPlatform()
    platformOn = false
    State.platform = false

    if platformPart then
        platformPart:Destroy()
        platformPart = nil
    end
    if platformConnection then
        platformConnection:Disconnect()
        platformConnection = nil
    end
end

-- ====== СИНИЙ ШАРИК (СЗАДИ ЗА ИГРОКОМ) ======
local function startBlueOrb()
    blueOrbOn = true
    State.blueOrb = true

    local function setupBlueOrb()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if blueOrbPart and blueOrbPart.Parent then
            blueOrbPart:Destroy()
            blueOrbPart = nil
        end
        if blueOrbLight then
            blueOrbLight:Destroy()
            blueOrbLight = nil
        end

        blueOrbPart = Instance.new("Part")
        blueOrbPart.Size = Vector3.new(0.8, 0.8, 0.8)
        blueOrbPart.Shape = Enum.PartType.Ball
        blueOrbPart.Material = Enum.Material.Neon
        blueOrbPart.Color = Color3.fromRGB(0, 100, 255)
        blueOrbPart.Anchored = true
        blueOrbPart.CanCollide = false
        blueOrbPart.Parent = hrp

        -- Шлейф
        local trail = Instance.new("Trail")
        trail.Parent = blueOrbPart
        trail.Attachment0 = Instance.new("Attachment", blueOrbPart)
        trail.Lifetime = 0.4
        trail.MinLength = 0.2
        trail.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 255))
        })
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(0.5, 0.3),
            NumberSequenceKeypoint.new(1, 1)
        })
        trail.Width = NumberSequence.new(1.2)

        -- Свет
        blueOrbLight = Instance.new("PointLight")
        blueOrbLight.Parent = blueOrbPart
        blueOrbLight.Color = Color3.fromRGB(0, 100, 255)
        blueOrbLight.Range = 15
        blueOrbLight.Brightness = 2.5

        blueOrbConn = RunService.RenderStepped:Connect(function()
            if not blueOrbOn or not hrp.Parent then return end
            local time = tick() * 0.5
            -- Летает сзади за игроком
            local offset = Vector3.new(
                math.sin(time) * 0.3,
                math.cos(time * 0.7) * 0.2 + 1.2,
                -3.5 + math.cos(time * 0.5) * 0.2
            )
            blueOrbPart.Position = hrp.Position + offset
        end)
    end

    setupBlueOrb()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        setupBlueOrb()
    end)
end

local function stopBlueOrb()
    blueOrbOn = false
    State.blueOrb = false
    if blueOrbConn then
        blueOrbConn:Disconnect()
        blueOrbConn = nil
    end
    if blueOrbPart then
        blueOrbPart:Destroy()
        blueOrbPart = nil
    end
    if blueOrbLight then
        blueOrbLight:Destroy()
        blueOrbLight = nil
    end
end
