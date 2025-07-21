local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local isMinimized = false
local dragging, dragInput, dragStart, startPos = false

local function makeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    uis.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- GUI 设置
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AdminToolsUI"
ScreenGui.ResetOnSpawn = false

local Container = Instance.new("Frame", ScreenGui)
-- 增大尺寸，矩形形状
Container.Size = UDim2.new(0, 600, 0, 400)
Container.Position = UDim2.new(0, 20, 0.5, -200)
Container.BackgroundColor3 = Color3.fromRGB(35,35,35)
Container.BorderSizePixel = 0
makeDraggable(Container)
Instance.new("UIStroke", Container).Color = Color3.fromRGB(90,90,90)

local TopBar = Instance.new("Frame", Container)
TopBar.Size = UDim2.new(1,0,0,30)
TopBar.BackgroundColor3 = Color3.fromRGB(45,45,45)
makeDraggable(TopBar)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1,-90,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.Text = "多功能工具中心"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(220,220,220)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeBtn = Instance.new("TextButton", TopBar)
MinimizeBtn.Size = UDim2.new(0,40,1,0)
MinimizeBtn.Position = UDim2.new(1,-50,0,0)
MinimizeBtn.Text = "—"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.TextColor3 = Color3.fromRGB(220,220,220)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(65,65,65)

-- 标志按钮 (改为"W"并移至左下)
local ZBtn = Instance.new("TextButton", ScreenGui)
ZBtn.Size = UDim2.new(0,40,0,40)
ZBtn.Position = UDim2.new(0, 10, 1, -40) -- 左下
ZBtn.Text = "W"
ZBtn.Font = Enum.Font.GothamBold
ZBtn.TextSize = 24
ZBtn.TextColor3 = Color3.fromRGB(220,220,220)
ZBtn.BackgroundColor3 = Color3.fromRGB(65,65,65)
ZBtn.Visible = false
makeDraggable(ZBtn)

MinimizeBtn.MouseEnter:Connect(function() MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100,100,100) end)
MinimizeBtn.MouseLeave:Connect(function() MinimizeBtn.BackgroundColor3 = Color3.fromRGB(65,65,65) end)

ZBtn.MouseEnter:Connect(function() ZBtn.BackgroundColor3 = Color3.fromRGB(100,100,100) end)
ZBtn.MouseLeave:Connect(function() ZBtn.BackgroundColor3 = Color3.fromRGB(65,65,65) end)

ZBtn.MouseButton1Click:Connect(function()
    isMinimized = false
    Container.Visible = true
    ZBtn.Visible = false
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Container.Visible = not isMinimized
    ZBtn.Visible = isMinimized
end)

-- 标签页
local TabsFrame = Instance.new("Frame", Container)
TabsFrame.Size = UDim2.new(1,0,0,40)
TabsFrame.Position = UDim2.new(0,0,0,30)
TabsFrame.BackgroundTransparency = 1

local function createTabButton(name, xPos)
    local btn = Instance.new("TextButton", TabsFrame)
    btn.Size = UDim2.new(0,110,1,-6) -- 适应新尺寸的更宽按钮
    btn.Position = UDim2.new(xPos,10,0,3)
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
    btn.AutoButtonColor = false
    return btn
end

local tabNames = {"管理员工具","幽灵中心","无限收益","方块果实","死亡铁轨"}
local tabButtons = {}
for i,name in ipairs(tabNames) do
    tabButtons[name] = createTabButton(name,(i-1)*110/600)
end

local ScrollFrame = Instance.new("ScrollingFrame", Container)
ScrollFrame.Size = UDim2.new(1,0,1,-70)
ScrollFrame.Position = UDim2.new(0,0,0,70)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(45,45,45)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)  -- 将动态更新

-- CREDIT 文本 (移至容器外，左下，标志上方)
local credit = Instance.new("TextLabel", ScreenGui)
credit.Size = UDim2.new(0, 120, 0, 20)
credit.Position = UDim2.new(0, 10, 1, -20) -- 标志上方
credit.Text = "由Z某人翻译"
credit.TextColor3 = Color3.fromRGB(180,180,180)
credit.Font = Enum.Font.GothamSemibold
credit.TextSize = 12
credit.BackgroundTransparency = 1
credit.TextXAlignment = Enum.TextXAlignment.Left

-- 按钮辅助函数
local function clearScroll()
    for _,c in pairs(ScrollFrame:GetChildren()) do
        if not (c:IsA("UIListLayout") or c:IsA("UIPadding")) then
            c:Destroy()
        end
    end
end

local function createButton(text, y)
    local btn = Instance.new("TextButton", ScrollFrame)
    btn.Size = UDim2.new(1,-30,0,36)
    btn.Position = UDim2.new(0,15,0,y)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(240,240,240)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(110,110,110)
    stroke.Thickness = 1
    btn.AutoButtonColor = false
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(100,100,100) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(70,70,70) end)
    return btn
end

-- 标签页逻辑
local function buildAdminTools()
    clearScroll()
    local b1 = createButton("🛫 切换飞行",10)
    b1.MouseButton1Click:Connect(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
        end)
        if not success then
            warn("飞行脚本执行失败:", err)
        end
    end)
    local b2 = createButton("🌀 切换无限跳跃",60)
    local b3 = createButton("👻 切换穿墙",110)
    local speedBtn = createButton("⚡ 设置行走速度",190)

    local speedBox = Instance.new("TextBox",ScrollFrame)
    speedBox.PlaceholderText = "输入速度 (默认 16)"
    speedBox.Size = UDim2.new(1,-30,0,36)
    speedBox.Position = UDim2.new(0,15,0,150)
    speedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
    speedBox.TextColor3 = Color3.fromRGB(240,240,240)
    speedBox.ClearTextOnFocus = false

    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    local infJump, noclip, flying = false, false, false

    -- 无限跳跃
    b2.MouseButton1Click:Connect(function() infJump = not infJump end)
    uis.JumpRequest:Connect(function()
        if infJump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    -- 穿墙切换优化: 仅在穿墙状态改变时更新以避免卡顿
    b3.MouseButton1Click:Connect(function()
        noclip = not noclip
        if noclip then
            for _,part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        else
            for _,part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end)

    -- 行走速度设置
    speedBtn.MouseButton1Click:Connect(function()
        local val = tonumber(speedBox.Text)
        if val and val > 0 then
            humanoid.WalkSpeed = val
        else
            humanoid.WalkSpeed = 16
            speedBox.Text = ""
        end
    end)

    -- 可选: 重生时重置行走速度
    player.CharacterAdded:Connect(function(char)
        humanoid = char:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 16
    end)
end

local function buildGhostHub()
    clearScroll()
    local btn = createButton("执行幽灵中心",10)
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/GhostHub'))()
        end)
    end)
end

local function buildInfiniteYield()
    clearScroll()
    local btn = createButton("执行无限收益",10)
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet('https://pastebin.com/raw/YSL3xKYU'))()
        end)
    end)
end

local function buildBloxFruits()
    clearScroll()
    local btn = createButton("执行方块果实",10)
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet('https://pastebin.com/raw/YourBloxFruitsScriptHere'))()
        end)
    end)
end

local function buildDeadRails()
    clearScroll()
    local btn = createButton("执行死亡铁轨",10)
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(game:HttpGet('https://skullhub.xyz/loader.lua'))()
        end)
    end)

    -- 添加自动债券农场按钮
    local autoBondsBtn = createButton("自动债券农场", 60)
    autoBondsBtn.MouseButton1Click:Connect(function()
        getgenv().bringitem = "Bond" -- 金币, 银币, 煤炭, 绷带等
        loadstring(game