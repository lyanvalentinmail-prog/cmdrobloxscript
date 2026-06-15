--// CMD Library con Args opcionales (Infinite Yield style)

local CMD = {}
CMD.Commands = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- GUI
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "CMD_UI"

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromScale(0.5,0.4)
Main.Position = UDim2.fromScale(0.25,0.3)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "Command Console"
Title.Font = Enum.Font.Code
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

local List = Instance.new("ScrollingFrame", Main)
List.Position = UDim2.new(0,10,0,35)
List.Size = UDim2.new(1,-20,1,-80)
List.BackgroundColor3 = Color3.fromRGB(14,14,14)
List.CanvasSize = UDim2.new()
List.ScrollBarImageTransparency = 0.4
Instance.new("UICorner", List)

local Layout = Instance.new("UIListLayout", List)
Layout.Padding = UDim.new(0,5)

local Input = Instance.new("TextBox", Main)
Input.Position = UDim2.new(0,10,1,-35)
Input.Size = UDim2.new(1,-20,0,25)
Input.PlaceholderText = ";speed 50"
Input.ClearTextOnFocus = false
Input.BackgroundColor3 = Color3.fromRGB(30,30,30)
Input.TextColor3 = Color3.new(1,1,1)
Input.Font = Enum.Font.Code
Input.TextSize = 15
Instance.new("UICorner", Input)

-- UI helpers
local function Clear()
    for _,v in pairs(List:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end

local function Line(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-10,0,18)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Left
    l.Text = text
    l.Font = Enum.Font.Code
    l.TextSize = 14
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Parent = List
    task.wait()
    List.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+5)
end

local function Refresh(filter)
    Clear()
    for _,cmd in pairs(CMD.Commands) do
        if not filter or cmd.Name:sub(1,#filter) == filter then
            local argText = cmd.HasArgs and (" ["..cmd.ArgName.."]") or ""
            Line(";"..cmd.Name..argText.."  -  "..cmd.Desc)
        end
    end
end

-- Add command
function CMD:AddCommand(data)
    CMD.Commands[data.Name] = data
    Refresh()
end

-- Auto list while typing
Input:GetPropertyChangedSignal("Text"):Connect(function()
    local t = Input.Text
    if t:sub(1,1) ~= ";" then return end
    local name = t:sub(2):split(" ")[1]
    Refresh(name)
end)

-- Execute
Input.FocusLost:Connect(function(enter)
    if not enter then return end

    local text = Input.Text
    Input.Text = ""

    if text:sub(1,1) ~= ";" then return end

    local split = text:sub(2):split(" ")
    local name = split[1]
    local arg = split[2]

    local cmd = CMD.Commands[name]
    if not cmd then return end

    if cmd.HasArgs and not arg then
        Refresh(name)
        return
    end

    task.spawn(function()
        if cmd.HasArgs then
            cmd.Run(arg)
        else
            cmd.Run()
        end
    end)
end)

UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

Refresh()
return CMD
