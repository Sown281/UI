-- Theme Module - Quản lý màu sắc và kiểu dáng
local Theme = {}
Theme.__index = Theme

function Theme.new()
    local self = setmetatable({}, Theme)
    
    -- Bảng màu cho hiệu ứng glass morphism
    self.colors = {
        -- Màu chính cho glass effect
        glass = Color3.fromRGB(255, 255, 255), -- Trắng trong suốt
        glassDark = Color3.fromRGB(0, 0, 0), -- Đen trong suốt cho theme tối
        
        -- Màu viền
        border = Color3.fromRGB(255, 255, 255), -- Viền trắng nhạt
        borderDark = Color3.fromRGB(100, 100, 100), -- Viền xám cho theme tối
        
        -- Màu text
        text = Color3.fromRGB(255, 255, 255), -- Text trắng
        textSecondary = Color3.fromRGB(200, 200, 200), -- Text phụ
        textDark = Color3.fromRGB(50, 50, 50), -- Text tối
        
        -- Màu accent (nhấn mạnh)
        primary = Color3.fromRGB(0, 162, 255), -- Xanh dương
        success = Color3.fromRGB(52, 199, 89), -- Xanh lá
        warning = Color3.fromRGB(255, 149, 0), -- Cam
        danger = Color3.fromRGB(255, 59, 48), -- Đỏ
        
        -- Màu nền gradient
        gradientStart = Color3.fromRGB(138, 43, 226), -- Tím
        gradientEnd = Color3.fromRGB(30, 144, 255), -- Xanh dương
    }
    
    -- Độ trong suốt cho các element
    self.transparency = {
        glass = 0.15, -- Glass containers
        button = 0.25, -- Buttons
        hover = 0.1, -- Hover effect
        input = 0.2, -- Text inputs
        overlay = 0.3, -- Overlays
    }
    
    -- Kích thước chuẩn
    self.sizes = {
        cornerRadius = 12, -- Bo góc
        borderWidth = 1, -- Độ dày viền
        shadowOffset = 4, -- Offset của shadow
        
        -- Component sizes
        buttonHeight = 40,
        inputHeight = 36,
        sliderHeight = 20,
        toggleWidth = 50,
        toggleHeight = 24,
    }
    
    -- Font settings
    self.fonts = {
        default = Enum.Font.Gotham,
        bold = Enum.Font.GothamBold,
        mono = Enum.Font.RobotoMono,
    }
    
    -- Text sizes
    self.textSizes = {
        small = 12,
        normal = 14,
        large = 16,
        title = 20,
        header = 24,
    }
    
    -- Animation settings
    self.animations = {
        fast = 0.15,
        normal = 0.25,
        slow = 0.4,
        easing = Enum.EasingStyle.Quad,
        direction = Enum.EasingDirection.Out,
    }
    
    return self
end

-- Lấy màu theo theme (sáng/tối)
function Theme:getColor(colorName, isDark)
    if isDark then
        if colorName == "glass" then
            return self.colors.glassDark
        elseif colorName == "border" then
            return self.colors.borderDark
        elseif colorName == "text" then
            return self.colors.textDark
        end
    end
    return self.colors[colorName] or self.colors.glass
end

-- Tạo gradient background
function Theme:createGradient(parent, startColor, endColor, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, startColor or self.colors.gradientStart),
        ColorSequenceKeypoint.new(1, endColor or self.colors.gradientEnd)
    }
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

-- Tạo shadow effect (sử dụng ImageLabel với shadow image)
function Theme:createShadow(parent, size, offset)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = size or UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, offset or self.sizes.shadowOffset, 0, offset or self.sizes.shadowOffset)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Placeholder shadow
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ZIndex = -1
    shadow.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.sizes.cornerRadius)
    corner.Parent = shadow
    
    return shadow
end

-- Animation helper
function Theme:animateProperty(object, property, targetValue, duration, callback)
    local tween = game:GetService("TweenService"):Create(
        object,
        TweenInfo.new(
            duration or self.animations.normal,
            self.animations.easing,
            self.animations.direction
        ),
        {[property] = targetValue}
    )
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    tween:Play()
    return tween
end

-- Animate multiple properties
function Theme:animateProperties(object, properties, duration, callback)
    local tween = game:GetService("TweenService"):Create(
        object,
        TweenInfo.new(
            duration or self.animations.normal,
            self.animations.easing,
            self.animations.direction
        ),
        properties
    )
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    tween:Play()
    return tween
end

return Theme