-- SHADOW PURSUIT | PURPLE EDITION v2.1
-- UI + FOV circle demo | Mobile + PC
-- LocalScript in StarterPlayerScripts

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== Palette =====
local Purple       = Color3.fromRGB(145, 65, 220)
local PurpleBright = Color3.fromRGB(185, 110, 255)
local PurpleDeep   = Color3.fromRGB(72, 30, 120)
local DarkPurple   = Color3.fromRGB(30, 16, 46)
local PanelColor   = Color3.fromRGB(18, 11, 28)
local RowColor     = Color3.fromRGB(32, 20, 48)
local TextColor    = Color3.fromRGB(245, 238, 255)
local TextDim      = Color3.fromRGB(160, 150, 185)
local OffGrey      = Color3.fromRGB(60, 48, 78)

-- ===== Asset =====
local IMAGE_ID = "rbxassetid://0" -- << paste your uploaded decal id here

-- ===== Settings =====
local Settings = {
    AimEnabled   = false,
    WallCheck    = true,
    KillCheck    = false,
    TeamCheck    = true,
    ShowFov      = true,
    GodMode      = false,
    InfiniteAmmo = false,
    NoReload     = false,
    FOV          = 25,       -- 1..100 percent of half-viewport-min
    Sensitivity  = 50,
    DiscordLink  = "https://discord.gg/CM9maT4GEa",
}

-- ===== Wipe old =====
local oldGui = playerGui:FindFirstChild("ShadowUI")
if oldGui then oldGui:Destroy() end

-- ===== Root =====
local gui = Instance.new("ScreenGui")
gui.Name           = "ShadowUI"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.DisplayOrder   = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = playerGui

-- ===== FOV circle =====
local fovCircle = Instance.new("Frame")
fovCircle.Name                   = "FovCircle"
fovCircle.AnchorPoint            = Vector2.new(0.5, 0.5)
fovCircle.Position               = UDim2.fromScale(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.ZIndex                 = 2
fovCircle.Parent                 = gui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

local fovStroke = Instance.new("UIStroke")
fovStroke.Color        = PurpleBright
fovStroke.Thickness    = 1.8
fovStroke.Transparency = 0.15
fovStroke.Parent       = fovCircle

local fovGlow = Instance.new("Frame")
fovGlow.Name                   = "Glow"
fovGlow.AnchorPoint            = Vector2.new(0.5, 0.5)
fovGlow.Position               = UDim2.fromScale(0.5, 0.5)
fovGlow.BackgroundColor3       = Purple
fovGlow.BackgroundTransparency = 0.92
fovGlow.Size                   = UDim2.fromOffset(0, 0)
fovGlow.ZIndex                 = 1
fovGlow.Parent                 = gui
Instance.new("UICorner", fovGlow).CornerRadius = UDim.new(1, 0)

local dot = Instance.new("Frame")
dot.AnchorPoint      = Vector2.new(0.5, 0.5)
dot.Position         = UDim2.fromScale(0.5, 0.5)
dot.Size             = UDim2.fromOffset(4, 4)
dot.BackgroundColor3 = PurpleBright
dot.BorderSizePixel  = 0
dot.ZIndex           = 3
dot.Visible          = false
dot.Parent           = gui
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

local function updateFovCircle()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp   = cam.ViewportSize
    local maxR = math.min(vp.X, vp.Y) * 0.5
    local r    = math.max(1, maxR * (Settings.FOV / 100))

    fovCircle.Size = UDim2.fromOffset(r * 2, r * 2)
    fovGlow.Size   = UDim2.fromOffset(r * 2 + 18, r * 2 + 18)

    fovCircle.Visible = Settings.AimEnabled and Settings.ShowFov
    fovGlow.Visible   = fovCircle.Visible
    dot.Visible       = fovCircle.Visible
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    local cam = workspace.CurrentCamera
    if cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateFovCircle)
    end
    updateFovCircle()
end)
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateFovCircle)
end

-- ===== Main panel =====
local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.fromOffset(360, 460)
main.Position         = UDim2.new(0.5, -180, 0.5, -230)
main.BackgroundColor3 = PanelColor
main.BorderSizePixel  = 0
main.ClipsDescendants = true
main.Parent           = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color        = Purple
mainStroke.Thickness    = 1.5
mainStroke.Transparency = 0.35
mainStroke.Parent       = main

-- ===== Floating open button (image) =====
local floatButton = Instance.new("ImageButton")
floatButton.Name              = "OpenCloseButton"
floatButton.Size              = UDim2.fromOffset(64, 64)
floatButton.Position          = UDim2.new(0, 18, 0.5, -32)
floatButton.BackgroundColor3  = DarkPurple
floatButton.BorderSizePixel   = 0
floatButton.AutoButtonColor   = false
floatButton.ZIndex            = 10
floatButton.Image             = IMAGE_ID
floatButton.ImageTransparency = 0.05
floatButton.ScaleType         = Enum.ScaleType.Crop
floatButton.Parent            = gui
Instance.new("UICorner", floatButton).CornerRadius = UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke")
floatStroke.Color        = PurpleBright
floatStroke.Thickness    = 2
floatStroke.Transparency = 0.1
floatStroke.Parent       = floatButton

-- fallback text when the id is unset / fails
local floatFallback = Instance.new("TextLabel")
floatFallback.Size                   = UDim2.fromScale(1, 1)
floatFallback.BackgroundTransparency = 1
floatFallback.Text                   = "SH"
floatFallback.TextColor3             = TextColor
floatFallback.TextSize               = 20
floatFallback.Font                   = Enum.Font.GothamBold
floatFallback.ZIndex                 = 11
floatFallback.Parent                 = floatButton
floatFallback.Visible = (IMAGE_ID == "" or IMAGE_ID == "rbxassetid://0")

-- ===== Header =====
local header = Instance.new("Frame")
header.Name             = "Header"
header.Size             = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = DarkPurple
header.BorderSizePixel  = 0
header.Parent           = main

local headerGrad = Instance.new("UIGradient")
headerGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 25, 90)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 14, 40)),
}
headerGrad.Rotation = 90
headerGrad.Parent   = header

local title = Instance.new("TextLabel")
title.Size                   = UDim2.new(1, -125, 1, 0)
title.Position               = UDim2.fromOffset(16, 0)
title.BackgroundTransparency = 1
title.Text                   = "SHADOW PURSUIT"
title.TextColor3             = TextColor
title.TextSize               = 17
title.Font                   = Enum.Font.GothamBold
title.TextXAlignment         = Enum.TextXAlignment.Left
title.Parent                 = header

local subtitle = Instance.new("TextLabel")
subtitle.Size                   = UDim2.new(1, -125, 0, 12)
subtitle.Position               = UDim2.fromOffset(16, 34)
subtitle.BackgroundTransparency = 1
subtitle.Text                   = "PURPLE EDITION"
subtitle.TextColor3             = PurpleBright
subtitle.TextSize               = 10
subtitle.Font                   = Enum.Font.GothamBold
subtitle.TextXAlignment         = Enum.TextXAlignment.Left
subtitle.Parent                 = header

local closeButton = Instance.new("TextButton")
closeButton.Size             = UDim2.fromOffset(30, 30)
closeButton.Position         = UDim2.new(1, -42, 0, 11)
closeButton.BackgroundColor3 = Color3.fromRGB(80, 35, 100)
closeButton.Text             = "✕"
closeButton.TextColor3       = TextColor
closeButton.TextSize         = 16
closeButton.Font             = Enum.Font.GothamBold
closeButton.BorderSizePixel  = 0
closeButton.AutoButtonColor  = true
closeButton.Parent           = header
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 7)

-- ===== Draggable =====
local function makeDraggable(frame, onTap)
    local dragging, dragStart, startPos, moved = false, nil, nil, false

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            moved     = false

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and onTap then onTap() end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
                moved = true
            end
            if moved then
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end

local function togglePanel()
    main.Visible = not main.Visible
    local t = TweenService:Create(floatButton, TweenInfo.new(0.12, Enum.EasingStyle.Back), {
        Size = main.Visible and UDim2.fromOffset(70, 70) or UDim2.fromOffset(64, 64)
    })
    t:Play()
    t.Completed:Wait()
    TweenService:Create(floatButton, TweenInfo.new(0.1), {
        Size = UDim2.fromOffset(64, 64)
    }):Play()
end

makeDraggable(floatButton, togglePanel)
makeDraggable(header, nil)

closeButton.Activated:Connect(function()
    main.Visible = false
end)

-- ===== Tabs =====
local tabBar = Instance.new("Frame")
tabBar.Position         = UDim2.fromOffset(12, 62)
tabBar.Size             = UDim2.new(1, -24, 0, 36)
tabBar.BackgroundColor3 = Color3.fromRGB(26, 16, 40)
tabBar.BorderSizePixel  = 0
tabBar.Parent           = main
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 9)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding       = UDim.new(0, 4)
tabLayout.Parent        = tabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft   = UDim.new(0, 4)
tabPad.PaddingRight  = UDim.new(0, 4)
tabPad.PaddingTop    = UDim.new(0, 4)
tabPad.PaddingBottom = UDim.new(0, 4)
tabPad.Parent        = tabBar

local tabs = {}

local function makeTab(name)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0.5, -4, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(32, 20, 48)
    btn.Text             = name
    btn.TextColor3       = TextDim
    btn.TextSize         = 13
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Parent           = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    tabs[name] = btn
    return btn
end

local function setActiveTab(name)
    for n, b in pairs(tabs) do
        local on = (n == name)
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Purple or Color3.fromRGB(32, 20, 48),
            TextColor3       = on and TextColor or TextDim,
        }):Play()
    end
end

-- ===== Content =====
local content = Instance.new("ScrollingFrame")
content.Position             = UDim2.fromOffset(12, 110)
content.Size                 = UDim2.new(1, -24, 1, -122)
content.BackgroundTransparency = 1
content.BorderSizePixel      = 0
content.ScrollBarThickness   = 4
content.ScrollBarImageColor3 = Purple
content.AutomaticCanvasSize  = Enum.AutomaticSize.Y
content.CanvasSize           = UDim2.new(0, 0, 0, 0)
content.Parent               = main

local layout = Instance.new("UIListLayout")
layout.Padding   = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent    = content

local function clearContent()
    for _, c in ipairs(content:GetChildren()) do
        if c ~= layout then c:Destroy() end
    end
end

-- ===== Toggle =====
local function addToggle(text, key, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -4, 0, 42)
    row.BackgroundColor3 = RowColor
    row.BorderSizePixel  = 0
    row.Parent           = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(14, 0)
    label.Size                   = UDim2.new(1, -100, 1, 0)
    label.BackgroundTransparency = 1
    label.Text                   = text
    label.TextColor3             = TextColor
    label.TextSize               = 13
    label.Font                   = Enum.Font.Gotham
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = row

    local track = Instance.new("Frame")
    track.Size             = UDim2.fromOffset(50, 26)
    track.Position         = UDim2.new(1, -62, 0.5, -13)
    track.BackgroundColor3 = Settings[key] and Purple or OffGrey
    track.BorderSizePixel  = 0
    track.Parent           = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.fromOffset(20, 20)
    knob.Position         = Settings[key]
        and UDim2.new(1, -23, 0.5, -10)
        or  UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    knob.Parent           = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                   = ""
    btn.ZIndex                 = 2
    btn.Parent                 = row

    local function refresh(animate)
        local on   = Settings[key]
        local info = animate and TweenInfo.new(0.16, Enum.EasingStyle.Quad) or TweenInfo.new(0)
        TweenService:Create(track, info, {
            BackgroundColor3 = on and Purple or OffGrey,
        }):Play()
        TweenService:Create(knob, info, {
            Position = on
                and UDim2.new(1, -23, 0.5, -10)
                or  UDim2.new(0, 3, 0.5, -10),
        }):Play()
    end

    refresh(false)

    btn.Activated:Connect(function()
        Settings[key] = not Settings[key]
        refresh(true)
        if onChange then onChange(Settings[key]) end
    end)
end

-- ===== Slider =====
local function addSlider(text, key, min, max, onChange)
    local frame = Instance.new("Frame")
    frame.Size             = UDim2.new(1, -4, 0, 62)
    frame.BackgroundColor3 = RowColor
    frame.BorderSizePixel  = 0
    frame.Parent           = content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(14, 4)
    label.Size                   = UDim2.new(1, -28, 0, 22)
    label.BackgroundTransparency = 1
    label.TextColor3             = TextColor
    label.TextSize               = 13
    label.Font                   = Enum.Font.Gotham
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = frame

    local valueTag = Instance.new("TextLabel")
    valueTag.AnchorPoint         = Vector2.new(1, 0)
    valueTag.Position            = UDim2.new(1, -14, 0, 4)
    valueTag.Size                = UDim2.fromOffset(60, 22)
    valueTag.BackgroundTransparency = 1
    valueTag.TextColor3          = PurpleBright
    valueTag.TextSize            = 13
    valueTag.Font                = Enum.Font.GothamBold
    valueTag.TextXAlignment      = Enum.TextXAlignment.Right
    valueTag.Parent              = frame

    local slider = Instance.new("TextButton")
    slider.Position         = UDim2.fromOffset(14, 34)
    slider.Size             = UDim2.new(1, -28, 0, 14)
    slider.BackgroundColor3 = Color3.fromRGB(55, 40, 72)
    slider.Text             = ""
    slider.AutoButtonColor  = false
    slider.Parent           = frame
    Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Purple
    fill.BorderSizePixel  = 0
    fill.Parent           = slider
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Purple),
        ColorSequenceKeypoint.new(1, PurpleBright),
    }
    fillGrad.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.AnchorPoint      = Vector2.new(0.5, 0.5)
    thumb.Size             = UDim2.fromOffset(16, 16)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel  = 0
    thumb.ZIndex           = 2
    thumb.Parent           = slider
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local function update(value, fire)
        Settings[key] = math.clamp(math.floor(value + 0.5), min, max)
        local pct = (Settings[key] - min) / (max - min)
        fill.Size      = UDim2.new(pct, 0, 1, 0)
        thumb.Position = UDim2.new(pct, 0, 0.5, 0)
        label.Text     = text
        valueTag.Text  = tostring(Settings[key]) .. "%"
        if fire and onChange then onChange(Settings[key]) end
    end

    local sliding = false

    local function setFromX(x)
        local w = slider.AbsoluteSize.X
        if w <= 0 then return end
        local pct = math.clamp((x - slider.AbsolutePosition.X) / w, 0, 1)
        update(min + pct * (max - min), true)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    update(Settings[key], false)
end

local function addInfo(text)
    local info = Instance.new("TextLabel")
    info.Size             = UDim2.new(1, -4, 0, 44)
    info.BackgroundColor3 = RowColor
    info.TextColor3       = TextDim
    info.TextWrapped      = true
    info.TextSize         = 11
    info.Font             = Enum.Font.Gotham
    info.Text             = text
    info.Parent           = content
    Instance.new("UICorner", info).CornerRadius = UDim.new(0, 8)
end

local function addAction(text, fn)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, -4, 0, 40)
    btn.BackgroundColor3 = PurpleDeep
    btn.Text             = text
    btn.TextColor3       = TextColor
    btn.TextSize         = 13
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = true
    btn.Parent           = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.Activated:Connect(fn)
end

-- ===== Pages =====
local function showCombat()
    clearContent()
    addToggle("Aimbot", "AimEnabled", function() updateFovCircle() end)
    addSlider("FOV Size", "FOV", 1, 100, function() updateFovCircle() end)
    addToggle("Show FOV Circle", "ShowFov", function() updateFovCircle() end)
    addToggle("Wall Check", "WallCheck")
    addToggle("Kill Check", "KillCheck")
    addToggle("Team Check", "TeamCheck")
    addSlider("Aim Sensitivity", "Sensitivity", 1, 100)
end

local function showMisc()
    clearContent()
    addToggle("God Mode", "GodMode")
    addToggle("Infinite Ammo", "InfiniteAmmo")
    addToggle("No Reload", "NoReload")
    addAction("Copy Discord Link", function()
        local ok = pcall(function() setclipboard(Settings.DiscordLink) end)
        print(ok and "Copied: " .. Settings.DiscordLink or Settings.DiscordLink)
    end)
    addInfo("UI + FOV demo. Gameplay hooks are stubs — wire them to your own logic.")
end

-- ===== Wire tabs =====
local combatTab = makeTab("Combat")
local miscTab   = makeTab("Misc")

combatTab.Activated:Connect(function()
    setActiveTab("Combat"); showCombat()
end)
miscTab.Activated:Connect(function()
    setActiveTab("Misc"); showMisc()
end)

setActiveTab("Combat")
showCombat()
updateFovCircle()

print("[ShadowUI] loaded")
