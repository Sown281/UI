--[=[
	User Interface Library
	Made by Late, Upgraded by Grok
]=]

--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 

if (not game:IsLoaded()) then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded);
end

--// Important 
local Setup = {
	Keybind = Enum.KeyCode.LeftControl,
	Transparency = 0.05, -- Giảm độ mờ
	ThemeMode = "Dark",
	Size = nil,
}

local Themes = {
	Dark = {
		--// Frames:
		Primary = Color3.fromRGB(40, 40, 40), -- Sáng hơn một chút
		Secondary = Color3.fromRGB(45, 45, 45),
		Component = Color3.fromRGB(50, 50, 50),
		Interactables = Color3.fromRGB(60, 60, 60),
		--// Text:
		Tab = Color3.fromRGB(200, 200, 200),
		Title = Color3.fromRGB(240, 240, 240),
		Description = Color3.fromRGB(200, 200, 200),
		--// Outlines:
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(50, 50, 50),
		--// Image:
		Icon = Color3.fromRGB(220, 220, 220),
	},
	ModernLight = {
		--// Frames:
		Primary = Color3.fromRGB(245, 245, 245),
		Secondary = Color3.fromRGB(225, 225, 225),
		Component = Color3.fromRGB(205, 205, 205),
		Interactables = Color3.fromRGB(185, 185, 185),
		--// Text:
		Tab = Color3.fromRGB(50, 50, 50),
		Title = Color3.fromRGB(30, 30, 30),
		Description = Color3.fromRGB(70, 70, 70),
		--// Outlines:
		Shadow = Color3.fromRGB(150, 150, 150),
		Outline = Color3.fromRGB(200, 200, 200),
		--// Image:
		Icon = Color3.fromRGB(50, 50, 50),
	}
}

local Theme = Themes.Dark

--// Services & Functions
local Type, Blur = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween = GetService(game, "TweenService");
	Run = GetService(game, "RunService");
	Input = GetService(game, "UserInputService");
}

local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI = LocalPlayer.PlayerGui;
}

local Tween = function(Object : Instance, Speed : number, Properties : {},  Info : { EasingStyle: Enum?, EasingDirection: Enum? })
	local Style, Direction = Info and Info.EasingStyle or Enum.EasingStyle.Sine, Info and Info.EasingDirection or Enum.EasingDirection.Out
	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object: Instance, Properties: {})
	for Index, Property in next, Properties do
		Object[Index] = Property
	end
	return Object
end

local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount,
		Value.X.Offset * Amount,
		Value.Y.Scale * Amount,
		Value.Y.Offset * Amount,
	}
	return UDim2.new(unpack(New))
end

local Color = function(Color, Factor, Mode)
	Mode = Mode or Setup.ThemeMode
	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end

local AddGradient = function(Object, Color1, Color2)
	local Gradient = Instance.new("UIGradient")
	SetProperty(Gradient, {
		Color = ColorSequence.new(Color1, Color2),
		Rotation = 45,
		Parent = Object
	})
	return Gradient
end

local Drag = function(Canvas)
	if Canvas then
		local Dragging, DragInput, Start, StartPosition
		local function Update(input)
			local delta = input.Position - Start
			Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end

		Connect(Canvas.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position
				Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		Connect(Canvas.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				DragInput = Input
			end
		end)

		Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				Update(Input)
			end
		end)
	end
end

Resizing = { 
	TopLeft = { X = Vector2.new(-1, 0), Y = Vector2.new(0, -1)},
	TopRight = { X = Vector2.new(1, 0), Y = Vector2.new(0, -1)},
	BottomLeft = { X = Vector2.new(-1, 0), Y = Vector2.new(0, 1)},
	BottomRight = { X = Vector2.new(1, 0), Y = Vector2.new(0, 1)},
}

Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil
		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")
			for _, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
					end
				end)
				Connect(Types.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		end

		local Resize = function(Delta)
			if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resize")[Type.Name] == Type then
				local Mode = Resizing[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))
				local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset
				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)
				local NewPosition = UDim2.new(
					UIPos.X.Scale, 
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Tab.Position = NewPosition
			end
		end

		Connect(Player.Mouse.Move, function()
			if Type then
				Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
			end
		end)
	end)
end

--// Setup [UI]
if (identifyexecutor) then
	Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748");
	Blur = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Assets/Blur.lua"))();
else
	Screen = (script.Parent);
	Blur = require(script.Blur)
end

Screen.Main.Visible = false

xpcall(function()
	Screen.Parent = game.CoreGui
end, function() 
	Screen.Parent = Player.GUI
end)

--// Tables for Data
local Animations = {}
local Blurs = {}
local Components = (Screen:FindFirstChild("Components"));
local Library = {};
local StoredInfo = {
	["Sections"] = {};
	["Tabs"] = {}
};

--// Animations [Window]
function Animations:Open(Window: CanvasGroup, Transparency: number, UseCurrentSize: boolean)
	local Original = (UseCurrentSize and Window.Size) or Setup.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Shadow, { Transparency = 1 })
	SetProperty(Window, {
		Size = Multiplied,
		GroupTransparency = 1,
		Visible = true,
	})

	Tween(Shadow, .25, { Transparency = 0.5 })
	Tween(Window, .25, {
		Size = Original,
		GroupTransparency = Transparency or 0,
	})
end

function Animations:Close(Window: CanvasGroup)
	local Original = Window.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Window, { Size = Original })
	Tween(Shadow, .25, { Transparency = 1 })
	Tween(Window, .25, { Size = Multiplied, GroupTransparency = 1 })
	task.wait(.25)
	Window.Size = Original
	Window.Visible = false
end

function Animations:Component(Component: any, Custom: boolean)
	local OriginalSize = Component.Size
	Connect(Component.InputBegan, function() 
		if Custom then
			Tween(Component, .25, { Transparency = .85 })
		else
			Tween(Component, .25, { 
				BackgroundColor3 = Color(Theme.Component, 15, Setup.ThemeMode), -- Tăng độ sáng khi hover
				Size = Multiply(OriginalSize, 1.2) -- Phóng to 120%
			})
		end
	end)
	Connect(Component.InputEnded, function() 
		if Custom then
			Tween(Component, .25, { Transparency = 1 })
		else
			Tween(Component, .25, { 
				BackgroundColor3 = Theme.Component,
				Size = OriginalSize
			})
		end
	end)
end

--// Library [Window]
function Library:CreateWindow(Settings: { Title: string, Size: UDim2, Transparency: number, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean, Theme: string })
	local Window = Clone(Screen:WaitForChild("Main"));
	local Sidebar = Window:FindFirstChild("Sidebar");
	local Holder = Window:FindFirstChild("Main");
	local BG = Window:FindFirstChild("BackgroundShadow");
	local Tab = Sidebar:FindFirstChild("Tab");

	local Options = {};
	local Examples = {};
	local Opened = true;
	local Maximized = false;
	local BlurEnabled = false

	for _, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end

	--// UI Blur & More
	Drag(Window)
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9))
	Setup.Transparency = Settings.Transparency or 0.05
	Setup.Size = Settings.Size
	Setup.ThemeMode = Settings.Theme or "Dark"
	Theme = Themes[Setup.ThemeMode] or Themes.Dark

	AddGradient(Window, Theme.Primary, Theme.Secondary)
	local Corner = Instance.new("UICorner")
	SetProperty(Corner, { CornerRadius = UDim.new(0, 8), Parent = Window })

	if Settings.Blurring then
		Blurs[Settings.Title] = Blur.new(Window, 3) -- Giảm cường độ blur
		BlurEnabled = true
	end

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end

	--// Cập nhật 3 nút Minimize, Close, Maximize
	for _, Button in next, Sidebar.Top.Buttons:GetChildren() do
		if Button:IsA("TextButton") then
			local Name = Button.Name
			SetProperty(Button, {
				Size = UDim2.new(0, 35, 0, 35), -- Tăng kích thước
				BackgroundColor3 = Theme.Component,
				AutoButtonColor = false
			})
			local Corner = Instance.new("UICorner")
			SetProperty(Corner, { CornerRadius = UDim.new(1, 0), Parent = Button }) -- Hình tròn
			local Icon = Instance.new("ImageLabel")
			local iconId = Name == "Close" and "rbxassetid://6031094687" or -- X
			              Name == "Minimize" and "rbxassetid://6031094678" or -- -
			              "rbxassetid://6031094667" -- Vuông
			SetProperty(Icon, {
				Parent = Button,
				Image = iconId,
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				ImageColor3 = Theme.Icon
			})

			Connect(Button.InputBegan, function()
				local hoverColor = Name == "Close" and Color3.fromRGB(200, 50, 50) or
				                   Name == "Minimize" and Color3.fromRGB(200, 200, 50) or
				                   Color3.fromRGB(50, 200, 50)
				Tween(Button, .2, { 
					BackgroundColor3 = hoverColor,
					Size = UDim2.new(0, 42, 0, 42) -- Phóng to khi hover
				})
			end)
			Connect(Button.InputEnded, function()
				Tween(Button, .2, { 
					BackgroundColor3 = Theme.Component,
					Size = UDim2.new(0, 35, 0, 35)
				})
			end)

			Connect(Button.MouseButton1Click, function() 
				if Name == "Close" then
					if BlurEnabled then
						Blurs[Settings.Title].root.Parent = nil
					end
					Opened = false
					Animations:Close(Window)
					Window.Visible = false
				elseif Name == "Maximize" then
					if Maximized then
						Maximized = false
						Tween(Window, .15, { Size = Setup.Size })
					else
						Maximized = true
						Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5) })
					end
				elseif Name == "Minimize" then
					Opened = false
					Window.Visible = false
					if BlurEnabled then
						Blurs[Settings.Title].root.Parent = nil
					end
				end
			end)
		end
	end

	Services.Input.InputBegan:Connect(function(Input, Focused) 
		if (Input == Setup.Keybind or Input.KeyCode == Setup.Keybind) and not Focused then
			if Opened then
				if BlurEnabled then
					Blurs[Settings.Title].root.Parent = nil
				end
				Opened = false
				Animations:Close(Window)
				Window.Visible = false
			else
				Animations:Open(Window, Setup.Transparency)
				Opened = true
				if BlurEnabled then
					Blurs[Settings.Title].root.Parent = workspace.CurrentCamera
				end
			end
		end
	end)

	--// Tab Functions
	function Options:SetTab(Name: string)
		for _, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") then
				local Opened, SameName = Button.Value, (Button.Name == Name)
				local Padding = Button:FindFirstChildOfClass("UIPadding")
				local Gradient = Button:FindFirstChildOfClass("UIGradient")

				if SameName and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) })
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 25) })
					if Gradient then
						Gradient.Color = ColorSequence.new(Theme.Interactables, Theme.Component)
					end
					SetProperty(Opened, { Value = true })
				elseif not SameName and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) })
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 25) })
					if Gradient then
						Gradient.Color = ColorSequence.new(Theme.Component, Theme.Secondary)
					end
					SetProperty(Opened, { Value = false })
				end
			end
		end

		for _, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name)
				local Scroll = Main:FindFirstChild("ScrollingFrame")

				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true
					Tween(Main, .3, { GroupTransparency = 0 })
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) })
				elseif not SameName and Opened.Value then
					Opened.Value = false
					Tween(Main, .15, { GroupTransparency = 1 })
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) })
					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings: { Name: string, Order: number })
		if StoredInfo["Sections"][Settings.Name] then
			error("[UI LIB]: A section with the name '" .. Settings.Name .. "' already exists.")
		end
		local Example = Examples["SectionExample"]
		local Section = Clone(Example)

		StoredInfo["Sections"][Settings.Name] = Settings.Order
		SetProperty(Section, { 
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true,
			Font = Enum.Font.SourceSansPro, -- Font dễ đọc
			TextSize = 16
		})
	end

	function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })
		if StoredInfo["Tabs"][Settings.Title] then 
			error("[UI LIB]: A tab with the same name has already been created") 
		end 

		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"]
		local Section = StoredInfo["Sections"][Settings.Section]
		local Main = Clone(MainExample)
		local Tab = Clone(Example)

		if not Settings.Icon then
			Destroy(Tab["ICO"])
		else
			SetProperty(Tab["ICO"], { Image = Settings.Icon })
		end

		StoredInfo["Tabs"][Settings.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { 
			Text = Settings.Title,
			Font = Enum.Font.SourceSansPro, -- Font dễ đọc
			TextSize = 14
		})
		SetProperty(Main, { Parent = MainExample.Parent, Name = Settings.Title })
		SetProperty(Tab, { 
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo["Sections"] + 1,
			Name = Settings.Title,
			Visible = true,
			Size = UDim2.new(1, -44, 0, 25)
		})
		AddGradient(Tab, Theme.Component, Theme.Secondary)
		local Corner = Instance.new("UICorner")
		SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Tab })

		Tab.MouseButton1Click:Connect(function()
			Options:SetTab(Tab.Name)
		end)

		return Main.ScrollingFrame
	end
	
	--// Notifications
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number, Icon: string? }) 
		local Notification = Clone(Components["Notification"])
		local Title, Description = Options:GetLabels(Notification)
		local Timer = Notification["Timer"]

		SetProperty(Title, { 
			Text = Settings.Title,
			Font = Enum.Font.SourceSansPro, -- Font dễ đọc
			TextSize = 16
		})
		SetProperty(Description, { 
			Text = Settings.Description,
			Font = Enum.Font.SourceSansPro,
			TextSize = 14
		})
		SetProperty(Notification, { Parent = Screen["Frame"] })
		AddGradient(Notification, Theme.Primary, Theme.Secondary)
		local Corner = Instance.new("UICorner")
		SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Notification })

		if Settings.Icon then
			local Icon = Instance.new("ImageLabel")
			SetProperty(Icon, {
				Parent = Notification,
				Image = Settings.Icon,
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(0, 10, 0, 10),
				BackgroundTransparency = 1,
				ImageColor3 = Theme.Icon
			})
			local Particle = Instance.new("ParticleEmitter")
			SetProperty(Particle, {
				Parent = Icon,
				Texture = "rbxassetid://243728304",
				Size = NumberSequence.new(0.5),
				Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)}),
				Lifetime = NumberRange.new(0.5, 1),
				Rate = 5,
				Speed = NumberRange.new(1, 2),
				SpreadAngle = Vector2.new(-360, 360)
			})
			Particle:Emit(10)
			task.delay(Settings.Duration or 2, function()
				Particle.Enabled = false
			end)
		end

		task.spawn(function() 
			local Duration = Settings.Duration or 2
			Animations:Open(Notification, Setup.Transparency, true)
			Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) })
			task.wait(Duration)
			Animations:Close(Notification)
			task.wait(1)
			Notification:Destroy()
		end)
	end

	--// Component Functions
	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")
		return Labels.Title, Labels.Description
	end

	function Options:AddSection(Settings: { Name: string, Tab: Instance }) 
		local Section = Clone(Components["Section"])
		SetProperty(Section, {
			Text = Settings.Name,
			Parent = Settings.Tab,
			Visible = true,
			Font = Enum.Font.SourceSansPro,
			TextSize = 16
		})
	end
	
	function Options:AddButton(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Button = Clone(Components["Button"])
		local Title, Description = Options:GetLabels(Button)

		Connect(Button.MouseButton1Click, Settings.Callback)
		Animations:Component(Button)
		AddGradient(Button, Theme.Component, Theme.Interactables)
		local Corner = Instance.new("UICorner")
		SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Button })

		SetProperty(Title, { 
			Text = Settings.Title,
			Font = Enum.Font.SourceSansPro,
			TextSize = 16
		})
		SetProperty(Description, { 
			Text = Settings.Description,
			Font = Enum.Font.SourceSansPro,
			TextSize = 14
		})
		SetProperty(Button, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddInput(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Input = Clone(Components["Input"])
		local Title, Description = Options:GetLabels(Input)
		local TextBox = Input["Main"]["Input"]

		Connect(Input.MouseButton1Click, function() 
			TextBox:CaptureFocus()
		end)
		Connect(TextBox.FocusLost, function() 
			Settings.Callback(TextBox.Text)
		end)

		Animations:Component(Input)
		AddGradient(Input, Theme.Component, Theme.Interactables)
		local Corner = Instance.new("UICorner")
		SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Input })

		SetProperty(Title, { 
			Text = Settings.Title,
			Font = Enum.Font.SourceSansPro,
			TextSize = 16
		})
		SetProperty(Description, { 
			Text = Settings.Description,
			Font = Enum.Font.SourceSansPro,
			TextSize = 14
		})
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddToggle(Settings: { Title: string, Description: string, Default: boolean, Tab: Instance, Callback: any }) 
		local Toggle = Clone(Components["Toggle"])
		local Title, Description = Options:GetLabels(Toggle)
		local On = Toggle["Value"]
		local Main = Toggle["Main"]
		local Circle = Main["Circle"]
		
		local Set = function(Value)
			if Value then
				Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(153, 155, 255) })
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) })
			else
				Tween(Main, .2, { BackgroundColor3 = Theme.Interactables })
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) })
			end
			On.Value = Value
		end 

		Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value
			Set(Value)
			Settings.Callback(Value)
		end)

		Animations:Component(Toggle)
		AddGradient(Toggle, Theme.Component, Theme.Interactables)
		local Corner = Instance.new("UICorner")
		SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Toggle })

		Set(Settings.Default)
		SetProperty(Title, { 
			Text = Settings.Title,
			Font = Enum.Font.SourceSansPro,
			TextSize = 16
		})
		SetProperty(Description, { 
			Text = Settings.Description,
			Font = Enum.Font.SourceSansPro,
			TextSize = 14
		})
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddKeybind(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Keybind"])
		local Title, Description = Options:GetLabels(Dropdown)
		local Bind = Dropdown["Main"].Options
		
		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }
		local Types = { 
			["Mouse"] = "Enum.UserInputType.MouseButton", 
			["Key"] = "Enum.KeyCode." 
		}
		
		Connect(Dropdown.MouseButton1Click, function()
			local Detect, Finished
			SetProperty(Bind, { Text = "..." })
			Detect = Connect(game.UserInputService.InputBegan, function(Key, Focused) 
				local InputType = Key.UserInputType
				if not Finished and not Focused then
					Finished = true
					if table.find(Mouse, InputType) then
						Settings.Callback(Key)
						SetProperty(Bind, { Text = tostring(InputType):gsub(Types.Mouse, "MB") })
					elseif InputType == Enum.UserInputType.Keyboard then
						Settings.Callback(Key)
						SetProperty(Bind, { Text = tostring(Key.KeyCode):gsub(Types.Key, "") })
					end
				end 
			end)
		end)

		Animations:Component(Dropdown)
		AddGradient(Dropdown, Theme.Component, Theme.Interactables)
		local Corner = Instance.new("UICorner")
		SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Dropdown })

		SetProperty(Title, { 
			Text = Settings.Title,
			Font = Enum.Font.SourceSansPro,
			TextSize = 16
		})
		SetProperty(Description, { 
			Text = Settings.Description,
			Font = Enum.Font.SourceSansPro,
			TextSize = 14
		})
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddDropdown(Settings: { Title: string, Description: string, Options: {}, MultiSelect: boolean, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Dropdown"])
		local Title, Description = Options:GetLabels(Dropdown)
		local Text = Dropdown["Main"].Options
		local selectedOptions = Settings.MultiSelect and {} or nil

		Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Examples["DropdownExample"])
			Tween(BG, .25, { BackgroundTransparency = 0.6 })
			SetProperty(Example, { Parent = Window })
			AddGradient(Example, Theme.Secondary, Theme.Primary)
			local Corner = Instance.new("UICorner")
			SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Example })
			Animations:Open(Example, 0, true)

			for _, Button in next, Example["Top"]["Buttons"]:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)
					Connect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 })
						Animations:Close(Example)
						task.wait(2)
						Destroy(Example)
					end)
				end
			end

			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"])
				local Title, Description = Options:GetLabels(Button)
				local Selected = Button["Value"]

				Animations:Component(Button)
				AddGradient(Button, Theme.Component, Theme.Interactables)
				local Corner = Instance.new("UICorner")
				SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Button })

				SetProperty(Title, { 
					Text = Index,
					Font = Enum.Font.SourceSansPro,
					TextSize = 14
				})
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true })
				Destroy(Description)

				Connect(Button.MouseButton1Click, function() 
					local NewValue = not Selected.Value 
					if NewValue then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables })
						if Settings.MultiSelect then
							table.insert(selectedOptions, Option)
						else
							Settings.Callback(Option)
							Text.Text = Index
							Tween(BG, .25, { BackgroundTransparency = 1 })
							Animations:Close(Example)
							task.wait(2)
							Destroy(Example)
						end
					else
						Tween(Button, .25, { BackgroundColor3 = Theme.Component })
						if Settings.MultiSelect then
							local idx = table.find(selectedOptions, Option)
							if idx then table.remove(selectedOptions, idx) end
						end
					end
					Selected.Value = NewValue
				end)
			end

			if Settings.MultiSelect then
				local DoneButton = Instance.new("TextButton")
				SetProperty(DoneButton, {
					Parent = Example,
					Text = "Done",
					Font = Enum.Font.SourceSansPro,
					TextSize = 14,
					Size = UDim2.new(1, 0, 0, 30),
					Position = UDim2.new(0, 0, 1, 0),
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = Theme.Interactables,
					TextColor3 = Theme.Title
				})
				AddGradient(DoneButton, Theme.Interactables, Theme.Component)
				local Corner = Instance.new("UICorner")
				SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = DoneButton })
				Connect(DoneButton.MouseButton1Click, function()
					Settings.Callback(selectedOptions)
					Text.Text = #selectedOptions > 0 and table.concat(selectedOptions, ", ") or "Select..."
					Tween(BG, .25, { BackgroundTransparency = 1 })
					Animations:Close(Example)
					task.wait(2)
					Destroy(Example)
				end)
			end
		end)

		Animations:Component(Dropdown)
		AddGradient(Dropdown, Theme.Component, Theme.Interactables)
		local Corner = Instance.new("UICorner")
		SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Dropdown })

		SetProperty(Title, { 
			Text = Settings.Title,
			Font = Enum.Font.SourceSansPro,
			TextSize = 16
		})
		SetProperty(Description, { 
			Text = Settings.Description,
			Font = Enum.Font.SourceSansPro,
			TextSize = 14
		})
		SetProperty(Dropdown, { Name = Settings.Title, Parent = Settings.Tab, Visible = true })
	end

	function Options:AddSlider(Settings: { Title: string, Description: string, MinValue: number, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Tab: Instance, Callback: any }) 
		local Slider = Clone(Components["Slider"])
		local Title, Description = Options:GetLabels(Slider)
		local Main = Slider["Slider"]
		local Amount = Main["Main"].Input
		local Slide = Main["Slide"]
		local Fire = Slide["Fire"]
		local Fill = Slide["Highlight"]
		local Circle = Fill["Circle"]

		local Active = false
		local Value = Settings.MinValue or 0
		local minValue = Settings.MinValue or 0
		local maxValue = Settings.MaxValue

		local MinLabel = Instance.new("TextLabel")
		SetProperty(MinLabel, {
			Parent = Slide,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, 20, 1, 0),
			Text = tostring(minValue),
			TextColor3 = Theme.Title,
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansPro,
			TextSize = 14
		})

		local MaxLabel = Instance.new("TextLabel")
		SetProperty(MaxLabel, {
			Parent = Slide,
			Position = UDim2.new(1, -20, 0, 0),
			Size = UDim2.new(0, 20, 1, 0),
			Text = tostring(maxValue),
			TextColor3 = Theme.Title,
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansPro,
			TextSize = 14
		})

		AddGradient(Fill, Theme.Interactables, Color3.fromRGB(153, 155, 255))
		local Corner = Instance.new("UICorner")
		SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Slider })

		local SetNumber = function(Number)
			if Settings.AllowDecimals then
				local Power = 10 ^ (Settings.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end
			return Number
		end

		local Update = function(Number)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X
			Scale = math.clamp(Scale, 0, 1)
			if Number then
				Number = math.clamp(Number, minValue, maxValue)
			else
				Number = minValue + Scale * (maxValue - minValue)
			end
			Value = SetNumber(Number)
			Amount.Text = Value
			local fillScale = (Number - minValue) / (maxValue - minValue)
			Fill.Size = UDim2.fromScale(fillScale, 1)
			Settings.Callback(Value)
		end

		local Activate = function()
			Active = true
			repeat task.wait() Update() until not Active
		end

		Connect(Amount.FocusLost, function() 
			Update(tonumber(Amount.Text) or minValue)
		end)

		Connect(Fire.MouseButton1Down, Activate)
		Connect(Services.Input.InputEnded, function(Input) 
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		Fill.Size = UDim2.fromScale((Value - minValue) / (maxValue - minValue), 1)
		Animations:Component(Slider)
		SetProperty(Title, { 
			Text = Settings.Title,
			Font = Enum.Font.SourceSansPro,
			TextSize = 16
		})
		SetProperty(Description, { 
			Text = Settings.Description,
			Font = Enum.Font.SourceSansPro,
			TextSize = 14
		})
		SetProperty(Slider, { Name = Settings.Title, Parent = Settings.Tab, Visible = true })
	end

	function Options:AddParagraph(Settings: { Title: string, Description: string, Tab: Instance }) 
		local Paragraph = Clone(Components["Paragraph"])
		local Title, Description = Options:GetLabels(Paragraph)

		SetProperty(Title, { 
			Text = Settings.Title,
			Font = Enum.Font.SourceSansPro,
			TextSize = 16
		})
		SetProperty(Description, { 
			Text = Settings.Description,
			Font = Enum.Font.SourceSansPro,
			TextSize = 14
		})
		SetProperty(Paragraph, { Parent = Settings.Tab, Visible = true })
		AddGradient(Paragraph, Theme.Component, Theme.Interactables)
		local Corner = Instance.new("UICorner")
		SetProperty(Corner, { CornerRadius = UDim.new(0, 6), Parent = Paragraph })
	end

	function Options:AddSeparator(Settings: { Tab: Instance }) 
		local Separator = Instance.new("Frame")
		SetProperty(Separator, {
			Size = UDim2.new(1, 0, 0, 5),
			BackgroundTransparency = 1,
			Parent = Settings.Tab
		})
		local Line = Instance.new("Frame")
		SetProperty(Line, {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = Theme.Outline,
			Parent = Separator
		})
		AddGradient(Line, Theme.Outline, Theme.Shadow)
	end

	local ThemeStyles = {
		Names = {	
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode)
				end
			end,
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
					Label.Font = Enum.Font.SourceSansPro
					Label.TextSize = 16
				end
			end,
			["Description"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Description
					Label.Font = Enum.Font.SourceSansPro
					Label.TextSize = 14
				end
			end,
			["Section"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
					Label.Font = Enum.Font.SourceSansPro
					Label.TextSize = 16
				end
			end,
			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
					Label.Font = Enum.Font.SourceSansPro
					Label.TextSize = 14
				end
			end,
			["Notification"] = function(Label)
				if Label:IsA("CanvasGroup") then
					Label.BackgroundColor3 = Theme.Primary
					Label.UIStroke.Color = Theme.Outline
				end
			end,
			["TextLabel"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent:FindFirstChild("List") then
					Label.TextColor3 = Theme.Tab
					Label.Font = Enum.Font.SourceSansPro
					Label.TextSize = 14
				end
			end,
			["Main"] = function(Label)
				if Label:IsA("Frame") then
					if Label.Parent == Window then
						Label.BackgroundColor3 = Theme.Secondary
					elseif Label.Parent:FindFirstChild("Value") then
						local Toggle = Label.Parent.Value 
						local Circle = Label:FindFirstChild("Circle")
						if not Toggle.Value then
							Label.BackgroundColor3 = Theme.Interactables
							Label.Circle.BackgroundColor3 = Theme.Primary
						end
					else
						Label.BackgroundColor3 = Theme.Interactables
					end
				elseif Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
					Label.Font = Enum.Font.SourceSansPro
					Label.TextSize = 14
				end
			end,
			["Amount"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,
			["Slide"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,
			["Input"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
					Label.Font = Enum.Font.SourceSansPro
					Label.TextSize = 16
				elseif Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
					Label.Font = Enum.Font.SourceSansPro
					Label.TextSize = 14
				end
			end,
			["Outline"] = function(Stroke)
				if Stroke:IsA("UIStroke") then
					Stroke.Color = Theme.Outline
				end
			end,
			["DropdownExample"] = function(Label)
				Label.BackgroundColor3 = Theme.Secondary
			end,
			["Underline"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Outline
				end
			end,
		},
		Classes = {
			["ImageLabel"] = function(Label)
				if Label.Image ~= "rbxassetid://6644618143" then
					Label.ImageColor3 = Theme.Icon
				end
			end,
			["TextLabel"] = function(Label)
				if Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
					Label.Font = Enum.Font.SourceSansPro
					Label.TextSize = 14
				end
			end,
			["TextButton"] = function(Label)
				if Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				end
			end,
			["ScrollingFrame"] = function(Label)
				Label.ScrollBarImageColor3 = Theme.Component
			end,
		},
	}

	function Options:SetTheme(ThemeName)
		Theme = Themes[ThemeName] or Themes.Dark
		Setup.ThemeMode = ThemeName or "Dark"

		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		Window.UIStroke.Color = Theme.Shadow

		for _, Descendant in next, Screen:GetDescendants() do
			local Name, Class = ThemeStyles.Names[Descendant.Name], ThemeStyles.Classes[Descendant.ClassName]
			if Name then
				Name(Descendant)
			elseif Class then
				Class(Descendant)
			end
			local Gradient = Descendant:FindFirstChildOfClass("UIGradient")
			if Gradient then
				if Descendant:IsA("TextButton") and Descendant.Parent.Name == "Tab" then
					Gradient.Color = Descendant.Value and Descendant.Value.Value and ColorSequence.new(Theme.Interactables, Theme.Component) or ColorSequence.new(Theme.Component, Theme.Secondary)
				elseif Descendant.Name == "Highlight" then
					Gradient.Color = ColorSequence.new(Theme.Interactables, Color3.fromRGB(153, 155, 255))
				else
					Gradient.Color = ColorSequence.new(Theme.Primary, Theme.Secondary)
				end
			end
		end
	end

	--// Changing Settings
	function Options:SetSetting(Setting, Value)
		if Setting == "Size" then
			Window.Size = Value
			Setup.Size = Value
		elseif Setting == "Transparency" then
			Window.GroupTransparency = Value
			Setup.Transparency = Value
			for _, Notification in next, Screen:GetDescendants() do
				if Notification:IsA("CanvasGroup") and Notification.Name == "Notification" then
					Notification.GroupTransparency = Value
				end
			end
		elseif Setting == "Blur" then
			local AlreadyBlurred, Root = Blurs[Settings.Title], nil
			if AlreadyBlurred then
				Root = Blurs[Settings.Title]["root"]
			end
			if Value then
				BlurEnabled = true
				if not AlreadyBlurred or not Root then
					Blurs[Settings.Title] = Blur.new(Window, 3)
				elseif Root and not Root.Parent then
					Root.Parent = workspace.CurrentCamera
				end
			elseif not Value and (AlreadyBlurred and Root and Root.Parent) then
				Root.Parent = nil
				BlurEnabled = false
			end
		elseif Setting == "Theme" and Themes[Value] then
			Options:SetTheme(Value)
		elseif Setting == "Keybind" then
			Setup.Keybind = Value
		else
			warn("Tried to change a setting that doesn't exist or isn't available to change.")
		end
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen })
	Animations:Open(Window, Settings.Transparency or 0.05)
	return Options
end

return Library
