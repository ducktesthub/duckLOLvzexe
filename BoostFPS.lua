if getgenv and getgenv().FPSBoost_Running then
    warn("[FPS Boost] Script is already running or completed.")
    return
end
if getgenv then
    getgenv().FPSBoost_Running = true
end

if not _G.Ignore then _G.Ignore = {} end
if not _G.WaitPerAmount then _G.WaitPerAmount = 500 end
if _G.SendNotifications == nil then _G.SendNotifications = false end
if _G.ConsoleLogs == nil then _G.ConsoleLogs = false end

if not game:IsLoaded() then repeat task.wait() until game:IsLoaded() end

if not _G.Settings then
    _G.Settings = {
        Players = { ["Ignore Me"] = true, ["Ignore Others"] = true, ["Ignore Tools"] = true },
        Meshes = { NoMesh = false, NoTexture = false, Destroy = false },
        Images = { Invisible = true, Destroy = false },
        Explosions = { Smaller = true, Invisible = false, Destroy = false },
        Particles = { Invisible = true, Destroy = false },
        TextLabels = { LowerQuality = false, Invisible = false, Destroy = false },
        MeshParts = { LowerQuality = true, Invisible = false, NoTexture = false, NoMesh = false, Destroy = false },
        Other = {
            ["FPS Cap"] = 240,
            ["No Camera Effects"] = true,
            ["No Clothes"] = true,
            ["Low Water Graphics"] = true,
            ["No Shadows"] = true,
            ["Low Rendering"] = true,
            ["Low Quality Parts"] = true,
            ["Low Quality Models"] = true,
            ["Reset Materials"] = true,
            ["Lower Quality MeshParts"] = true
        }
    }
end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local TweenService = game:GetService("TweenService")
local ME = Players.LocalPlayer
local CanBeEnabled = {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

local function PartOfCharacter(Instance)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= ME and v.Character and Instance:IsDescendantOf(v.Character) then return true end
    end
    return false
end

local function DescendantOfIgnore(Instance)
    for _, v in pairs(_G.Ignore) do
        if Instance:IsDescendantOf(v) then return true end
    end
    return false
end

local function CheckIfBad(Instance)
    if not Instance:IsDescendantOf(Players)
        and (_G.Settings.Players["Ignore Others"] and not PartOfCharacter(Instance) or not _G.Settings.Players["Ignore Others"])
        and (_G.Settings.Players["Ignore Me"] and ME.Character and not Instance:IsDescendantOf(ME.Character) or not _G.Settings.Players["Ignore Me"])
        and (_G.Settings.Players["Ignore Tools"] and not Instance:IsA("BackpackItem") and not Instance:FindFirstAncestorWhichIsA("BackpackItem") or not _G.Settings.Players["Ignore Tools"])
        and (_G.Ignore and not table.find(_G.Ignore, Instance) and not DescendantOfIgnore(Instance) or (not _G.Ignore or type(_G.Ignore) ~= "table" or #_G.Ignore <= 0))
    then
        if Instance:IsA("DataModelMesh") then
            if _G.Settings.Meshes.NoMesh and Instance:IsA("SpecialMesh") then Instance.MeshId = "" end
            if _G.Settings.Meshes.NoTexture and Instance:IsA("SpecialMesh") then Instance.TextureId = "" end
            if _G.Settings.Meshes.Destroy then Instance:Destroy() end
        elseif Instance:IsA("FaceInstance") then
            if _G.Settings.Images.Invisible then Instance.Transparency = 1 end
            if _G.Settings.Images.Destroy then Instance:Destroy() end
        elseif Instance:IsA("ShirtGraphic") then
            if _G.Settings.Images.Invisible then Instance.Graphic = "" end
            if _G.Settings.Images.Destroy then Instance:Destroy() end
        elseif table.find(CanBeEnabled, Instance.ClassName) then
            if _G.Settings.Particles.Invisible then Instance.Enabled = false end
            if _G.Settings.Particles.Destroy then Instance:Destroy() end
        elseif Instance:IsA("PostEffect") and _G.Settings.Other["No Camera Effects"] then
            Instance.Enabled = false
        elseif Instance:IsA("Explosion") then
            if _G.Settings.Explosions.Smaller then Instance.BlastPressure = 1 Instance.BlastRadius = 1 end
            if _G.Settings.Explosions.Invisible then Instance.Visible = false end
            if _G.Settings.Explosions.Destroy then Instance:Destroy() end
        elseif Instance:IsA("Clothing") or Instance:IsA("SurfaceAppearance") or Instance:IsA("BaseWrap") then
            if _G.Settings.Other["No Clothes"] then Instance:Destroy() end
        elseif Instance:IsA("BasePart") and not Instance:IsA("MeshPart") then
            if _G.Settings.Other["Low Quality Parts"] then Instance.Material = Enum.Material.Plastic Instance.Reflectance = 0 end
        elseif Instance:IsA("TextLabel") and Instance:IsDescendantOf(workspace) then
            if _G.Settings.TextLabels.LowerQuality then
                Instance.Font = Enum.Font.SourceSans
                Instance.TextScaled = false
                Instance.TextSize = 14
            end
            if _G.Settings.TextLabels.Invisible then Instance.Visible = false end
            if _G.Settings.TextLabels.Destroy then Instance:Destroy() end
        elseif Instance:IsA("Model") then
            if _G.Settings.Other["Low Quality Models"] then Instance.LevelOfDetail = 1 end
        elseif Instance:IsA("MeshPart") then
            if _G.Settings.MeshParts.LowerQuality then
                Instance.RenderFidelity = Enum.RenderFidelity.Automatic
                Instance.Material = Enum.Material.Plastic
                Instance.Reflectance = 0
            end
            if _G.Settings.MeshParts.NoTexture then Instance.TextureID = "" end
            if _G.Settings.MeshParts.NoMesh then Instance.MeshId = "" end
            if _G.Settings.MeshParts.Destroy then Instance:Destroy() end
        end
    end
end

task.spawn(function()
    if _G.Settings.Other["Low Water Graphics"] then
        local Terrain = workspace:FindFirstChildOfClass("Terrain") or workspace:WaitForChildOfClass("Terrain")
        Terrain.WaterWaveSize, Terrain.WaterWaveSpeed, Terrain.WaterReflectance, Terrain.WaterTransparency = 0, 0, 0, 0
        if sethiddenproperty then sethiddenproperty(Terrain, "Decoration", false) end
    end
end)

task.spawn(function()
    if _G.Settings.Other["No Shadows"] then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.ShadowSoftness = 0
        if sethiddenproperty then sethiddenproperty(Lighting, "Technology", 2) end
    end
end)

task.spawn(function()
    if _G.Settings.Other["Low Rendering"] then
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    end
end)

task.spawn(function()
    if _G.Settings.Other["Reset Materials"] then
        for _, v in pairs(MaterialService:GetChildren()) do v:Destroy() end
        MaterialService.Use2022Materials = false
    end
end)

task.spawn(function()
    if _G.Settings.Other["FPS Cap"] and setfpscap then
        local cap = tonumber(_G.Settings.Other["FPS Cap"]) or 240
        setfpscap(cap)
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local TitleLabel = Instance.new("TextLabel", ScreenGui)
TitleLabel.Size = UDim2.new(0, 400, 0, 40)
TitleLabel.Position = UDim2.new(0.5, -200, 0.5, -70)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextScaled = true
TitleLabel.Text = "⚡ FPS Boost Running..."

local ProgressFrame = Instance.new("Frame", ScreenGui)
ProgressFrame.Size = UDim2.new(0, 400, 0, 40)
ProgressFrame.Position = UDim2.new(0.5, -200, 0.5, -20)
ProgressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", ProgressFrame).CornerRadius = UDim.new(0, 10)

local ProgressBar = Instance.new("Frame", ProgressFrame)
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(0, 10)

local ProgressText = Instance.new("TextLabel", ProgressFrame)
ProgressText.Size = UDim2.new(1, 0, 1, 0)
ProgressText.BackgroundTransparency = 1
ProgressText.TextColor3 = Color3.fromRGB(255, 255, 255)
ProgressText.Font = Enum.Font.SourceSansBold
ProgressText.TextScaled = true
ProgressText.Text = "0% - Processing..."

local Descendants = game:GetDescendants()
local Total = #Descendants
local BatchSize = _G.WaitPerAmount
local Done = 0

for i, obj in ipairs(Descendants) do
    CheckIfBad(obj)
    Done += 1
    local percent = Done / Total
    local percentText = math.floor(percent * 100)

    TweenService:Create(ProgressBar, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    ProgressText.Text = string.format("%d%% - Processing %d/%d", percentText, Done, Total)

    if i % BatchSize == 0 then task.wait() end
end

ProgressText.Text = "✅ Complete!"
TitleLabel.Text = "✅ FPS Boost Done"
TweenService:Create(ProgressBar, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 255, 127)}):Play()

task.wait(1.5)
ScreenGui:Destroy()
getgenv().FPSBoost_Running = false
warn("[FPS Boost] Optimization completed successfully.")
