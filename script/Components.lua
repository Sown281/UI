-- Components Module - Các thành phần UI cơ bản
local Components = {}
Components.__index = Components

function Components.new(theme, background)
    local self = setmetatable({}, Components)
    
    self.theme = theme
    self.background = background
    
    return self
end

-- Tạo Button với hiệu ứng glass
function Components:createButton(properties)
    properties = properties or {}
    
    local button = Instance.new("TextButton")
    button.Name = properties.Name or "GlassButton"
    button.Size = properties.Size or UDim2.new(0, 120, 0, self.theme.sizes.buttonHeight)
    button.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = properties.Color or self.theme.colors.glass
    button.BackgroundTransparency = properties.Transparency or self.theme.transparency.button
    button.BorderSizePixel = 0
    button.Text = properties.Text or "Nhấn vào đây"
    button.TextColor3 = properties.TextColor or self.theme.colors.text
    button.TextSize = properties.TextSize or self.theme.textSizes.normal
    button.Font = properties.Font or self.theme.fonts.default
    button.Parent = properties.Parent
    
    -- Bo góc
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, properties.CornerRadius or self.theme.sizes.cornerRadius)
    corner.Parent = button
    
    -- Viền
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.theme.colors.border
    stroke.Thickness = self.theme.sizes.borderWidth
    stroke.Transparency = 0.5
    stroke.Parent = button
    
    -- Thêm hiệu ứng blur
    self.background:addBlurEffect(button)
    
    -- Thêm reflection
    self.background:addGlassReflection(button)
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        self.theme:animateProperties(button, {
            BackgroundTransparency = self.theme.transparency.hover,
            Size = button.Size + UDim2.new(0, 4, 0, 2)
        }, self.theme.animations.fast)
    end)
    
    button.MouseLeave:Connect(function()
        self.theme:animateProperties(button, {
            BackgroundTransparency = properties.Transparency or self.theme.transparency.button,
            Size = properties.Size or UDim2.new(0, 120, 0, self.theme.sizes.buttonHeight)
        }, self.theme.animations.fast)
    end)
    
    -- Click effect
    button.MouseButton1Down:Connect(function()
        self.theme:animateProperty(button, "Size", button.Size - UDim2.new(0, 2, 0, 1), 0.1)
    end)
    
    button.MouseButton1Up:Connect(function()
        self.theme:animateProperty(button, "Size", properties.Size or UDim2.new(0, 120, 0, self.theme.sizes.buttonHeight), 0.1)
    end)
    
    return button
end

-- Tạo Text Label
function Components:createLabel(properties)
    properties = properties or {}
    
    local label = Instance.new("TextLabel")
    label.Name = properties.Name or "GlassLabel"
    label.Size = properties.Size or UDim2.new(0, 200, 0, 30)
    label.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = properties.BackgroundTransparency or 1
    label.Text = properties.Text or "Nhãn văn bản"
    label.TextColor3 = properties.TextColor or self.theme.colors.text
    label.TextSize = properties.TextSize or self.theme.textSizes.normal
    label.Font = properties.Font or self.theme.fonts.default
    label.TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = properties.TextYAlignment or Enum.TextYAlignment.Center
    label.Parent = properties.Parent
    
    -- Nếu có background
    if properties.HasBackground then
        label.BackgroundTransparency = self.theme.transparency.glass
        label.BackgroundColor3 = self.theme.colors.glass
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = label
        
        self.background:addBlurEffect(label)
    end
    
    return label
end

-- Tạo Text Input
function Components:createTextBox(properties)
    properties = properties or {}
    
    local textBox = Instance.new("TextBox")
    textBox.Name = properties.Name or "GlassTextBox"
    textBox.Size = properties.Size or UDim2.new(0, 200, 0, self.theme.sizes.inputHeight)
    textBox.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    textBox.BackgroundColor3 = self.theme.colors.glass
    textBox.BackgroundTransparency = self.theme.transparency.input
    textBox.BorderSizePixel = 0
    textBox.Text = properties.Text or ""
    textBox.PlaceholderText = properties.PlaceholderText or "Nhập văn bản..."
    textBox.TextColor3 = properties.TextColor or self.theme.colors.text
    textBox.PlaceholderColor3 = self.theme.colors.textSecondary
    textBox.TextSize = properties.TextSize or self.theme.textSizes.normal
    textBox.Font = properties.Font or self.theme.fonts.default
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = properties.ClearTextOnFocus or false
    textBox.Parent = properties.Parent
    
    -- Bo góc
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = textBox
    
    -- Viền
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.theme.colors.border
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = textBox
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = textBox
    
    -- Focus effects
    textBox.Focused:Connect(function()
        self.theme:animateProperties(stroke, {
            Color = self.theme.colors.primary,
            Transparency = 0.3
        }, self.theme.animations.fast)
    end)
    
    textBox.FocusLost:Connect(function()
        self.theme:animateProperties(stroke, {
            Color = self.theme.colors.border,
            Transparency = 0.7
        }, self.theme.animations.fast)
    end)
    
    return textBox
end

-- Tạo Slider
function Components:createSlider(properties)
    properties = properties or {}
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = properties.Name or "GlassSlider"
    sliderFrame.Size = properties.Size or UDim2.new(0, 200, 0, self.theme.sizes.sliderHeight)
    sliderFrame.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    sliderFrame.BackgroundColor3 = self.theme.colors.glass
    sliderFrame.BackgroundTransparency = 0.4
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = properties.Parent
    
    -- Bo góc cho track
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderFrame
    
    -- Fill (phần đã kéo)
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(properties.Value or 0.5, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = properties.FillColor or self.theme.colors.primary
    fill.BackgroundTransparency = 0.2
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    -- Handle (nút kéo)
    local handle = Instance.new("TextButton")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 20, 0, 20)
    handle.Position = UDim2.new(properties.Value or 0.5, -10, 0.5, -10)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BackgroundTransparency = 0.1
    handle.BorderSizePixel = 0
    handle.Text = ""
    handle.Parent = sliderFrame
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    -- Slider logic
    local dragging = false
    local value = properties.Value or 0.5
    local minValue = properties.MinValue or 0
    local maxValue = properties.MaxValue or 1
    
    handle.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = game.Players.LocalPlayer:GetMouse()
            local relativeX = math.clamp((mouse.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            
            value = minValue + (maxValue - minValue) * relativeX
            
            handle.Position = UDim2.new(relativeX, -10, 0.5, -10)
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            
            if properties.OnValueChanged then
                properties.OnValueChanged(value)
            end
        end
    end)
    
    return sliderFrame, value
end

-- Tạo Toggle Switch
function Components:createToggle(properties)
    properties = properties or {}
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = properties.Name or "GlassToggle"
    toggleFrame.Size = UDim2.new(0, self.theme.sizes.toggleWidth, 0, self.theme.sizes.toggleHeight)
    toggleFrame.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    toggleFrame.BackgroundColor3 = self.theme.colors.glass
    toggleFrame.BackgroundTransparency = 0.4
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = properties.Parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleFrame
    
    -- Toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 20, 0, 20)
    toggleButton.Position = UDim2.new(0, 2, 0.5, -10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BackgroundTransparency = 0.1
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = toggleButton
    
    -- Toggle state
    local isToggled = properties.InitialState or false
    
    local function updateToggle()
        if isToggled then
            self.theme:animateProperties(toggleButton, {
                Position = UDim2.new(1, -22, 0.5, -10)
            }, self.theme.animations.fast)
            self.theme:animateProperty(toggleFrame, "BackgroundColor3", self.theme.colors.primary, self.theme.animations.fast)
        else
            self.theme:animateProperties(toggleButton, {
                Position = UDim2.new(0, 2, 0.5, -10)
            }, self.theme.animations.fast)
            self.theme:animateProperty(toggleFrame, "BackgroundColor3", self.theme.colors.glass, self.theme.animations.fast)
        end
        
        if properties.OnToggle then
            properties.OnToggle(isToggled)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        updateToggle()
    end)
    
    -- Initialize
    updateToggle()
    
    return toggleFrame, function() return isToggled end
end

-- Tạo Dropdown Menu
function Components:createDropdown(properties)
    properties = properties or {}
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = properties.Name or "GlassDropdown"
    dropdownFrame.Size = properties.Size or UDim2.new(0, 200, 0, 36)
    dropdownFrame.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = properties.Parent
    
    -- Main button
    local mainButton = Instance.new("TextButton")
    mainButton.Size = UDim2.new(1, 0, 1, 0)
    mainButton.Position = UDim2.new(0, 0, 0, 0)
    mainButton.BackgroundColor3 = self.theme.colors.glass
    mainButton.BackgroundTransparency = self.theme.transparency.button
    mainButton.BorderSizePixel = 0
    mainButton.Text = properties.DefaultText or "Chọn một tùy chọn"
    mainButton.TextColor3 = self.theme.colors.text
    mainButton.TextSize = self.theme.textSizes.normal
    mainButton.Font = self.theme.fonts.default
    mainButton.TextXAlignment = Enum.TextXAlignment.Left
    mainButton.Parent = dropdownFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainButton
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 36)
    padding.Parent = mainButton
    
    -- Arrow icon
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = self.theme.colors.text
    arrow.TextSize = 12
    arrow.Font = self.theme.fonts.default
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    arrow.Parent = mainButton
    
    -- Dropdown list
    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "DropdownList"
    dropdownList.Size = UDim2.new(1, 0, 0, 0)
    dropdownList.Position = UDim2.new(0, 0, 1, 4)
    dropdownList.BackgroundColor3 = self.theme.colors.glass
    dropdownList.BackgroundTransparency = self.theme.transparency.button
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ZIndex = 10
    dropdownList.Parent = dropdownFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = dropdownList
    
    self.background:addBlurEffect(dropdownList)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList
    
    -- Options
    local options = properties.Options or {"Tùy chọn 1", "Tùy chọn 2", "Tùy chọn 3"}
    local isOpen = false
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 32)
        optionButton.BackgroundTransparency = 1
        optionButton.Text = option
        optionButton.TextColor3 = self.theme.colors.text
        optionButton.TextSize = self.theme.textSizes.normal
        optionButton.Font = self.theme.fonts.default
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.Parent = dropdownList
        
        local optionPadding = Instance.new("UIPadding")
        optionPadding.PaddingLeft = UDim.new(0, 12)
        optionPadding.Parent = optionButton
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundTransparency = 0.8
            optionButton.BackgroundColor3 = self.theme.colors.primary
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 1
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            mainButton.Text = option
            isOpen = false
            dropdownList.Visible = false
            arrow.Text = "▼"
            
            if properties.OnSelectionChanged then
                properties.OnSelectionChanged(option, i)
            end
        end)
    end
    
    -- Toggle dropdown
    mainButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownList.Visible = isOpen
        
        if isOpen then
            arrow.Text = "▲"
            local height = #options * 32
            self.theme:animateProperty(dropdownList, "Size", UDim2.new(1, 0, 0, height), self.theme.animations.normal)
        else
            arrow.Text = "▼"
            self.theme:animateProperty(dropdownList, "Size", UDim2.new(1, 0, 0, 0), self.theme.animations.normal)
        end
    end)
    
    return dropdownFrame
end

-- Tạo Progress Bar
function Components:createProgressBar(properties)
    properties = properties or {}
    
    local progressFrame = Instance.new("Frame")
    progressFrame.Name = properties.Name or "GlassProgressBar"
    progressFrame.Size = properties.Size or UDim2.new(0, 200, 0, 20)
    progressFrame.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    progressFrame.BackgroundColor3 = self.theme.colors.glass
    progressFrame.BackgroundTransparency = 0.4
    progressFrame.BorderSizePixel = 0
    progressFrame.Parent = properties.Parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = progressFrame
    
    -- Progress fill
    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(properties.Progress or 0, 0, 1, 0)
    progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = properties.FillColor or self.theme.colors.primary
    progressFill.BackgroundTransparency = 0.2
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = progressFill
    
    -- Progress text (optional)
    if properties.ShowText then
        local progressText = Instance.new("TextLabel")
        progressText.Size = UDim2.new(1, 0, 1, 0)
        progressText.Position = UDim2.new(0, 0, 0, 0)
        progressText.BackgroundTransparency = 1
        progressText.Text = math.floor((properties.Progress or 0) * 100) .. "%"
        progressText.TextColor3 = self.theme.colors.text
        progressText.TextSize = 12
        progressText.Font = self.theme.fonts.default
        progressText.TextXAlignment = Enum.TextXAlignment.Center
        progressText.TextYAlignment = Enum.TextYAlignment.Center
        progressText.Parent = progressFrame
    end
    
    -- Update function
    local function updateProgress(newProgress)
        newProgress = math.clamp(newProgress, 0, 1)
        self.theme:animateProperty(progressFill, "Size", UDim2.new(newProgress, 0, 1, 0), self.theme.animations.normal)
        
        if properties.ShowText then
            progressFrame.TextLabel.Text = math.floor(newProgress * 100) .. "%"
        end
    end
    
    return progressFrame, updateProgress
end

-- Tạo Notification
function Components:createNotification(title, message, duration)
    duration = duration or 3
    
    local notification = Instance.new("Frame")
    notification.Name = "GlassNotification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 0, 20)
    notification.BackgroundColor3 = self.theme.colors.glass
    notification.BackgroundTransparency = self.theme.transparency.button
    notification.BorderSizePixel = 0
    notification.Parent = game.Players.LocalPlayer.PlayerGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notification
    
    self.background:addBlurEffect(notification)
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Thông báo"
    titleLabel.TextColor3 = self.theme.colors.text
    titleLabel.TextSize = self.theme.textSizes.large
    titleLabel.Font = self.theme.fonts.bold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = notification
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -40, 0, 35)
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message or "Nội dung thông báo"
    messageLabel.TextColor3 = self.theme.colors.textSecondary
    messageLabel.TextSize = self.theme.textSizes.normal
    messageLabel.Font = self.theme.fonts.default
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -30, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = self.theme.colors.text
    closeButton.TextSize = 18
    closeButton.Font = self.theme.fonts.bold
    closeButton.TextXAlignment = Enum.TextXAlignment.Center
    closeButton.TextYAlignment = Enum.TextYAlignment.Center
    closeButton.Parent = notification
    
    -- Slide in animation
    self.theme:animateProperty(notification, "Position", UDim2.new(1, -320, 0, 20), self.theme.animations.normal)
    
    -- Auto hide
    local function hideNotification()
        self.theme:animateProperty(notification, "Position", UDim2.new(1, 0, 0, 20), self.theme.animations.normal, function()
            notification:Destroy()
        end)
    end
    
    closeButton.MouseButton1Click:Connect(hideNotification)
    
    -- Auto hide after duration
    spawn(function()
        wait(duration)
        if notification.Parent then
            hideNotification()
        end
    end)
    
    return notification
end

return Components
