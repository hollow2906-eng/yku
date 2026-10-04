--[[
    Kyu's ESP tracer v14
    - Nomes sempre via TextLabel (fix definitivo)
    - Botão de minimizar (—) + botão X
    - Tema galáxia com contorno roxo
    - Só players, 1 tracer por personagem
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if CoreGui:FindFirstChild("KyuESPTracer") then
    CoreGui.KyuESPTracer:Destroy()
end

local Config = {
    Enabled = true,
    Color = Color3.fromRGB(0, 255, 120),
    Thickness = 1.5,
    Transparency = 0.2,
    MaxDistance = 100000,
    EdgeMargin = 40,
    SkipSelf = false,
    ShowNames = true,
    NameOffsetY = 18,
    NameTextSize = 14,
}

local Tracers = {}

--------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KyuESPTracer"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local EXPANDED_HEIGHT = 250
local COLLAPSED_HEIGHT = 30

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, EXPANDED_HEIGHT)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(15, 10, 30)
Frame.BorderSizePixel = 0
Frame.Active = false
Frame.Draggable = false
Frame.ClipsDescendants = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

-- ====== Galaxy background ======
local GalaxyBase = Instance.new("Frame")
GalaxyBase.Name = "GalaxyBase"
GalaxyBase.Size = UDim2.new(1, 0, 1, 0)
GalaxyBase.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
GalaxyBase.BorderSizePixel = 0
GalaxyBase.ZIndex = 0
GalaxyBase.Parent = Frame

local GalaxyGradient = Instance.new("UIGradient")
GalaxyGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(15, 5, 35)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(45, 15, 80)),
    ColorSequenceKeypoint.new(0.65, Color3.fromRGB(80, 25, 110)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 10, 50)),
})
GalaxyGradient.Rotation = 45
GalaxyGradient.Parent = GalaxyBase

do
    local rng = Random.new(42)
    for i = 1, 45 do
        local star = Instance.new("Frame")
        star.Name = "Star" .. i
        local size = rng:NextNumber(1, 3)
        star.Size = UDim2.new(0, size, 0, size)
        star.Position = UDim2.new(rng:NextNumber(0, 1), 0, rng:NextNumber(0, 1), 0)
        star.AnchorPoint = Vector2.new(0.5, 0.5)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BackgroundTransparency = rng:NextNumber(0.1, 0.7)
        star.BorderSizePixel = 0
        star.ZIndex = 1
        star.Parent = GalaxyBase
        local starCorner = Instance.new("UICorner")
        starCorner.CornerRadius = UDim.new(1, 0)
        starCorner.Parent = star
    end
    for i = 1, 4 do
        local blob = Instance.new("Frame")
        blob.Name = "Nebula" .. i
        local w = rng:NextInteger(60, 130)
        blob.Size = UDim2.new(0, w, 0, w)
        blob.Position = UDim2.new(rng:NextNumber(-0.2, 1), 0, rng:NextNumber(-0.2, 1), 0)
        blob.AnchorPoint = Vector2.new(0.5, 0.5)
        blob.BackgroundColor3 = (i % 2 == 0)
            and Color3.fromRGB(140, 60, 220)
            or Color3.fromRGB(60, 100, 220)
        blob.BackgroundTransparency = 0.85
        blob.BorderSizePixel = 0
        blob.ZIndex = 0
        blob.Parent = GalaxyBase
        local blobCorner = Instance.new("UICorner")
        blobCorner.CornerRadius = UDim.new(1, 0)
        blobCorner.Parent = blob
    end
end

-- ====== Contorno roxo neon ======
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(170, 80, 255)
Stroke.Thickness = 2
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Frame

local GlowStroke = Instance.new("UIStroke")
GlowStroke.Color = Color3.fromRGB(120, 40, 200)
GlowStroke.Thickness = 4
GlowStroke.Transparency = 0.6
GlowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
GlowStroke.Parent = Frame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 30)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Kyu's ESP tracer"
Title.TextColor3 = Color3.fromRGB(230, 200, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 10
Title.Active = true
Title.Parent = Frame

-- Drag do painel
do
    local draggingPanel = false
    local dragStart, startPos

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            draggingPanel = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not draggingPanel then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
           or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            draggingPanel = false
        end
    end)
end

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -60, 0, 3)
MinBtn.BackgroundColor3 = Color3.fromRGB(130, 60, 210)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 14
MinBtn.Font = Enum.Font.GothamBold
MinBtn.ZIndex = 10
MinBtn.Parent = Frame
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

local MinStroke = Instance.new("UIStroke")
MinStroke.Color = Color3.fromRGB(170, 80, 255)
MinStroke.Thickness = 1
MinStroke.Transparency = 0.3
MinStroke.Parent = MinBtn

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(190, 40, 90)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 10
CloseBtn.Parent = Frame
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Toggle ESP
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -24, 0, 30)
ToggleBtn.Position = UDim2.new(0, 12, 0, 38)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(130, 60, 210)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "ESP: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.ZIndex = 10
ToggleBtn.Parent = Frame
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(170, 80, 255)
ToggleStroke.Thickness = 1
ToggleStroke.Transparency = 0.3
ToggleStroke.Parent = ToggleBtn

-- Color preview
local ColorPreview = Instance.new("Frame")
ColorPreview.Size = UDim2.new(1, -24, 0, 22)
ColorPreview.Position = UDim2.new(0, 12, 0, 76)
ColorPreview.BackgroundColor3 = Config.Color
ColorPreview.BorderSizePixel = 0
ColorPreview.ZIndex = 10
ColorPreview.Parent = Frame
local ColorPrevCorner = Instance.new("UICorner")
ColorPrevCorner.CornerRadius = UDim.new(0, 6)
ColorPrevCorner.Parent = ColorPreview

local ColorPrevStroke = Instance.new("UIStroke")
ColorPrevStroke.Color = Color3.fromRGB(170, 80, 255)
ColorPrevStroke.Thickness = 1
ColorPrevStroke.Parent = ColorPreview

--------------------------------------------------------------------
-- RGB sliders
--------------------------------------------------------------------
local rgb = {
    R = math.floor(Config.Color.R * 255),
    G = math.floor(Config.Color.G * 255),
    B = math.floor(Config.Color.B * 255),
}

local function applyColor()
    Config.Color = Color3.fromRGB(rgb.R, rgb.G, rgb.B)
    ColorPreview.BackgroundColor3 = Config.Color
end

local ActiveSliderFn = nil

local function makeSlider(name, yPos, channel, initial)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, 14)
    label.Position = UDim2.new(0, 12, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. initial
    label.TextColor3 = Color3.fromRGB(220, 200, 240)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 10
    label.Parent = Frame

    local bar = Instance.new("TextButton")
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.Size = UDim2.new(1, -24, 0, 12)
    bar.Position = UDim2.new(0, 12, 0, yPos + 18)
    bar.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    bar.BorderSizePixel = 0
    bar.ZIndex = 10
    bar.Parent = Frame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initial / 255, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(220, 180, 255)
    fill.BorderSizePixel = 0
    fill.ZIndex = 11
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(initial / 255, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(245, 235, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 12
    knob.Parent = bar

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Color3.fromRGB(170, 80, 255)
    knobStroke.Thickness = 2
    knobStroke.Parent = knob

    local function updateFromX(absX)
        local barX = bar.AbsolutePosition.X
        local barW = bar.AbsoluteSize.X
        local rel = math.clamp(absX - barX, 0, barW)
        local pct = barW > 0 and (rel / barW) or 0
        local val = math.floor(pct * 255 + 0.5)

        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        label.Text = name .. ": " .. val
        rgb[channel] = val
        applyColor()
    end

    bar.MouseButton1Down:Connect(function()
        ActiveSliderFn = updateFromX
        updateFromX(UserInputService:GetMouseLocation().X)
    end)

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            ActiveSliderFn = updateFromX
        end
    end)

    return bar
end

UserInputService.InputChanged:Connect(function(input)
    if not ActiveSliderFn then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch then
        ActiveSliderFn(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        ActiveSliderFn = nil
    end
end)

makeSlider("R", 106, "R", rgb.R)
makeSlider("G", 148, "G", rgb.G)
makeSlider("B", 190, "B", rgb.B)

--------------------------------------------------------------------
-- Minimize logic
--------------------------------------------------------------------
local Minimized = false
local function setMinimized(state)
    Minimized = state
    Frame.Size = Minimized
        and UDim2.new(0, 220, 0, COLLAPSED_HEIGHT)
        or UDim2.new(0, 220, 0, EXPANDED_HEIGHT)
end
MinBtn.MouseButton1Click:Connect(function() setMinimized(not Minimized) end)

--------------------------------------------------------------------
-- Tracer helpers (nome sempre em TextLabel)
--------------------------------------------------------------------
local HAS_DRAWING = (typeof(Drawing) == "table" and Drawing.new ~= nil)
print("[Kyu ESP] Drawing disponível:", HAS_DRAWING)

local function newTracer(playerName)
    local entry = { name = playerName }

    -- ===== Linha: Drawing se disponível, senão Frame =====
    if HAS_DRAWING then
        local okL, line = pcall(function() return Drawing.new("Line") end)
        if okL and line then
            line.Visible = false
            line.Thickness = Config.Thickness
            line.Transparency = Config.Transparency
            line.Color = Config.Color
            entry.line = { obj = line, type = "drawing" }
        end
    end

    if not entry.line then
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Config.Color
        line.BorderSizePixel = 0
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Visible = false
        line.ZIndex = 5
        line.Parent = ScreenGui
        entry.line = { obj = line, type = "frame" }
    end

    -- ===== Nome: SEMPRE TextLabel =====
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Text = playerName
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = Config.NameTextSize
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Size = UDim2.new(0, 200, 0, 20)
    textLabel.AnchorPoint = Vector2.new(0.5, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    textLabel.ZIndex = 10
    textLabel.Visible = false
    textLabel.Parent = ScreenGui
    entry.text = { obj = textLabel, type = "frame" }

    return entry
end

local function updateTracer(entry, from, to)
    if not entry then return end

    -- ===== LINHA =====
    local lt = entry.line
    if lt and lt.obj then
        if lt.type == "drawing" then
            lt.obj.From = from
            lt.obj.To = to
            lt.obj.Color = Config.Color
            lt.obj.Thickness = Config.Thickness
            lt.obj.Transparency = Config.Transparency
            lt.obj.Visible = Config.Enabled
        else
            local delta = to - from
            local center = (from + to) * 0.5
            lt.obj.Position = UDim2.new(0, center.X, 0, center.Y)
            lt.obj.Size = UDim2.new(0, delta.Magnitude, 0, Config.Thickness)
            lt.obj.Rotation = math.deg(math.atan2(delta.Y, delta.X))
            lt.obj.BackgroundColor3 = Config.Color
            lt.obj.BackgroundTransparency = Config.Transparency
            lt.obj.Visible = Config.Enabled
        end
    end

    -- ===== NOME =====
    local tt = entry.text
    if tt and tt.obj then
        if Config.Enabled and Config.ShowNames then
            tt.obj.Position = UDim2.new(0, to.X, 0, to.Y - Config.NameOffsetY)
            tt.obj.Text = entry.name
            tt.obj.Visible = true
        else
            tt.obj.Visible = false
        end
    end
end

local function hideTracer(entry)
    if not entry then return end
    if entry.line and entry.line.obj then entry.line.obj.Visible = false end
    if entry.text and entry.text.obj then entry.text.obj.Visible = false end
end

local function destroyTracer(entry)
    if not entry then return end
    local function kill(t)
        if not t or not t.obj then return end
        if t.type == "drawing" then
            pcall(function() t.obj:Remove() end)
        else
            pcall(function() t.obj:Destroy() end)
        end
    end
    kill(entry.line)
    kill(entry.text)
end

--------------------------------------------------------------------
-- Detecção: é player?
--------------------------------------------------------------------
local function isPlayerCharacter(model)
    if not model then return false, nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then return true, plr end
    end
    local playerVal = model:FindFirstChild("Player")
    if playerVal and playerVal:IsA("ObjectValue") and playerVal.Value and playerVal.Value:IsA("Player") then
        return true, playerVal.Value
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        local humPlayer = hum:FindFirstChild("Player")
        if humPlayer and humPlayer:IsA("ObjectValue") and humPlayer.Value then
            return true, humPlayer.Value
        end
        local attrPlayer = model:GetAttribute("Player")
        if typeof(attrPlayer) == "Instance" and attrPlayer:IsA("Player") then
            return true, attrPlayer
        end
    end
    local nameLower = string.lower(model.Name)
    for _, plr in ipairs(Players:GetPlayers()) do
        if string.lower(plr.Name) == nameLower or string.lower(plr.DisplayName) == nameLower then
            return true, plr
        end
    end
    return false, nil
end

--------------------------------------------------------------------
-- Corpo (Mid)
--------------------------------------------------------------------
local function getBodyPart(model)
    if not model then return nil end
    local detail = model:FindFirstChild("Detail") or model:FindFirstChild("Detail", true)
    if not detail then
        return model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("Torso")
            or model:FindFirstChild("UpperTorso")
    end
    local body = detail:FindFirstChild("Mid")
        or detail:FindFirstChild("Middle")
        or detail:FindFirstChild("Body")
        or detail:FindFirstChild("Torso")
    if body and body:IsA("BasePart") then return body end
    return nil
end

--------------------------------------------------------------------
-- Clamp off-screen
--------------------------------------------------------------------
local function computeScreenTarget(worldPos)
    local vx, vy = Camera.ViewportSize.X, Camera.ViewportSize.Y
    local cx, cy = vx / 2, vy / 2
    local margin = Config.EdgeMargin

    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    local sx, sy = screenPos.X, screenPos.Y
    local behind = screenPos.Z < 0

    if behind then
        sx = vx - sx
        sy = vy - sy
    end

    local offscreen = behind
        or not onScreen
        or sx < margin or sx > vx - margin
        or sy < margin or sy > vy - margin

    if offscreen then
        local dx = sx - cx
        local dy = sy - cy
        if math.abs(dx) < 0.001 and math.abs(dy) < 0.001 then
            dx, dy = 0, 1
        end
        local scaleX = math.abs(dx) > 0.001 and ((cx - margin) / math.abs(dx)) or math.huge
        local scaleY = math.abs(dy) > 0.001 and ((cy - margin) / math.abs(dy)) or math.huge
        local scale = math.min(scaleX, scaleY)
        if scale < 1 then
            sx = cx + dx * scale
            sy = cy + dy * scale
        end
    end

    return Vector2.new(sx, sy), cx, cy
end

--------------------------------------------------------------------
-- Main loop
--------------------------------------------------------------------
local renderConn = RunService.RenderStepped:Connect(function()
    local folder = Workspace:FindFirstChild("Characters")
    if not folder then return end

    for _, model in ipairs(folder:GetChildren()) do
        local isPlayer, plr = isPlayerCharacter(model)

        if not isPlayer then
            if Tracers[model] then
                destroyTracer(Tracers[model])
                Tracers[model] = nil
            end
        elseif Config.SkipSelf and plr == LocalPlayer then
            if Tracers[model] then
                destroyTracer(Tracers[model])
                Tracers[model] = nil
            end
        else
            local bodyPart = getBodyPart(model)
            if not bodyPart then
                if Tracers[model] then
                    destroyTracer(Tracers[model])
                    Tracers[model] = nil
                end
            else
                if not Tracers[model] then
                    local displayName = plr and (plr.DisplayName ~= "" and plr.DisplayName or plr.Name) or model.Name
                    Tracers[model] = newTracer(displayName)
                end
                local t = Tracers[model]
                local dist = (Camera.CFrame.Position - bodyPart.Position).Magnitude

                if Config.Enabled and dist <= Config.MaxDistance then
                    local to, cx, cy = computeScreenTarget(bodyPart.Position)
                    local from = Vector2.new(cx, cy)
                    updateTracer(t, from, to)
                else
                    hideTracer(t)
                end
            end
        end
    end

    for model, t in pairs(Tracers) do
        if not model.Parent then
            destroyTracer(t)
            Tracers[model] = nil
        end
    end
end)

--------------------------------------------------------------------
-- UI handlers
--------------------------------------------------------------------
local function updateToggleUI()
    if Config.Enabled then
        ToggleBtn.Text = "ESP: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(130, 60, 210)
    else
        ToggleBtn.Text = "ESP: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(90, 30, 120)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    updateToggleUI()
end)

local function unload()
    if renderConn then renderConn:Disconnect() renderConn = nil end
    for _, t in pairs(Tracers) do destroyTracer(t) end
    Tracers = {}
    pcall(function() ScreenGui:Destroy() end)
    print("[Kyu ESP] Unloaded.")
end

CloseBtn.MouseButton1Click:Connect(unload)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Frame.Visible = not Frame.Visible
    end
end)

updateToggleUI()
print("[Kyu ESP] Loaded v14 - nomes corrigidos.")
