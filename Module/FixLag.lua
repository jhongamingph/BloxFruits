local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

Lighting.FogStart = math.huge
Lighting.FogEnd = math.huge
Lighting.GlobalShadows = false

if setfpscap then
    setfpscap(math.huge)
end

if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
end

local function optimizeInstance(instance)
    if instance:IsA("Texture") or instance:IsA("Decal") then
        instance:Destroy()
    elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Smoke") or instance:IsA("Fire") or instance:IsA("Sparkles") then
        instance:Destroy()
    elseif instance:IsA("BasePart") and not instance:IsDescendantOf(game.Players.LocalPlayer.Character or workspace) then
        instance.Material = Enum.Material.SmoothPlastic
        instance.Reflectance = 0
    elseif instance:IsA("SurfaceAppearance") or instance:IsA("MeshPart") then
        if instance:IsA("MeshPart") then
            instance.Material = Enum.Material.SmoothPlastic
        end
    end
end

for _, obj in ipairs(workspace:GetDescendants()) do
    optimizeInstance(obj)
end

for _, obj in ipairs(Lighting:GetDescendants()) do
    if obj:IsA("Atmosphere") or obj:IsA("Sky") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") then
        obj:Destroy()
    end
end

workspace.DescendantAdded:Connect(function(newObj)
    task.wait()
    if newObj and newObj.Parent then
        optimizeInstance(newObj)
    end
end)
