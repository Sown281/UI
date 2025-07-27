-- Background Module - Quản lý hiệu ứng blur và nền
local Background = {}
Background.__index = Background

function Background.new(parent)
    local self = setmetatable({}, Background)
    
    self.parent = parent
    self.blurEffects = {} -- Lưu trữ các blur effect
    
    -- Tạo background overlay
    self:createBackgroundOverlay()
    
    return self
end

-- Tạo lớp nền với gradient
function Background:createBackgroundOverlay()
    self.overlay = Instance.new("Frame")
    self.overlay.Name = "GlassUIOverlay"
    self.overlay.Size = UDim2.new(1, 0, 1, 0)
    self.overlay.Position = UDim2.new(0, 0, 0, 0)
    self.overlay.BackgroundTransparency = 0.7
    self.overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.overlay.BorderSizePixel = 0
    self.overlay.ZIndex = -10
    self.overlay.Parent = self.parent
    
    -- Thêm gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)), -- Tím
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 144, 255)), -- Xanh dương
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 20, 147)) -- Hồng
    }
    gradient.Rotation = 45
    gradient.Parent = self.overlay
    
    -- Animation cho gradient
    self:animateGradient(gradient)
end

-- Animation cho gradient background
function Background:animateGradient(gradient)
    local function animate()
        local tween = game:GetService("TweenService"):Create(
            gradient,
            TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {Rotation = gradient.Rotation + 360}
        )
        tween:Play()
    end
    
    spawn(animate)
end

-- Thêm hiệu ứng blur cho element (mô phỏng bằng cách sử dụng multiple layers)
function Background:addBlurEffect(element)
    -- Tạo blur container
    local blurContainer = Instance.new("Frame")
    blurContainer.Name = "BlurEffect"
    blurContainer.Size = UDim2.new(1, 0, 1, 0)
    blurContainer.Position = UDim2.new(0, 0, 0, 0)
    blurContainer.BackgroundTransparency = 1
    blurContainer.ZIndex = element.ZIndex - 1
    blurContainer.Parent = element
    
    -- Tạo nhiều layer để mô phỏng blur
    for i = 1, 3 do
        local layer = Instance.new("Frame")
        layer.Name = "BlurLayer" .. i
        layer.Size = UDim2.new(1, i * 2, 1, i * 2)
        layer.Position = UDim2.new(0, -i, 0, -i)
        layer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        layer.BackgroundTransparency = 0.85 + (i * 0.05)
        layer.BorderSizePixel = 0
        layer.ZIndex = -i
        layer.Parent = blurContainer
        
        -- Bo góc cho layer
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12 + i)
        corner.Parent = layer
    end
    
    -- Lưu blur effect để có thể xóa sau
    table.insert(self.blurEffects, blurContainer)
    
    return blurContainer
end

-- Tạo hiệu ứng glass reflection
function Background:addGlassReflection(element)
    local reflection = Instance.new("Frame")
    reflection.Name = "GlassReflection"
    reflection.Size = UDim2.new(0.6, 0, 0.3, 0)
    reflection.Position = UDim2.new(0.1, 0, 0.1, 0)
    reflection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    reflection.BackgroundTransparency = 0.8
    reflection.BorderSizePixel = 0
    reflection.Parent = element
    
    -- Gradient cho reflection
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    }
    gradient.Rotation = 135
    gradient.Parent = reflection
    
    -- Bo góc
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = reflection
    
    return reflection
end

-- Tạo hiệu ứng particle (dùng ImageLabel)
function Background:createParticles()
    local particleContainer = Instance.new("Frame")
    particleContainer.Name = "ParticleContainer"
    particleContainer.Size = UDim2.new(1, 0, 1, 0)
    particleContainer.Position = UDim2.new(0, 0, 0, 0)
    particleContainer.BackgroundTransparency = 1
    particleContainer.ZIndex = -5
    particleContainer.Parent = self.overlay
    
    -- Tạo các particle
    for i = 1, 20 do
        local particle = Instance.new("Frame")
        particle.Name = "Particle" .. i
        particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        particle.Position = UDim2.new(
            math.random() * 0.8 + 0.1,
            0,
            math.random() * 0.8 + 0.1,
            0
        )
        particle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        particle.BackgroundTransparency = math.random(50, 80) / 100
        particle.BorderSizePixel = 0
        particle.Parent = particleContainer
        
        -- Bo tròn particle
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = particle
        
        -- Animation cho particle
        self:animateParticle(particle)
    end
    
    return particleContainer
end

-- Animation cho particle
function Background:animateParticle(particle)
    local function animate()
        -- Random movement
        local newX = math.random() * 0.8 + 0.1
        local newY = math.random() * 0.8 + 0.1
        local duration = math.random(3, 8)
        
        local tween = game:GetService("TweenService"):Create(
            particle,
            TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {
                Position = UDim2.new(newX, 0, newY, 0),
                BackgroundTransparency = math.random(50, 90) / 100
            }
        )
        
        tween.Completed:Connect(function()
            wait(math.random(1, 3))
            animate() -- Repeat animation
        end)
        
        tween:Play()
    end
    
    spawn(animate)
end

-- Hiển thị overlay
function Background:show()
    if self.overlay then
        self.overlay.Visible = true
        
        -- Fade in animation
        game:GetService("TweenService"):Create(
            self.overlay,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.7}
        ):Play()
    end
end

-- Ẩn overlay
function Background:hide()
    if self.overlay then
        local tween = game:GetService("TweenService"):Create(
            self.overlay,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        )
        
        tween.Completed:Connect(function()
            self.overlay.Visible = false
        end)
        
        tween:Play()
    end
end

-- Cleanup
function Background:destroy()
    if self.overlay then
        self.overlay:Destroy()
    end
    
    for _, blurEffect in pairs(self.blurEffects) do
        if blurEffect then
            blurEffect:Destroy()
        end
    end
    
    self.blurEffects = {}
end

return Background