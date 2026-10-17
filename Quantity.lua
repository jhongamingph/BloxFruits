local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

setclipboard("discord.gg/NyvndxAadV")

local Window = Rayfield:CreateWindow({
   Name = "Quantity Dynamics Hub 🚀",
   LoadingTitle = "🚀 Quantity Dynamics 🚀",
   LoadingSubtitle = "Join Discord for more script...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Quantity Dynamics",
        FileName = "ScriptFlag"
    },
    Discord = {
        Enabled = true,
        Invite = "discord.gg/NyvndxAadV",
        RememberJoins = true
    },
   KeySystem = false,
})

local Tab = Window:CreateTab("Main Farm", 4483362458)

local AutoFarmEnabled = false
local TeleportPlayerEnabled = false
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

_G.FastAttack = true
if _G.FastAttack then
    local _ENV = (getgenv or getrenv or getfenv)()

    local function SafeWaitForChild(parent, childName)
        local success, result = pcall(function()
            return parent:WaitForChild(childName)
        end)
        if not success or not result then
            warn("noooooo: " .. childName)
        end
        return result
    end

    local function WaitChilds(path, ...)
        local last = path
        for _, child in {...} do
            last = last:FindFirstChild(child) or SafeWaitForChild(last, child)
            if not last then break end
        end
        return last
    end

    local VirtualInputManager = game:GetService("VirtualInputManager")
    local CollectionService = game:GetService("CollectionService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TeleportService = game:GetService("TeleportService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    if not Player then
        warn("Không tìm thy ngi chi cc b.")
        return
    end

    local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes")
    if not Remotes then return end

    local Validator = SafeWaitForChild(Remotes, "Validator")
    local CommF = SafeWaitForChild(Remotes, "CommF_")
    local CommE = SafeWaitForChild(Remotes, "CommE")

    local ChestModels = SafeWaitForChild(workspace, "ChestModels")
    local WorldOrigin = SafeWaitForChild(workspace, "_WorldOrigin")
    local Characters = SafeWaitForChild(workspace, "Characters")
    local Enemies = SafeWaitForChild(workspace, "Enemies")
    local Map = SafeWaitForChild(workspace, "Map")

    local EnemySpawns = SafeWaitForChild(WorldOrigin, "EnemySpawns")
    local Locations = SafeWaitForChild(WorldOrigin, "Locations")

    local RenderStepped = RunService.RenderStepped
    local Heartbeat = RunService.Heartbeat
    local Stepped = RunService.Stepped

    local Modules = SafeWaitForChild(ReplicatedStorage, "Modules")
    local Net = SafeWaitForChild(Modules, "Net")

    local sethiddenproperty = sethiddenproperty or function(...) return ... end
    local setupvalue = setupvalue or (debug and debug.setupvalue)
    local getupvalue = getupvalue or (debug and debug.getupvalue)

    local Settings = {
        AutoClick = true,
        ClickDelay = 0,
    }

    local Module = {}

    Module.FastAttack = (function()
        if _ENV.rz_FastAttack then
            return _ENV.rz_FastAttack
        end

        local FastAttack = {
            Distance = 150,
            attackMobs = true,
            attackPlayers = true,
            Equipped = nil
        }

        local RegisterAttack = SafeWaitForChild(Net, "RE/RegisterAttack")
        local RegisterHit = SafeWaitForChild(Net, "RE/RegisterHit")

        local function IsAlive(character)
        return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
        end

        local function ProcessEnemies(OthersEnemies, Folder)
            local BasePart = nil
            for _, Enemy in Folder:GetChildren() do
                local Head = Enemy:FindFirstChild("Head")
                if Head and IsAlive(Enemy) and Player:DistanceFromCharacter(Head.Position) < FastAttack.Distance then
                    if Enemy ~= Player.Character then
                        table.insert(OthersEnemies, { Enemy, Head })
                        BasePart = Head
                    end
                end
            end
            return BasePart
        end

        function FastAttack:Attack(BasePart, OthersEnemies)
            if not BasePart or #OthersEnemies == 0 then return end
            RegisterAttack:FireServer(Settings.ClickDelay or 0)
            RegisterHit:FireServer(BasePart, OthersEnemies)
        end

        function FastAttack:AttackNearest()
            local OthersEnemies = {}
            local Part1 = ProcessEnemies(OthersEnemies, Enemies)
            local Part2 = ProcessEnemies(OthersEnemies, Characters)
            if #OthersEnemies > 0 then
                self:Attack(Part1 or Part2, OthersEnemies)
            else
                task.wait(0)
            end
        end

        function FastAttack:BladeHits()
            local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
            if Equipped and Equipped.ToolTip ~= "Gun" then
                self:AttackNearest()
            else
                task.wait(0)
            end
        end

        task.spawn(function()
            while task.wait(Settings.ClickDelay) do
                if Settings.AutoClick then
                    FastAttack:BladeHits()
                end
            end
        end)

        _ENV.rz_FastAttack = FastAttack
        return FastAttack
    end)()
end

Tab:CreateToggle({
   Name = "Auto Farm Nearest (Please Equip Mele)",
   CurrentValue = false,
   Flag = "AutoFarmNearest",
   Callback = function(Value)
      AutoFarmEnabled = Value
      
      task.spawn(function()
          while AutoFarmEnabled do
              RunService.Heartbeat:Wait()
              local char = LocalPlayer.Character
              if char and char:FindFirstChild("HumanoidRootPart") then
                  local rootPart = char.HumanoidRootPart
                  local enemies = workspace:FindFirstChild("Enemies")
                  
                  local target = nil
                  local shortestDist = 500 
                  
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

Tab:CreateToggle({
   Name = "Teleport Nearest Player (Please Equip Mele)",
   CurrentValue = false,
   Flag = "TeleportNearestPlayer",
   Callback = function(Value)
      TeleportPlayerEnabled = Value
      
      task.spawn(function()
          while TeleportPlayerEnabled do
              RunService.Heartbeat:Wait()
              local char = LocalPlayer.Character
              if char and char:FindFirstChild("HumanoidRootPart") then
                  local rootPart = char.HumanoidRootPart
                  local target = nil
                  local shortestDist = 500
                  
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

Tab:CreateButton({
   Name = "Fast Mode",
   Callback = function()
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
          elseif instance:IsA("BasePart") and not instance:IsDescendantOf(LocalPlayer.Character or workspace) then
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
   end,
})

Rayfield:LoadConfiguration()
