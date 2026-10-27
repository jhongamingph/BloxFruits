local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Quantity Hub | Blox Fruits",
    LoadingTitle = "Join Discord for more script",
    LoadingSubtitle = "discord.gg/ntbyD4efEQ",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Quantity Hub • Blox Fruits",
        FileName = "Configuration"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false,
})

local MobsTab = Window:CreateTab("Mobs", 4483362458)
local PlayersTab = Window:CreateTab("Players", 4483345998)
local EspTab = Window:CreateTab("Esp", 6031094678)

local AutoFarmNearestSpeedEnabled = false
local AutoFarmNearestInstantEnabled = false
local TeleportPlayerSpeedEnabled = false
local TeleportPlayerInstantEnabled = false
local ESPEnabled = false
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

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

_G.FastAttack = true

if _G.FastAttack then
    local _ENV = (getgenv or getrenv or getfenv)()

    local function SafeWaitForChild(parent, childName, timeout)
        local success, result = pcall(function()
            return parent:WaitForChild(childName, timeout or 5)
        end)
        return success and result or nil
    end

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Player = Players.LocalPlayer

    if not Player then return end

    local Modules = SafeWaitForChild(ReplicatedStorage, "Modules")
    if not Modules then return end

    local Net = SafeWaitForChild(Modules, "Net")
    if not Net then return end

    local RegisterAttack = SafeWaitForChild(Net, "RE/RegisterAttack")
    local RegisterHit = SafeWaitForChild(Net, "RE/RegisterHit")

    local Enemies = SafeWaitForChild(workspace, "Enemies")
    local Characters = SafeWaitForChild(workspace, "Characters")

    local Settings = {
        AutoClick = true,
        ClickDelay = 0.015,
        MaxTargets = 8
    }

    local FastAttack = _ENV.rz_FastAttack or {
        Distance = 55,
        attackMobs = true,
        attackPlayers = true
    }

    local function IsAlive(char)
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health > 0
    end

    local function IsValidPlayer(char)
        if char == Player.Character or not IsAlive(char) then return false end
        
        if char:FindFirstChildOfClass("ForceField") then
            return false
        end

        return true
    end

    local function GetTargets()
        local targets = {}
        local primaryPart = nil
        
        local myChar = Player.Character
        if not IsAlive(myChar) then return nil, targets end
        
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil, targets end

        if FastAttack.attackMobs and Enemies then
            for _, enemy in ipairs(Enemies:GetChildren()) do
                if #targets >= Settings.MaxTargets then break end
                if IsAlive(enemy) then
                    local part = enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart")
                    if part and (part.Position - myRoot.Position).Magnitude <= FastAttack.Distance then
                        if not primaryPart then primaryPart = part end
                        table.insert(targets, { enemy, part })
                    end
                end
            end
        end

        if FastAttack.attackPlayers and Characters then
            for _, char in ipairs(Characters:GetChildren()) do
                if #targets >= Settings.MaxTargets then break end
                
                if IsValidPlayer(char) then
                    local targetRoot = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                    if targetRoot and (targetRoot.Position - myRoot.Position).Magnitude <= FastAttack.Distance then
                        if not primaryPart then primaryPart = targetRoot end
                        table.insert(targets, { char, targetRoot })
                    end
                end
            end
        end

        return primaryPart, targets
    end

    function FastAttack:BladeHits()
        local myChar = Player.Character
        if not IsAlive(myChar) then return end

        local tool = myChar:FindFirstChildOfClass("Tool")
        if not tool or tool.ToolTip == "Gun" then return end

        local primaryPart, targets = GetTargets()
        if primaryPart and #targets > 0 then
            pcall(function()
                tool:Activate()
            end)

            RegisterAttack:FireServer(Settings.ClickDelay)
            RegisterHit:FireServer(primaryPart, targets)
        end
    end

    if not _ENV.FastAttackThread then
        _ENV.FastAttackThread = task.spawn(function()
            while true do
                if Settings.AutoClick then
                    pcall(function()
                        FastAttack:BladeHits()
                    end)
                end
                task.wait(Settings.ClickDelay)
            end
        end)
    end

    _ENV.rz_FastAttack = FastAttack
end

MobsTab:CreateToggle({
    Name = "Auto Farm Nearest (Speed)",
    CurrentValue = false,
    Flag = "AutoFarmNearestSpeed",
    Callback = function(Value)
        AutoFarmNearestSpeedEnabled = Value
        
        task.spawn(function()
            local TweenService = game:GetService("TweenService")
            local currentTween = nil
            local noclipConnection = nil
            
            if AutoFarmNearestSpeedEnabled then
                noclipConnection = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
            
            while AutoFarmNearestSpeedEnabled do
                RunService.Heartbeat:Wait()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local rootPart = char.HumanoidRootPart
                    local enemies = workspace:FindFirstChild("Enemies")
                    
                    local target = nil
                    local shortestDist = 950
                    
                    if enemies then
                        for _, enemy in ipairs(enemies:GetChildren()) do
                            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                            local hum = enemy:FindFirstChildOfClass("Humanoid")
                            if enemyRoot and hum and hum.Health > 0 then
                                local dist = (rootPart.Position - enemyRoot.Position).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    target = enemyRoot
                                end
                            end
                        end
                    end
                    
                    if target then
                        local targetCFrame = CFrame.new(target.Position + Vector3.new(0, 25, 0))
                        local distance = (rootPart.Position - targetCFrame.Position).Magnitude
                        local speed = 200
                        local timeToReach = distance / speed
                        
                        if currentTween then
                            currentTween:Cancel()
                        end
                        
                        local tweenInfo = TweenInfo.new(
                            timeToReach,
                            Enum.EasingStyle.Linear,
                            Enum.EasingDirection.Out
                        )
                        
                        currentTween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
                        currentTween:Play()
                        
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    else
                        if currentTween then
                            currentTween:Cancel()
                        end
                    end
                else
                    if currentTween then
                        currentTween:Cancel()
                    end
                end
            end
            
            if currentTween then
                currentTween:Cancel()
            end
            
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if part.Name == "HumanoidRootPart" then
                            part.CanCollide = false
                        else
                            part.CanCollide = true
                        end
                    end
                end
            end
        end)
    end,
})

MobsTab:CreateToggle({
    Name = "Auto Farm Nearest (Instant)",
    CurrentValue = false,
    Flag = "AutoFarmNearestInstant",
    Callback = function(Value)
        AutoFarmNearestInstantEnabled = Value
        
        task.spawn(function()
            while AutoFarmNearestInstantEnabled do
                RunService.Heartbeat:Wait()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local rootPart = char.HumanoidRootPart
                    local enemies = workspace:FindFirstChild("Enemies")
                    
                    local target = nil
                    local shortestDist = 400
                    
                    if enemies then
                        for _, enemy in ipairs(enemies:GetChildren()) do
                            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                            local hum = enemy:FindFirstChildOfClass("Humanoid")
                            if enemyRoot and hum and hum.Health > 0 then
                                local dist = (rootPart.Position - enemyRoot.Position).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    target = enemyRoot
                                end
                            end
                        end
                    end
                    
                    if target then
                        rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 25, 0))
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
    end,
})

PlayersTab:CreateToggle({
    Name = "Teleport Nearest Player (Speed)",
    CurrentValue = false,
    Flag = "TeleportNearestPlayerSpeed",
    Callback = function(Value)
        TeleportPlayerSpeedEnabled = Value
        
        task.spawn(function()
            local TweenService = game:GetService("TweenService")
            local currentTween = nil
            local noclipConnection = nil
            
            if TeleportPlayerSpeedEnabled then
                noclipConnection = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
            
            while TeleportPlayerSpeedEnabled do
                RunService.Heartbeat:Wait()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local rootPart = char.HumanoidRootPart
                    local target = nil
                    local shortestDist = 950
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local pChar = player.Character
                            if pChar then
                                local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                                local pHum = pChar:FindFirstChildOfClass("Humanoid")
                                if pRoot and pHum and pHum.Health > 0 then
                                    local dist = (rootPart.Position - pRoot.Position).Magnitude
                                    if dist < shortestDist then
                                        shortestDist = dist
                                        target = pRoot
                                    end
                                end
                            end
                        end
                    end
                    
                    if target then
                        local targetCFrame = CFrame.new(target.Position + Vector3.new(0, 25, 0))
                        local distance = (rootPart.Position - targetCFrame.Position).Magnitude
                        local speed = 200
                        local timeToReach = distance / speed
                        
                        if currentTween then
                            currentTween:Cancel()
                        end
                        
                        local tweenInfo = TweenInfo.new(
                            timeToReach,
                            Enum.EasingStyle.Linear,
                            Enum.EasingDirection.Out
                        )
                        
                        currentTween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
                        currentTween:Play()
                        
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    else
                        if currentTween then
                            currentTween:Cancel()
                        end
                    end
                else
                    if currentTween then
                        currentTween:Cancel()
                    end
                end
            end
            
            if currentTween then
                currentTween:Cancel()
            end
            
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if part.Name == "HumanoidRootPart" then
                            part.CanCollide = false
                        else
                            part.CanCollide = true
                        end
                    end
                end
            end
        end)
    end,
})

PlayersTab:CreateToggle({
    Name = "Teleport Nearest Player (Instant)",
    CurrentValue = false,
    Flag = "TeleportPlayerInstant",
    Callback = function(Value)
        TeleportPlayerInstantEnabled = Value
        
        task.spawn(function()
            while TeleportPlayerInstantEnabled do
                RunService.Heartbeat:Wait()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local rootPart = char.HumanoidRootPart
                    local target = nil
                    local shortestDist = 400
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local pChar = player.Character
                            if pChar then
                                local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                                local pHum = pChar:FindFirstChildOfClass("Humanoid")
                                if pRoot and pHum and pHum.Health > 0 then
                                    local dist = (rootPart.Position - pRoot.Position).Magnitude
                                    if dist < shortestDist then
                                        shortestDist = dist
                                        target = pRoot
                                    end
                                end
                            end
                        end
                    end
                    
                    if target then
                        rootPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 25, 0))
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
    end,
})

EspTab:CreateToggle({
    Name = "Esp Player (Show Player Name)",
    CurrentValue = false,
    Flag = "EspPlayer",
    Callback = function(Value)
        ESPEnabled = Value
        
        local function applyESP(player)
            if player == LocalPlayer then return end
            
            local function createBillboard(char)
                if char:FindFirstChild("QuantityDynamicsESP") then return end
                
                local head = char:WaitForChild("Head", 5)
                local humanoid = char:WaitForChild("Humanoid", 5)
                if not head or not humanoid then return end
                
                local bg = Instance.new("BillboardGui")
                bg.Name = "QuantityDynamicsESP"
                bg.Adornee = head
                bg.Size = UDim2.new(0, 200, 0, 50)
                bg.StudsOffset = Vector3.new(0, 2.5, 0)
                bg.AlwaysOnTop = true
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "ESPText"
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextScaled = false
                textLabel.TextSize = 14
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextStrokeTransparency = 0
                textLabel.Parent = bg
                
                bg.Parent = char
                
                local connection
                connection = RunService.Heartbeat:Connect(function()
                    if not ESPEnabled or not char or not char.Parent or humanoid.Health <= 0 then
                        bg:Destroy()
                        if connection then connection:Disconnect() end
                        return
                    end
                    
                    local teamColor = Color3.fromRGB(255, 255, 255)
                    local teamVal = player:FindFirstChild("Team") or (player.Team and player.Team.Name)
                    local teamStr = tostring(player.Team or "")
                    
                    if teamStr == "Pirates" or teamStr == "Pirate" then
                        teamColor = Color3.fromRGB(255, 50, 50)
                    elseif teamStr == "Marines" or teamStr == "Marine" then
                        teamColor = Color3.fromRGB(50, 100, 255)
                    end
                    
                    textLabel.TextColor3 = teamColor
                    
                    local level = "N/A"
                    local dataFolder = player:FindFirstChild("Data")
                    if dataFolder and dataFolder:FindFirstChild("Level") then
                        level = tostring(dataFolder.Level.Value)
                    elseif player:FindFirstChild("Level") then
                        level = tostring(player.Level.Value)
                    end
                    
                    local hp = math.floor(humanoid.Health)
                    local maxHp = math.floor(humanoid.MaxHealth)
                    
                    textLabel.Text = string.format("Level %s | %s | %d/%d HP", level, player.DisplayName, hp, maxHp)
                end)
            end
            
            if player.Character then
                createBillboard(player.Character)
            end
            player.CharacterAdded:Connect(createBillboard)
        end
        
        for _, p in ipairs(Players:GetPlayers()) do
            applyESP(p)
        end
        
        Players.PlayerAdded:Connect(applyESP)
    end,
})

Rayfield:LoadConfiguration()
