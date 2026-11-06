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
