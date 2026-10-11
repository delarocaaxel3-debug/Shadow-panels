-- MEI PANEL | PURPLE EDITION | KEY GATE
-- UI + FOV circle | Mobile + PC
-- LocalScript in StarterPlayerScripts

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== Palette (purple, original) =====
local BG         = Color3.fromRGB(18, 11, 28)
local Row        = Color3.fromRGB(32, 20, 48)
local RowAlt     = Color3.fromRGB(44, 28, 68)
local Accent     = Color3.fromRGB(145, 65, 220)
local AccentSoft = Color3.fromRGB(185, 110, 255)
local AccentDeep = Color3.fromRGB(72, 30, 120)
local TxtHi      = Color3.fromRGB(245, 238, 255)
local TxtDim     = Color3.fromRGB(160, 150, 185)
local TxtFaint   = Color3.fromRGB(120, 112, 145)
local Bad        = Color3.fromRGB(230, 70, 90)

-- ===== Asset =====
local IMAGE_ID = "rbxassetid://0" -- << paste your decal id

-- ===== Key system =====
local KEY_LIST = {
    ["MEI-OFFICIAL"]   = true,
    ["MEI-VIP"]    = true,
    ["KABU-OFFICIAL"] = true,
    -- add keys here
}
local KEY_FILE    = "MeiUI/key.txt"
local DISCORD_URL = "https://discord.gg/CM9maT4GEa"

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
    DiscordLink  = DISCORD_URL,
}

-- ===== Wipe old =====
local old = playerGui:FindFirstChild("MeiUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name           = "MeiUI"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.DisplayOrder   = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = playerGui

-- ===== File IO =====
local hasFileIO = false
pcall(function()
    hasFileIO = type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end)

local function loadSavedKey()
    if not hasFileIO then return nil end
    local ok, data = pcall(function()
        if isfile(KEY_FILE) then return readfile(KEY_FILE) end
    end)
    if ok and type(data) == "string" then
        return (data:gsub("%s+", ""))
    end
    return nil
end

local function saveKey(key)
    if not hasFileIO then return end
    pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" then
            if not isfolder("MeiUI") then makefolder("MeiUI") end
        end
        writefile(KEY_FILE, key)
    end)
end

local function isValidKey(key)
    if type(key) ~= "string" then return false end
    return KEY_LIST[key:upper()] == true
end

-- ===== FOV circle =====
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint            = Vector2.new(0.5, 0.5)
fovCircle.Position               = UDim2.fromScale(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.ZIndex                 = 2
fovCircle.Visible                = false
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
fovDot.Visible          = false
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
    if cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateFov)
    end
    updateFov()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(hookCam)
hookCam()

-- ===== Draggable (rebuilt: UserInputService.InputEnded for release) =====
local function makeDraggable(frame, onTap)
    local dragging, dragStart, startPos, moved = false, nil, nil, false

    frame.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        dragging  = true
        dragStart = input.Position
        startPos  = frame.Position
        moved     = false
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local d = input.Position - dragStart
        if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then
            moved = true
        end
        if moved then
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        dragging = false
        if not moved and onTap then
            onTap()
        end
    end)
end

-- =====================================================================
-- KEY GATE
-- =====================================================================
local keyFrame = Instance.new("Frame")
keyFrame.Name             = "KeyGate"
keyFrame.Size             = UDim2.fromOffset(340, 300)
keyFrame.Position         = UDim2.new(0.5, -170, 0.5, -150)
keyFrame.BackgroundColor3 = BG
keyFrame.BorderSizePixel  = 0
keyFrame.ZIndex           = 50
keyFrame.Parent           = gui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 12)

local keyStroke = Instance.new("UIStroke")
keyStroke.Color        = Accent
keyStroke.Thickness    = 1.4
keyStroke.Transparency = 0.25
keyStroke.Parent       = keyFrame

local keyHeader = Instance.new("Frame")
keyHeader.Size             = UDim2.new(1, 0, 0, 52)
keyHeader.BackgroundColor3 = Row
keyHeader.BorderSizePixel  = 0
keyHeader.ZIndex           = 51
keyHeader.Parent           = keyFrame
Instance.new("UICorner", keyHeader).CornerRadius = UDim.new(0, 12)

local keyHeaderMask = Instance.new("Frame")
keyHeaderMask.Size             = UDim2.new(1, 0, 0, 14)
keyHeaderMask.Position         = UDim2.new(0, 0, 1, -14)
keyHeaderMask.BackgroundColor3 = Row
keyHeaderMask.BorderSizePixel  = 0
keyHeaderMask.ZIndex           = 51
keyHeaderMask.Parent           = keyHeader

local keyTitle = Instance.new("TextLabel")
keyTitle.Position               = UDim2.fromOffset(16, 0)
keyTitle.Size                   = UDim2.new(1, -32, 1, 0)
keyTitle.BackgroundTransparency = 1
keyTitle.Text                   = "MEI  ·  KEY SYSTEM"
keyTitle.TextColor3             = Accent
keyTitle.TextSize               = 15
keyTitle.Font                   = Enum.Font.GothamBold
keyTitle.TextXAlignment         = Enum.TextXAlignment.Left
keyTitle.ZIndex                 = 52
keyTitle.Parent                 = keyHeader

local keyDesc = Instance.new("TextLabel")
keyDesc.Position               = UDim2.fromOffset(20, 64)
keyDesc.Size                   = UDim2.new(1, -40, 0, 30)
keyDesc.BackgroundTransparency = 1
keyDesc.Text                   = "Enter your key to unlock the panel."
keyDesc.TextColor3             = TxtDim
keyDesc.TextSize               = 12
keyDesc.Font                   = Enum.Font.Gotham
keyDesc.TextWrapped            = true
keyDesc.TextXAlignment         = Enum.TextXAlignment.Left
keyDesc.ZIndex                 = 52
keyDesc.Parent                 = keyFrame

local keyBox = Instance.new("TextBox")
keyBox.Position               = UDim2.fromOffset(20, 100)
keyBox.Size                   = UDim2.new(1, -40, 0, 40)
keyBox.BackgroundColor3       = Row
keyBox.BorderSizePixel        = 0
keyBox.Text                   = ""
keyBox.PlaceholderText        = "MEI-XXXX"
keyBox.PlaceholderColor3      = TxtFaint
keyBox.TextColor3             = TxtHi
keyBox.TextSize               = 14
keyBox.Font                   = Enum.Font.GothamMedium
keyBox.ClearTextOnFocus       = false
keyBox.TextXAlignment         = Enum.TextXAlignment.Left
keyBox.ZIndex                 = 52
keyBox.Parent                 = keyFrame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

local keyBoxPad = Instance.new("UIPadding")
keyBoxPad.PaddingLeft  = UDim.new(0, 12)
keyBoxPad.PaddingRight = UDim.new(0, 12)
keyBoxPad.Parent       = keyBox

local keyBoxStroke = Instance.new("UIStroke")
keyBoxStroke.Color        = AccentDeep
keyBoxStroke.Thickness    = 1
keyBoxStroke.Transparency = 0.3
keyBoxStroke.Parent       = keyBox

local keyErr = Instance.new("TextLabel")
keyErr.Position               = UDim2.fromOffset(20, 144)
keyErr.Size                   = UDim2.new(1, -40, 0, 16)
keyErr.BackgroundTransparency = 1
keyErr.Text                   = ""
keyErr.TextColor3             = Bad
keyErr.TextSize               = 11
keyErr.Font                   = Enum.Font.Gotham
keyErr.TextXAlignment         = Enum.TextXAlignment.Left
keyErr.ZIndex                 = 52
keyErr.Parent                 = keyFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Position         = UDim2.fromOffset(20, 168)
submitBtn.Size             = UDim2.new(1, -40, 0, 40)
submitBtn.BackgroundColor3 = Accent
submitBtn.Text             = "UNLOCK"
submitBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
submitBtn.TextSize         = 14
submitBtn.Font             = Enum.Font.GothamBold
submitBtn.BorderSizePixel  = 0
submitBtn.AutoButtonColor  = false
submitBtn.ZIndex           = 52
submitBtn.Parent           = keyFrame
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 8)

local submitStroke = Instance.new("UIStroke")
submitStroke.Color        = AccentSoft
submitStroke.Thickness    = 1
submitStroke.Transparency = 0.2
submitStroke.Parent       = submitBtn

-- Get Key button
local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Position         = UDim2.fromOffset(20, 216)
getKeyBtn.Size             = UDim2.new(1, -40, 0, 40)
getKeyBtn.BackgroundColor3 = RowAlt
getKeyBtn.Text             = "GET KEY  ·  DISCORD"
getKeyBtn.TextColor3       = AccentSoft
getKeyBtn.TextSize         = 13
getKeyBtn.Font             = Enum.Font.GothamBold
getKeyBtn.BorderSizePixel  = 0
getKeyBtn.AutoButtonColor  = false
getKeyBtn.ZIndex           = 52
getKeyBtn.Parent           = keyFrame
Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)

local getKeyStroke = Instance.new("UIStroke")
getKeyStroke.Color        = AccentDeep
getKeyStroke.Thickness    = 1
getKeyStroke.Transparency = 0.3
getKeyStroke.Parent       = getKeyBtn

local keyHint = Instance.new("TextLabel")
keyHint.Position               = UDim2.fromOffset(20, 262)
keyHint.Size                   = UDim2.new(1, -40, 0, 16)
keyHint.BackgroundTransparency = 1
keyHint.Text                   = "Tap to copy link  ·  enter key to unlock"
keyHint.TextColor3             = TxtFaint
keyHint.TextSize               = 10
keyHint.Font                   = Enum.Font.Gotham
keyHint.TextXAlignment         = Enum.TextXAlignment.Center
keyHint.ZIndex                 = 52
keyHint.Parent                 = keyFrame

-- drag the header and the frame
makeDraggable(keyHeader, nil)
makeDraggable(keyFrame, nil)

-- =====================================================================
-- MAIN PANEL
-- =====================================================================
local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.fromOffset(380, 480)
main.Position         = UDim2.new(0.5, -190, 0.5, -240)
main.BackgroundColor3 = BG
main.BorderSizePixel  = 0
main.ClipsDescendants = true
main.Visible          = false
main.Parent           = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color        = AccentDeep
mainStroke.Thickness    = 1
mainStroke.Transparency = 0.35
mainStroke.Parent       = main

local header = Instance.new("Frame")
header.Name                   = "Header"
header.Size                   = UDim2.new(1, 0, 0, 60)
header.BackgroundTransparency = 1
header.Parent                 = main

local title = Instance.new("TextLabel")
title.Position               = UDim2.fromOffset(16, 12)
title.Size                   = UDim2.new(1, -160, 0, 22)
title.BackgroundTransparency = 1
title.Text                   = "MEI"
title.TextColor3             = Accent
title.TextSize               = 17
title.Font                   = Enum.Font.GothamBold
title.TextXAlignment         = Enum.TextXAlignment.Left
title.Parent                 = header

local sub = Instance.new("TextLabel")
sub.Position               = UDim2.fromOffset(16, 34)
sub.Size                   = UDim2.new(1, -160, 0, 14)
sub.BackgroundTransparency = 1
sub.Text                   = "by MEI"
sub.TextColor3             = TxtFaint
sub.TextSize               = 11
sub.Font                   = Enum.Font.Gotham
sub.TextXAlignment         = Enum.TextXAlignment.Left
sub.Parent                 = header

local expiresLbl = Instance.new("TextLabel")
expiresLbl.AnchorPoint            = Vector2.new(1, 0)
expiresLbl.Position               = UDim2.new(1, -70, 0, 12)
expiresLbl.Size                   = UDim2.fromOffset(120, 16)
expiresLbl.BackgroundTransparency = 1
expiresLbl.Text                   = "Expires at"
expiresLbl.TextColor3             = Accent
expiresLbl.TextSize               = 11
expiresLbl.Font                   = Enum.Font.GothamBold
expiresLbl.TextXAlignment         = Enum.TextXAlignment.Right
expiresLbl.Parent                 = header

local expiresVal = Instance.new("TextLabel")
expiresVal.AnchorPoint            = Vector2.new(1, 0)
expiresVal.Position               = UDim2.new(1, -70, 0, 28)
expiresVal.Size                   = UDim2.fromOffset(120, 16)
expiresVal.BackgroundTransparency = 1
expiresVal.Text                   = "Unlimited"
expiresVal.TextColor3             = TxtDim
expiresVal.TextSize               = 11
expiresVal.Font                   = Enum.Font.Gotham
expiresVal.TextXAlignment         = Enum.TextXAlignment.Right
expiresVal.Parent                 = header

local headerIcon = Instance.new("Frame")
headerIcon.AnchorPoint      = Vector2.new(1, 0)
headerIcon.Position         = UDim2.new(1, -16, 0, 20)
headerIcon.Size             = UDim2.fromOffset(26, 26)
headerIcon.BackgroundColor3 = RowAlt
headerIcon.BorderSizePixel  = 0
headerIcon.Parent           = header
Instance.new("UICorner", headerIcon).CornerRadius = UDim.new(1, 0)

local iconStroke = Instance.new("UIStroke")
iconStroke.Color     = Accent
iconStroke.Thickness = 1.5
iconStroke.Parent    = headerIcon

local iconGlyph = Instance.new("TextLabel")
iconGlyph.Size                   = UDim2.fromScale(1, 1)
iconGlyph.BackgroundTransparency = 1
iconGlyph.Text                   = "!"
iconGlyph.TextColor3             = Accent
iconGlyph.TextSize               = 15
iconGlyph.Font                   = Enum.Font.GothamBold
iconGlyph.Parent                 = headerIcon

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
floatBtn.Visible           = false
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

-- ===== Content =====
local content = Instance.new("ScrollingFrame")
content.Position               = UDim2.fromOffset(10, 68)
content.Size                   = UDim2.new(1, -20, 1, -106)
content.BackgroundTransparency = 1
content.BorderSizePixel        = 0
content.ScrollBarThickness     = 3
content.ScrollBarImageColor3   = Accent
content.AutomaticCanvasSize    = Enum.AutomaticSize.Y
content.CanvasSize             = UDim2.new(0, 0, 0, 0)
content.Parent                 = main

local list = Instance.new("UIListLayout")
list.Padding   = UDim.new(0, 5)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent    = content

local function divider()
    local d = Instance.new("Frame")
    d.Size             = UDim2.new(1, -8, 0, 1)
    d.BackgroundColor3 = Color3.fromRGB(48, 34, 68)
    d.BorderSizePixel  = 0
    d.Parent           = content
end

local function addToggle(name, desc, key, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -6, 0, 44)
    row.BackgroundColor3 = Row
    row.BorderSizePixel  = 0
    row.Parent           = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(14, 5)
    label.Size                   = UDim2.new(1, -90, 0, 17)
    label.BackgroundTransparency = 1
    label.Text                   = name
    label.TextColor3             = Settings[key] and AccentSoft or TxtHi
    label.TextSize               = 13
    label.Font                   = Enum.Font.GothamMedium
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = row

    local descLbl = Instance.new("TextLabel")
    descLbl.Position               = UDim2.fromOffset(14, 23)
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
    check.Size             = UDim2.fromOffset(26, 26)
    check.BackgroundColor3 = Settings[key] and Accent or RowAlt
    check.Text             = Settings[key] and "✓" or ""
    check.TextColor3       = Color3.fromRGB(255, 255, 255)
    check.TextSize         = 14
    check.Font             = Enum.Font.GothamBold
    check.BorderSizePixel  = 0
    check.AutoButtonColor  = false
    check.ZIndex           = 2
    check.Parent           = row
    Instance.new("UICorner", check).CornerRadius = UDim.new(0, 7)

    local stroke = Instance.new("UIStroke")
    stroke.Color        = Settings[key] and AccentSoft or Color3.fromRGB(58, 42, 80)
    stroke.Thickness    = 1
    stroke.Transparency = 0.2
    stroke.Parent       = check

    local hit = Instance.new("TextButton")
    hit.Size                   = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text                   = ""
    hit.ZIndex                 = 3
    hit.Parent                 = row

    local function refresh(anim)
        local on   = Settings[key]
        local info = anim and TweenInfo.new(0.14, Enum.EasingStyle.Quad) or TweenInfo.new(0)
        TweenService:Create(check, info, { BackgroundColor3 = on and Accent or RowAlt }):Play()
        TweenService:Create(stroke, info, { Color = on and AccentSoft or Color3.fromRGB(58, 42, 80) }):Play()
        TweenService:Create(label, info, { TextColor3 = on and AccentSoft or TxtHi }):Play()
        check.Text = on and "✓" or ""
    end

    hit.Activated:Connect(function()
        Settings[key] = not Settings[key]
        refresh(true)
        if onChange then onChange(Settings[key]) end
    end)
end

local function addSlider(name, key, min, max, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -6, 0, 48)
    row.BackgroundColor3 = Row
    row.BorderSizePixel  = 0
    row.Parent           = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(14, 7)
    label.Size                   = UDim2.new(1, -70, 0, 17)
    label.BackgroundTransparency = 1
    label.Text                   = name
    label.TextColor3             = TxtHi
    label.TextSize               = 13
    label.Font                   = Enum.Font.GothamMedium
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = row

    local value = Instance.new("TextLabel")
    value.AnchorPoint            = Vector2.new(1, 0)
    value.Position               = UDim2.new(1, -14, 0, 7)
    value.Size                   = UDim2.fromOffset(50, 17)
    value.BackgroundTransparency = 1
    value.TextColor3             = TxtDim
    value.TextSize               = 12
    value.Font                   = Enum.Font.Gotham
    value.TextXAlignment         = Enum.TextXAlignment.Right
    value.Parent                 = row

    local track = Instance.new("TextButton")
    track.Position         = UDim2.fromOffset(14, 32)
    track.Size             = UDim2.new(1, -28, 0, 5)
    track.BackgroundColor3 = Color3.fromRGB(52, 36, 72)
    track.Text             = ""
    track.AutoButtonColor  = false
    track.ZIndex           = 2
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
        fill.Size  = UDim2.new(pct, 0, 1, 0)
        value.Text = tostring(Settings[key])
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

local aimTargetOptions = {"Head", "Neck", "Chest", "Random"}
local function addDropdown(name, key)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -6, 0, 40)
    row.BackgroundColor3 = Row
    row.BorderSizePixel  = 0
    row.Parent           = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(14, 0)
    label.Size                   = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text                   = name .. "  ·  " .. Settings[key]
    label.TextColor3             = TxtHi
    label.TextSize               = 13
    label.Font                   = Enum.Font.GothamMedium
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = row

    local btn = Instance.new("TextButton")
    btn.AnchorPoint      = Vector2.new(1, 0.5)
    btn.Position         = UDim2.new(1, -14, 0.5, 0)
    btn.Size             = UDim2.fromOffset(26, 26)
    btn.BackgroundColor3 = RowAlt
    btn.Text             = "≡"
    btn.TextColor3       = TxtDim
    btn.TextSize         = 15
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.ZIndex           = 2
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
end

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

-- ===== Footer =====
local footer = Instance.new("Frame")
footer.AnchorPoint      = Vector2.new(0.5, 1)
footer.Position         = UDim2.new(0.5, 0, 1, -10)
footer.Size             = UDim2.new(1, -20, 0, 26)
footer.BackgroundColor3 = Row
footer.BorderSizePixel  = 0
footer.Parent           = main
Instance.new("UICorner", footer).CornerRadius = UDim.new(1, 0)

local footerText = Instance.new("TextLabel")
footerText.Position               = UDim2.fromOffset(14, 0)
footerText.Size                   = UDim2.new(1, -56, 1, 0)
footerText.BackgroundTransparency = 1
footerText.Text                   = "MEI  |  FPS: --  |  PING: --"
footerText.TextColor3             = Accent
footerText.TextSize               = 12
footerText.Font                   = Enum.Font.GothamMedium
footerText.TextXAlignment         = Enum.TextXAlignment.Left
footerText.Parent                 = footer

local footerIcon = Instance.new("TextLabel")
footerIcon.AnchorPoint            = Vector2.new(1, 0.5)
footerIcon.Position               = UDim2.new(1, -12, 0.5, 0)
footerIcon.Size                   = UDim2.fromOffset(20, 20)
footerIcon.BackgroundTransparency = 1
footerIcon.Text                   = "≡"
footerIcon.TextColor3             = TxtDim
footerIcon.TextSize               = 15
footerIcon.Font                   = Enum.Font.GothamBold
footerIcon.Parent                 = footer

-- ===== FPS/PING =====
local smoothedFps = 60
RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then smoothedFps = smoothedFps * 0.9 + (1 / dt) * 0.1 end
end)

task.spawn(function()
    while gui.Parent do
        local pingMs = 0
        pcall(function()
            pingMs = math.floor(player:GetNetworkPing() * 1000 + 0.5)
        end)
        footerText.Text = string.format(
            "MEI  |  FPS: %d  |  PING: %d",
            math.floor(smoothedFps + 0.5),
            pingMs
        )
        task.wait(0.5)
    end
end)

-- =====================================================================
-- UNLOCK
-- =====================================================================
local unlocked = false

local function unlock()
    if unlocked then return end
    unlocked = true
    print("[MeiUI] unlocking")

    keyFrame.Visible = false
    keyFrame:Destroy()

    main.Visible     = true
    floatBtn.Visible = true

    main.Size = UDim2.fromOffset(340, 430)
    TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(380, 480),
    }):Play()

    print("[MeiUI] unlocked")
end

local function shakeKeyFrame()
    local base = keyFrame.Position
    task.spawn(function()
        for i = 1, 6 do
            local dir = (i % 2 == 0) and 1 or -1
            keyFrame.Position = base + UDim2.fromOffset(6 * dir, 0)
            task.wait(0.03)
        end
        keyFrame.Position = base
    end)
end

local function trySubmit()
    local raw = (keyBox.Text or ""):gsub("%s+", ""):upper()
    print("[MeiUI] submit: " .. raw)
    if raw == "" then
        keyErr.Text = "Enter a key first."
        shakeKeyFrame()
        return
    end
    if isValidKey(raw) then
        keyErr.Text = ""
        keyBoxStroke.Color = AccentSoft
        saveKey(raw)
        task.wait(0.1)
        unlock()
    else
        keyErr.Text = "Invalid key."
        keyBoxStroke.Color = Bad
        shakeKeyFrame()
        task.wait(0.6)
        keyBoxStroke.Color = AccentDeep
    end
end

submitBtn.Activated:Connect(trySubmit)

keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then trySubmit() end
end)

getKeyBtn.Activated:Connect(function()
    print("[MeiUI] get key: " .. DISCORD_URL)
    local ok = pcall(function() setclipboard(DISCORD_URL) end)
    if ok then
        getKeyBtn.Text = "COPIED  ✓"
        task.wait(1.2)
        getKeyBtn.Text = "GET KEY  ·  DISCORD"
    else
        getKeyBtn.Text = "SEE CONSOLE FOR LINK"
        task.wait(1.2)
        getKeyBtn.Text = "GET KEY  ·  DISCORD"
    end
end)

-- =====================================================================
-- BOOT
-- =====================================================================
local saved = loadSavedKey()
print("[MeiUI] saved key: " .. tostring(saved))

if saved and isValidKey(saved) then
    unlock()
else
    keyFrame.Visible = true
    main.Visible     = false
    floatBtn.Visible = false
    task.defer(function()
        pcall(function() keyBox:CaptureFocus() end)
    end)
end

updateFov()
print("[MeiUI] loaded")
