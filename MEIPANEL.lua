-- cheat by mds | UI clone | Mobile + PC
-- LocalScript in StarterPlayerScripts

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== Palette (screenshot-matched) =====
local BG         = Color3.fromRGB(10, 10, 12)
local Row        = Color3.fromRGB(20, 20, 23)
local RowAlt     = Color3.fromRGB(26, 26, 30)
local Accent     = Color3.fromRGB(255, 45, 105)   -- pink
local AccentSoft = Color3.fromRGB(255, 100, 145)
local AccentDeep = Color3.fromRGB(90, 20, 45)
local TxtHi      = Color3.fromRGB(238, 238, 242)
local TxtDim     = Color3.fromRGB(130, 130, 140)
local TxtFaint   = Color3.fromRGB(85, 85, 95)

-- ===== Asset =====
local IMAGE_ID = "rbxassetid://0" -- << paste your decal id

-- ===== Settings =====
local Settings = {
    AimEnabled   = false,
    ShowFov      = true,
    GodMode      = false,
    AimStrength  = 27,
    FOV          = 7,
    AimTarget    = "Head",
    InfiniteAmmo = false,
    NoReload     = false,
    WallCheck    = true,
    TeamCheck    = true,
    DiscordLink  = "https://discord.gg/CM9maT4GEa",
}

-- ===== Wipe old =====
local old = playerGui:FindFirstChild("MdsUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name           = "MEIUI"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.DisplayOrder   = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = playerGui

-- ===== FOV circle =====
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint            = Vector2.new(0.5, 0.5)
fovCircle.Position               = UDim2.fromScale(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.ZIndex                 = 2
fovCircle.Parent                 = gui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

local fovStroke = Instance.new("UIStroke")
fovStroke.Color        = Accent
fovStroke.Thickness    = 1.6
fovStroke.Transparency = 0.25
fovStroke.Parent       = fovCircle

local fovDot = Instance.new("Frame")
fovDot.AnchorPoint      = Vector2.new(0.5, 0.5)
fovDot.Position         = UDim2.fromScale(0.5, 0.5)
fovDot.Size             = UDim2.fromOffset(3, 3)
fovDot.BackgroundColor3 = Accent
fovDot.BorderSizePixel  = 0
fovDot.ZIndex           = 3
fovDot.Parent           = gui
Instance.new("UICorner", fovDot).CornerRadius = UDim.new(1, 0)

local function updateFov()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp   = cam.ViewportSize
    local maxR = math.min(vp.X, vp.Y) * 0.5
    local r    = math.max(1, maxR * (Settings.FOV / 100))
    fovCircle.Size = UDim2.fromOffset(r * 2, r * 2)
    local show = Settings.AimEnabled and Settings.ShowFov
    fovCircle.Visible = show
    fovDot.Visible    = show
end

local function hookCam()
    local cam = workspace.CurrentCamera
    if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateFov) end
    updateFov()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(hookCam)
hookCam()

-- ===== Main panel =====
local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.fromOffset(370, 470)
main.Position         = UDim2.new(0.5, -185, 0.5, -235)
main.BackgroundColor3 = BG
main.BorderSizePixel  = 0
main.ClipsDescendants = true
main.Parent           = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color        = Color3.fromRGB(40, 40, 46)
mainStroke.Thickness    = 1
mainStroke.Transparency = 0.2
mainStroke.Parent       = main

-- ===== Header =====
local header = Instance.new("Frame")
header.Name             = "Header"
header.Size             = UDim2.new(1, 0, 0, 62)
header.BackgroundTransparency = 1
header.Parent           = main

local title = Instance.new("TextLabel")
title.Position               = UDim2.fromOffset(16, 12)
title.Size                   = UDim2.new(1, -160, 0, 22)
title.BackgroundTransparency = 1
title.Text                   = "cheat by MEI"
title.TextColor3             = Accent
title.TextSize               = 17
title.Font                   = Enum.Font.GothamBold
title.TextXAlignment         = Enum.TextXAlignment.Left
title.Parent                 = header

local sub = Instance.new("TextLabel")
sub.Position               = UDim2.fromOffset(16, 34)
sub.Size                   = UDim2.new(1, -160, 0, 14)
sub.BackgroundTransparency = 1
sub.Text                   = "by mds"
sub.TextColor3             = TxtFaint
sub.TextSize               = 11
sub.Font                   = Enum.Font.Gotham
sub.TextXAlignment         = Enum.TextXAlignment.Left
sub.Parent                 = header

local expiresLbl = Instance.new("TextLabel")
expiresLbl.AnchorPoint         = Vector2.new(1, 0)
expiresLbl.Position            = UDim2.new(1, -70, 0, 12)
expiresLbl.Size                = UDim2.fromOffset(120, 16)
expiresLbl.BackgroundTransparency = 1
expiresLbl.Text                = "Expires at"
expiresLbl.TextColor3          = Accent
expiresLbl.TextSize            = 11
expiresLbl.Font                = Enum.Font.GothamBold
expiresLbl.TextXAlignment      = Enum.TextXAlignment.Right
expiresLbl.Parent              = header

local expiresVal = Instance.new("TextLabel")
expiresVal.AnchorPoint         = Vector2.new(1, 0)
expiresVal.Position            = UDim2.new(1, -70, 0, 28)
expiresVal.Size                = UDim2.fromOffset(120, 16)
expiresVal.BackgroundTransparency = 1
expiresVal.Text                = "Unlimited"
expiresVal.TextColor3          = TxtDim
expiresVal.TextSize            = 11
expiresVal.Font                = Enum.Font.Gotham
expiresVal.TextXAlignment      = Enum.TextXAlignment.Right
expiresVal.Parent              = header

-- small round icon top-right (matches the little circle in the shot)
local headerIcon = Instance.new("Frame")
headerIcon.AnchorPoint      = Vector2.new(1, 0)
headerIcon.Position         = UDim2.new(1, -16, 0, 20)
headerIcon.Size             = UDim2.fromOffset(26, 26)
headerIcon.BackgroundColor3 = RowAlt
headerIcon.BorderSizePixel  = 0
headerIcon.Parent           = header
Instance.new("UICorner", headerIcon).CornerRadius = UDim.new(1, 0)

local iconStroke = Instance.new("UIStroke")
iconStroke.Color        = AccentDeep
iconStroke.Thickness    = 1.5
iconStroke.Parent       = headerIcon

local iconGlyph = Instance.new("TextLabel")
iconGlyph.Size                   = UDim2.fromScale(1, 1)
iconGlyph.BackgroundTransparency = 1
iconGlyph.Text                   = "!"
iconGlyph.TextColor3             = Accent
iconGlyph.TextSize               = 15
iconGlyph.Font                   = Enum.Font.GothamBold
iconGlyph.Parent                 = headerIcon

-- ===== Draggable =====
local function makeDraggable(frame, onTap)
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos, moved = true, input.Position, frame.Position, false
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
            local d = input.Position - dragStart
            if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then moved = true end
            if moved then
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end)
end

-- ===== Floating button =====
local floatBtn = Instance.new("ImageButton")
floatBtn.Name              = "OpenClose"
floatBtn.Size              = UDim2.fromOffset(58, 58)
floatBtn.Position          = UDim2.new(0, 18, 0.5, -29)
floatBtn.BackgroundColor3  = Row
floatBtn.BorderSizePixel   = 0
floatBtn.AutoButtonColor   = false
floatBtn.ZIndex            = 10
floatBtn.Image             = IMAGE_ID
floatBtn.ImageTransparency = 0.05
floatBtn.ScaleType         = Enum.ScaleType.Crop
floatBtn.Parent            = gui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 12)

local floatStroke = Instance.new("UIStroke")
floatStroke.Color     = Accent
floatStroke.Thickness = 1.8
floatStroke.Parent    = floatBtn

local floatFallback = Instance.new("TextLabel")
floatFallback.Size                   = UDim2.fromScale(1, 1)
floatFallback.BackgroundTransparency = 1
floatFallback.Text                   = "MEI"
floatFallback.TextColor3             = Accent
floatFallback.TextSize               = 14
floatFallback.Font                   = Enum.Font.GothamBold
floatFallback.ZIndex                 = 11
floatFallback.Parent                 = floatBtn
floatFallback.Visible = (IMAGE_ID == "" or IMAGE_ID == "rbxassetid://0")

local function togglePanel()
    main.Visible = not main.Visible
end

makeDraggable(floatBtn, togglePanel)
makeDraggable(header, nil)

-- ===== Content scroll =====
local content = Instance.new("ScrollingFrame")
content.Position             = UDim2.fromOffset(10, 70)
content.Size                 = UDim2.new(1, -20, 1, -108)
content.BackgroundTransparency = 1
content.BorderSizePixel      = 0
content.ScrollBarThickness   = 3
content.ScrollBarImageColor3 = Accent
content.AutomaticCanvasSize  = Enum.AutomaticSize.Y
content.CanvasSize           = UDim2.new(0, 0, 0, 0)
content.Parent               = main

local list = Instance.new("UIListLayout")
list.Padding   = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent    = content

local function divider()
    local d = Instance.new("Frame")
    d.Size             = UDim2.new(1, -8, 0, 1)
    d.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    d.BorderSizePixel  = 0
    d.Parent           = content
end

-- ===== Toggle row (screenshot style) =====
local function addToggle(name, desc, key, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -6, 0, 46)
    row.BackgroundColor3 = Row
    row.BorderSizePixel  = 0
    row.Parent           = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(14, 6)
    label.Size                   = UDim2.new(1, -90, 0, 18)
    label.BackgroundTransparency = 1
    label.Text                   = name
    label.TextColor3             = Settings[key] and AccentSoft or TxtHi
    label.TextSize               = 13
    label.Font                   = Enum.Font.GothamMedium
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = row

    local descLbl = Instance.new("TextLabel")
    descLbl.Position               = UDim2.fromOffset(14, 25)
    descLbl.Size                   = UDim2.new(1, -90, 0, 14)
    descLbl.BackgroundTransparency = 1
    descLbl.Text                   = desc or ""
    descLbl.TextColor3             = TxtFaint
    descLbl.TextSize               = 11
    descLbl.Font                   = Enum.Font.Gotham
    descLbl.TextXAlignment         = Enum.TextXAlignment.Left
    descLbl.Parent                 = row

    local check = Instance.new("TextButton")
    check.AnchorPoint      = Vector2.new(1, 0.5)
    check.Position         = UDim2.new(1, -14, 0.5, 0)
    check.Size             = UDim2.fromOffset(28, 28)
    check.BackgroundColor3 = Settings[key] and Accent or RowAlt
    check.Text             = Settings[key] and "✓" or ""
    check.TextColor3       = Color3.fromRGB(255, 255, 255)
    check.TextSize         = 15
    check.Font             = Enum.Font.GothamBold
    check.BorderSizePixel  = 0
    check.AutoButtonColor  = false
    check.Parent           = row
    Instance.new("UICorner", check).CornerRadius = UDim.new(0, 7)

    local stroke = Instance.new("UIStroke")
    stroke.Color        = Settings[key] and AccentSoft or Color3.fromRGB(45, 45, 52)
    stroke.Thickness    = 1
    stroke.Transparency = 0.2
    stroke.Parent       = check

    local hit = Instance.new("TextButton")
    hit.Size                   = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text                   = ""
    hit.ZIndex                 = 2
    hit.Parent                 = row

    local function refresh(anim)
        local on   = Settings[key]
        local info = anim and TweenInfo.new(0.14, Enum.EasingStyle.Quad) or TweenInfo.new(0)
        TweenService:Create(check, info, {
            BackgroundColor3 = on and Accent or RowAlt,
        }):Play()
        TweenService:Create(stroke, info, {
            Color = on and AccentSoft or Color3.fromRGB(45, 45, 52),
        }):Play()
        TweenService:Create(label, info, {
            TextColor3 = on and AccentSoft or TxtHi,
        }):Play()
        check.Text = on and "✓" or ""
    end

    hit.Activated:Connect(function()
        Settings[key] = not Settings[key]
        refresh(true)
        if onChange then onChange(Settings[key]) end
    end)
end

-- ===== Slider row =====
local function addSlider(name, key, min, max, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -6, 0, 52)
    row.BackgroundColor3 = Row
    row.BorderSizePixel  = 0
    row.Parent           = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(14, 8)
    label.Size                   = UDim2.new(1, -70, 0, 18)
    label.BackgroundTransparency = 1
    label.Text                   = name
    label.TextColor3             = TxtHi
    label.TextSize               = 13
    label.Font                   = Enum.Font.GothamMedium
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = row

    local value = Instance.new("TextLabel")
    value.AnchorPoint         = Vector2.new(1, 0)
    value.Position            = UDim2.new(1, -14, 0, 8)
    value.Size                = UDim2.fromOffset(50, 18)
    value.BackgroundTransparency = 1
    value.TextColor3          = TxtDim
    value.TextSize            = 12
    value.Font                = Enum.Font.Gotham
    value.TextXAlignment      = Enum.TextXAlignment.Right
    value.Parent              = row

    local track = Instance.new("TextButton")
    track.Position         = UDim2.fromOffset(14, 34)
    track.Size             = UDim2.new(1, -28, 0, 6)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    track.Text             = ""
    track.AutoButtonColor  = false
    track.Parent           = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Accent
    fill.BorderSizePixel  = 0
    fill.Parent           = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local function update(v, fire)
        Settings[key] = math.clamp(math.floor(v + 0.5), min, max)
        local pct = (Settings[key] - min) / (max - min)
        fill.Size    = UDim2.new(pct, 0, 1, 0)
        value.Text   = tostring(Settings[key])
        if fire and onChange then onChange(Settings[key]) end
    end

    local sliding = false
    local function setFromX(x)
        local w = track.AbsoluteSize.X
        if w <= 0 then return end
        local pct = math.clamp((x - track.AbsolutePosition.X) / w, 0, 1)
        update(min + pct * (max - min), true)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            setFromX(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            setFromX(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    update(Settings[key], false)
end

-- ===== Dropdown row (Aim Target) =====
local aimTargetOptions = {"Head", "Neck", "Chest", "Random"}
local function addDropdown(name, key)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -6, 0, 42)
    row.BackgroundColor3 = Row
    row.BorderSizePixel  = 0
    row.Parent           = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(14, 0)
    label.Size                   = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text                   = name
    label.TextColor3             = TxtHi
    label.TextSize               = 13
    label.Font                   = Enum.Font.GothamMedium
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = row

    local btn = Instance.new("TextButton")
    btn.AnchorPoint      = Vector2.new(1, 0.5)
    btn.Position         = UDim2.new(1, -14, 0.5, 0)
    btn.Size             = UDim2.fromOffset(28, 28)
    btn.BackgroundColor3 = RowAlt
    btn.Text             = "≡"
    btn.TextColor3       = TxtDim
    btn.TextSize         = 15
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Parent           = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    local idx = 1
    for i, v in ipairs(aimTargetOptions) do
        if v == Settings[key] then idx = i end
    end

    btn.Activated:Connect(function()
        idx = (idx % #aimTargetOptions) + 1
        Settings[key] = aimTargetOptions[idx]
        label.Text = name .. "  ·  " .. Settings[key]
    end)
    label.Text = name .. "  ·  " .. Settings[key]
end

-- ===== Build page =====
divider()
addToggle("Aimbot", "Enable soft aimbot", "AimEnabled", function() updateFov() end)
divider()
addToggle("Show FOV", "Draw FOV circle", "ShowFov", function() updateFov() end)
divider()
addToggle("God Mode", "Immune to death", "GodMode")
divider()
addSlider("Aim Strength", "AimStrength", 1, 100)
divider()
addSlider("FOV Size", "FOV", 1, 100, function() updateFov() end)
divider()
addDropdown("Aim Target", "AimTarget")

-- ===== Footer bar =====
local footer = Instance.new("Frame")
footer.AnchorPoint      = Vector2.new(0.5, 1)
footer.Position         = UDim2.new(0.5, 0, 1, -10)
footer.Size             = UDim2.new(1, -20, 0, 28)
footer.BackgroundColor3 = Row
footer.BorderSizePixel  = 0
footer.Parent           = main
Instance.new("UICorner", footer).CornerRadius = UDim.new(1, 0)

local footerText = Instance.new("TextLabel")
footerText.Position               = UDim2.fromOffset(14, 0)
footerText.Size                   = UDim2.new(1, -56, 1, 0)
footerText.BackgroundTransparency = 1
footerText.Text                   = "mds  |  FPS: --  |  PING: --"
footerText.TextColor3             = Accent
footerText.TextSize               = 12
footerText.Font                   = Enum.Font.GothamMedium
footerText.TextXAlignment         = Enum.TextXAlignment.Left
footerText.Parent                 = footer

local footerIcon = Instance.new("TextLabel")
footerIcon.AnchorPoint         = Vector2.new(1, 0.5)
footerIcon.Pocon.BackgroundTransparency = 1
footerIcon.Text                = "≡"
footerIcon.TextColor3          = TxtDim
footerIcon.TextSize            = 15
footerIcon.Font                = Enum.Font.GothamBold
footerIcon.Parent              = footer

-- ===== Live FPS / PING =====
local smoothedFps = 60
RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then smoothedFps = smoothedFps * 0.9 + (1 / dt) * 0.1 end
end)

task.spawn(function()
    while gui.Parent do
        local pingMs = 0
        local ok = pcall(function()
            pingMs = math.floor(player:GetNetworkPing() * 1000 + 0.5)
        end)
        footerText.Text = string.format(
            "mds  |  FPS: %d  |  PING: %d",
            math.floor(smoothedFps + 0.5),
            pingMs
        )
        task.wait(0.5)
    end
end)

updateFov()
print("[MdsUI] loaded")
