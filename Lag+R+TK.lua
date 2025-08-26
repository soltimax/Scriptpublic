-- Script principal pour Delta (un seul exécutable)

local function script1()
	local Players = game:GetService("Players")
	local Workspace = game:GetService("Workspace")
	local Lighting = game:GetService("Lighting")
	local LocalPlayer = Players.LocalPlayer

-- 🔁 Suppression ciblée des "Part" inutiles dans le workspace
for _, obj in pairs(Workspace:GetChildren()) do
    if obj:IsA("BasePart") and obj.Name == "Part" then
        obj.Transparency = 1
        obj.CanCollide = false
    end
end

-- 💡 Allègement général de la carte
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

-- 💥 Suppression visuelle des explosions
for _, obj in pairs(Workspace:GetChildren()) do
    if obj:IsA("Explosion") then
        obj.BlastPressure = 0
        obj.BlastRadius = 0
        obj.Visible = false
    end
end

Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Explosion") then
        child.BlastPressure = 0
        child.BlastRadius = 0
        child.Visible = false
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

-- 👤 Optimisation LOD des joueurs éloignés (>150 studs)
task.spawn(function()
    while true do
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHRP then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - myHRP.Position).Magnitude
                        if dist > 150 then
                            for _, obj in pairs(player.Character:GetDescendants()) do
                                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                                    obj.Enabled = false
                                elseif obj:IsA("Sound") then
                                    obj.Volume = 0
                                elseif obj:IsA("BasePart") then
                                    pcall(function()
                                        obj.CastShadow = false
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(2) -- mise à jour toutes les 2 secondes
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
