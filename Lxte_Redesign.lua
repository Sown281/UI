--[[
	Enhanced User Interface Library
	Made by Late - Enhanced Version
	+ Windows-style title bar buttons (X, -, □)
	+ Dynamic nested components
	+ Recursive component system
]]

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
	Transparency = 0.2,
	ThemeMode = "Dark",
	Size = nil,
}

local Theme = { --// (Dark Theme)
	--// Frames:
	Primary = Color3.fromRGB(30, 30, 30),
	Secondary = Color3.fromRGB(35, 35, 35),
	Component = Color3.fromRGB(40, 40, 40),
	Interactables = Color3.fromRGB(45, 45, 45),

	--// Text:
	Tab = Color3.fromRGB(200, 200, 200),
	Title = Color3.fromRGB(240,240,240),
	Description = Color3.fromRGB(200,200,200),

	--// Outlines:
	Shadow = Color3.fromRGB(0, 0, 0),
	Outline = Color3.fromRGB(40, 40, 40),

	--// Image:
	Icon = Color3.fromRGB(220, 220, 220),
	
	--// Button Colors:
	CloseButton = Color3.fromRGB(232, 17, 35),
	MinimizeButton = Color3.fromRGB(255, 191, 0),
	MaximizeButton = Color3.fromRGB(0, 120, 215),
}

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
	local Style, Direction

	if Info then
		Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
	else
		Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
	end

	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object: Instance, Properties: {})
	for Index, Property in next, Properties do
		Object[Index] = (Property);
	end

	return Object
end

local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Y.Scale * Amount;
		Value.Y.Offset * Amount;
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

local Drag = function(Canvas)
	if Canvas then
		local Dragging;
		local DragInput;
		local Start;
		local StartPosition;

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
	TopLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, -1)};
	TopRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, -1)};
	BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
	BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
}

Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil

		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")

			for Index, Types in next, Positions:GetChildren() do
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

--// Windows-style Button Creation
local CreateWindowsButton = function(Parent, ButtonType, Position, Size)
	local Button = Instance.new("TextButton")
	local Corner = Instance.new("UICorner")
	
	Button.Name = ButtonType
	Button.Parent = Parent
	Button.BackgroundTransparency = 1
	Button.Position = Position
	Button.Size = Size or UDim2.new(0, 30, 0, 20)
	Button.Font = Enum.Font.SourceSansBold
	Button.TextSize = 14
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	
	Corner.CornerRadius = UDim.new(0, 3)
	Corner.Parent = Button
	
	-- Set button text and colors based on type
	if ButtonType == "Close" then
		Button.Text = "×"
		Button.TextSize = 16
		Button.BackgroundColor3 = Theme.CloseButton
	elseif ButtonType == "Minimize" then
		Button.Text = "−"
		Button.TextSize = 16
		Button.BackgroundColor3 = Theme.MinimizeButton
	elseif ButtonType == "Maximize" then
		Button.Text = "□"
		Button.TextSize = 12
		Button.BackgroundColor3 = Theme.MaximizeButton
	end
	
	-- Hover effects
	Button.MouseEnter:Connect(function()
		Button.BackgroundTransparency = 0
		Tween(Button, 0.15, { BackgroundTransparency = 0.2 })
	end)
	
	Button.MouseLeave:Connect(function()
		Tween(Button, 0.15, { BackgroundTransparency = 1 })
	end)
	
	return Button
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
	["Tabs"] = {};
	["NestedComponents"] = {}; -- New: Track nested components
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

	SetProperty(Window, {
		Size = Original,
	})

	Tween(Shadow, .25, { Transparency = 1 })
	Tween(Window, .25, {
		Size = Multiplied,
		GroupTransparency = 1,
	})

	task.wait(.25)
	Window.Size = Original
	Window.Visible = false
end

function Animations:Component(Component: any, Custom: boolean)	
	Connect(Component.InputBegan, function() 
		if Custom then
			Tween(Component, .25, { Transparency = .85 });
		else
			Tween(Component, .25, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) });
		end
	end)

	Connect(Component.InputEnded, function() 
		if Custom then
			Tween(Component, .25, { Transparency = 1 });
		else
			Tween(Component, .25, { BackgroundColor3 = Theme.Component });
		end
	end)
end

-- New: Nested component animation
function Animations:NestedExpand(Container: Instance, Expanded: boolean)
	local Content = Container:FindFirstChild("NestedContent")
	if not Content then return end
	
	if Expanded then
		Content.Visible = true
		Tween(Content, 0.3, { 
			GroupTransparency = 0,
			Size = UDim2.new(1, -10, 0, Content.UIListLayout.AbsoluteContentSize.Y + 10)
		})
	else
		Tween(Content, 0.2, { 
			GroupTransparency = 1,
			Size = UDim2.new(1, -10, 0, 0)
		})
		task.wait(0.2)
		Content.Visible = false
	end
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

	for Index, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end

	--// UI Blur & More
	Drag(Window);
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9));
	Setup.Transparency = Settings.Transparency or 0
	Setup.Size = Settings.Size
	Setup.ThemeMode = Settings.Theme or "Dark"

	if Settings.Blurring then
		Blurs[Settings.Title] = Blur.new(Window, 5)
		BlurEnabled = true
	end

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end

	--// Replace title bar buttons with Windows-style buttons
	local ButtonsContainer = Sidebar.Top.Buttons
	
	-- Clear existing buttons
	for _, child in pairs(ButtonsContainer:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- Create new Windows-style buttons
	local CloseBtn = CreateWindowsButton(ButtonsContainer, "Close", UDim2.new(1, -35, 0, 5))
	local MaximizeBtn = CreateWindowsButton(ButtonsContainer, "Maximize", UDim2.new(1, -70, 0, 5))
	local MinimizeBtn = CreateWindowsButton(ButtonsContainer, "Minimize", UDim2.new(1, -105, 0, 5))

	--// Animate
	local Close = function()
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

	-- Connect Windows-style buttons
	CloseBtn.MouseButton1Click:Connect(function()
		Close()
	end)

	MaximizeBtn.MouseButton1Click:Connect(function()
		if Maximized then
			Maximized = false
			MaximizeBtn.Text = "□"
			Tween(Window, .15, { Size = Setup.Size });
		else
			Maximized = true
			MaximizeBtn.Text = "⧉"
			Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5 )});
		end
	end)

	MinimizeBtn.MouseButton1Click:Connect(function()
		Opened = false
		Window.Visible = false
		if BlurEnabled then
			Blurs[Settings.Title].root.Parent = nil
		end
	end)

	Services.Input.InputBegan:Connect(function(Input, Focused) 
		if (Input == Setup.Keybind or Input.KeyCode == Setup.Keybind) and not Focused then
			Close()
		end
	end)

	--// Tab Functions
	function Options:SetTab(Name: string)
		for Index, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") then
				local Opened, SameName = Button.Value, (Button.Name == Name);
				local Padding = Button:FindFirstChildOfClass("UIPadding");

				if SameName and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) });
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) });
					SetProperty(Opened, { Value = true });
				elseif not SameName and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) });
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) });
					SetProperty(Opened, { Value = false });
				end
			end
		end

		for Index, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name);
				local Scroll = Main:FindFirstChild("ScrollingFrame");

				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true

					Tween(Main, .3, { GroupTransparency = 0 });
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) });

				elseif not SameName and Opened.Value then
					Opened.Value = false

					Tween(Main, .15, { GroupTransparency = 1 });
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) });	

					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings: { Name: string, Order: number })
		local Example = Examples["SectionExample"];
		local Section = Clone(Example);

		StoredInfo["Sections"][Settings.Name] = (Settings.Order);
		SetProperty(Section, { 
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true
		});
	end

	function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })
		if StoredInfo["Tabs"][Settings.Title] then 
			error("[UI LIB]: A tab with the same name has already been created") 
		end 

		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"];
		local Section = StoredInfo["Sections"][Settings.Section];
		local Main = Clone(MainExample);
		local Tab = Clone(Example);

		if not Settings.Icon then
			Destroy(Tab["ICO"]);
		else
			SetProperty(Tab["ICO"], { Image = Settings.Icon });
		end

		StoredInfo["Tabs"][Settings.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { Text = Settings.Title });

		SetProperty(Main, { 
			Parent = MainExample.Parent,
			Name = Settings.Title;
		});

		SetProperty(Tab, { 
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo["Sections"] + 1,
			Name = Settings.Title;
			Visible = true;
		});

		Tab.MouseButton1Click:Connect(function()
			Options:SetTab(Tab.Name);
		end)

		return Main.ScrollingFrame
	end
	
	--// Notifications
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number }) 
		local Notification = Clone(Components["Notification"]);
		local Title, Description = Options:GetLabels(Notification);
		local Timer = Notification["Timer"];
		
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Notification, {
			Parent = Screen["Frame"],
		})
		
		task.spawn(function() 
			local Duration = Settings.Duration or 2
			local Wait = task.wait;
			
			Animations:Open(Notification, Setup.Transparency, true); 
			Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) });
			Wait(Duration);
			Animations:Close(Notification);
			Wait(1);
			Notification:Destroy();
		end)
	end

	--// Component Functions
	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")
		return Labels.Title, Labels.Description
	end

	function Options:AddSection(Settings: { Name: string, Tab: Instance }) 
		local Section = Clone(Components["Section"]);
		SetProperty(Section, {
			Text = Settings.Name,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddButton(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Button = Clone(Components["Button"]);
		local Title, Description = Options:GetLabels(Button);

		Connect(Button.MouseButton1Click, Settings.Callback)
		Animations:Component(Button)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Button, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	-- NEW: Collapsible Group Component
	function Options:AddCollapsibleGroup(Settings: { Title: string, Description: string, Tab: Instance, Expanded: boolean })
		local Group = Instance.new("Frame")
		local Header = Clone(Components["Button"])
		local Content = Instance.new("CanvasGroup")
		local Layout = Instance.new("UIListLayout")
		local Padding = Instance.new("UIPadding")
		local Arrow = Instance.new("TextLabel")
		
		-- Setup main group
		Group.Name = Settings.Title .. "_Group"
		Group.Parent = Settings.Tab
		Group.BackgroundTransparency = 1
		Group.Size = UDim2.new(1, 0, 0, 50)
		Group.AutomaticSize = Enum.AutomaticSize.Y
		
		-- Setup header (clickable)
		Header.Parent = Group
		Header.Name = "Header"
		Header.Position = UDim2.new(0, 0, 0, 0)
		Header.Size = UDim2.new(1, 0, 0, 40)
		
		local Title, Description = Options:GetLabels(Header)
		Title.Text = Settings.Title
		Description.Text = Settings.Description
		
		-- Add arrow indicator
		Arrow.Name = "Arrow"
		Arrow.Parent = Header
		Arrow.BackgroundTransparency = 1
		Arrow.Position = UDim2.new(1, -25, 0.5, -8)
		Arrow.Size = UDim2.new(0, 16, 0, 16)
		Arrow.Text = Settings.Expanded and "▼" or "▶"
		Arrow.TextColor3 = Theme.Title
		Arrow.TextScaled = true
		Arrow.Font = Enum.Font.SourceSans
		
		-- Setup content container
		Content.Name = "NestedContent"
		Content.Parent = Group
		Content.BackgroundColor3 = Color(Theme.Component, -5)
		Content.Position = UDim2.new(0, 5, 0, 45)
		Content.Size = UDim2.new(1, -10, 0, 0)
		Content.GroupTransparency = Settings.Expanded and 0 or 1
		Content.Visible = Settings.Expanded or false
		
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 6)
		Corner.Parent = Content
		
		-- Setup layout for content
		Layout.Parent = Content
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Padding = UDim.new(0, 5)
		
		Padding.Parent = Content
		Padding.PaddingTop = UDim.new(0, 10)
		Padding.PaddingBottom = UDim.new(0, 10)
		Padding.PaddingLeft = UDim.new(0, 10)
		Padding.PaddingRight = UDim.new(0, 10)
		
		local IsExpanded = Settings.Expanded
		
		-- Handle click to expand/collapse
		Header.MouseButton1Click:Connect(function()
			IsExpanded = not IsExpanded
			Arrow.Text = IsExpanded and "▼" or "▶"
			Animations:NestedExpand(Group, IsExpanded)
		end)
		
		Animations:Component(Header)
		
		-- Return content container for adding nested components
		return Content
	end

	-- NEW: Recursive Tab System
	function Options:AddNestedTab(Settings: { Title: string, Parent: Instance, Icon: string? })
		local NestedTab = Instance.new("TextButton")
		local Content = Instance.new("CanvasGroup")
		local ScrollFrame = Instance.new("ScrollingFrame")
		local Layout = Instance.new("UIListLayout")
		local Padding = Instance.new("UIPadding")
		
		-- Setup nested tab button
		NestedTab.Name = Settings.Title
		NestedTab.Parent = Settings.Parent
		NestedTab.BackgroundColor3 = Color(Theme.Component, 10)
		NestedTab.BorderSizePixel = 0
		NestedTab.Size = UDim2.new(1, 0, 0, 35)
		NestedTab.Font = Enum.Font.SourceSans
		NestedTab.Text = "  " .. Settings.Title
		NestedTab.TextColor3 = Theme.Title
		NestedTab.TextSize = 14
		NestedTab.TextXAlignment = Enum.TextXAlignment.Left
		
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 4)
		Corner.Parent = NestedTab
		
		-- Setup content area
		Content.Name = Settings.Title .. "_Content"
		Content.Parent = Settings.Parent
		Content.BackgroundColor3 = Color(Theme.Secondary, -5)
		Content.Size = UDim2.new(1, 0, 0, 0)
		Content.GroupTransparency = 1
		Content.Visible = false
		Content.AutomaticSize = Enum.AutomaticSize.Y
		
		local ContentCorner = Instance.new("UICorner")
		ContentCorner.CornerRadius = UDim.new(0, 6)
		ContentCorner.Parent = Content
		
		-- Setup scrolling frame
		ScrollFrame.Parent = Content
		ScrollFrame.BackgroundTransparency = 1
		ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
		ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ScrollFrame.ScrollBarThickness = 4
		ScrollFrame.ScrollBarImageColor3 = Theme.Component
		
		Layout.Parent = ScrollFrame
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Padding = UDim.new(0, 5)
		
		Padding.Parent = ScrollFrame
		Padding.PaddingAll = UDim.new(0, 10)
		
		local IsOpen = false
		
		NestedTab.MouseButton1Click:Connect(function()
			IsOpen = not IsOpen
			
			if IsOpen then
				Content.Visible = true
				Tween(Content, 0.3, { GroupTransparency = 0 })
				Tween(NestedTab, 0.2, { BackgroundColor3 = Color(Theme.Component, 15) })
			else
				Tween(Content, 0.2, { GroupTransparency = 1 })
				Tween(NestedTab, 0.2, { BackgroundColor3 = Color(Theme.Component, 10) })
				task.wait(0.2)
				Content.Visible = false
			end
		end)
		
		Animations:Component(NestedTab)
		
		return ScrollFrame
	end

	function Options:AddInput(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Input = Clone(Components["Input"]);
		local Title, Description = Options:GetLabels(Input);
		local TextBox = Input["Main"]["Input"];

		Connect(Input.MouseButton1Click, function() 
			TextBox:CaptureFocus()
		end)

		Connect(TextBox.FocusLost, function() 
			Settings.Callback(TextBox.Text)
		end)

		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddToggle(Settings: { Title: string, Description: string, Default: boolean, Tab: Instance, Callback: any }) 
		local Toggle = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(Toggle);

		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["Circle"];
		
		local Set = function(Value)
			if Value then
				Tween(Main,   .2, { BackgroundColor3 = Color3.fromRGB(153, 155, 255) });
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
			else
				Tween(Main,   .2, { BackgroundColor3 = Theme.Interactables });
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) });
			end
			
			On.Value = Value
		end 

		Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value

			Set(Value)
			Settings.Callback(Value)
		end)

		Animations:Component(Toggle);
		Set(Settings.Default);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	-- NEW: Multi-Toggle Component (Radio buttons)
	function Options:AddMultiToggle(Settings: { Title: string, Description: string, Options: {}, Default: string, Tab: Instance, Callback: any })
		local MultiToggle = Instance.new("Frame")
		local Labels = Instance.new("Frame")
		local Title = Instance.new("TextLabel")
		local Description = Instance.new("TextLabel")
		local OptionsContainer = Instance.new("Frame")
		local Layout = Instance.new("UIListLayout")
		
		-- Setup main frame
		MultiToggle.Name = Settings.Title
		MultiToggle.Parent = Settings.Tab
		MultiToggle.BackgroundColor3 = Theme.Component
		MultiToggle.Size = UDim2.new(1, 0, 0, 60 + (#Settings.Options * 25))
		
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 6)
		Corner.Parent = MultiToggle
		
		-- Setup labels
		Labels.Name = "Labels"
		Labels.Parent = MultiToggle
		Labels.BackgroundTransparency = 1
		Labels.Size = UDim2.new(1, 0, 0, 40)
		
		Title.Name = "Title"
		Title.Parent = Labels
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 15, 0, 5)
		Title.Size = UDim2.new(1, -30, 0, 20)
		Title.Font = Enum.Font.SourceSansBold
		Title.Text = Settings.Title
		Title.TextColor3 = Theme.Title
		Title.TextSize = 14
		Title.TextXAlignment = Enum.TextXAlignment.Left
		
		Description.Name = "Description"
		Description.Parent = Labels
		Description.BackgroundTransparency = 1
		Description.Position = UDim2.new(0, 15, 0, 22)
		Description.Size = UDim2.new(1, -30, 0, 15)
		Description.Font = Enum.Font.SourceSans
		Description.Text = Settings.Description
		Description.TextColor3 = Theme.Description
		Description.TextSize = 12
		Description.TextXAlignment = Enum.TextXAlignment.Left
		
		-- Setup options container
		OptionsContainer.Name = "Options"
		OptionsContainer.Parent = MultiToggle
		OptionsContainer.BackgroundTransparency = 1
		OptionsContainer.Position = UDim2.new(0, 10, 0, 45)
		OptionsContainer.Size = UDim2.new(1, -20, 0, #Settings.Options * 25)
		
		Layout.Parent = OptionsContainer
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Padding = UDim.new(0, 2)
		
		local CurrentSelection = Settings.Default
		local OptionButtons = {}
		
		-- Create option buttons
		for i, option in ipairs(Settings.Options) do
			local OptionButton = Instance.new("TextButton")
			local Indicator = Instance.new("Frame")
			local InnerCircle = Instance.new("Frame")
			
			OptionButton.Name = option
			OptionButton.Parent = OptionsContainer
			OptionButton.BackgroundTransparency = 1
			OptionButton.Size = UDim2.new(1, 0, 0, 20)
			OptionButton.Font = Enum.Font.SourceSans
			OptionButton.Text = "   " .. option
			OptionButton.TextColor3 = Theme.Title
			OptionButton.TextSize = 12
			OptionButton.TextXAlignment = Enum.TextXAlignment.Left
			
			-- Radio button indicator
			Indicator.Name = "Indicator"
			Indicator.Parent = OptionButton
			Indicator.BackgroundColor3 = Theme.Interactables
			Indicator.Position = UDim2.new(0, 0, 0.5, -6)
			Indicator.Size = UDim2.new(0, 12, 0, 12)
			
			local IndicatorCorner = Instance.new("UICorner")
			IndicatorCorner.CornerRadius = UDim.new(1, 0)
			IndicatorCorner.Parent = Indicator
			
			local IndicatorStroke = Instance.new("UIStroke")
			IndicatorStroke.Color = Theme.Outline
			IndicatorStroke.Thickness = 1
			IndicatorStroke.Parent = Indicator
			
			InnerCircle.Name = "InnerCircle"
			InnerCircle.Parent = Indicator
			InnerCircle.BackgroundColor3 = Color3.fromRGB(153, 155, 255)
			InnerCircle.Position = UDim2.new(0.5, -3, 0.5, -3)
			InnerCircle.Size = UDim2.new(0, 6, 0, 6)
			InnerCircle.Visible = option == Settings.Default
			
			local InnerCorner = Instance.new("UICorner")
			InnerCorner.CornerRadius = UDim.new(1, 0)
			InnerCorner.Parent = InnerCircle
			
			OptionButtons[option] = { Button = OptionButton, Circle = InnerCircle }
			
			OptionButton.MouseButton1Click:Connect(function()
				-- Hide all circles
				for _, data in pairs(OptionButtons) do
					data.Circle.Visible = false
				end
				
				-- Show selected circle
				InnerCircle.Visible = true
				CurrentSelection = option
				Settings.Callback(option)
			end)
			
			Animations:Component(OptionButton)
		end
		
		Animations:Component(MultiToggle)
	end
	
	-- NEW: Progress Bar Component
	function Options:AddProgressBar(Settings: { Title: string, Description: string, Value: number, MaxValue: number, Tab: Instance })
		local ProgressBar = Clone(Components["Button"]) -- Use button as base
		local Title, Description = Options:GetLabels(ProgressBar)
		local ProgressContainer = Instance.new("Frame")
		local ProgressFill = Instance.new("Frame")
		local ProgressText = Instance.new("TextLabel")
		
		-- Setup progress container
		ProgressContainer.Name = "ProgressContainer"
		ProgressContainer.Parent = ProgressBar
		ProgressContainer.BackgroundColor3 = Theme.Interactables
		ProgressContainer.Position = UDim2.new(0, 15, 1, -25)
		ProgressContainer.Size = UDim2.new(1, -30, 0, 8)
		
		local ContainerCorner = Instance.new("UICorner")
		ContainerCorner.CornerRadius = UDim.new(0, 4)
		ContainerCorner.Parent = ProgressContainer
		
		-- Setup progress fill
		ProgressFill.Name = "ProgressFill"
		ProgressFill.Parent = ProgressContainer
		ProgressFill.BackgroundColor3 = Color3.fromRGB(153, 155, 255)
		ProgressFill.Size = UDim2.fromScale((Settings.Value or 0) / (Settings.MaxValue or 100), 1)
		
		local FillCorner = Instance.new("UICorner")
		FillCorner.CornerRadius = UDim.new(0, 4)
		FillCorner.Parent = ProgressFill
		
		-- Setup progress text
		ProgressText.Name = "ProgressText"
		ProgressText.Parent = ProgressBar
		ProgressText.BackgroundTransparency = 1
		ProgressText.Position = UDim2.new(1, -80, 0, 5)
		ProgressText.Size = UDim2.new(0, 70, 0, 20)
		ProgressText.Font = Enum.Font.SourceSans
		ProgressText.Text = tostring(Settings.Value or 0) .. "/" .. tostring(Settings.MaxValue or 100)
		ProgressText.TextColor3 = Theme.Description
		ProgressText.TextSize = 11
		ProgressText.TextXAlignment = Enum.TextXAlignment.Right
		
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		SetProperty(ProgressBar, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Size = UDim2.new(1, 0, 0, 65),
			Visible = true,
		})
		
		-- Return update function
		local UpdateProgress = function(NewValue, NewMax)
			local Value = NewValue or Settings.Value or 0
			local MaxValue = NewMax or Settings.MaxValue or 100
			
			ProgressText.Text = tostring(Value) .. "/" .. tostring(MaxValue)
			Tween(ProgressFill, 0.3, { Size = UDim2.fromScale(Value / MaxValue, 1) })
		end
		
		return UpdateProgress
	end

	function Options:AddKeybind(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Keybind"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Bind = Dropdown["Main"].Options;
		
		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }; 
		local Types = { 
			["Mouse"] = "Enum.UserInputType.MouseButton", 
			["Key"] = "Enum.KeyCode." 
		}
		
		Connect(Dropdown.MouseButton1Click, function()
			local Time = tick();
			local Detect, Finished
			
			SetProperty(Bind, { Text = "..." });
			Detect = Connect(game.UserInputService.InputBegan, function(Key, Focused) 
				local InputType = (Key.UserInputType);
				
				if not Finished and not Focused then
					Finished = (true)
					
					if table.find(Mouse, InputType) then
						Settings.Callback(Key);
						SetProperty(Bind, {
							Text = tostring(InputType):gsub(Types.Mouse, "MB")
						})
					elseif InputType == Enum.UserInputType.Keyboard then
						Settings.Callback(Key);
						SetProperty(Bind, {
							Text = tostring(Key.KeyCode):gsub(Types.Key, "")
						})
					end
				end 
			end)
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddDropdown(Settings: { Title: string, Description: string, Options: {}, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Text = Dropdown["Main"].Options;

		Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Examples["DropdownExample"]);
			local Buttons = Example["Top"]["Buttons"];

			Tween(BG, .25, { BackgroundTransparency = 0.6 });
			SetProperty(Example, { Parent = Window });
			Animations:Open(Example, 0, true)

			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)

					Connect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 });
						Animations:Close(Example);
						task.wait(2)
						Destroy(Example);
					end)
				end
			end

			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"]);
				local Title, Description = Options:GetLabels(Button);
				local Selected = Button["Value"];

				Animations:Component(Button);
				SetProperty(Title, { Text = Index });
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true });
				Destroy(Description);

				Connect(Button.MouseButton1Click, function() 
					local NewValue = not Selected.Value 

					if NewValue then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables });
						Settings.Callback(Option)
						Text.Text = Index

						for _, Others in next, Example:GetChildren() do
							if Others:IsA("TextButton") and Others ~= Button then
								Others.BackgroundColor3 = Theme.Component
							end
						end
					else
						Tween(Button, .25, { BackgroundColor3 = Theme.Component });
					end

					Selected.Value = NewValue
					Tween(BG, .25, { BackgroundTransparency = 1 });
					Animations:Close(Example);
					task.wait(2)
					Destroy(Example);
				end)
			end
		end)

		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddSlider(Settings: { Title: string, Description: string, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Tab: Instance, Callback: any }) 
		local Slider = Clone(Components["Slider"]);
		local Title, Description = Options:GetLabels(Slider);

		local Main = Slider["Slider"];
		local Amount = Main["Main"].Input;
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];
		local Circle = Fill["Circle"];

		local Active = false
		local Value = 0
		
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
			Scale = (Scale > 1 and 1) or (Scale < 0 and 0) or Scale
			
			if Number then
				Number = (Number > Settings.MaxValue and Settings.MaxValue) or (Number < 0 and 0) or Number
			end
			
			Value = SetNumber(Number or (Scale * Settings.MaxValue))
			Amount.Text = Value
			Fill.Size = UDim2.fromScale((Number and Number / Settings.MaxValue) or Scale, 1)
			Settings.Callback(Value)
		end

		local Activate = function()
			Active = true

			repeat task.wait()
				Update()
			until not Active
		end
		
		Connect(Amount.FocusLost, function() 
			Update(tonumber(Amount.Text) or 0)
		end)

		Connect(Fire.MouseButton1Down, Activate)
		Connect(Services.Input.InputEnded, function(Input) 
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		Fill.Size = UDim2.fromScale(Value, 1);
		Animations:Component(Slider);
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Slider, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	function Options:AddParagraph(Settings: { Title: string, Description: string, Tab: Instance }) 
		local Paragraph = Clone(Components["Paragraph"]);
		local Title, Description = Options:GetLabels(Paragraph);

		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Paragraph, {
			Parent = Settings.Tab,
			Visible = true,
		})
	end

	-- NEW: Color Picker Component
	function Options:AddColorPicker(Settings: { Title: string, Description: string, Default: Color3, Tab: Instance, Callback: any })
		local ColorPicker = Clone(Components["Button"])
		local Title, Description = Options:GetLabels(ColorPicker)
		local ColorPreview = Instance.new("Frame")
		
		-- Setup color preview
		ColorPreview.Name = "ColorPreview"
		ColorPreview.Parent = ColorPicker
		ColorPreview.BackgroundColor3 = Settings.Default or Color3.fromRGB(255, 255, 255)
		ColorPreview.Position = UDim2.new(1, -30, 0.5, -10)
		ColorPreview.Size = UDim2.new(0, 20, 0, 20)
		
		local PreviewCorner = Instance.new("UICorner")
		PreviewCorner.CornerRadius = UDim.new(0, 4)
		PreviewCorner.Parent = ColorPreview
		
		local PreviewStroke = Instance.new("UIStroke")
		PreviewStroke.Color = Theme.Outline
		PreviewStroke.Thickness = 1
		PreviewStroke.Parent = ColorPreview
		
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		SetProperty(ColorPicker, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
		
		-- Simple color picker (this would need a more complex implementation for full functionality)
		ColorPicker.MouseButton1Click:Connect(function()
			-- This is a simplified implementation - a full color picker would need HSV controls
			local colors = {
				Color3.fromRGB(255, 0, 0),
				Color3.fromRGB(0, 255, 0),
				Color3.fromRGB(0, 0, 255),
				Color3.fromRGB(255, 255, 0),
				Color3.fromRGB(255, 0, 255),
				Color3.fromRGB(0, 255, 255),
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(0, 0, 0)
			}
			
			local currentIndex = 1
			for i, color in ipairs(colors) do
				if ColorPreview.BackgroundColor3 == color then
					currentIndex = i
					break
				end
			end
			
			local nextIndex = (currentIndex % #colors) + 1
			local newColor = colors[nextIndex]
			
			ColorPreview.BackgroundColor3 = newColor
			Settings.Callback(newColor)
		end)
		
		Animations:Component(ColorPicker)
		
		-- Return function to update color
		local UpdateColor = function(NewColor)
			ColorPreview.BackgroundColor3 = NewColor
		end
		
		return UpdateColor
	end

	local Themes = {
		Names = {	
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, "Dark");
				end
			end,
			
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Description"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Description
				end
			end,
			
			["Section"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,

			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
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
				elseif Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
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

	function Options:SetTheme(Info)
		Theme = Info or Theme

		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		Window.UIStroke.Color = Theme.Shadow

		for Index, Descendant in next, Screen:GetDescendants() do
			local Name, Class =  Themes.Names[Descendant.Name],  Themes.Classes[Descendant.ClassName]

			if Name then
				Name(Descendant);
			elseif Class then
				Class(Descendant);
			end
		end
	end

	--// Changing Settings
	function Options:SetSetting(Setting, Value) --// Available settings - Size, Transparency, Blur, Theme
		if Setting == "Size" then
			
			Window.Size = Value
			Setup.Size = Value
			
		elseif Setting == "Transparency" then
			
			Window.GroupTransparency = Value
			Setup.Transparency = Value
			
			for Index, Notification in next, Screen:GetDescendants() do
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
					Blurs[Settings.Title] = Blur.new(Window, 5)
				elseif Root and not Root.Parent then
					Root.Parent = workspace.CurrentCamera
				end
			elseif not Value and (AlreadyBlurred and Root and Root.Parent) then
				Root.Parent = nil
				BlurEnabled = false
			end
			
		elseif Setting == "Theme" and typeof(Value) == "table" then
			
			Options:SetTheme(Value)
			
		elseif Setting == "Keybind" then
			
			Setup.Keybind = Value
			
		else
			warn("Tried to change a setting that doesn't exist or isn't available to change.")
		end
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen });
	Animations:Open(Window, Settings.Transparency or 0)

	return Options
end

return Library
