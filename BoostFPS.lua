if not _G.Ignore then
    _G.Ignore = {}
end
if not _G.WaitPerAmount then
    _G.WaitPerAmount = 500
end
if _G.SendNotifications == nil then
    _G.SendNotifications = false
end
if _G.ConsoleLogs == nil then
    _G.ConsoleLogs = false
end

if not game:IsLoaded() then
    repeat task.wait() until game:IsLoaded()
end

if not _G.Settings then
    _G.Settings = {
        Players = {
            ["Ignore Me"] = true,
            ["Ignore Others"] = true,
            ["Ignore Tools"] = true
        },
        Meshes = {
            NoMesh = false,
            NoTexture = false,
            Destroy = false
        },
        Images = {
            Invisible = true,
            Destroy = false
        },
        Explosions = {
            Smaller = true,
            Invisible = false,
            Destroy = false
        },
        Particles = {
            Invisible = true,
            Destroy = false
        },
        TextLabels = {
            LowerQuality = false,
            Invisible = false,
            Destroy = false
        },
        MeshParts = {
            LowerQuality = true,
            Invisible = false,
            NoTexture = false,
            NoMesh = false,
            Destroy = false
        },
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
local StarterGui = game:GetService("StarterGui")
local MaterialService = game:GetService("MaterialService")
local TweenService = game:GetService("TweenService")
local ME = Players.LocalPlayer
local CanBeEnabled = {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

local function PartOfCharacter(Instance)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= ME and v.Character and Instance:IsDescendantOf(v.Character) then
            return true
        end
    end
    return false
end

local function DescendantOfIgnore(Instance)
    for _, v in pairs(_G.Ignore) do
        if Instance:IsDescendantOf(v) then
            return true
        end
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
            if _G.Settings.Meshes.NoMesh and Instance:IsA("SpecialMesh") then
                Instance.MeshId = ""
            end
            if _G.Settings.Meshes.NoTexture and Instance:IsA("SpecialMesh") then
                Instance.TextureId = ""
            end
            if _G.Settings.Meshes.Destroy then
                Instance:Destroy()
            end
        elseif Instance:IsA("FaceInstance") then
            if _G.Settings.Images.Invisible then
                Instance.Transparency = 1
                Instance.Shiny = 1
            end
            if _G.Settings.Images.Destroy then
                Instance:Destroy()
            end
        elseif Instance:IsA("ShirtGraphic") then
            if _G.Settings.Images.Invisible then
                Instance.Graphic = ""
            end
            if _G.Settings.Images.Destroy then
                Instance:Destroy()
            end
        elseif table.find(CanBeEnabled, Instance.ClassName) then
            if _G.Settings.Particles.Invisible then
                Instance.Enabled = false
            end
            if _G.Settings.Particles.Destroy then
                Instance:Destroy()
            end
        elseif Instance:IsA("PostEffect") and _G.Settings.Other["No Camera Effects"] then
            Instance.Enabled = false
        elseif Instance:IsA("Explosion") then
            if _G.Settings.Explosions.Smaller then
                Instance.BlastPressure = 1
                Instance.BlastRadius = 1
            end
            if _G.Settings.Explosions.Invisible then
                Instance.BlastPressure = 1
                Instance.BlastRadius = 1
                Instance.Visible = false
            end
            if _G.Settings.Explosions.Destroy then
                Instance:Destroy()
            end
        elseif Instance:IsA("Clothing") or Instance:IsA("SurfaceAppearance") or Instance:IsA("BaseWrap") then
            if _G.Settings.Other["No Clothes"] then
                Instance:Destroy()
            end
        elseif Instance:IsA("BasePart") and not Instance:IsA("MeshPart") then
            if _G.Settings.Other["Low Quality Parts"] then
                Instance.Material = Enum.Material.Plastic
                Instance.Reflectance = 0
            end
        elseif Instance:IsA("TextLabel") and Instance:IsDescendantOf(workspace) then
            if _G.Settings.TextLabels.LowerQuality then
                Instance.Font = Enum.Font.SourceSans
                Instance.TextScaled = false
                Instance.RichText = false
                Instance.TextSize = 14
            end
            if _G.Settings.TextLabels.Invisible then
                Instance.Visible = false
            end
            if _G.Settings.TextLabels.Destroy then
                Instance:Destroy()
            end
        elseif Instance:IsA("Model") then
            if _G.Settings.Other["Low Quality Models"] then
                Instance.LevelOfDetail = 1
            end
        elseif Instance:IsA("MeshPart") then
            if _G.Settings.MeshParts.LowerQuality then
                Instance.RenderFidelity = 2
                Instance.Reflectance = 0
                Instance.Material = Enum.Material.Plastic
            end
            if _G.Settings.MeshParts.Invisible then
                Instance.Transparency = 1
                Instance.RenderFidelity = 2
                Instance.Reflectance = 0
                Instance.Material = Enum.Material.Plastic
            end
            if _G.Settings.MeshParts.NoTexture then
                Instance.TextureID = ""
            end
            if _G.Settings.MeshParts.NoMesh then
                Instance.MeshId = ""
            end
            if _G.Settings.MeshParts.Destroy then
                Instance:Destroy()
            end
        end
    end
end

coroutine.wrap(function()
    if _G.Settings.Other["Low Water Graphics"] then
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        if not Terrain then
            repeat task.wait() until workspace:FindFirstChildOfClass("Terrain")
            Terrain = workspace:FindFirstChildOfClass("Terrain")
        end
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0
        if sethiddenproperty then
            sethiddenproperty(Terrain, "Decoration", false)
        end
    end
end)()

coroutine.wrap(function()
    if _G.Settings.Other["No Shadows"] then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.ShadowSoftness = 0
        if sethiddenproperty then
            sethiddenproperty(Lighting, "Technology", 2)
        end
    end
end)()

coroutine.wrap(function()
    if _G.Settings.Other["Low Rendering"] then
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    end
end)()

coroutine.wrap(function()
    if _G.Settings.Other["Reset Materials"] then
        for _, v in pairs(MaterialService:GetChildren()) do
            v:Destroy()
        end
        MaterialService.Use2022Materials = false
    end
end)()

coroutine.wrap(function()
    if _G.Settings.Other["FPS Cap"] and setfpscap then
        local cap = _G.Settings.Other["FPS Cap"]
        if type(cap) == "number" or type(cap) == "string" then
            setfpscap(tonumber(cap))
        elseif cap == true then
            setfpscap(1e6)
        end
    end
end)()

game.DescendantAdded:Connect(function(value)
    wait(_G.LoadedWait or 1)
    CheckIfBad(value)
end)

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local TitleLabel = Instance.new("TextLabel", ScreenGui)
local ProgressFrame = Instance.new("Frame", ScreenGui)
local ProgressBar = Instance.new("Frame", ProgressFrame)
local ProgressText = Instance.new("TextLabel", ProgressFrame)

TitleLabel.Size = UDim2.new(0, 400, 0, 40)
TitleLabel.Position = UDim2.new(0.5, -200, 0.5, -70)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextScaled = true
TitleLabel.Text = "⚡ FPS Boost"

ProgressFrame.Size = UDim2.new(0, 400, 0, 40)
ProgressFrame.Position = UDim2.new(0.5, -200, 0.5, -20)
ProgressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ProgressFrame.BackgroundTransparency = 0.2
Instance.new("UICorner", ProgressFrame).CornerRadius = UDim.new(0, 10)

ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(0, 10)

ProgressText.Size = UDim2.new(1, 0, 1, 0)
ProgressText.BackgroundTransparency = 1
ProgressText.TextColor3 = Color3.fromRGB(255, 255, 255)
ProgressText.Font = Enum.Font.SourceSansBold
ProgressText.TextScaled = true
ProgressText.Text = "0% - Processing..."

local Descendants = game:GetDescendants()
local StartNumber = _G.WaitPerAmount or 500
local WaitNumber = StartNumber
local Total = #Descendants

for i, v in ipairs(Descendants) do
    CheckIfBad(v)
    local percent = i / Total
    local percentText = math.floor(percent * 100)

    TweenService:Create(ProgressBar, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(percent, 0, 1, 0)
    }):Play()

    ProgressText.Text = string.format("%d%% - Processing: %d / %d", percentText, i, Total)

    if i == WaitNumber then
        task.wait()
        WaitNumber = WaitNumber + StartNumber
    end
end

ProgressText.Text = "✅ Optimization Complete!"
TweenService:Create(ProgressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundColor3 = Color3.fromRGB(0, 255, 127)
}):Play()

task.wait(1)
ScreenGui:Destroy()
