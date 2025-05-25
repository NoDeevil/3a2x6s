-- Roblox ESP Script mit GUI Menu
-- Drücke 'INSERT' um das Menu zu öffnen/schließen

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Konfiguration
local ESP_SETTINGS = {
    Enabled = false,
    MenuToggleKey = Enum.KeyCode.Insert,
    
    -- Farben (änderbar über Menu)
    BoxColor = Color3.new(1, 0, 0), -- Rot
    SkeletonColor = Color3.new(0, 1, 0), -- Grün
    NameColor = Color3.new(1, 1, 1), -- Weiß
    DistanceColor = Color3.new(0.8, 0.8, 0.8), -- Hellgrau
    HealthBarBackgroundColor = Color3.new(0.2, 0.2, 0.2), -- Dunkelgrau
    HealthBarColor = Color3.new(0, 1, 0), -- Grün
    
    -- Einstellungen
    BoxThickness = 2,
    SkeletonThickness = 1,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    MaxDistance = 1000,
    
    -- Features
    ShowBox = true,
    ShowSkeleton = true,
    ShowName = true,
    ShowDistance = true,
    ShowHealthBar = true,
}

-- ESP Objekte Storage
local ESPObjects = {}
local MenuOpen = false

-- GUI Creation
local function CreateMenu()
    -- Screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPMenu"
    screenGui.Parent = game.CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Visible = false
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Parent = mainFrame
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0.15, 0.15, 0.15)),
        ColorSequenceKeypoint.new(1, Color3.new(0.05, 0.05, 0.05))
    }
    gradient.Rotation = 45
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = mainFrame
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(12, 12, 256, 256)
    shadow.ZIndex = -1
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = mainFrame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Font = Enum.Font.GothamBold
    title.Text = "ESP MENU"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Parent = mainFrame
    closeBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextScaled = true
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn
    
    -- Scroll Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Parent = mainFrame
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Position = UDim2.new(0, 20, 0, 70)
    scrollFrame.Size = UDim2.new(1, -40, 1, -90)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.new(0.3, 0.3, 0.3)
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = scrollFrame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    
    return screenGui, mainFrame, scrollFrame, closeBtn
end

local function CreateToggle(parent, text, settingName, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Name = text .. "Frame"
    frame.Parent = parent
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.LayoutOrder = layoutOrder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton")
    toggle.Parent = frame
    toggle.BackgroundColor3 = ESP_SETTINGS[settingName] and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
    toggle.Position = UDim2.new(1, -60, 0.5, -10)
    toggle.Size = UDim2.new(0, 50, 0, 20)
    toggle.Font = Enum.Font.GothamBold
    toggle.Text = ESP_SETTINGS[settingName] and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.TextScaled = true
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        ESP_SETTINGS[settingName] = not ESP_SETTINGS[settingName]
        toggle.BackgroundColor3 = ESP_SETTINGS[settingName] and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
        toggle.Text = ESP_SETTINGS[settingName] and "ON" or "OFF"
        
        -- Tween Animation
        local tween = TweenService:Create(toggle, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 55, 0, 22)
        })
        tween:Play()
        tween.Completed:Connect(function()
            local tween2 = TweenService:Create(toggle, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 50, 0, 20)
            })
            tween2:Play()
        end)
    end)
    
    return frame
end

local function CreateSlider(parent, text, settingName, minVal, maxVal, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Name = text .. "Frame"
    frame.Parent = parent
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.LayoutOrder = layoutOrder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Size = UDim2.new(1, -30, 0, 25)
    label.Font = Enum.Font.Gotham
    label.Text = text .. ": " .. ESP_SETTINGS[settingName]
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = frame
    sliderBg.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    sliderBg.Position = UDim2.new(0, 15, 0, 30)
    sliderBg.Size = UDim2.new(1, -30, 0, 10)
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(0, 5)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBg
    sliderFill.BackgroundColor3 = Color3.new(0.3, 0.6, 1)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.Size = UDim2.new((ESP_SETTINGS[settingName] - minVal) / (maxVal - minVal), 0, 1, 0)
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 5)
    sliderFillCorner.Parent = sliderFill
    
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UserInputService:GetMouseLocation()
            local relativeX = mouse.X - sliderBg.AbsolutePosition.X
            local percentage = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)
            
            ESP_SETTINGS[settingName] = math.floor(minVal + (maxVal - minVal) * percentage)
            label.Text = text .. ": " .. ESP_SETTINGS[settingName]
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        end
    end)
    
    return frame
end

-- Hilfsfunktionen (gleich wie vorher)
local function CreateDrawing(drawingType)
    local drawing = Drawing.new(drawingType)
    return drawing
end

local function WorldToScreen(position)
    local vector, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(vector.X, vector.Y), onScreen
end

local function GetBoundingBox(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    local cf = humanoidRootPart.CFrame
    local size = humanoidRootPart.Size
    
    local corners = {
        cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
        cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
        cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
        cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
        cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
        cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
        cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
        cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
    }
    
    local screenPoints = {}
    for i, corner in pairs(corners) do
        local screenPoint, onScreen = WorldToScreen(corner.Position)
        if not onScreen then
            return nil
        end
        table.insert(screenPoints, screenPoint)
    end
    
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    
    for _, point in pairs(screenPoints) do
        minX = math.min(minX, point.X)
        minY = math.min(minY, point.Y)
        maxX = math.max(maxX, point.X)
        maxY = math.max(maxY, point.Y)
    end
    
    return {
        TopLeft = Vector2.new(minX, minY),
        TopRight = Vector2.new(maxX, minY),
        BottomLeft = Vector2.new(minX, maxY),
        BottomRight = Vector2.new(maxX, maxY),
        Size = Vector2.new(maxX - minX, maxY - minY)
    }
end

local function GetSkeletonPoints(character)
    if not character then return {} end
    
    local points = {}
    local limbConnections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"UpperTorso", "RightUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LowerTorso", "RightUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"RightLowerLeg", "RightFoot"},
    }
    
    for _, connection in pairs(limbConnections) do
        local part1 = character:FindFirstChild(connection[1])
        local part2 = character:FindFirstChild(connection[2])
        
        if part1 and part2 then
            local pos1, onScreen1 = WorldToScreen(part1.Position)
            local pos2, onScreen2 = WorldToScreen(part2.Position)
            
            if onScreen1 and onScreen2 then
                table.insert(points, {pos1, pos2})
            end
        end
    end
    
    return points
end

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end
    
    local espData = {
        Player = player,
        Drawings = {}
    }
    
    -- Box Lines
    if ESP_SETTINGS.ShowBox then
        for i = 1, 4 do
            local line = CreateDrawing("Line")
            line.Thickness = ESP_SETTINGS.BoxThickness
            line.Color = ESP_SETTINGS.BoxColor
            line.Visible = false
            table.insert(espData.Drawings, line)
        end
    end
    
    -- Skeleton Lines
    if ESP_SETTINGS.ShowSkeleton then
        for i = 1, 14 do
            local line = CreateDrawing("Line")
            line.Thickness = ESP_SETTINGS.SkeletonThickness
            line.Color = ESP_SETTINGS.SkeletonColor
            line.Visible = false
            table.insert(espData.Drawings, line)
        end
    end
    
    -- Name Text
    if ESP_SETTINGS.ShowName then
        local nameText = CreateDrawing("Text")
        nameText.Text = player.Name
        nameText.Size = ESP_SETTINGS.TextSize
        nameText.Font = ESP_SETTINGS.Font
        nameText.Color = ESP_SETTINGS.NameColor
        nameText.Center = true
        nameText.Outline = true
        nameText.OutlineColor = Color3.new(0, 0, 0)
        nameText.Visible = false
        table.insert(espData.Drawings, nameText)
    end
    
    -- Distance Text
    if ESP_SETTINGS.ShowDistance then
        local distanceText = CreateDrawing("Text")
        distanceText.Size = ESP_SETTINGS.TextSize - 2
        distanceText.Font = ESP_SETTINGS.Font
        distanceText.Color = ESP_SETTINGS.DistanceColor
        distanceText.Center = true
        distanceText.Outline = true
        distanceText.OutlineColor = Color3.new(0, 0, 0)
        distanceText.Visible = false
        table.insert(espData.Drawings, distanceText)
    end
    
    -- Health Bar
    if ESP_SETTINGS.ShowHealthBar then
        local healthBarBg = CreateDrawing("Square")
        healthBarBg.Color = ESP_SETTINGS.HealthBarBackgroundColor
        healthBarBg.Filled = true
        healthBarBg.Visible = false
        table.insert(espData.Drawings, healthBarBg)
        
        local healthBarFill = CreateDrawing("Square")
        healthBarFill.Color = ESP_SETTINGS.HealthBarColor
        healthBarFill.Filled = true
        healthBarFill.Visible = false
        table.insert(espData.Drawings, healthBarFill)
    end
    
    ESPObjects[player] = espData
end

local function UpdateESPForPlayer(player)
    local espData = ESPObjects[player]
    if not espData or not player.Character then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not humanoidRootPart or not humanoid then return end
    
    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
        and (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude or 0
    
    if distance > ESP_SETTINGS.MaxDistance then
        for _, drawing in pairs(espData.Drawings) do
            drawing.Visible = false
        end
        return
    end
    
    local boundingBox = GetBoundingBox(character)
    if not boundingBox then
        for _, drawing in pairs(espData.Drawings) do
            drawing.Visible = false
        end
        return
    end
    
    local drawingIndex = 1
    
    -- Update Box
    if ESP_SETTINGS.ShowBox then
        local boxLines = {
            {boundingBox.TopLeft, boundingBox.TopRight},
            {boundingBox.TopRight, boundingBox.BottomRight},
            {boundingBox.BottomRight, boundingBox.BottomLeft},
            {boundingBox.BottomLeft, boundingBox.TopLeft}
        }
        
        for i, line in pairs(boxLines) do
            local drawing = espData.Drawings[drawingIndex]
            drawing.From = line[1]
            drawing.To = line[2]
            drawing.Color = ESP_SETTINGS.BoxColor
            drawing.Visible = ESP_SETTINGS.Enabled
            drawingIndex = drawingIndex + 1
        end
    end
    
    -- Update Skeleton
    if ESP_SETTINGS.ShowSkeleton then
        local skeletonPoints = GetSkeletonPoints(character)
        
        for i = 1, 14 do
            local drawing = espData.Drawings[drawingIndex]
            if skeletonPoints[i] then
                drawing.From = skeletonPoints[i][1]
                drawing.To = skeletonPoints[i][2]
                drawing.Color = ESP_SETTINGS.SkeletonColor
                drawing.Visible = ESP_SETTINGS.Enabled
            else
                drawing.Visible = false
            end
            drawingIndex = drawingIndex + 1
        end
    end
    
    -- Update Name
    if ESP_SETTINGS.ShowName then
        local nameText = espData.Drawings[drawingIndex]
        nameText.Position = Vector2.new(boundingBox.TopLeft.X + boundingBox.Size.X/2, boundingBox.TopLeft.Y - 20)
        nameText.Text = player.Name
        nameText.Color = ESP_SETTINGS.NameColor
        nameText.Visible = ESP_SETTINGS.Enabled
        drawingIndex = drawingIndex + 1
    end
    
    -- Update Distance
    if ESP_SETTINGS.ShowDistance then
        local distanceText = espData.Drawings[drawingIndex]
        distanceText.Position = Vector2.new(boundingBox.TopLeft.X + boundingBox.Size.X/2, boundingBox.BottomRight.Y + 5)
        distanceText.Text = math.floor(distance) .. "m"
        distanceText.Color = ESP_SETTINGS.DistanceColor
        distanceText.Visible = ESP_SETTINGS.Enabled
        drawingIndex = drawingIndex + 1
    end
    
    -- Update Health Bar
    if ESP_SETTINGS.ShowHealthBar then
        local healthPercentage = humanoid.Health / humanoid.MaxHealth
        local barWidth = boundingBox.Size.X
        local barHeight = 4
        
        local healthBarBg = espData.Drawings[drawingIndex]
        healthBarBg.Size = Vector2.new(barWidth, barHeight)
        healthBarBg.Position = Vector2.new(boundingBox.TopLeft.X, boundingBox.TopLeft.Y - 8)
        healthBarBg.Color = ESP_SETTINGS.HealthBarBackgroundColor
        healthBarBg.Visible = ESP_SETTINGS.Enabled
        drawingIndex = drawingIndex + 1
        
        local healthBarFill = espData.Drawings[drawingIndex]
        healthBarFill.Size = Vector2.new(barWidth * healthPercentage, barHeight)
        healthBarFill.Position = Vector2.new(boundingBox.TopLeft.X, boundingBox.TopLeft.Y - 8)
        
        if healthPercentage > 0.6 then
            healthBarFill.Color = Color3.new(0, 1, 0)
        elseif healthPercentage > 0.3 then
            healthBarFill.Color = Color3.new(1, 1, 0)
        else
            healthBarFill.Color = Color3.new(1, 0, 0)
        end
        
        healthBarFill.Visible = ESP_SETTINGS.Enabled
        drawingIndex = drawingIndex + 1
    end
end

local function RemoveESPForPlayer(player)
    local espData = ESPObjects[player]
    if espData then
        for _, drawing in pairs(espData.Drawings) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
end

-- Event Handlers
local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        CreateESPForPlayer(player)
    end)
    
    if player.Character then
        CreateESPForPlayer(player)
    end
end

local function OnPlayerRemoving(player)
    RemoveESPForPlayer(player)
end

-- Menu Creation
local screenGui, mainFrame, scrollFrame, closeBtn = CreateMenu()

-- Create Menu Items
CreateToggle(scrollFrame, "ESP Aktiviert", "Enabled", 1)
CreateToggle(scrollFrame, "Box anzeigen", "ShowBox", 2)
CreateToggle(scrollFrame, "Skelett anzeigen", "ShowSkeleton", 3)
CreateToggle(scrollFrame, "Namen anzeigen", "ShowName", 4)
CreateToggle(scrollFrame, "Distanz anzeigen", "ShowDistance", 5)
CreateToggle(scrollFrame, "Gesundheitsbalken", "ShowHealthBar", 6)

CreateSlider(scrollFrame, "Box Dicke", "BoxThickness", 1, 5, 7)
CreateSlider(scrollFrame, "Skelett Dicke", "SkeletonThickness", 1, 3, 8)
CreateSlider(scrollFrame, "Text Größe", "TextSize", 10, 30, 9)
CreateSlider(scrollFrame, "Max Distanz", "MaxDistance", 100, 2000, 10)

-- Menu Toggle
local function ToggleMenu()
    MenuOpen = not MenuOpen
    mainFrame.Visible = MenuOpen
    
    if MenuOpen then
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 400, 0, 500),
            Position = UDim2.new(0.5, -200, 0.5, -250)
        })
        tween:Play()
    end
end

-- Event Connections
closeBtn.MouseButton1Click:Connect(function()
    ToggleMenu()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == ESP_SETTINGS.MenuToggleKey then
        ToggleMenu()
    end
end)

-- Main Update Loop
RunService.Heartbeat:Connect(function()
    if not ESP_SETTINGS.Enabled then return end
    
    for player, _ in pairs(ESPObjects) do
        if player and player.Character then
            UpdateESPForPlayer(player)
        end
    end
end)

-- Initialize
for _, player in pairs(Players:GetPlayers()) do
    OnPlayerAdded(player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

print("ESP Script mit Menu geladen!")
print("Drücke 'INSERT' um das Menu zu öffnen.")
