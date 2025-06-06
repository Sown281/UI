local DragonLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/daucobonhi/uilibrary/refs/heads/main/Sitink%20Lib/SitinkUIfix.lua"))()
local Window = DragonLib:Start({
    ["Name"] = "DragonToro Make Ui",
    ["Description"] = "",
    ["Info Color"] = Color3.fromRGB(13, 182, 255),
    ["Tab Width"] = 135,
    ["Color"] = Color3.fromRGB(13, 182, 255),
    ["CloseCallBack"] = function() end
})
local MainTab = Window:MakeTab("Main")
local Section = MainTab:Section({["Title"] = "Information", ["Content"] = ""})
local Seperator = Section:Seperator("Local Player")

local Paragraph = Section:Paragraph({
    ["Title"] = "Paragraph",
    ["Content"] = ""
})
local Paragraph1 = Section:Paragraph({
    ["Title"] = "Paragraph",
    ["Content"] = "This is a Paragraph"
})
local Button = Section:Button({
    ["Title"] = "Button",
    ["Content"] = "",
    ["Callback"] = function()
        print("Button Clicked!")
    end
})
local Button1 = Section:Button({
    ["Title"] = "Button",
    ["Content"] = "This is a Button",
    ["Callback"] = function()
        print("Button Clicked!")
    end
})
local TextInput = Section:TextInput({
    ["Title"] = "Text Input",
    ["Content"] = "",
    ["Place Holder Text"] = "Enter you text here...",
    ["Clear Text On Focus"] = true,
    ["Callback"] = function(Value)
        print(Value)
    end
})
local TextInput1 = Section:TextInput({
    ["Title"] = "Text Input",
    ["Content"] = "This is a Text Input",
    ["Place Holder Text"] = "Enter you text here...",
    ["Clear Text On Focus"] = true,
    ["Callback"] = function(Value)
        print(Value)
    end
})
local Toggle = Section:Toggle({
	["Title"]= "Toggle",
	["Content"] = "",
	["Default"] = true,
	["Callback"] = function(Value) 
		print(Value)
	end
})
local Toggle1 = Section:Toggle({
	["Title"]= "Toggle",
	["Content"] = "This is a Toggle",
	["Default"] = false,
	["Callback"] = function(Value) 
		print(Value)
	end
})
local Slider = Section:Slider({
    ["Title"] = "Slider",
    ["Content"] = "",
    ["Min"] = 0,
    ["Max"] = 100,
    ["Increment"] = 1,
    ["Default"] = 30,
    ["Callback"] = function(Value)
        print(Value)
    end
})
local Slider1 = Section:Slider({
    ["Title"] = "Slider",
    ["Content"] = "This is a Slider",
    ["Min"] = 0,
    ["Max"] = 100,
    ["Increment"] = 1,
    ["Default"] = 30,
    ["Callback"] = function(Value)
        print(Value)
    end
})
local Dropdown = Section:Dropdown({
    ["Title"] = "Dropdown",
    ["Multi"] = true,
    ["Options"] = {"Option 1", "Option 2"},
    ["Default"] = {"Option 1"},
    ["Place Holder Text"] = "Select Options",
    ["Callback"] = function(Value)
        print(Value)
    end
})
local ProfileTab = Window:MakeTab("Profile")

local ScreenGui1 = Instance.new("ScreenGui")
local ImageButton1 = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui1.Name = "ImageButton"
ScreenGui1.Parent = game.CoreGui
ScreenGui1.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ImageButton1.Parent = ScreenGui1
ImageButton1.BorderSizePixel = 0
ImageButton1.Position = UDim2.new(0.120833337, 0, 0.0952890813, 0)
ImageButton1.Size = UDim2.new(0, 50, 0, 50)
ImageButton1.Draggable = true
ImageButton1.Image = "http://www.roblox.com/asset/?id=86093074270143"
ImageButton1.MouseButton1Down:connect(function()
  DragonLib:ToggleUI()
end)
UICorner.Parent = ImageButton1
UIStroke.Color = Color3.fromRGB(13, 182, 255)
UIStroke.Thickness = 2
UIStroke.Parent = ImageButton1

