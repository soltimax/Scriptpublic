-- Script principal pour Delta (un seul exécutable)

local function script1()
	local Players = game:GetService("Players")
	local Lighting = game:GetService("Lighting")
	local Workspace = game:GetService("Workspace")
	local LocalPlayer = Players.LocalPlayer

	local characterAddedConnections = {}
	local optimizeConnections = {}

-- 🔁 Suppression ciblée des "Part" inutiles dans le workspace
task.spawn(function()
    while true do
        local partsToRemove = {}
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name == "Part" then
                table.insert(partsToRemove, obj)
            end
        end
        for _, part in pairs(partsToRemove) do
            part:Destroy()
        end
        task.wait(1)
    end
end)

-- 💡 Allègement de la carte
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

-- 🎯 Traitement d’un personnage
local function ProcessCharacter(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.5
        elseif part:IsA("Accessory") or part:IsA("ParticleEmitter") or part:IsA("Trail") then
            part:Destroy()
        end
    end
end

-- 👤 Traitement d’un joueur
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

-- 🧼 Nettoyage visuel complet d’un personnage
local function OptimizeCharacter(character)
    local function onDescendantAdded(descendant)
        if descendant:IsA("Accessory") or descendant:IsA("Clothing") or descendant:IsA("ShirtGraphic") or descendant:IsA("Hair") then
            descendant:Destroy()
        elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
            descendant:Destroy()
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

    wait(1)

    for _, item in pairs(character:GetDescendants()) do
        pcall(function() onDescendantAdded(item) end)
    end

    wait(0.5)

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

-- 📦 Application de l’optimisation sur le joueur
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

-- ⚙️ Initialisation des joueurs présents
for _, player in pairs(Players:GetPlayers()) do
    task.spawn(function()
        ProcessPlayer(player)
        OptimizePlayer(player)
    end)
end

-- 📥 Connexion des nouveaux joueurs
Players.PlayerAdded:Connect(function(player)
    ProcessPlayer(player)
    OptimizePlayer(player)
end)

-- 🧹 Nettoyage des connexions quand un joueur part
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

-- 🔭 Optimisation dynamique des joueurs éloignés (>150 studs)
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
                                if obj:IsA("Sound") or obj:IsA("LocalScript") then
                                    pcall(function() obj:Destroy() end)
                                elseif obj:IsA("BasePart") then
                                    pcall(function()
                                        obj.CastShadow = false
                                        obj.CanCollide = false
                                        obj.Transparency = 0.8
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(2.5)
    end
end)

-- 💥 Suppression instantanée des explosions
Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Explosion") then
        task.defer(function()
            pcall(function()
                child:Destroy()
            end)
        end)
    end
end)

-- 🔄 Boucle continue de sécurité pour supprimer les explosions restantes
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

-- 🌳 Optimisation des arbres Cyber Tree
task.spawn(function()
    while true do
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if myHRP then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Cyber Tree" then
                    local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if primary and (primary.Position - myHRP.Position).Magnitude <= 1000 then
                        for _, part in pairs(obj:GetDescendants()) do
                            if part:IsA("BasePart") then
                                pcall(function()
                                    part.Material = Enum.Material.SmoothPlastic
                                    part.CastShadow = false
                                    part.Transparency = 1  -- tu peux mettre 0.5 si tu veux juste rendre "fantôme"
                                end)
                            end
                        end
                    end
                end
            end
        end
        task.wait(3)
    end
end)
end

local function script2()
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

local function script3()
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

local function script4()
    local Players = game:GetService("Players")

local BAD_IDS = {
    ["rbxassetid://11257899743"] = true,
    ["rbxassetid://11257809743"] = true,
}

-- Fonction pour bloquer une animation spécifique
local function blockIfBadAnimation(anim)
    if anim:IsA("Animation") and BAD_IDS[anim.AnimationId] then
        anim.AnimationId = "rbxassetid://0"
    end
end

-- Fonction qui connecte les événements d’un personnage
local function monitorCharacter(character)
    -- Check initial de toutes les animations
    for _, obj in ipairs(character:GetDescendants()) do
        blockIfBadAnimation(obj)
    end

    -- Check dynamique si une animation est ajoutée plus tard
    character.DescendantAdded:Connect(function(descendant)
        blockIfBadAnimation(descendant)
    end)
end

-- Fonction pour gérer chaque joueur
local function onPlayer(player)
    if player.Character then
        monitorCharacter(player.Character)
    end
    player.CharacterAdded:Connect(monitorCharacter)
end

-- Appliquer à tous les joueurs actuels
for _, player in ipairs(Players:GetPlayers()) do
    onPlayer(player)
end

-- Pour les nouveaux joueurs
Players.PlayerAdded:Connect(onPlayer)
end

-- Lancer tous les scripts
script1()
script2()
script3()
script4()
