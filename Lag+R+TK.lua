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

-- 💡 Allègement de la carte (optimisé GPU/CPU)
local function ProcessMap()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Matériau le plus léger
            part.Material = Enum.Material.Plastic
            -- Supprime les ombres
            part.CastShadow = false
        end
    end

    for _, light in pairs(Workspace:GetDescendants()) do
        if light:IsA("Light") then
            light.Enabled = false
        end
    end

    -- Réglages Lighting ultra light
    Lighting.Brightness = 0.5
    Lighting.Ambient = Color3.fromRGB(50, 50, 50)
    Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 80)
    Lighting.EnvironmentDiffuseScale = 0.2
    Lighting.EnvironmentSpecularScale = 0
    Lighting.Technology = Enum.Technology.Legacy
    Lighting.GlobalShadows = false
end
ProcessMap()

-- 💥 Suppression instantanée des explosions (C4 / grenades)
Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Explosion") then
        task.defer(function()
            pcall(function()
                child:Destroy()
            end)
        end)
    end
end)

-- 🌳 Optimisation des arbres "Cyber Tree" (une seule fois)
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and obj.Name == "Cyber Tree" then
        local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if primary then
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.Material = Enum.Material.SmoothPlastic
                        part.CastShadow = false
                        part.Transparency = 1
                    end)
                end
            end
        end
    end
end

-- 🔄 Boucle continue de sécurité pour supprimer toute explosion restante
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
    local toolName = "Throwing Knife" -- Nom exact de l'outil
	local player = game.Players.LocalPlayer
	local boostEnabled = false -- Par défaut, le boost est désactivé

-- Fonction qui applique le boost vers la droite du joueur
local function applyBoost()
    if not boostEnabled then return end -- Si boost désactivé, ne rien faire

    local character = player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    -- Déterminer la direction vers la droite du joueur
    local rightDirection = humanoidRootPart.CFrame.RightVector

    -- Appliquer une impulsion vers la droite et en hauteur
    local boostDirection = Vector3.new(rightDirection.X * 150, 75, rightDirection.Z * 150)
    humanoidRootPart.Velocity = boostDirection
end

-- Détection de l'équipement de l'outil
local function onCharacterAdded(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == toolName then
            applyBoost()
        end
    end)
end

-- Vérifier quand le joueur spawn
if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Détection des touches pour activer/désactiver le boost
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end -- Ignorer si l'input est déjà traité

    if input.KeyCode == Enum.KeyCode.K then
        boostEnabled = true
        print("Boost activé")
    elseif input.KeyCode == Enum.KeyCode.L then
        boostEnabled = false
        print("Boost désactivé")
    end
end)
end

-- Lancer tous les scripts
script1()
script2()
script3()
