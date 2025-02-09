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

_G.AutoFarm = false
_G.AutoQuest = false
_G.AutoChest = false

function teleportTo(position)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local tween = tweenService:Create(plr.Character.HumanoidRootPart, TweenInfo.new((plr.Character.HumanoidRootPart.Position - position).magnitude / 300, Enum.EasingStyle.Linear), {CFrame = CFrame.new(position)})
        tween:Play()
        wait(0.5)
    end
end

function attack()
    pcall(function()
        vu:Button1Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(0.1)
        vu:Button1Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end

function autoFarm()
    while _G.AutoFarm do
        pcall(function()
            local enemies = game:GetService("Workspace").Enemies:GetChildren()
            for _, enemy in pairs(enemies) do
                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    repeat
                        teleportTo(enemy.HumanoidRootPart.Position + Vector3.new(0, 10, 0))
                        attack()
                        wait(0.1)
                    until enemy.Humanoid.Health <= 0 or not _G.AutoFarm
                end
            end
        end)
        wait(1)
    end
end

function getQuest()
    local level = plr.Data.Level.Value
    local questData = {
        [1] = {Name = "Bandit Quest", NPC = "Bandit", LevelReq = 1, Enemy = "Bandit"},
        [10] = {Name = "Monkey Quest", NPC = "Monkey", LevelReq = 10, Enemy = "Monkey"},
        [30] = {Name = "Pirate Quest", NPC = "Pirate", LevelReq = 30, Enemy = "Pirate"},
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
            teleportTo(questGiver.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
            wait(1)
            fireproximityprompt(questGiver.HumanoidRootPart:FindFirstChildOfClass("ProximityPrompt"))
        end
    end
end

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

ChestSection:NewToggle("Auto Chest", "Tự động nhặt rương trên bản đồ", function(state)
    _G.AutoChest = state
    if state then
        collectChests()
    end
end)
