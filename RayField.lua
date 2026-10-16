local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

setclipboard("discord.gg/NyvndxAadV")

local Window = Rayfield:CreateWindow({
   Name = "Quantity Dynamics Hub",
   LoadingTitle = "Please Wait...",
   LoadingSubtitle = "By: jhongamingph",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false,
})

local Tab = Window:CreateTab("Main Farm", 4483362458)

local AutoFarmEnabled = false
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
        return result
    end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Net = SafeWaitForChild(ReplicatedStorage, "Modules") and SafeWaitForChild(ReplicatedStorage.Modules, "Net")
    
    local Settings = {
        AutoClick = true,
        ClickDelay = 0,
    }

    if Net and not _ENV.rz_FastAttack then
        local FastAttack = {
            Distance = 120,
            attackMobs = true,
            attackPlayers = true,
        }

        local RegisterAttack = SafeWaitForChild(Net, "RE/RegisterAttack")
        local RegisterHit = SafeWaitForChild(Net, "RE/RegisterHit")

        local function IsAlive(character)
            return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
        end

        local function ProcessEnemies(OthersEnemies, Folder)
            local BasePart = nil
            if not Folder then return BasePart end
            for _, Enemy in ipairs(Folder:GetChildren()) do
                local tryHead = Enemy:FindFirstChild("Head")
                if tryHead and IsAlive(Enemy) and LocalPlayer:DistanceFromCharacter(tryHead.Position) < FastAttack.Distance then
                    if Enemy ~= LocalPlayer.Character then
                        table.insert(OthersEnemies, { Enemy, tryHead })
                        BasePart = tryHead
                    end
                end
            end
            return BasePart
        end

        function FastAttack:Attack(BasePart, OthersEnemies)
            if not BasePart or #OthersEnemies == 0 or not RegisterAttack or not RegisterHit then return end
            RegisterAttack:FireServer(Settings.ClickDelay or 0)
            RegisterHit:FireServer(BasePart, OthersEnemies)
        end

        function FastAttack:AttackNearest()
            local OthersEnemies = {}
            local Part1 = ProcessEnemies(OthersEnemies, workspace:FindFirstChild("Enemies"))
            local Part2 = ProcessEnemies(OthersEnemies, workspace:FindFirstChild("Characters"))
            if #OthersEnemies > 0 then
                self:Attack(Part1 or Part2, OthersEnemies)
            end
        end

        task.spawn(function()
            while task.wait(Settings.ClickDelay) do
                if Settings.AutoClick and AutoFarmEnabled then
                    FastAttack:AttackNearest()
                end
            end
        end)

        _ENV.rz_FastAttack = FastAttack
    end
end

Tab:CreateToggle({
   Name = "Auto Farm Nearest",
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
                  local shortestDist = math.huge
                  
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
                      rootPart.CFrame = target.CFrame + Vector3.new(0, 15, 0)
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
