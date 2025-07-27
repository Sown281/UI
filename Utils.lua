-- Utils Module - Các hàm tiện ích
local Utils = {}

-- Clamp value trong khoảng min-max
function Utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Lerp (Linear interpolation) giữa 2 giá trị
function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

-- Chuyển đổi màu từ HSV sang RGB
function Utils.hsvToRgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    local remainder = i % 6
    
    if remainder == 0 then
        r, g, b = v, t, p
    elseif remainder == 1 then
        r, g, b = q, v, p
    elseif remainder == 2 then
        r, g, b = p, v, t
    elseif remainder == 3 then
        r, g, b = p, q, v
    elseif remainder == 4 then
        r, g, b = t, p, v
    elseif remainder == 5 then
        r, g, b = v, p, q
    end
    
    return Color3.fromRGB(r * 255, g * 255, b * 255)
end

-- Tính khoảng cách giữa 2 điểm
function Utils.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Random màu sắc
function Utils.randomColor()
    return Color3.fromRGB(
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255)
    )
end

-- Làm tối màu
function Utils.darkenColor(color, amount)
    amount = amount or 0.2
    return Color3.new(
        color.R * (1 - amount),
        color.G * (1 - amount),
        color.B * (1 - amount)
    )
end

-- Làm sáng màu
function Utils.lightenColor(color, amount)
    amount = amount or 0.2
    return Color3.new(
        math.min(1, color.R + amount),
        math.min(1, color.G + amount),
        math.min(1, color.B + amount)
    )
end

-- Tạo hiệu ứng typewriter cho text
function Utils.typewriterEffect(textLabel, text, speed, callback)
    speed = speed or 0.05
    textLabel.Text = ""
    
    spawn(function()
        for i = 1, #text do
            textLabel.Text = string.sub(text, 1, i)
            wait(speed)
        end
        
        if callback then
            callback()
        end
    end)
end

-- Tạo hiệu ứng fade in/out cho UI element
function Utils.fadeIn(element, duration, callback)
    duration = duration or 0.5
    local originalTransparency = element.BackgroundTransparency
    element.BackgroundTransparency = 1
    
    local tween = game:GetService("TweenService"):Create(
        element,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = originalTransparency}
    )
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    tween:Play()
    return tween
end

function Utils.fadeOut(element, duration, callback)
    duration = duration or 0.5
    
    local tween = game:GetService("TweenService"):Create(
        element,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    tween:Play()
    return tween
end

-- Scale animation
function Utils.scaleAnimation(element, targetScale, duration, callback)
    duration = duration or 0.3
    local originalSize = element.Size
    
    local tween = game:GetService("TweenService"):Create(
        element,
        TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = originalSize * targetScale}
    )
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    tween:Play()
    return tween
end

-- Bounce animation
function Utils.bounceAnimation(element, intensity, duration)
    intensity = intensity or 1.1
    duration = duration or 0.2
    local originalSize = element.Size
    
    local bounceUp = game:GetService("TweenService"):Create(
        element,
        TweenInfo.new(duration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = originalSize * intensity}
    )
    
    bounceUp.Completed:Connect(function()
        local bounceDown = game:GetService("TweenService"):Create(
            element,
            TweenInfo.new(duration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = originalSize}
        )
        bounceDown:Play()
    end)
    
    bounceUp:Play()
end

-- Shake animation
function Utils.shakeAnimation(element, intensity, duration)
    intensity = intensity or 5
    duration = duration or 0.5
    local originalPosition = element.Position
    
    spawn(function()
        local startTime = tick()
        while tick() - startTime < duration do
            local offsetX = (math.random() - 0.5) * intensity
            local offsetY = (math.random() - 0.5) * intensity
            element.Position = originalPosition + UDim2.new(0, offsetX, 0, offsetY)
            wait(0.03)
        end
        element.Position = originalPosition
    end)
end

-- Format số thành chuỗi có dấu phẩy
function Utils.formatNumber(number)
    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

-- Chuyển đổi giây thành format mm:ss
function Utils.formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

-- Tạo unique ID
function Utils.generateId()
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local id = ""
    for i = 1, 8 do
        local rand = math.random(1, #charset)
        id = id .. string.sub(charset, rand, rand)
    end
    return id
end

-- Deep copy table
function Utils.deepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for originalKey, originalValue in next, original, nil do
            copy[Utils.deepCopy(originalKey)] = Utils.deepCopy(originalValue)
        end
        setmetatable(copy, Utils.deepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

-- Merge tables
function Utils.mergeTables(t1, t2)
    local result = Utils.deepCopy(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = Utils.mergeTables(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- Kiểm tra điểm có nằm trong hình chữ nhật không
function Utils.pointInRect(pointX, pointY, rectX, rectY, rectWidth, rectHeight)
    return pointX >= rectX and pointX <= rectX + rectWidth and
           pointY >= rectY and pointY <= rectY + rectHeight
end

-- Tạo ripple effect
function Utils.createRippleEffect(parent, clickPosition)
    local ripple = Instance.new("Frame")
    ripple.Name = "RippleEffect"
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, clickPosition.X, 0, clickPosition.Y)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 10
    ripple.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    -- Animation
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    
    local expandTween = game:GetService("TweenService"):Create(
        ripple,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            Position = UDim2.new(0, clickPosition.X - maxSize/2, 0, clickPosition.Y - maxSize/2),
            BackgroundTransparency = 1
        }
    )
    
    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
    
    expandTween:Play()
end

-- Easing functions
Utils.Easing = {}

function Utils.Easing.easeInQuad(t)
    return t * t
end

function Utils.Easing.easeOutQuad(t)
    return t * (2 - t)
end

function Utils.Easing.easeInOutQuad(t)
    return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
end

function Utils.Easing.easeInCubic(t)
    return t * t * t
end

function Utils.Easing.easeOutCubic(t)
    return (t - 1)^3 + 1
end

function Utils.Easing.easeInOutCubic(t)
    return t < 0.5 and 4 * t^3 or (t - 1) * (2 * t - 2)^2 + 1
end

-- Device detection
function Utils.isMobile()
    return game:GetService("UserInputService").TouchEnabled and 
           not game:GetService("UserInputService").KeyboardEnabled
end

function Utils.isTablet()
    local gui = game:GetService("GuiService")
    return gui:IsTenFootInterface()
end

-- Screen size helpers
function Utils.getScreenSize()
    local camera = workspace.CurrentCamera
    return camera.ViewportSize
end

function Utils.getAspectRatio()
    local screenSize = Utils.getScreenSize()
    return screenSize.X / screenSize.Y
end

return Utils