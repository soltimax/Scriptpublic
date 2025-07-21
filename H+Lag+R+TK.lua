-- Script principal pour Delta (un seul exécutable)

local function script1()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local hitboxSize = Vector3.new(3, 3, 3)
    local hitboxOffset = Vector3.new(0, 0, 0)
    local modifiedCharacters = {}
    local hitboxEnabled = true
    local localPlayer = Players.LocalPlayer

    local excludedNames = {
        [localPlayer.Name] = true,
        ["AANGEL999S"] = true,
        ["bc_baconthe98"] = true,
    }

    local function removeHitboxFromCharacter(character)
        if character then
            local existing = character:FindFirstChild("HitboxExtension")
            if existing then
                existing:Destroy()
            end
            modifiedCharacters[character] = nil
        end
    end

    local function applyHitboxToCharacter(character)
        if not hitboxEnabled or not character or modifiedCharacters[character] then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local player = Players:GetPlayerFromCharacter(character)
        if not humanoidRootPart or (player and excludedNames[player.Name]) then
            removeHitboxFromCharacter(character)
            return
        end

        local hitbox = Instance.new("Part")
        hitbox.Size = hitboxSize
        hitbox.Transparency = 0.5
        hitbox.CanCollide = false
        hitbox.Anchored = false
        hitbox.Massless = true
        hitbox.Name = "HitboxExtension"
        hitbox.CFrame = humanoidRootPart.CFrame * CFrame.new(hitboxOffset)
        hitbox.Parent = character

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = humanoidRootPart
        weld.Part1 = hitbox
        weld.Parent = hitbox

        modifiedCharacters[character] = true
    end

    local function applyHitbox()
        if not hitboxEnabled then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if not excludedNames[player.Name] then
                applyHitboxToCharacter(player.Character)
            else
                removeHitboxFromCharacter(player.Character)
            end
        end
    end

    local function disableHitbox()
        if hitboxEnabled then
            hitboxEnabled = false
            for _, player in ipairs(Players:GetPlayers()) do
                removeHitboxFromCharacter(player.Character)
            end
        end
    end

    local function enableHitbox()
        if not hitboxEnabled then
            hitboxEnabled = true
            applyHitbox()
        end
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(0.1)
            applyHitboxToCharacter(character)
        end)
    end)

    applyHitbox()

    localPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        applyHitbox()
    end)

    task.spawn(function()
        while true do
            if hitboxEnabled then
                applyHitbox()
            end
            task.wait(2.5)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.J then
                disableHitbox()
            elseif input.KeyCode == Enum.KeyCode.H then
                enableHitbox()
            end
        end
    end)
end

local function script2()
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer

    local characterAddedConnections = {}
    local optimizeConnections = {}

    task.spawn(function()
        while true do
            local partsToRemove = {}
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") and obj.Name == "Part" then
                    table.insert(partsToRemove, obj)
                end
            end
            for _, part in pairs(partsToRemove) do
                pcall(function() part:Destroy() end)
            end
            task.wait(1)
        end
    end)

    local function ProcessMap()
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.SmoothPlastic
                part.CastShadow = false
            end
        end

        for _, light in pairs(Workspace:GetDescendants()) do
            if light:IsA("Light") then
                light.Enabled = false
            end
        end

        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(80, 80, 80)
        Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120)
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.GlobalShadows = true
    end
    ProcessMap()

    local function ProcessCharacter(character)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
            elseif part:IsA("Accessory") or part:IsA("ParticleEmitter") or part:IsA("Trail") then
                task.delay(0.05, function()
                    if part:IsDescendantOf(game) then
                        pcall(function() part:Destroy() end)
                    end
                end)
            end
        end
    end

    local function ProcessPlayer(player)
        if characterAddedConnections[player] then
            characterAddedConnections[player]:Disconnect()
        end

        if player.Character then
            ProcessCharacter(player.Character)
        end

        local conn = player.CharacterAdded:Connect(function(character)
            local success = pcall(function()
                character:WaitForChild("HumanoidRootPart", 5)
            end)
            if success then
                ProcessCharacter(character)
            end
        end)

        characterAddedConnections[player] = conn
    end

    local function OptimizeCharacter(character)
        local function onDescendantAdded(descendant)
            if descendant:IsA("Accessory") or descendant:IsA("Clothing") or descendant:IsA("ShirtGraphic") or descendant:IsA("Hair") then
                task.delay(0.05, function()
                    if descendant:IsDescendantOf(game) then
                        pcall(function() descendant:Destroy() end)
                    end
                end)
            elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
                task.delay(0.05, function()
                    if descendant:IsDescendantOf(game) then
                        pcall(function() descendant:Destroy() end)
                    end
                end)
            end
        end

        local conn
        conn = character.DescendantAdded:Connect(function(descendant)
            pcall(function()
                onDescendantAdded(descendant)
            end)
        end)

        pcall(function()
            character:WaitForChild("HumanoidRootPart", 5)
            character:WaitForChild("Humanoid", 5)
        end)

        task.wait(1)

        for _, item in pairs(character:GetDescendants()) do
            pcall(function() onDescendantAdded(item) end)
        end

        task.wait(0.5)

        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CastShadow = false
                end)
            end
        end

        task.delay(10, function()
            if conn then
                conn:Disconnect()
            end
        end)
    end

    local function OptimizePlayer(player)
        if optimizeConnections[player] then
            optimizeConnections[player]:Disconnect()
        end

        if player.Character then
            OptimizeCharacter(player.Character)
        end

        local conn = player.CharacterAdded:Connect(OptimizeCharacter)
        optimizeConnections[player] = conn
    end

    for _, player in pairs(Players:GetPlayers()) do
        task.spawn(function()
            ProcessPlayer(player)
            OptimizePlayer(player)
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        ProcessPlayer(player)
        OptimizePlayer(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        if characterAddedConnections[player] then
            characterAddedConnections[player]:Disconnect()
            characterAddedConnections[player] = nil
        end
        if optimizeConnections[player] then
            optimizeConnections[player]:Disconnect()
            optimizeConnections[player] = nil
        end
    end)

    task.spawn(function()
        while true do
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if myHRP then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local char = player.Character
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local dist = (hrp.Position - myHRP.Position).Magnitude
                            if dist > 150 and not char:GetAttribute("Optimized") then
                                char:SetAttribute("Optimized", true)
                                for _, obj in ipairs(char:GetDescendants()) do
                                    task.spawn(function()
                                        if obj:IsA("Sound") or obj:IsA("LocalScript") then
                                            pcall(function() obj:Destroy() end)
                                        elseif obj:IsA("BasePart") then
                                            pcall(function()
                                                obj.CastShadow = false
                                                obj.CanCollide = false
                                                obj.Transparency = 0.8
                                            end)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(2.5)
        end
    end)

    Workspace.ChildAdded:Connect(function(child)
        if child:IsA("Explosion") then
            task.defer(function()
                pcall(function()
                    child:Destroy()
                end)
            end)
        end
    end)

    task.spawn(function()
        while true do
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Explosion") then
                    pcall(function() obj:Destroy() end)
                end
            end
            task.wait(0.2)
        end
    end)
end

local function script3()
    local player = game.Players.LocalPlayer

    local function setupCharacter(character)
        local humanoid = character:WaitForChild("Humanoid")

        local function onKeyPress(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.R then
                humanoid.Health = 0
            end
        end

        game:GetService("UserInputService").InputBegan:Connect(onKeyPress)
    end

    player.CharacterAdded:Connect(setupCharacter)

    if player.Character then
        setupCharacter(player.Character)
    end
end

local function script4()
    local toolName = "Throwing Knife"
    local player = game.Players.LocalPlayer

    local function applyBoost()
        local character = player.Character
        if not character then return end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end

        local rightDirection = humanoidRootPart.CFrame.RightVector
        local boostDirection = Vector3.new(rightDirection.X * 150, 75, rightDirection.Z * 150)
        humanoidRootPart.Velocity = boostDirection
    end

    local function onCharacterAdded(character)
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and child.Name == toolName then
                applyBoost()
            end
        end)
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end

    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Lancer tous les scripts
script1()
script2()
script3()
script4()
