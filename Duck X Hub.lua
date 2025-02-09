local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Blox Fruits Auto Hub", "DarkTheme")

local FarmTab = Window:NewTab("Auto Farm")
local FarmSection = FarmTab:NewSection("Auto Farm Level")

local plr = game:GetService("Players").LocalPlayer
local tweenService = game:GetService("TweenService")
local vu = game:GetService("VirtualUser")
local rs = game:GetService("ReplicatedStorage")

_G.AutoFarm = false

-- Dữ liệu nhiệm vụ theo cấp độ
local questData = {
    [1] = {NPC = "Bandit Quest Giver", Quest = "BanditQuest1", Enemy = "Bandit", Pos = Vector3.new(1057, 16, 1600)},
    [10] = {NPC = "Jungle Quest Giver", Quest = "JungleQuest1", Enemy = "Monkey", Pos = Vector3.new(-1600, 36, 150)},
    [30] = {NPC = "Pirate Quest Giver", Quest = "PirateQuest1", Enemy = "Pirate", Pos = Vector3.new(-1200, 10, 3950)},
}

-- Hàm dịch chuyển
function teleportTo(position)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(position)
        wait(0.5)
    end
end

-- Hàm nhận nhiệm vụ
function getQuest()
    local level = plr.Data.Level.Value
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

-- Hàm kiểm tra đã nhận nhiệm vụ chưa
function hasQuest()
    local plrQuest = plr.PlayerGui.Main.Quest.Visible
    return plrQuest
end

-- Auto Farm
function autoFarm()
    while _G.AutoFarm do
        pcall(function()
            local level = plr.Data.Level.Value
            local currentQuest

            for reqLevel, quest in pairs(questData) do
                if level >= reqLevel then
                    currentQuest = quest
                end
            end

            -- Nếu chưa nhận nhiệm vụ thì nhận
            if not hasQuest() then
                getQuest()
                wait(2)
            end

            -- Đánh quái
            if currentQuest then
                local enemies = game:GetService("Workspace").Enemies:GetChildren()
                for _, enemy in pairs(enemies) do
                    if enemy.Name == currentQuest.Enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        repeat
                            teleportTo(enemy.HumanoidRootPart.Position + Vector3.new(0, 10, 0))
                            vu:Button1Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                            wait(0.1)
                            vu:Button1Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                        until enemy.Humanoid.Health <= 0 or not _G.AutoFarm
                    end
                end
            end
        end)
        wait(1)
    end
end

-- Giao diện Auto Farm
FarmSection:NewToggle("Auto Farm Level", "Tự động farm quái + nhận nhiệm vụ", function(state)
    _G.AutoFarm = state
    if state then
        autoFarm()
    end
end)
