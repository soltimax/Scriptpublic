-- Bodyguard v7 (Smart Bot - Realistic Movement + Gun Equip + Chainsaw Melee Hit & Run)
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Variables
local targetPlayerNames = {}
local MaintainDistance = 70
local RANGE = math.huge
local MeleeRange = 15 -- Distance pour déclencher l'attaque Chainsaw

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
local TextBox = Instance.new("TextBox")
local AddButton = Instance.new("TextButton")
local RemoveButton = Instance.new("TextButton")
local SuggestionsFrame = Instance.new("Frame")

ScreenGui.Parent = game.CoreGui

TextBox.Parent = ScreenGui
TextBox.Size = UDim2.new(0, 200, 0, 30)
TextBox.Position = UDim2.new(1, -220, 0, 10)
TextBox.PlaceholderText = "Entrer le nom du joueur"
TextBox.Text = ""
TextBox.TextSize = 14

AddButton.Parent = ScreenGui
AddButton.Size = UDim2.new(0, 100, 0, 30)
AddButton.Position = UDim2.new(1, -120, 0, 50)
AddButton.Text = "Fixe"
AddButton.TextSize = 14

RemoveButton.Parent = ScreenGui
RemoveButton.Size = UDim2.new(0, 100, 0, 30)
RemoveButton.Position = UDim2.new(1, -230, 0, 50)
RemoveButton.Text = "Unfixe"
RemoveButton.TextSize = 14

SuggestionsFrame.Parent = ScreenGui
SuggestionsFrame.Size = UDim2.new(0, 200, 0, 100)
SuggestionsFrame.Position = UDim2.new(1, -220, 0, 90)
SuggestionsFrame.BackgroundTransparency = 0.5
SuggestionsFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
SuggestionsFrame.Visible = false

-- Fonctions utilitaires
local function GetPlayerByName(displayName)
    for _, player in pairs(Players:GetPlayers()) do
        if player.DisplayName == displayName then
            return player
        end
    end
    return nil
end

local function getClosestTargetForShooting()
    local closest, shortestDist = nil, math.huge
    for _, plr in pairs(targetPlayerNames) do
        local player = GetPlayerByName(plr)
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = player
            end
        end
    end
    return closest
end

local function fireAtTarget(gun, target)
    if not gun or not target or not target.Character then return end
    
    local attachment = gun:FindFirstChild("Barrel")
    if attachment then
        attachment = attachment:FindFirstChild("Attachment")
    end
    
    local replicateRemote = gun:FindFirstChild("ReplicateRemote")
    local damageRemote = gun:FindFirstChild("DamageRemote")
    local bulletTemplate = ReplicatedStorage:FindFirstChild("Revolver Bullet")

    if not (attachment and replicateRemote and damageRemote and bulletTemplate) then return end

    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local humanoidState = humanoid:GetState()
    if humanoidState == Enum.HumanoidStateType.Physics then return end

    local animator = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):FindFirstChild("Animator")
    local anim
    if animator and gun:FindFirstChild("Fire") then
        anim = animator:LoadAnimation(gun.Fire)
        anim:Play()
        anim:AdjustSpeed(0.8)
    end

    local origin = attachment.WorldPosition
    local hitPos = target.Character.HumanoidRootPart.Position
    local direction = (hitPos - origin).Unit * 100

    local ignoreList = {LocalPlayer.Character, workspace:FindFirstChild("Target Filter")}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Accessory") then
            table.insert(ignoreList, v)
        end
    end

    local ray = Ray.new(origin, direction)
    local hitPart, finalHitPos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

    if hitPart and hitPart.Parent and hitPart.Parent ~= target.Character then
        if anim then anim:Stop() end
        return
    end

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

    replicateRemote:FireServer(finalHitPos)
end

-- UI Events
AddButton.MouseButton1Click:Connect(function()
    local enteredName = TextBox.Text
    if enteredName ~= "" and not table.find(targetPlayerNames, enteredName) then
        table.insert(targetPlayerNames, enteredName)
        TextBox.Text = ""
    end
end)

RemoveButton.MouseButton1Click:Connect(function()
    local enteredName = TextBox.Text
    if enteredName ~= "" then
        for i, name in ipairs(targetPlayerNames) do
            if name == enteredName then
                table.remove(targetPlayerNames, i)
                break
            end
        end
        TextBox.Text = ""
    end
end)

local function updateSuggestions(inputText)
    for _, child in ipairs(SuggestionsFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    if inputText == "" then SuggestionsFrame.Visible = false return end

    SuggestionsFrame.Visible = true
    local yOffset = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName:lower():find(inputText:lower()) then
            local SuggestionButton = Instance.new("TextButton")
            SuggestionButton.Size = UDim2.new(1, 0, 0, 20)
            SuggestionButton.Position = UDim2.new(0, 0, 0, yOffset)
            SuggestionButton.Text = player.DisplayName
            SuggestionButton.TextScaled = true
            SuggestionButton.TextColor3 = Color3.new(1, 1, 1)
            SuggestionButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            SuggestionButton.BorderSizePixel = 0
            SuggestionButton.Parent = SuggestionsFrame

            SuggestionButton.MouseButton1Click:Connect(function()
                TextBox.Text = player.DisplayName
                updateSuggestions("")
            end)
            yOffset = yOffset + 25
        end
    end
end

TextBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateSuggestions(TextBox.Text)
end)

-- Smart Auto-Shoot & Chainsaw Melee System
local function SetupAutoAttackLoop()
    task.spawn(function()
        while true do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local target = getClosestTargetForShooting()
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                
                local gun = character:FindFirstChild("Kawaii Revolver")
                local chainsaw = character:FindFirstChild("Chainsaw")

                if target and target.Character and hrp then
                    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local distance = (hrp.Position - targetRoot.Position).Magnitude

                        -- Priorité 1 : CORPS A CORPS (Si on est assez proche)
                        if distance <= MeleeRange then
                            -- On range le revolver s'il est dans les mains
                            if gun and backpack then gun.Parent = backpack end
                            
                            -- On équilibre la Chainsaw
                            if not chainsaw and backpack then
                                local chainsawInBackpack = backpack:FindFirstChild("Chainsaw")
                                if chainsawInBackpack then
                                    chainsawInBackpack.Parent = character
                                    chainsaw = chainsawInBackpack
                                    task.wait(0.2) -- Temps d'équipement
                                end
                            end

                            if chainsaw then
                                -- Arrêt net pour préparer la propulsion
                                local bv = hrp:FindFirstChildOfClass("BodyVelocity")
                                if bv then bv.Velocity = Vector3.new(0,0,0) end
                                task.wait(0.1)

                                -- Calcul de la direction de projection
                                local dirToTarget = (targetRoot.Position - hrp.Position)
                                dirToTarget = Vector3.new(dirToTarget.X, 0, dirToTarget.Z)

                                -- Propulsion violente vers la cible (Slingshot)
                                if bv then
                                    bv.Velocity = dirToTarget.Unit * 200
                                end
                                
                                task.wait(0.15) -- Temps pour parcourir les derniers mètres

                                -- On fixe la cible avec le CFrame et on active l'attaque
                                hrp.CFrame = CFrame.new(hrp.Position, targetRoot.Position)
                                chainsaw:Activate()

                                -- Fuite immédiate en arrière pour ne pas prendre de dégâts
                                task.wait(0.2) -- Laisser le temps aux dégâts de la Chainsaw de s'appliquer
                                if bv then
                                    bv.Velocity = -dirToTarget.Unit * 180
                                end
                                
                                task.wait(0.4) -- Temps de la phase de recul
                                if bv then bv.Velocity = Vector3.new(0,0,0) end -- Stop net après la fuite
                            end

                        -- Priorité 2 : TIR A DISTANCE (Si on est trop loin)
                        else
                            -- On range la Chainsaw si elle est dans les mains
                            if chainsaw and backpack then chainsaw.Parent = backpack end

                            -- On équilibre le Revolver
                            if not gun and backpack then
                                local gunInBackpack = backpack:FindFirstChild("Kawaii Revolver")
                                if gunInBackpack then
                                    gunInBackpack.Parent = character
                                    gun = gunInBackpack
                                    task.wait(0.3)
                                end
                            end
                            
                            if gun then fireAtTarget(gun, target) end
                        end
                    end
                else
                    -- Plus de cible : On range tout
                    if gun and backpack then gun.Parent = backpack end
                    if chainsaw and backpack then chainsaw.Parent = backpack end
                end
            else
                task.wait(0.2)
            end
            task.wait(0.1) -- Boucle d'attaque plus rapide pour la réactivité au CaC
        end
    end)
end

SetupAutoAttackLoop()

-- ==========================================
-- NOUVEAU SYSTÈME DE DÉPLACEMENT RÉALISTE
-- ==========================================
local function SetupMovementLoop()
    task.spawn(function()
        while true do
            -- On attend d'avoir un personnage valide
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
                task.wait(1)
                continue
            end

            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Nettoyer les anciens BodyVelocity (sécurité)
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyVelocity") then v:Destroy() end
            end

            -- Créer BodyVelocity
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(1e5, 0, 1e5)
            bv.P = 1250
            bv.Parent = hrp

            -- Paramètres de raycast
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.IgnoreWater = true

            -- Vérifie s'il y a un obstacle dans la direction donnée + détection de précipice
            local function isDirectionClear(direction)
                local origin = hrp.Position
                local horizontalOffset = direction.Unit * 10
                local horizontalEnd = origin + horizontalOffset

                local obstacleCheck = workspace:Raycast(origin, horizontalOffset, rayParams)
                if obstacleCheck then return false end

                local downOffset = Vector3.new(0, -100, 0)
                local currentGround = workspace:Raycast(origin, downOffset, rayParams)
                local targetGround = workspace:Raycast(horizontalEnd, downOffset, rayParams)

                if currentGround and targetGround then
                    local heightDiff = currentGround.Position.Y - targetGround.Position.Y
                    if heightDiff < 4 then return true end
                end
                return false
            end

            -- Limite l'angle entre deux directions
            local function isDirectionWithinAngleLimit(oldDir, newDir, maxAngleDeg)
                if not oldDir then return true end
                local dot = oldDir.Unit:Dot(newDir.Unit)
                local angle = math.deg(math.acos(dot))
                return angle <= maxAngleDeg
            end

            -- Génère une direction aléatoire mais raisonnable
            local function getSafeDirection(previousDirection)
                local tries = 0
                while tries < 15 do
                    local angle = math.rad(math.random(0, 360))
                    local radius = math.random(20, 50)
                    local x = math.cos(angle) * radius
                    local z = math.sin(angle) * radius
                    local dir = Vector3.new(x, 0, z)

                    if dir.Magnitude > 5 and isDirectionClear(dir) then
                        if isDirectionWithinAngleLimit(previousDirection, dir, 90) then
                            return dir
                        end
                    end
                    tries = tries + 1
                end
                return nil
            end

            local speed = 70
            local currentDirection = nil
            local strafeSide = 1 -- Variable pour changer de côté de strafe (1 = droite, -1 = gauche)
            local strafeTimer = 0 -- Timer pour changer de côté régulièrement

            -- Boucle de mouvement spécifique à CE personnage
            while character and character.Parent and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 do
                local target = getClosestTargetForShooting()

                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    -- MODE SUIVI DE CIBLE
                    local targetRoot = target.Character.HumanoidRootPart
                    local currentDistance = (hrp.Position - targetRoot.Position).Magnitude
                    
                    -- Calcul du vecteur latéral (strafe) perpendiculaire à la cible
                    local dirToTarget = (targetRoot.Position - hrp.Position)
                    dirToTarget = Vector3.new(dirToTarget.X, 0, dirToTarget.Z)
                    local strafeVector = Vector3.new(-dirToTarget.Z, 0, dirToTarget.X).Unit * strafeSide
                    
                    strafeTimer = strafeTimer + 0.1
                    -- Changer de direction de strafe toutes les 0.8 secondes pour être imprévisible
                    if strafeTimer >= 0.8 then
                        strafeSide = strafeSide * -1
                        strafeTimer = 0
                    end

                    -- Si on est en phase d'attaque au Corps à Corps, on désactive le mouvement normal pour ne pas interférer avec la propulsion/fuite
                    local chainsawEquipped = character:FindFirstChild("Chainsaw")
                    if currentDistance <= MeleeRange and chainsawEquipped then
                        bv.Velocity = Vector3.new(0,0,0) -- Le script d'attaque gère le BodyVelocity
                        task.wait(0.8)
                        continue
                    end

                    if currentDistance > MaintainDistance then
                        -- Trop loin : on se rapproche EN STRAFANT (diagonale) pour ne pas être une cible facile
                        local moveDir = (dirToTarget.Unit + strafeVector).Unit
                        
                        if isDirectionClear(moveDir) then
                            local velocity = moveDir * speed
                            bv.Velocity = velocity
                            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dirToTarget) -- On regarde toujours la cible
                        else
                            -- Si bloqué en diagonale, on essaie juste de straffer
                            if isDirectionClear(strafeVector) then
                                bv.Velocity = strafeVector * speed
                                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dirToTarget)
                            else
                                -- Si vraiment coincé, on cherche une autre voie
                                bv.Velocity = Vector3.new(0,0,0)
                                strafeSide = strafeSide * -1 -- Force le changement de côté
                            end
                        end
                        
                    elseif currentDistance < MaintainDistance - 5 then
                        -- Trop proche : on s'éloigne
                        local dirAway = (hrp.Position - targetRoot.Position)
                        dirAway = Vector3.new(dirAway.X, 0, dirAway.Z)
                        local moveDir = (dirAway.Unit + strafeVector).Unit
                        
                        if isDirectionClear(moveDir) then
                            local velocity = moveDir * speed
                            bv.Velocity = velocity
                            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dirToTarget)
                        else
                            -- ANTI-BLOCAGE : S'il y a un mur derrière en reculant, on straffe pur sur le côté pour esquiver !
                            if isDirectionClear(strafeVector) then
                                local velocity = strafeVector * speed
                                bv.Velocity = velocity
                                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dirToTarget)
                            else
                                -- Si le strafe est aussi bloqué, on force le changement de côté au prochain tick
                                bv.Velocity = Vector3.new(0,0,0)
                                strafeSide = strafeSide * -1 
                            end
                        end
                    else
                        -- Distance parfaite : on ne reste pas immobile, on STRAFE pour esquiver les tirs !
                        if isDirectionClear(strafeVector) then
                            local velocity = strafeVector * speed
                            bv.Velocity = velocity
                            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dirToTarget)
              else
                    -- MODE ALÉATOIRE (Ton script d'origine)
                    currentDirection = getSafeDirection(currentDirection)

                    if currentDirection then
                        local moveTime = math.random(1.5, 3)
                        local elapsed = 0
                        local step = 0.1

                        while elapsed < moveTime and character and character.Parent and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 do
                            -- Si une cible apparaît, on sort de la boucle aléatoire pour retourner suivre la cible
                            if getClosestTargetForShooting() then break end
                            
                            if not isDirectionClear(currentDirection) then
                                break
                    end

                    local velocity = currentDirection.Unit * speed
                            bv.Velocity = velocity
                            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + velocity)

                            task.wait(step)
                            elapsed += step
                        end
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                        task.wait(1)
                    end
                end
            end
            
            -- Si on arrive ici, le personnage est mort. Le BodyVelocity est détruit avec lui.
            -- La boucle extérieure va se relancer et attendre le nouveau personnage.
            bv:Destroy()
        end
    end)
    end

    SetupMovementLoop()

-- Gestion du respawn (plus besoin de logique complexe, le système de mouvement s'adapte tout seul)
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
end)
