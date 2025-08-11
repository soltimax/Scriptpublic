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
  if not game:IsLoaded() then
game.Loaded:Wait()
end

-- Obtenez les services nécessaires
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Liste des noms de joueurs à fixer
local targetPlayerNames = {}
local LockDistance = 10 -- Distance de verrouillage pour fixer
local FollowDistance = 45 -- Distance pour suivre la caméra
local revolverEquipped = false
local RANGE = 90

-- Crée l'interface utilisateur
local ScreenGui = Instance.new("ScreenGui")
local TextBox = Instance.new("TextBox")
local AddButton = Instance.new("TextButton")
local RemoveButton = Instance.new("TextButton")
local SuggestionsFrame = Instance.new("Frame")

-- Configure ScreenGui
ScreenGui.Parent = game.CoreGui

-- Configure TextBox pour entrer le nom du joueur
TextBox.Parent = ScreenGui
TextBox.Size = UDim2.new(0, 200, 0, 30)
TextBox.Position = UDim2.new(1, -220, 0, 10) -- En haut à droite
TextBox.PlaceholderText = "Entrer le nom du joueur"
TextBox.Text = ""
TextBox.TextSize = 14

-- Configure le bouton "Fixe"
AddButton.Parent = ScreenGui
AddButton.Size = UDim2.new(0, 100, 0, 30)
AddButton.Position = UDim2.new(1, -120, 0, 50) -- Sous la zone de texte, à droite
AddButton.Text = "Fixe"
AddButton.TextSize = 14

-- Configure le bouton "Unfixe"
RemoveButton.Parent = ScreenGui
RemoveButton.Size = UDim2.new(0, 100, 0, 30)
RemoveButton.Position = UDim2.new(1, -230, 0, 50) -- À gauche du bouton "Fixe"
RemoveButton.Text = "Unfixe"
RemoveButton.TextSize = 14

-- Configure le cadre des suggestions
SuggestionsFrame.Parent = ScreenGui
SuggestionsFrame.Size = UDim2.new(0, 200, 0, 100) -- Largeur de 200 et hauteur ajustée
SuggestionsFrame.Position = UDim2.new(1, -220, 0, 90) -- Sous les boutons "Fixe" et "Unfixe"
SuggestionsFrame.BackgroundTransparency = 0.5
SuggestionsFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
SuggestionsFrame.Visible = false -- Masqué par défaut

-- Fonction pour obtenir le joueur cible par son nom d'affichage
local function GetPlayerByName(displayName)
for _, player in pairs(Players:GetPlayers()) do
if player.DisplayName == displayName then
return player
end
end
return nil
end

-- Action du bouton "Fixe" pour ajouter un joueur à la liste
AddButton.MouseButton1Click:Connect(function()
local enteredName = TextBox.Text
if enteredName ~= "" and not table.find(targetPlayerNames, enteredName) then
table.insert(targetPlayerNames, enteredName)
TextBox.Text = "" -- Réinitialise la zone de texte après l'ajout
end
end)

-- Action du bouton "Unfixe" pour retirer un joueur de la liste
RemoveButton.MouseButton1Click:Connect(function()
local enteredName = TextBox.Text
if enteredName ~= "" then
for i, name in ipairs(targetPlayerNames) do
if name == enteredName then
table.remove(targetPlayerNames, i)
break
end
end
TextBox.Text = "" -- Réinitialise la zone de texte après le retrait
end
end)

-- Fonction pour obtenir le joueur cible le plus proche dans la liste, en excluant ceux en ragdoll ou morts
local function GetClosestTargetPlayer()
local closestPlayer = nil
local closestDistance = FollowDistance -- Distance max pour suivre

for _, targetName in ipairs(targetPlayerNames) do    
    local targetPlayer = GetPlayerByName(targetName)    

    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then    
        local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")    
        local forceField = targetPlayer.Character:FindFirstChildOfClass("ForceField") -- Vérifie s'il a un ForceField    

        -- Vérifier si le joueur est en mode ragdoll, mort ou protégé par un ForceField    
        if humanoid and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Physics and not forceField then    
            -- Calculer la distance au joueur valide    
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude    
              
            -- Si le joueur est plus proche que le précédent    
            if distance <= FollowDistance and (not closestPlayer or distance < (closestPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) then    
                closestPlayer = targetPlayer    
            end    
        end    
    end    
end    
return closestPlayer

end

-- Script d'AutoShoot intégré
local function getClosestTargetForShooting()
    local closest, shortestDist = nil, math.huge
    for _, plr in pairs(targetPlayerNames) do  -- Vérifie uniquement les joueurs cibles
        local player = GetPlayerByName(plr)
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist and dist <= RANGE then
                shortestDist = dist
                closest = player
            end
        end
    end
    return closest
end

local function fireAtTarget(gun, target)
    local attachment = gun:FindFirstChild("Barrel") and gun.Barrel:FindFirstChild("Attachment")
    local replicateRemote = gun:FindFirstChild("ReplicateRemote")
    local damageRemote = gun:FindFirstChild("DamageRemote")
    local bulletTemplate = ReplicatedStorage:FindFirstChild("Revolver Bullet")

    if not (attachment and replicateRemote and damageRemote and bulletTemplate) then return end  

    -- Arrêter si le joueur est en ragdoll  
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")  
    if humanoid and humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Physics then  
        return  -- Si en ragdoll ou la santé est à 0, arrêter de tirer  
    end  

    -- Animation du tir  
    local animator = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):FindFirstChild("Animator")  
    local anim  
    if animator and gun:FindFirstChild("Fire") then  
        anim = animator:LoadAnimation(gun.Fire)  
        anim:Play()  
        anim:AdjustSpeed(0.8)  
    end  

    local origin = attachment.WorldPosition  
    local hitPos = target.Character.HumanoidRootPart.Position  -- Position cible de base  

    -- Animation du tir (pas de déviation aléatoire)  
    local direction = (hitPos - origin).Unit * 100  -- Utilise la position cible de base  

    -- Liste des objets à ignorer lors du raycast  
    local ignoreList = {LocalPlayer.Character, workspace:FindFirstChild("Target Filter")}  
    for _, v in pairs(workspace:GetDescendants()) do  
        if v:IsA("Accessory") then  
            table.insert(ignoreList, v)  
        end
    end  

    -- Raycast pour vérifier si un obstacle bloque le tir  
    local ray = Ray.new(origin, direction)  
    local hitPart, finalHitPos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)  

    -- Si un obstacle est détecté entre le tireur et la cible, arrêter l'animation de tir  
    if hitPart and hitPart.Parent and hitPart.Parent ~= target.Character then  
        -- Arrêter l'animation si un obstacle est rencontré  
        if anim then  
            anim:Stop()  -- Arrêter l'animation de tir  
        end  
        return  -- Ignorer le tir  
    end  

    -- Si aucun obstacle, continuer  
    if not finalHitPos then finalHitPos = hitPos end  

    local distance = (origin - finalHitPos).Magnitude  
    local bullet = bulletTemplate:Clone()  
    bullet.Size = Vector3.new(0.2, 0.2, distance)  
    bullet.CFrame = CFrame.new(origin, finalHitPos) * CFrame.new(0, 0, -distance / 2)  
    bullet.Parent = workspace:FindFirstChild("Target Filter") or workspace  
    Debris:AddItem(bullet, 1)  

    TweenService:Create(bullet, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {  
        Size = Vector3.new(0.05, 0.05, distance),  
        Transparency = 1  
    }):Play()  

    if hitPart and hitPart.Parent:FindFirstChild("Humanoid") then  
        local impact = Instance.new("Part")  
        impact.Anchored = true  
        impact.CanCollide = false  
        impact.Shape = "Ball"  
        impact.Material = Enum.Material.Neon  
        impact.BrickColor = bullet.BrickColor  
        impact.Size = Vector3.new(0.1, 0.1, 0.1)  
        impact.Position = finalHitPos  
        impact.Parent = workspace:FindFirstChild("Target Filter") or workspace  
        Debris:AddItem(impact, 2)  

        TweenService:Create(impact, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {  
            Size = Vector3.new(2, 2, 2),  
            Transparency = 1  
        }):Play()  

        damageRemote:FireServer(hitPart.Parent.Humanoid)  
    end  

    replicateRemote:FireServer(finalHitPos)  -- Envoie la position finale du tir
end

-- Tirs auto
task.spawn(function()
while true do
if revolverEquipped then
local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Kawaii Revolver")
local target = getClosestTargetForShooting()
if gun and target then
fireAtTarget(gun, target)
end
end
task.wait(1)
end
end)

-- Gestion de l’équipement manuel
local function setupToolDetection(char)
char.ChildAdded:Connect(function(child)
if child:IsA("Tool") and child.Name == "Kawaii Revolver" then
revolverEquipped = true
end
end)

char.ChildRemoved:Connect(function(child)  
    if child:IsA("Tool") and child.Name == "Kawaii Revolver" then  
        revolverEquipped = false  
    end  
end)

end

-- S’il a déjà son perso et l’arme
if LocalPlayer.Character then
setupToolDetection(LocalPlayer.Character)
if LocalPlayer.Character:FindFirstChild("Kawaii Revolver") then
revolverEquipped = true
end
end

-- Nouveau personnage
LocalPlayer.CharacterAdded:Connect(function(char)
revolverEquipped = false
char:WaitForChild("HumanoidRootPart")
setupToolDetection(char)
end)

-- Fonction pour mettre Ã  jour les suggestions
local function updateSuggestions(inputText)
-- Effacer les suggestions prÃ©cÃ©dentes
for _, child in ipairs(SuggestionsFrame:GetChildren()) do
if child:IsA("TextButton") then
child:Destroy()
end
end

-- Si aucun texte n'est entrÃ©, ne rien afficher
if inputText == "" then
SuggestionsFrame.Visible = false
return
end

SuggestionsFrame.Visible = true
local yOffset = 0

-- Comparer avec les noms d'affichage des joueurs
for _, player in ipairs(Players:GetPlayers()) do
if player.DisplayName:lower():find(inputText:lower()) then
-- CrÃ©er un bouton pour chaque suggestion
local SuggestionButton = Instance.new("TextButton")
SuggestionButton.Size = UDim2.new(1, 0, 0, 20) -- Ajustement de la taille pour Ãªtre plus compact
SuggestionButton.Position = UDim2.new(0, 0, 0, yOffset)
SuggestionButton.Text = player.DisplayName
SuggestionButton.TextScaled = true
SuggestionButton.TextColor3 = Color3.new(1, 1, 1)
SuggestionButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
SuggestionButton.BorderSizePixel = 0
SuggestionButton.Parent = SuggestionsFrame

-- Quand une suggestion est sÃ©lectionnÃ©e, remplir le TextBox    
    SuggestionButton.MouseButton1Click:Connect(function()    
        TextBox.Text = player.DisplayName    
        updateSuggestions("") -- RÃ©initialise les suggestions    
    end)    

    yOffset = yOffset + 25 -- Espace pour chaque suggestion    
end

end

end

-- DÃ©tecter les changements dans le TextBox et mettre Ã  jour les suggestions
TextBox:GetPropertyChangedSignal("Text"):Connect(function()
updateSuggestions(TextBox.Text)
end)

-- Liste des joueurs temporairement exclus
local excludedPlayerNames = {}

-- Fonction pour vérifier si un joueur a le Kawaii Revolver
local function HasKawaiiRevolver(player)
if player.Backpack:FindFirstChild("Kawaii Revolver") or (player.Character and player.Character:FindFirstChild("Kawaii Revolver")) then
return true
end
return false
end

-- Met à jour dynamiquement les listes des cibles et des exclus
local function UpdateTargetList()
local newTargetList = {}

-- Parcourir la liste actuelle pour exclure ceux sans Kawaii Revolver
for _, targetName in ipairs(targetPlayerNames) do
local targetPlayer = GetPlayerByName(targetName)

if targetPlayer then    
    if HasKawaiiRevolver(targetPlayer) then    
        -- Garde le joueur dans la liste principale s'il a le Kawaii Revolver    
        table.insert(newTargetList, targetName)    
    else    
        -- Déplace le joueur dans la liste des exclus    
        if not table.find(excludedPlayerNames, targetName) then    
            table.insert(excludedPlayerNames, targetName)    
        end    
    end    
end

end

-- Parcourir les exclus pour réintégrer ceux qui ont maintenant le Kawaii Revolver
local remainingExclusions = {}
for _, excludedName in ipairs(excludedPlayerNames) do
local excludedPlayer = GetPlayerByName(excludedName)

if excludedPlayer and HasKawaiiRevolver(excludedPlayer) then    
    -- Réintègre dans la liste principale    
    table.insert(newTargetList, excludedName)    
else    
    -- Garde dans la liste des exclus s'ils n'ont toujours pas l'objet    
    table.insert(remainingExclusions, excludedName)    
end

end

-- Mise à jour des listes
targetPlayerNames = newTargetList
excludedPlayerNames = remainingExclusions

end

-- Fonction pour vérifier si l'outil Chainsaw est équipé
local function checkEquippedTool()
local character = LocalPlayer.Character
if character then
local tool = character:FindFirstChildOfClass("Tool")
if tool then
-- Si l'outil est Chainsaw
if tool.Name == "Chainsaw" then
return true
end
end
end
return false
end

-- Fonction pour obtenir la position anticipée du joueur cible en fonction de sa vélocité
local function GetPredictedPosition(targetPlayer, predictionTime)
if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
local humanoidRootPart = targetPlayer.Character.HumanoidRootPart
local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")

if humanoid and humanoidRootPart then
-- Utiliser la vélocité du joueur pour prédire sa position dans 'predictionTime' secondes
local velocity = humanoidRootPart.Velocity
local predictedPosition = humanoidRootPart.Position + velocity * predictionTime

-- Pour éviter de prédire trop loin, on limite la distance de prédiction    
    local maxPredictionDistance = 7  -- Limite de la prédiction à 10 unités    
    if (predictedPosition - humanoidRootPart.Position).Magnitude > maxPredictionDistance then    
        predictedPosition = humanoidRootPart.Position + velocity.unit * maxPredictionDistance    
    end    

    return predictedPosition    
end

end
return nil

end

-- Fonction pour verrouiller la caméra et viser la position anticipée
local function UpdateCamera(closestPlayer)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
-- Vérification de l'outil équipé
local equippedTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
local isChainsawEquipped = equippedTool and equippedTool.Name == "Chainsaw"

-- Si aucun joueur cible ou aucun outil Chainsaw n'est équipé, ne rien faire
if not closestPlayer or not isChainsawEquipped then
return
end

-- Vérifie si le joueur cible a un ForceField    
if closestPlayer.Character:FindFirstChildOfClass("ForceField") then    
    return -- Ignore ce joueur et n'applique pas la caméra sur lui    
end    

local localRoot = LocalPlayer.Character.HumanoidRootPart    
local targetRoot = closestPlayer.Character.HumanoidRootPart    

-- Calcul de la position anticipée du joueur cible uniquement si la Chainsaw est équipée    
local predictedPosition = GetPredictedPosition(closestPlayer, 0.2)    

if predictedPosition then    
    -- Distance et hauteur de la caméra    
    local orbitDistance = 25  -- Distance de la caméra autour du joueur local    
    local heightOffset = 20   -- Hauteur de la caméra    

    -- Calculer la position de la caméra    
    local directionToTarget = (predictedPosition - localRoot.Position).unit    
    local cameraPosition = localRoot.Position - directionToTarget * orbitDistance + Vector3.new(0, heightOffset, 0)    

    -- Mise à jour de la caméra pour regarder vers la position anticipée    
    workspace.CurrentCamera.CFrame = CFrame.new(cameraPosition, predictedPosition)    
end

end

end

-- Fonction pour fixer le personnage sur le joueur cible
local function LockToTarget(closestPlayer)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
local equippedTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
local isChainsawEquipped = equippedTool and equippedTool.Name == "Chainsaw"

-- Ne pas exécuter la fonction si Chainsaw n'est pas équipé ou aucun joueur n'est ciblé
if not isChainsawEquipped or not closestPlayer then
return
end

-- Vérifier si le joueur cible a un ForceField    
if closestPlayer.Character:FindFirstChildOfClass("ForceField") then    
    return -- Ignore ce joueur et ne le fixe pas    
end    

-- Ne pas fixer les cibles si le joueur local est mort ou en ragdoll    
if humanoid and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Physics then    
    local characterPosition = LocalPlayer.Character.HumanoidRootPart.Position    
    local targetPosition = closestPlayer.Character.HumanoidRootPart.Position    

    -- Vérifiez si le joueur cible est à 10 mètres ou moins    
    local distance = (characterPosition - targetPosition).Magnitude    
    if distance <= LockDistance then    
        -- Fixer le personnage sur le joueur cible sans inclinaison    
        targetPosition = Vector3.new(targetPosition.X, characterPosition.Y, targetPosition.Z)    
        local lookDirection = (targetPosition - characterPosition).unit    
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(characterPosition, characterPosition + lookDirection)    
    end    
end

end

end

-- Suivre le joueur cible le plus proche, uniquement si le joueur local est actif
RunService.RenderStepped:Connect(function()
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")

-- Ne pas fixer les cibles si le joueur local est mort ou en ragdoll
if humanoid and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Physics then
-- Met à jour dynamiquement la liste des cibles
UpdateTargetList()
local closestPlayer = GetClosestTargetPlayer()

if closestPlayer then    
        -- Appelle les fonctions de mise à jour de la caméra et de verrouillage    
        UpdateCamera(closestPlayer) -- Suivre le joueur cible avec la caméra    
        LockToTarget(closestPlayer) -- Fixer le personnage sur le joueur cible    
    end    
end

end

end)
end
