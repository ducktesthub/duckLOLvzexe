local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Blox Fruits Auto Hub", "DarkTheme")

local FarmTab = Window:NewTab("Auto Farm")
local TeleportTab = Window:NewTab("Teleport")
local MiscTab = Window:NewTab("Misc")

local FarmSection = FarmTab:NewSection("Auto Farm Level")
local TeleportSection = TeleportTab:NewSection("Teleport")
local ChestSection = MiscTab:NewSection("Auto Chest")

local plr = game:GetService("Players").LocalPlayer
local tweenService = game:GetService("TweenService")
local vu = game:GetService("VirtualUser")
local rs = game:GetService("ReplicatedStorage")

_G.AutoFarm = false
_G.AutoQuest = false
_G.AutoChest = false

-- Hàm dịch chuyển
function teleportTo(position)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local tween = tweenService:Create(plr.Character.HumanoidRootPart, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = CFrame.new(position)})
        tween:Play()
        wait(0.5)
    end
end

-- Hàm tấn công quái
function attack()
    pcall(function()
        vu:Button1Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(0.1)
        vu:Button1Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end

-- Hàm lấy nhiệm vụ phù hợp với level
function getQuest()
    local level = plr.Data.Level.Value
    local questData = {
        [1] = {NPC = "Bandit Quest Giver", Quest = "BanditQuest1", Enemy = "Bandit", Pos = Vector3.new(1057, 16, 1600)},
        [10] = {NPC = "Jungle Quest Giver", Quest = "JungleQuest1", Enemy = "Monkey", Pos = Vector3.new(-1600, 36, 150)},
        [30] = {NPC = "Pirate Quest Giver", Quest = "PirateQuest1", Enemy = "Pirate", Pos = Vector3.new(-1200, 10, 3950)},
    }

    local currentQuest
    for reqLevel, quest in pairs(questData) do
        if level >= reqLevel then
            currentQuest = quest
        end
    end

    if currentQuest then
        local questGiver = game:GetService("Workspace").NPCs:FindFirstChild(currentQuest.NPC)
        if questGiver then
            teleportTo(currentQuest.Pos)
            wait(1)
            fireproximityprompt(questGiver.HumanoidRootPart:FindFirstChildOfClass("ProximityPrompt"))
        end
    end
end

-- Auto Farm (Sửa lỗi không đánh quái)
function autoFarm()
    while _G.AutoFarm do
        pcall(function()
            local level = plr.Data.Level.Value
            local questData = {
                [1] = {Quest = "BanditQuest1", Enemy = "Bandit", Pos = Vector3.new(1057, 16, 1600)},
                [10] = {Quest = "JungleQuest1", Enemy = "Monkey", Pos = Vector3.new(-1600, 36, 150)},
                [30] = {Quest = "PirateQuest1", Enemy = "Pirate", Pos = Vector3.new(-1200, 10, 3950)},
            }

            local currentQuest
            for reqLevel, quest in pairs(questData) do
                if level >= reqLevel then
                    currentQuest = quest
                end
            end

            if currentQuest then
                local enemies = game:GetService("Workspace").Enemies:GetChildren()
                for _, enemy in pairs(enemies) do
                    if enemy.Name == currentQuest.Enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        repeat
                            teleportTo(enemy.HumanoidRootPart.Position + Vector3.new(0, 10, 0))
                            attack()
                            wait(0.1)
                        until enemy.Humanoid.Health <= 0 or not _G.AutoFarm
                    end
                end
            end
        end)
        wait(1)
    end
end

-- Auto Chest
function collectChests()
    while _G.AutoChest do
        pcall(function()
            local chests = game:GetService("Workspace"):GetChildren()
            for _, chest in pairs(chests) do
                if chest:IsA("Model") and chest:FindFirstChild("HumanoidRootPart") and chest:FindFirstChild("TouchInterest") then
                    teleportTo(chest.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
                    wait(0.5)
                end
            end
        end)
        wait(2)
    end
end

-- Giao diện Auto Farm
FarmSection:NewToggle("Auto Farm Level", "Tự động farm quái để lên cấp", function(state)
    _G.AutoFarm = state
    if state then
        autoFarm()
    end
end)

FarmSection:NewToggle("Auto Quest", "Tự động nhận nhiệm vụ phù hợp với level", function(state)
    _G.AutoQuest = state
    if state then
        while _G.AutoQuest do
            getQuest()
            wait(5)
        end
    end
end)

-- Giao diện Teleport
local locations = {
    ["Starter Island"] = Vector3.new(-655, 8, 4000),
    ["Jungle"] = Vector3.new(-1100, 10, 350),
    ["Pirate Village"] = Vector3.new(-1100, 10, 3850),
    ["Marine Fortress"] = Vector3.new(-5000, 100, 4300),
    ["Sky Island"] = Vector3.new(-500, 1000, -3000),
    ["Frozen Village"] = Vector3.new(1200, 10, -1400),
}

for name, pos in pairs(locations) do
    TeleportSection:NewButton(name, "Dịch chuyển đến " .. name, function()
        teleportTo(pos)
    end)
end

-- Giao diện Auto Chest
ChestSection:NewToggle("Auto Chest", "Tự động nhặt rương trên bản đồ", function(state)
    _G.AutoChest = state
    if state then
        collectChests()
    end
end)
