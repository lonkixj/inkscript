-- 🌌 Full Delta Script (рабочий)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local function round(obj) local c = Instance.new("UICorner", obj) c.CornerRadius = UDim.new(0,10) end

-- ===== Главное окно (создаём заранее) =====
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,220,0,220)
MainFrame.Position = UDim2.new(0.1,0,0.2,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.Visible = false
round(MainFrame)

-- Заголовок
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,30)
TitleBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
round(TitleBar)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,-30,1,0)
Title.Position = UDim2.new(0,5,0,0)
Title.Text = "🔥 Delta Full Script"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0,30,1,0)
MinimizeBtn.Position = UDim2.new(1,-30,0,0)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
round(MinimizeBtn)

-- Кнопки
local ButtonHolder = Instance.new("Frame", MainFrame)
ButtonHolder.Size = UDim2.new(1,0,1,-30)
ButtonHolder.Position = UDim2.new(0,0,0,30)
ButtonHolder.BackgroundTransparency = 1

local function makeBtn(name, y)
    local btn = Instance.new("TextButton", ButtonHolder)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Size = UDim2.new(1,-20,0,40)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = name
    round(btn)
    return btn
end

local TpUp = makeBtn("⬆️ ТП Вверх", 20)
local TpDown = makeBtn("⬇️ ТП Вниз", 70)
local KillAura = makeBtn("⚔️ Смарт Килл-Аура", 120)

-- ===== Экран загрузки =====
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(0,300,0,120)
LoadingFrame.Position = UDim2.new(0.5,-150,0.5,-60)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
round(LoadingFrame)

local LoadingLabel = Instance.new("TextLabel", LoadingFrame)
LoadingLabel.Size = UDim2.new(1,0,1,0)
LoadingLabel.Text = "Загрузка..."
LoadingLabel.TextColor3 = Color3.fromRGB(255,255,255)
LoadingLabel.TextScaled = true
LoadingLabel.BackgroundTransparency = 1

task.spawn(function()
    for i=1,3 do
        LoadingLabel.Text = "Загрузка."
        task.wait(0.3)
        LoadingLabel.Text = "Загрузка.."
        task.wait(0.3)
        LoadingLabel.Text = "Загрузка..."
        task.wait(0.3)
    end
    LoadingFrame:TweenSize(UDim2.new(0,0,0,0),"Out","Quad",0.6,true)
    task.wait(0.6)
    LoadingFrame:Destroy()
    MainFrame.Visible = true -- показываем главное меню
end)

-- ===== Логика =====
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- ТП
TpUp.MouseButton1Click:Connect(function() hrp.CFrame = hrp.CFrame + Vector3.new(0,100,0) end)
TpDown.MouseButton1Click:Connect(function() hrp.CFrame = hrp.CFrame + Vector3.new(0,-40,0) end)

-- Full KillAura
local auraEnabled = false
local currentTarget = nil
local RunService = game:GetService("RunService")

KillAura.MouseButton1Click:Connect(function()
    auraEnabled = not auraEnabled
    currentTarget = nil
    KillAura.Text = auraEnabled and "✅ Килл-Аура Вкл" or "⚔️ Смарт Килл-Аура"
end)

RunService.Heartbeat:Connect(function()
    if not auraEnabled or not hrp then return end

    if not currentTarget 
       or not currentTarget.Character 
       or not currentTarget.Character:FindFirstChild("Humanoid") 
       or currentTarget.Character.Humanoid.Health <= 0 then

        currentTarget = nil
        local closest, dist = nil, 50
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player 
            and plr.Character 
            and plr.Character:FindFirstChild("HumanoidRootPart") 
            and plr.Character:FindFirstChild("Humanoid") 
            and plr.Character.Humanoid.Health > 0 then
                local mag = (hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then
                    closest, dist = plr, mag
                end
            end
        end
        currentTarget = closest
    end

    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local enemyHRP = currentTarget.Character.HumanoidRootPart
        hrp.CFrame = enemyHRP.CFrame * CFrame.new(0,0,3)
    end
end)

-- ===== Перетаскивание (ПК + Телефон) =====
local UserInputService = game:GetService("UserInputService")
local dragging, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        update(input)
    end
end)

-- ===== Сворачивание =====
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ButtonHolder.Visible = not minimized
    MainFrame:TweenSize(UDim2.new(0,220,0, minimized and 30 or 220),"Out","Quad",0.3,true)
end)
