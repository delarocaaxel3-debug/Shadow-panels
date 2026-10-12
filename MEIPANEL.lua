-- MEI PANEL | PURPLE EDITION | KEY GATE + AIMBOT
-- LocalScript in StarterPlayerScripts

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== Palette (purple) =====
local BG          = Color3.fromRGB(16, 10, 26)
local PanelBG     = Color3.fromRGB(22, 14, 34)
local Row         = Color3.fromRGB(30, 19, 46)
local RowOutline  = Color3.fromRGB(52, 34, 76)
local Accent      = Color3.fromRGB(145, 65, 220)
local AccentSoft  = Color3.fromRGB(185, 110, 255)
local AccentDeep  = Color3.fromRGB(72, 30, 120)
local TxtHi       = Color3.fromRGB(240, 234, 250)
local TxtDim      = Color3.fromRGB(160, 150, 185)
local TxtFaint    = Color3.fromRGB(115, 106, 140)
local Bad         = Color3.fromRGB(230, 70, 90)

-- ===== Asset (floater icon) =====
local IMAGE_ID = "rbxassetid://1234567890" -- << paste your decal id

-- ===== Key system =====
local KEY_LIST = {
    ["MEI-2027"]   = true,
    ["MEI-VIP"]    = true,
    ["KABU-KEY"] = true,
}
local KEY_FILE    = "MeiUI/key.txt"
local DISCORD_URL = "https://discord.gg/CM9maT4GEa"

-- ===== Settings =====
local Settings = {
    AimEnabled  = false,
    ShowFov     = true,
    GodMode     = false,
    AimStrength = 27,
    FOV         = 7,
    AimTarget   = "Head",
    WallCheck   = true,
    TeamCheck   = true,
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
    if ok and type(data) == "string" then return (data:gsub("%s+", "")) end
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

-- =====================================================================
-- AIMBOT
-- =====================================================================
local camera = workspace.CurrentCamera

local function getFovRadius()
    local vp = camera.ViewportSize
    return math.min(vp.X, vp.Y) * 0.5 * (Settings.FOV / 100)
end

local function isVisible(targetPos, targetChar)
    if not Settings.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {}
    if player.Character then table.insert(ignore, player.Character) end
    if targetChar then table.insert(ignore, targetChar) end
    params.FilterDescendantsInstances = ignore
    local origin = camera.CFrame.Position
    local dir    = targetPos - origin
    local result = workspace:Raycast(origin, dir, params)
    if result and result.Instance then
        if targetChar and result.Instance:IsDescendantOf(targetChar) then
            return true
        end
        return false
    end
    return true
end

local function pickBone(char)
    local name = Settings.AimTarget
    if name == "Random" then
        local pool = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"}
        name = pool[math.random(1, #pool)]
    end
    local map = { Head = "Head", Neck = "Neck", Chest = "UpperTorso" }
    local partName = map[name] or "Head"
    local part = char:FindFirstChild(partName)
    if not part then part = char:FindFirstChild("Torso") end
    if not part then part = char:FindFirstChild("HumanoidRootPart") end
    return part
end

local function getTarget()
    local vp     = camera.ViewportSize
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    local maxR   = getFovRadius()
    local bestPart, bestDist = nil, maxR

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local skip = false
                    if Settings.TeamCheck and player.Team and p.Team
                    and player.Team == p.Team then skip = true end
                    if not skip then
                        local part = pickBone(char)
                        if part and isVisible(part.Position, char) then
                            local sp, onScreen = camera:WorldToViewportPoint(part.Position)
                            if onScreen and sp.Z > 0 then
                                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if d < bestDist then
                                    bestPart = part
                                    bestDist = d
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

RunService:BindToRenderStep("MeiAimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if not Settings.AimEnabled then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    if camera ~= cam then camera = cam end
    local target = getTarget()
    if not target then return end
    local camPos = cam.CFrame.Position
    local goal   = CFrame.new(camPos, target.Position)
    local alpha  = math.clamp(Settings.AimStrength / 100, 0.01, 1)
    cam.CFrame   = cam.CFrame:Lerp(goal, alpha)
end)

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
fovStroke.Thickness    = 1.4
fovStroke.Transparency = 0.3
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
    camera = cam
    local r = math.max(1, getFovRadius())
    fovCircle.Size = UDim2.fromOffset(r * 2, r * 2)
    local show = Settings.AimEnabled and Settings.ShowFov
    fovCircle.Visible = show
    fovDot.Visible    = show
end

local function hookCam()
    local cam = workspace.CurrentCamera
    if cam then
        camera = cam
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateFov)
    end
    updateFov()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(hookCam)
hookCam()

-- =====================================================================
-- DRAGGABLE (tap + drag for buttons, drag-only for headers)
-- =====================================================================
local function makeDraggable(frame, onTap)
    local dragging, dragStart, startPos, moved = false, nil, nil, false

    frame.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging, dragStart, startPos, moved = true, input.Position, frame.Position, false
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = input.Position - dragStart
        if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then moved = true end
        if moved then
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    local function release()
        if not dragging then return end
        dragging = false
        if not moved and onTap then onTap() end
        moved = false
    end

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then release() end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then release() end
    end)
end

-- =====================================================================
-- FLOATING BUTTON (circular, top-left, drag + tap)
-- =====================================================================
local hasImg = (IMAGE_ID ~= "" and IMAGE_ID ~= "rbxassetid://0")

local floater = Instance.new("ImageButton")
floater.Name              = "Floater"
floater.Size              = UDim2.fromOffset(56, 56)
floater.Position          = UDim2.new(0, 14, 0, 14)
floater.BackgroundColor3  = BG
floater.BorderSizePixel   = 0
floater.AutoButtonColor   = false
floater.Active            = true
floater.Image             = hasImg and IMAGE_ID or ""
floater.ScaleType         = Enum.ScaleType.Fit
floater.ZIndex            = 60
floater.Visible           = false
floater.Parent            = gui
Instance.new("UICorner", floater).CornerRadius = UDim.new(1, 0)

local floaterStroke = Instance.new("UIStroke")
floaterStroke.Color        = AccentSoft
floaterStroke.Thickness    = 2
floaterStroke.Transparency = 0.05
floaterStroke.Parent       = floater

-- soft inner ring (matches the double-ring in the ss)
local floaterInner = Instance.new("Frame")
floaterInner.AnchorPoint            = Vector2.new(0.5, 0.5)
floaterInner.Position               = UDim2.fromScale(0.5, 0.5)
floaterInner.Size                   = UDim2.fromScale(0.86, 0.86)
floaterInner.BackgroundTransparency = 1
floaterInner.Active                 = false
floaterInner.ZIndex                 = 61
floaterInner.Parent                 = floater
Instance.new("UICorner", floaterInner).CornerRadius = UDim.new(1, 0)

local innerStroke = Instance.new("UIStroke")
innerStroke.Color        = Accent
innerStroke.Thickness    = 1
innerStroke.Transparency = 0.5
innerStroke.Parent       = floaterInner

local floaterFallback = Instance.new("TextLabel")
floaterFallback.AnchorPoint            = Vector2.new(0.5, 0.5)
floaterFallback.Position               = UDim2.fromScale(0.5, 0.5)
floaterFallback.Size                   = UDim2.fromScale(1, 1)
floaterFallback.BackgroundTransparency = 1
floaterFallback.Text                   = "MEI"
floaterFallback.TextColor3             = AccentSoft
floaterFallback.TextSize               = 14
floaterFallback.Font                   = Enum.Font.GothamBold
floaterFallback.Active                 = false
floaterFallback.ZIndex                 = 62
floaterFallback.Parent                 = floater
floaterFallback.Visible = not hasImg

local function togglePanel()
    main.Visible = not main.Visible
    TweenService:Create(floaterStroke, TweenInfo.new(0.15), {
        Color = main.Visible and AccentSoft or AccentDeep,
    }):Play()
    floater.Size = UDim2.fromOffset(50, 50)
    TweenService:Create(floater, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(56, 56),
    }):Play()
end

makeDraggable(floater, togglePanel)

-- =====================================================================
-- KEY GATE
-- =====================================================================
local keyFrame = Instance.new("Frame")
keyFrame.Name             = "KeyGate"
keyFrame.Size             = UDim2.fromOffset(320, 290)
keyFrame.Position         = UDim2.new(0.5, -160, 0.5, -145)
keyFrame.BackgroundColor3 = PanelBG
keyFrame.BorderSizePixel  = 0
keyFrame.ZIndex           = 50
keyFrame.Parent           = gui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 12)

local keyStroke = Instance.new("UIStroke")
keyStroke.Color        = RowOutline
keyStroke.Thickness    = 1
keyStroke.Transparency = 0.1
keyStroke.Parent       = keyFrame

local keyHeader = Instance.new("Frame")
keyHeader.Size             = UDim2.new(1, 0, 0, 50)
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
keyTitle.TextColor3             = AccentSoft
keyTitle.TextSize               = 14
keyTitle.Font                   = Enum.Font.GothamBold
keyTitle.TextXAlignment         = Enum.TextXAlignment.Left
keyTitle.ZIndex                 = 52
keyTitle.Parent                 = keyHeader

local keyDesc = Instance.new("TextLabel")
keyDesc.Position               = UDim2.fromOffset(20, 60)
keyDesc.Size                   = UDim2.new(1, -40, 0, 28)
keyDesc.BackgroundTransparency = 1
keyDesc.Text                   = "Enter your key to unlock the panel."
keyDesc.TextColor3             = TxtDim
keyDesc.TextSize               = 11
keyDesc.Font                   = Enum.Font.Gotham
keyDesc.TextWrapped            = true
keyDesc.TextXAlignment         = Enum.TextXAlignment.Left
keyDesc.ZIndex                 = 52
keyDesc.Parent                 = keyFrame

local keyBox = Instance.new("TextBox")
keyBox.Position               = UDim2.fromOffset(20, 94)
keyBox.Size                   = UDim2.new(1, -40, 0, 38)
keyBox.BackgroundColor3       = Row
keyBox.BorderSizePixel        = 0
keyBox.Text                   = ""
keyBox.PlaceholderText        = "MEI-XXXX"
keyBox.PlaceholderColor3      = TxtFaint
keyBox.TextColor3             = TxtHi
keyBox.TextSize               = 13
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
keyBoxStroke.Color        = RowOutline
keyBoxStroke.Thickness    = 1
keyBoxStroke.Transparency = 0.1
keyBoxStroke.Parent       = keyBox

local keyErr = Instance.new("TextLabel")
keyErr.Position               = UDim2.fromOffset(20, 136)
keyErr.Size                   = UDim2.new(1, -40, 0, 14)
keyErr.BackgroundTransparency = 1
keyErr.Text                   = ""
keyErr.TextColor3             = Bad
keyErr.TextSize               = 10
keyErr.Font                   = Enum.Font.Gotham
keyErr.TextXAlignment         = Enum.TextXAlignment.Left
keyErr.ZIndex                 = 52
keyErr.Parent                 = keyFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Position         = UDim2.fromOffset(20, 156)
submitBtn.Size             = UDim2.new(1, -40, 0, 38)
submitBtn.BackgroundColor3 = Accent
submitBtn.Text             = "UNLOCK"
submitBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
submitBtn.TextSize         = 13
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

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Position         = UDim2.fromOffset(20, 202)
getKeyBtn.Size             = UDim2.new(1, -40, 0, 38)
getKeyBtn.BackgroundColor3 = Row
getKeyBtn.Text             = "GET KEY  ·  DISCORD"
getKeyBtn.TextColor3       = AccentSoft
getKeyBtn.TextSize         = 12
getKeyBtn.Font             = Enum.Font.GothamBold
getKeyBtn.BorderSizePixel  = 0
getKeyBtn.AutoButtonColor  = false
getKeyBtn.ZIndex           = 52
getKeyBtn.Parent           = keyFrame
Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)

local getKeyStroke = Instance.new("UIStroke")
getKeyStroke.Color        = RowOutline
getKeyStroke.Thickness    = 1
getKeyStroke.Transparency = 0.1
getKeyStroke.Parent       = getKeyBtn

makeDraggable(keyHeader)
makeDraggable(keyFrame)

-- =====================================================================
-- MAIN PANEL
-- =====================================================================
local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.fromOffset(360, 420)
main.Position         = UDim2.new(0.5, -180, 0.5, -210)
main.BackgroundColor3 = PanelBG
main.BorderSizePixel  = 0
main.ClipsDescendants = true
main.Visible          = false
main.Parent           = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color        = RowOutline
mainStroke.Thickness    = 1
mainStroke.Transparency = 0.1
mainStroke.Parent       = main

-- ===== Header =====
local header = Instance.new("Frame")
header.Name                   = "Header"
header.Size                   = UDim2.new(1, 0, 0, 54)
header.BackgroundTransparency = 1
header.Parent                 = main

local title = Instance.new("TextLabel")
title.Position               = UDim2.fromOffset(16, 8)
title.Size                   = UDim2.new(1, -140, 0, 18)
title.BackgroundTransparency = 1
title.Text                   = "cheat by MEI"
title.TextColor3             = AccentSoft
title.TextSize               = 14
title.Font                   = Enum.Font.GothamBold
title.TextXAlignment         = Enum.TextXAlignment.Left
title.Parent                 = header

local sub = Instance.new("TextLabel")
sub.Position               = UDim2.fromOffset(16, 26)
sub.Size                   = UDim2.new(1, -140, 0, 12)
sub.BackgroundTransparency = 1
sub.Text                   = "by MEI"
sub.TextColor3             = TxtFaint
sub.TextSize               = 10
sub.Font                   = Enum.Font.Gotham
sub.TextXAlignment         = Enum.TextXAlignment.Left
sub.Parent                 = header

local expiresLbl = Instance.new("TextLabel")
expiresLbl.AnchorPoint            = Vector2.new(1, 0)
expiresLbl.Position               = UDim2.new(1, -58, 0, 10)
expiresLbl.Size                   = UDim2.fromOffset(110, 13)
expiresLbl.BackgroundTransparency = 1
expiresLbl.Text                   = "Expires at"
expiresLbl.TextColor3             = AccentSoft
expiresLbl.TextSize               = 10
expiresLbl.Font                   = Enum.Font.GothamBold
expiresLbl.TextXAlignment         = Enum.TextXAlignment.Right
expiresLbl.Parent                 = header

local expiresVal = Instance.new("TextLabel")
expiresVal.AnchorPoint            = Vector2.new(1, 0)
expiresVal.Position               = UDim2.new(1, -58, 0, 26)
expiresVal.Size                   = UDim2.fromOffset(110, 13)
expiresVal.BackgroundTransparency = 1
expiresVal.Text                   = "Unlimited"
expiresVal.TextColor3             = TxtDim
expiresVal.TextSize               = 10
expiresVal.Font                   = Enum.Font.Gotham
expiresVal.TextXAlignment         = Enum.TextXAlignment.Right
expiresVal.Parent                 = header

-- circular badge far right (matches ss)
local headerBadge = Instance.new("Frame")
headerBadge.AnchorPoint      = Vector2.new(1, 0.5)
headerBadge.Position         = UDim2.new(1, -14, 0, 27)
headerBadge.Size             = UDim2.fromOffset(28, 28)
headerBadge.BackgroundColor3 = BG
headerBadge.BorderSizePixel  = 0
headerBadge.Parent           = header
Instance.new("UICorner", headerBadge).CornerRadius = UDim.new(1, 0)

local badgeStroke = Instance.new("UIStroke")
badgeStroke.Color        = AccentSoft
badgeStroke.Thickness    = 1.8
badgeStroke.Transparency = 0.1
badgeStroke.Parent       = headerBadge

local badgeDot = Instance.new("Frame")
badgeDot.AnchorPoint      = Vector2.new(0.5, 0.5)
badgeDot.Position         = UDim2.fromScale(0.5, 0.5)
badgeDot.Size             = UDim2.fromOffset(10, 10)
badgeDot.BackgroundColor3 = Accent
badgeDot.BorderSizePixel  = 0
badgeDot.Parent           = headerBadge
Instance.new("UICorner", badgeDot).CornerRadius = UDim.new(1, 0)

makeDraggable(header)  -- drag panel by header

-- ===== Content =====
local content = Instance.new("ScrollingFrame")
content.Position               = UDim2.fromOffset(0, 54)
content.Size                   = UDim2.new(1, 0, 1, -84)
content.BackgroundTransparency = 1
content.BorderSizePixel        = 0
content.ScrollBarThickness     = 3
content.ScrollBarImageColor3   = Accent
content.AutomaticCanvasSize    = Enum.AutomaticSize.Y
content.CanvasSize             = UDim2.new(0, 0, 0, 0)
content.Parent                 = main

local list = Instance.new("UIListLayout")
list.Padding   = UDim.new(0, 0)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent    = content

local function addSection(text)
    local section = Instance.new("TextLabel")
    section.Size                   = UDim2.new(1, -28, 0, 32)
    section.Position               = UDim2.fromOffset(14, 0)
    section.BackgroundTransparency = 1
    section.Text                   = text
    section.TextColor3             = TxtHi
    section.TextSize               = 14
    section.Font                   = Enum.Font.GothamBold
    section.TextXAlignment         = Enum.TextXAlignment.Left
    section.Parent                 = content

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.Parent = section
end

local function addRow(name, desc, key, onChange)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -20, 0, 48)
    row.Position         = UDim2.fromOffset(10, 0)
    row.BackgroundColor3 = Row
    row.BorderSizePixel  = 0
    row.Parent           = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local stroke = Instance.new("UIStroke")
    stroke.Color        = RowOutline
    stroke.Thickness    = 1
    stroke.Transparency = 0.5
    stroke.Parent       = row

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(12, 6)
    label.Size                   = UDim2.new(1, -60, 0, 16)
    label.BackgroundTransparency = 1
    label.Text                   = name
    label.TextColor3             = Settings[key] and AccentSoft or TxtDim
    label.TextSize               = 12
    label.Font                   = Enum.Font.GothamMedium
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = row

    local descLbl = Instance.new("TextLabel")
    descLbl.Position               = UDim2.fromOffset(12, 24)
    descLbl.Size                   = UDim2.new(1, -60, 0, 14)
    descLbl.BackgroundTransparency = 1
    descLbl.Text                   = desc or ""
    descLbl.TextColor3             = TxtFaint
    descLbl.TextSize               = 10
    descLbl.Font                   = Enum.Font.Gotham
    descLbl.TextXAlignment         = Enum.TextXAlignment.Left
    descLbl.Parent                 = row

    local check = Instance.new("TextButton")
    check.AnchorPoint      = Vector2.new(1, 0.5)
    check.Position         = UDim2.new(1, -10, 0.5, 0)
    check.Size             = UDim2.fromOffset(28, 28)
    check.BackgroundColor3 = Settings[key] and Accent or BG
    check.Text             = Settings[key] and "✓" or ""
    check.TextColor3       = Color3.fromRGB(255, 255, 255)
    check.TextSize         = 15
    check.Font             = Enum.Font.GothamBold
    check.BorderSizePixel  = 0
    check.AutoButtonColor  = false
    check.ZIndex           = 3
    check.Parent           = row
    Instance.new("UICorner", check).CornerRadius = UDim.new(0, 7)

    local checkStroke = Instance.new("UIStroke")
    checkStroke.Color        = Settings[key] and AccentSoft or RowOutline
    checkStroke.Thickness    = 1
    checkStroke.Transparency = 0.1
    checkStroke.Parent       = check

    local hit = Instance.new("TextButton")
    hit.Size                   = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text                   = ""
    hit.ZIndex                 = 2
    hit.Parent                 = row

    local function refresh(anim)
        local on   = Settings[key]
        local info = anim and TweenInfo.new(0.13, Enum.EasingStyle.Quad) or TweenInfo.new(0)
        TweenService:Create(check, info, { BackgroundColor3 = on and Accent or BG }):Play()
        TweenService:Create(checkStroke, info, { Color = on and AccentSoft or RowOutline }):Play()
        TweenService:Create(label, info, { TextColor3 = on and AccentSoft or TxtDim }):Play()
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
    row.Size             = UDim2.new(1, -20, 0, 46)
    row.Position         = UDim2.fromOffset(10, 0)
    row.BackgroundColor3 = Row
    row.BorderSizePixel  = 0
    row.Parent           = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local stroke = Instance.new("UIStroke")
    stroke.Color        = RowOutline
    stroke.Thickness    = 1
    stroke.Transparency = 0.5
    stroke.Parent       = row

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(12, 6)
    label.Size                   = UDim2.new(1, -60, 0, 15)
    label.BackgroundTransparency = 1
    label.Text                   = name
    label.TextColor3             = TxtDim
    label.TextSize               = 12
    label.Font                   = Enum.Font.GothamMedium
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = row

    local value = Instance.new("TextLabel")
    value.AnchorPoint            = Vector2.new(1, 0)
    value.Position               = UDim2.new(1, -12, 0, 6)
    value.Size                   = UDim2.fromOffset(50, 15)
    value.BackgroundTransparency = 1
    value.TextColor3             = TxtDim
    value.TextSize               = 11
    value.Font                   = Enum.Font.Gotham
    value.TextXAlignment         = Enum.TextXAlignment.Right
    value.Parent                 = row

    local track = Instance.new("TextButton")
    track.Position         = UDim2.fromOffset(12, 26)
    track.Size             = UDim2.new(1, -24, 0, 4)
    track.BackgroundColor3 = Color3.fromRGB(54, 36, 78)
    track.Text             = ""
    track.AutoButtonColor  = false
    track.ZIndex           = 3
    track.Parent           = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
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
    row.Size             = UDim2.new(1, -20, 0, 46)
    row.Position         = UDim2.fromOffset(10, 0)
    row.BackgroundColor3 = Row
    row.BorderSizePixel  = 0
    row.Parent           = content
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local stroke = Instance.new("UIStroke")
    stroke.Color        = RowOutline
    stroke.Thickness    = 1
    stroke.Transparency = 0.5
    stroke.Parent       = row

    local label = Instance.new("TextLabel")
    label.Position               = UDim2.fromOffset(12, 6)
    label.Size                   = UDim2.new(1, -50, 0, 15)
    label.BackgroundTransparency = 1
    label.Text                   = name
    label.TextColor3             = TxtDim
    label.TextSize               = 12
    label.Font                   = Enum.Font.GothamMedium
    label.TextXAlignment         = Enum.TextXAlignment.Left
    label.Parent                 = row

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Position               = UDim2.fromOffset(12, 24)
    valueLbl.Size                   = UDim2.new(1, -50, 0, 14)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text                   = Settings[key]
    valueLbl.TextColor3             = TxtFaint
    valueLbl.TextSize               = 10
    valueLbl.Font                   = Enum.Font.Gotham
    valueLbl.TextXAlignment         = Enum.TextXAlignment.Left
    valueLbl.Parent                 = row

    local btn = Instance.new("TextButton")
    btn.AnchorPoint      = Vector2.new(1, 0.5)
    btn.Position         = UDim2.new(1, -10, 0.5, 0)
    btn.Size             = UDim2.fromOffset(28, 28)
    btn.BackgroundColor3 = BG
    btn.Text             = "≡"
    btn.TextColor3       = TxtDim
    btn.TextSize         = 15
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.ZIndex           = 3
    btn.Parent           = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color        = RowOutline
    btnStroke.Thickness    = 1
    btnStroke.Transparency = 0.1
    btnStroke.Parent       = btn

    local idx = 1
    for i, v in ipairs(aimTargetOptions) do
        if v == Settings[key] then idx = i end
    end

    btn.Activated:Connect(function()
        idx = (idx % #aimTargetOptions) + 1
        Settings[key] = aimTargetOptions[idx]
        valueLbl.Text = Settings[key]
    end)
end

-- ===== Build page (matches screenshot order) =====
addSection("Aimbot")
addRow("Aimbot", "Enable soft aimbot", "AimEnabled", function() updateFov() end)
addRow("Show FOV", "Draw FOV circle", "ShowFov", function() updateFov() end)
addRow("God Mode", "Immune to death", "GodMode")
addSlider("Aim Strength", "AimStrength", 1, 100)
addSlider("FOV Size", "FOV", 1, 100, function() updateFov() end)
addDropdown("Aim Target", "AimTarget")

-- ===== Footer (centered pill) =====
local footer = Instance.new("Frame")
footer.AnchorPoint      = Vector2.new(0.5, 1)
footer.Position         = UDim2.new(0.5, 0, 1, -8)
footer.Size             = UDim2.new(0, 240, 0, 24)
footer.BackgroundColor3 = Row
footer.BorderSizePixel  = 0
footer.Parent           = main
Instance.new("UICorner", footer).CornerRadius = UDim.new(1, 0)

local footerStroke = Instance.new("UIStroke")
footerStroke.Color        = RowOutline
footerStroke.Thickness    = 1
footerStroke.Transparency = 0.3
footerStroke.Parent       = footer

local footerText = Instance.new("TextLabel")
footerText.Position               = UDim2.fromOffset(14, 0)
footerText.Size                   = UDim2.new(1, -42, 1, 0)
footerText.BackgroundTransparency = 1
footerText.Text                   = "MEI  |  FPS: --  |  PING: --"
footerText.TextColor3             = AccentSoft
footerText.TextSize               = 11
footerText.Font                   = Enum.Font.GothamMedium
footerText.TextXAlignment         = Enum.TextXAlignment.Center
footerText.Parent                 = footer

local footerIcon = Instance.new("TextLabel")
footerIcon.AnchorPoint            = Vector2.new(1, 0.5)
footerIcon.Position               = UDim2.new(1, -10, 0.5, 0)
footerIcon.Size                   = UDim2.fromOffset(18, 18)
footerIcon.BackgroundTransparency = 1
footerIcon.Text                   = "≡"
footerIcon.TextColor3             = TxtDim
footerIcon.TextSize               = 14
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
    keyFrame:Destroy()
    main.Visible    = true
    floater.Visible = true

    main.Size = UDim2.fromOffset(320, 380)
    TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(360, 420),
    }):Play()

    floater.Size = UDim2.fromOffset(44, 44)
    TweenService:Create(floater, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(56, 56),
    }):Play()
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
        keyBoxStroke.Color = RowOutline
    end
end

submitBtn.MouseButton1Click:Connect(trySubmit)

getKeyBtn.MouseButton1Click:Connect(function()
    local ok = pcall(function() setclipboard(DISCORD_URL) end)
    if ok then
        getKeyBtn.Text = "COPIED  ✓"
        task.wait(1.2)
        getKeyBtn.Text = "GET KEY  ·  DISCORD"
    else
        getKeyBtn.Text = "SEE CONSOLE"
        print("[MeiUI] " .. DISCORD_URL)
        task.wait(1.2)
        getKeyBtn.Text = "GET KEY  ·  DISCORD"
    end
end)

-- =====================================================================
-- BOOT
-- =====================================================================
local saved = loadSavedKey()
if saved and isValidKey(saved) then
    unlock()
else
    keyFrame.Visible = true
    main.Visible     = false
    floater.Visible  = false
end
    -- reliable click binding across mobile executors
local function bindClick(btn, fn)
    local cool = false
    local function fire()
        if cool then return end
        cool = true
        task.wait(0.2)
        cool = false
    end
    -- capture press immediately on touch (Activated / MouseButton1Click
    -- are unreliable on some mobile executors)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            fn()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        if not cool then fn() end
    end)
end

bindClick(submitBtn, trySubmit)

bindClick(getKeyBtn, function()
    local ok = pcall(function() setclipboard(DISCORD_URL) end)
    if ok then
        getKeyBtn.Text = "COPIED  ✓"
        task.wait(1.2)
        getKeyBtn.Text = "GET KEY  ·  DISCORD"
    else
        getKeyBtn.Text = "SEE CONSOLE"
        print("[MeiUI] " .. DISCORD_URL)
        task.wait(1.2)
        getKeyBtn.Text = "GET KEY  ·  DISCORD"
    end
end)

updateFov()
print("[MeiUI] loaded")
