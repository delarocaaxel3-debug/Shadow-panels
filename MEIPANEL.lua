
-- SHADOW PURSUIT | PURPLE EDITION
-- UI DEMO | MOBILE + PC
-- Place in a LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Purple = Color3.fromRGB(145, 65, 220)
local DarkPurple = Color3.fromRGB(35, 18, 52)
local PanelColor = Color3.fromRGB(24, 16, 34)
local TextColor = Color3.fromRGB(245, 238, 255)

local Settings = {
    AimEnabled = false,
    WallCheck = true,
    KillCheck = false,
    TeamCheck = true,
    GodMode = false,
    InfiniteAmmo = false,
    NoReload = false,
    FOV = 100,
    Sensitivity = 50,
    DiscordLink = "https://discord.gg/CM9maT4GEa",
}

-- Remove old copy if script runs again
local oldGui = playerGui:FindFirstChild("ShadowUI")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ShadowUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = playerGui

-- Main panel
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(340, 420)
main.Position = UDim2.new(0.5, -170, 0.5, -210)
main.BackgroundColor3 = PanelColor
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius =
    UDim.new(0, 12)

local outline = Instance.new("UIStroke")
outline.Color = Purple
outline.Thickness = 1.5
outline.Parent = main

-- Floating open/close button
local floatButton = Instance.new("TextButton")
floatButton.Name = "OpenCloseButton"
floatButton.Size = UDim2.fromOffset(58, 58)
floatButton.Position = UDim2.new(0, 18, 0.5, -29)
floatButton.BackgroundColor3 = DarkPurple
floatButton.Text = "SH"
floatButton.TextColor3 = TextColor
floatButton.TextSize = 19
floatButton.Font = Enum.Font.GothamBold
floatButton.BorderSizePixel = 0
floatButton.AutoButtonColor = true
floatButton.ZIndex = 10
floatButton.Parent = gui

Instance.new("UICorner", floatButton).CornerRadius =
    UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Purple
floatStroke.Thickness = 2
floatStroke.Parent = floatButton

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = DarkPurple
header.BorderSizePixel = 0
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -125, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "MEI PANEL"
title.TextColor3 = TextColor
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local pcButton = Instance.new("TextButton")
pcButton.Size = UDim2.fromOffset(36, 32)
pcButton.Position = UDim2.new(1, -78, 0, 8)
pcButton.BackgroundColor3 = Purple
pcButton.Text = "▣"
pcButton.TextColor3 = TextColor
pcButton.TextSize = 20
pcButton.Font = Enum.Font.GothamBold
pcButton.Parent = header

Instance.new("UICorner", pcButton).CornerRadius =
    UDim.new(0, 7)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(30, 32)
closeButton.Position = UDim2.new(1, -36, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(75, 35, 90)
closeButton.Text = "—"
closeButton.TextColor3 = TextColor
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = header

Instance.new("UICorner", closeButton).CornerRadius =
    UDim.new(0, 7)

-- Drag helper for touch and mouse.
-- Tapping the floating button toggles visibility;
-- dragging it moves it instead.
local function makeDraggable(object, onTap)
    local activeInput
    local startPosition
    local startObjectPosition
    local moved = false
    local dragThreshold = 8

    object.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            activeInput = input
            startPosition = input.Position
            startObjectPosition = object.Position
            moved = false
        end
    end)

    object.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            if activeInput then
                activeInput = activeInput
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not activeInput then
            return
        end

        local matches =
            input == activeInput
            or (
                activeInput.UserInputType ==
                    Enum.UserInputType.MouseButton1
                and input.UserInputType ==
                    Enum.UserInputType.MouseMovement
            )

        if not matches then
            return
        end

        local delta = input.Position - startPosition

        if math.abs(delta.X) > dragThreshold
            or math.abs(delta.Y) > dragThreshold then
            moved = true
        end

        if moved then
            object.Position = UDim2.new(
                startObjectPosition.X.Scale,
                startObjectPosition.X.Offset + delta.X,
                startObjectPosition.Y.Scale,
                startObjectPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not activeInput then
            return
        end

        if input == activeInput
            or input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

            local wasMoved = moved
            activeInput = nil

            if not wasMoved and onTap then
                onTap()
            end
        end
    end)
end

local function togglePanel()
    main.Visible = not main.Visible
    floatButton.Text = main.Visible and "SH" or "OPEN"
end

makeDraggable(floatButton, togglePanel)
makeDraggable(header, nil)

closeButton.Activated:Connect(function()
    main.Visible = false
    floatButton.Text = "OPEN"
end)

-- Tabs
local tabs = Instance.new("Frame")
tabs.Position = UDim2.fromOffset(10, 58)
tabs.Size = UDim2.new(1, -20, 0, 36)
tabs.BackgroundTransparency = 1
tabs.Parent = main

local function createButton(parent, text, position, size)
    local button = Instance.new("TextButton")
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = DarkPurple
    button.Text = text
    button.TextColor3 = TextColor
    button.TextSize = 13
    button.Font = Enum.Font.GothamSemibold
    button.BorderSizePixel = 0
    button.Parent = parent

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 6)

    return button
end

local combatTab = createButton(
    tabs, "Combat",
    UDim2.new(0, 0, 0, 0),
    UDim2.new(0.5, -4, 1, 0)
)

local miscTab = createButton(
    tabs, "Misc",
    UDim2.new(0.5, 4, 0, 0),
    UDim2.new(0.5, -4, 1, 0)
)

local content = Instance.new("ScrollingFrame")
content.Position = UDim2.fromOffset(10, 104)
content.Size = UDim2.new(1, -20, 1, -114)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Purple
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child ~= layout then
            child:Destroy()
        end
    end
end

local function addToggle(text, key)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 38)
    row.BackgroundColor3 = DarkPurple
    row.BorderSizePixel = 0
    row.Parent = content

    Instance.new("UICorner", row).CornerRadius =
        UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(10, 0)
    label.Size = UDim2.new(1, -90, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = TextColor
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggle = createButton(
        row,
        Settings[key] and "ON" or "OFF",
        UDim2.new(1, -65, 0, 5),
        UDim2.fromOffset(56, 28)
    )

    local function refresh()
        toggle.Text = Settings[key] and "ON" or "OFF"
        toggle.BackgroundColor3 = Settings[key]
            and Purple
            or Color3.fromRGB(65, 55, 75)
    end

    refresh()

    toggle.Activated:Connect(function()
        Settings[key] = not Settings[key]
        refresh()
    end)
end

local function addSlider(text, key, minimum, maximum)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 64)
    frame.BackgroundColor3 = DarkPurple
    frame.BorderSizePixel = 0
    frame.Parent = content

    Instance.new("UICorner", frame).CornerRadius =
        UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(10, 4)
    label.Size = UDim2.new(1, -20, 0, 23)
    label.BackgroundTransparency = 1
    label.TextColor3 = TextColor
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local slider = Instance.new("TextButton")
    slider.Position = UDim2.fromOffset(10, 34)
    slider.Size = UDim2.new(1, -20, 0, 18)
    slider.BackgroundColor3 = Color3.fromRGB(65, 48, 80)
    slider.Text = ""
    slider.AutoButtonColor = false
    slider.Parent = frame

    Instance.new("UICorner", slider).CornerRadius =
        UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = Purple
    fill.BorderSizePixel = 0
    fill.Parent = slider

    Instance.new("UICorner", fill).CornerRadius =
        UDim.new(1, 0)

    local function update(value)
        Settings[key] = math.clamp(
            math.floor(value + 0.5), minimum, maximum
        )

        local percent = (Settings[key] - minimum) /
            (maximum - minimum)

        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = text .. ": " .. Settings[key]
    end

    local sliding = false

    local function setFromPosition(position)
        local width = slider.AbsoluteSize.X
        if width <= 0 then
            return
        end

        local percent = math.clamp(
            (position.X - slider.AbsolutePosition.X) / width,
            0, 1
        )

        update(minimum + percent * (maximum - minimum))
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            setFromPosition(input.Position)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            setFromPosition(input.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    update(Settings[key])
end

local function showCombat()
    clearContent()
    addToggle("Aimbot (UI demo)", "AimEnabled")
    addToggle("Wall Check", "WallCheck")
    addToggle("Kill Check", "KillCheck")
    addToggle("Team Check", "TeamCheck")
    addSlider("FOV Size", "FOV", 1, 200)
    addSlider("Aim Sensitivity", "Sensitivity", 1, 100)
end

local function showMisc()
    clearContent()
    addToggle("God Mode (demo only)", "GodMode")
    addToggle("Infinite Ammo (demo only)", "InfiniteAmmo")
    addToggle("No Reload (demo only)", "NoReload")

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -4, 0, 52)
    info.BackgroundColor3 = DarkPurple
    info.TextColor3 = TextColor
    info.TextWrapped = true
    info.TextSize = 12
    info.Font = Enum.Font.Gotham
    info.Text = "UI demo only. Gameplay mechanics must be implemented and validated in your own game."
    info.Parent = content

    Instance.new("UICorner", info).CornerRadius =
        UDim.new(0, 7)

    local discord = Instance.new("TextLabel")
    discord.Size = UDim2.new(1, -4, 0, 32)
    discord.BackgroundColor3 = DarkPurple
    discord.TextColor3 = TextColor
    discord.TextSize = 12
    discord.Font = Enum.Font.Gotham
    discord.Text = Settings.DiscordLink == ""
        and "Discord: Not configured"
        or "Discord: " .. Settings.DiscordLink
    discord.Parent = content

    Instance.new("UICorner", discord).CornerRadius =
        UDim.new(0, 7)
end

combatTab.Activated:Connect(showCombat)
miscTab.Activated:Connect(showMisc)

pcButton.Activated:Connect(showMisc)

showCombat()

print("Shadow UI loaded successfully!")
