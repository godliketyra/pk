
local HttpService = game:GetService("HttpService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local Lighting = game:GetService("Lighting")

local Vim = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer

local Camera = workspace.CurrentCamera



-----------------------------------------------------------

-- 🔧 PARAMÈTRES

-----------------------------------------------------------

if setfpscap then

    setfpscap(30)

end



-----------------------------------------------------------

-- 🚨 UI D'ALERTE LOCALE (AFFICHE EN JEU)

-----------------------------------------------------------

local WarningGui = Instance.new("ScreenGui")

WarningGui.Name = "PK_WarningUI"

WarningGui.IgnoreGuiInset = true

WarningGui.Parent = game:GetService("CoreGui")



local WarningLabel = Instance.new("TextLabel")

WarningLabel.Size = UDim2.new(1, 0, 0, 40)

WarningLabel.Position = UDim2.new(0, 0, 0, 0)

WarningLabel.BackgroundColor3 = Color3.fromRGB(255, 50, 50)

WarningLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

WarningLabel.TextSize = 18

WarningLabel.Font = Enum.Font.GothamBold

WarningLabel.Visible = false

WarningLabel.Parent = WarningGui



-----------------------------------------------------------

-- 🔑 GESTION DE LA CLÉ API

-----------------------------------------------------------

local ScriptKey = getgenv().PKKey or _G.PKKey



if not ScriptKey or ScriptKey == "" then

    local KeyScreen = Instance.new("ScreenGui")

    KeyScreen.Name = "PK_KeySystem"

    KeyScreen.Parent = Player:WaitForChild("PlayerGui")

    

    local Frame = Instance.new("Frame")

    Frame.Size = UDim2.new(0, 400, 0, 250)

    Frame.Position = UDim2.new(0.5, -200, 0.5, -125)

    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

    Frame.BorderSizePixel = 0

    Frame.Parent = KeyScreen

    

    local UICorner = Instance.new("UICorner")

    UICorner.CornerRadius = UDim.new(0, 12)

    UICorner.Parent = Frame

    

    local Title = Instance.new("TextLabel")

    Title.Text = "AUTHENTIFICATION"

    Title.Font = Enum.Font.GothamBlack

    Title.TextSize = 20

    Title.TextColor3 = Color3.fromRGB(255, 255, 255)

    Title.Size = UDim2.new(1, 0, 0, 50)

    Title.BackgroundTransparency = 1

    Title.Parent = Frame



    local InputBox = Instance.new("TextBox")

    InputBox.Size = UDim2.new(0.8, 0, 0, 50)

    InputBox.Position = UDim2.new(0.1, 0, 0.4, -10)

    InputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

    InputBox.TextColor3 = Color3.fromRGB(200, 200, 200)

    InputBox.Text = ""

    InputBox.PlaceholderText = "Clé API..."

    InputBox.Font = Enum.Font.Gotham

    InputBox.TextSize = 14

    InputBox.Parent = Frame

    

    local SubmitBtn = Instance.new("TextButton")

    SubmitBtn.Size = UDim2.new(0.8, 0, 0, 45)

    SubmitBtn.Position = UDim2.new(0.1, 0, 0.7, 0)

    SubmitBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)

    SubmitBtn.Text = "VALIDER"

    SubmitBtn.Font = Enum.Font.GothamBold

    SubmitBtn.TextSize = 16

    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

    SubmitBtn.Parent = Frame



    local isWaiting = true

    SubmitBtn.MouseButton1Click:Connect(function()

        if #InputBox.Text > 5 then

            ScriptKey = InputBox.Text

            isWaiting = false

            KeyScreen:Destroy()

        end

    end)

    repeat task.wait(0.1) until isWaiting == false

end



-----------------------------------------------------------

-- 🧠 GESTION AGRESSIVE DE LA RAM

-----------------------------------------------------------

task.spawn(function()

    while true do

        task.wait(30)

        -- Force Lua à libérer la mémoire inutilisée

        collectgarbage("collect")

        -- Libère la mémoire des textures non utilisées par le moteur

        setmemoryunit("VideoMemory", 0) 

    end

end)



-----------------------------------------------------------

-- 🥔 OPTIMISATION LÉGÈRE

-----------------------------------------------------------

local function LightOptimize()

    pcall(function()

        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01

    end)

    task.spawn(function()

        for _, v in pairs(workspace:GetDescendants()) do

            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end

            if v:IsA("ParticleEmitter") then v.Enabled = false end

        end

    end)

end

LightOptimize()



-----------------------------------------------------------

-- 📡 SYSTÈME RÉSEAU (REMOTES)

-----------------------------------------------------------

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local CrewRemote = Remotes:WaitForChild("Crew")

local RefreshCrewEvent = Remotes:WaitForChild("RefreshCrew")



local PendingCrewID = nil



RefreshCrewEvent.OnClientEvent:Connect(function(action, data)

    if action == "CrewInvite" and type(data) == "table" and data.CrewID then

        PendingCrewID = data.CrewID

        print("🚨 INVITE REÇUE (ID: " .. PendingCrewID .. ")")

    end

end)



-----------------------------------------------------------

-- ⚙️ CONFIGURATION API

-----------------------------------------------------------

local SERVER_URL = "https://api-pk.crypto-gate.shop"



-----------------------------------------------------------

-- 🛠️ FONCTIONS UTILITAIRES

-----------------------------------------------------------

local function IsVisible(obj)

    if not obj then return false end

    if not obj:IsDescendantOf(game) then return false end

    if obj:IsA("GuiObject") and not obj.Visible then return false end

    if obj:IsA("ScreenGui") and not obj.Enabled then return false end

    return true

end



local function ClickObject(obj)

    if not obj then return end

    local absPos = obj.AbsolutePosition

    local absSize = obj.AbsoluteSize

    local x = absPos.X + (absSize.X / 2)

    local y = absPos.Y + (absSize.Y / 2) + 58 

    Vim:SendMouseButtonEvent(x, y, 0, true, game, 1)

    task.spawn(function()

        task.wait(0.05)

        Vim:SendMouseButtonEvent(x, y, 0, false, game, 1)

    end)

end



-----------------------------------------------------------

-- 🛡️ ANTI-AFK & AUTO-TEAM (INDÉTECTABLE)

-----------------------------------------------------------

task.spawn(function()

    pcall(function()

        for _, connection in pairs(getconnections(Player.Idled)) do

            connection:Disable()

        end

    end)



    while true do

        local waitTime = math.random(300, 540)

        task.wait(waitTime)

        

        pcall(function()

            Vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)

            task.wait(0.1)

            Vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)

            print("💤 Anti-AFK : Saut humain effectué ("..waitTime.."s)")

        end)

    end

end)



local function AutoJoinPirates()

    if Player.Team and tostring(Player.Team) == "Pirates" then return end

    local team = Player.Team

    if not team or tostring(team) == "Neutral" then

        local playerGui = Player:FindFirstChild("PlayerGui")

        if not playerGui then return end

        local mainGui = playerGui:FindFirstChild("Main (minimal)") or playerGui:FindFirstChild("Main")

        if mainGui then

            local chooseTeam = mainGui:FindFirstChild("ChooseTeam")

            if chooseTeam and chooseTeam.Visible then

                local btn = chooseTeam:FindFirstChild("Container") 

                    and chooseTeam.Container:FindFirstChild("Pirates")

                    and chooseTeam.Container.Pirates:FindFirstChild("Frame")

                if btn and IsVisible(btn) then

                    ClickObject(btn)

                    task.wait(1.5)

                end

            end

        end

    end

end



-----------------------------------------------------------

-- 🔍 ANALYSE D'ÉTAT & VÉRIFICATION CREW

-----------------------------------------------------------

local IsCrewMemberInServer = false



local function UpdateCrewMemberStatus()

    IsCrewMemberInServer = false

    if not PendingCrewID then return end

    

    for _, p in pairs(Players:GetPlayers()) do

        if p ~= Player then

            local pData = p:FindFirstChild("Data")

            if pData then

                local crewIdObj = pData:FindFirstChild("CrewID")

                if crewIdObj and tostring(crewIdObj.Value) == tostring(PendingCrewID) then

                    IsCrewMemberInServer = true

                    break

                end

            end

        end

    end

end



local function AnalyzeStatus(playersInServerCount, maxPlayersLimit)

    local warningText = ""

    

    if playersInServerCount > maxPlayersLimit then

        warningText = "_WARN" .. playersInServerCount

        WarningLabel.Text = "⚠️ ALERTE : " .. playersInServerCount .. " COMPTES SONT DANS CE SERVEUR (MAX: " .. maxPlayersLimit .. ") ⚠️"

        WarningLabel.Visible = true

    else

        WarningLabel.Visible = false

    end



    if Player.Team and tostring(Player.Team) == "Marines" then

        return "MARINE", Color3.fromRGB(50, 50, 255), "Marine" .. warningText

    end

    

    local myData = Player:FindFirstChild("Data")

    if myData and myData:FindFirstChild("CrewID") and myData.CrewID.Value ~= "" then

         return "ALREADY_IN_CREW", Color3.fromRGB(255, 170, 0), "In Crew" .. warningText

    end

    

    if PendingCrewID then

        if IsCrewMemberInServer then

            return "READY", Color3.fromRGB(0, 255, 0), "READY" .. warningText

        else

            return "NO_CREW_SRV", Color3.fromRGB(255, 170, 0), "No Crew Srv" .. warningText

        end

    end

    

    if playersInServerCount > maxPlayersLimit then

        return "WARNING_SRV", Color3.fromRGB(255, 0, 0), "WARNING_SRV" .. warningText

    end

    

    return "WAITING_INVITE", Color3.fromRGB(255, 50, 50), "Wait" .. warningText

end



-----------------------------------------------------------

-- 🔄 BOUCLE PRINCIPALE OPTIMISÉE (ASYNCHRONE)

-----------------------------------------------------------

local GlobalTargetTime = 0

local lastTargetID = 0

local lastServerCount = 1

local GlobalMaxPlayers = 1 -- Récupéré depuis l'API React



-- THREAD 1 : Communiquer avec le serveur (Ne bloque pas le jeu)

task.spawn(function()

    task.wait(math.random(0, 200) / 100)

    

    while true do

        task.wait(2)

        

        pcall(function()

            AutoJoinPirates()

            UpdateCrewMemberStatus()

            

            local status, color, detail = AnalyzeStatus(lastServerCount, GlobalMaxPlayers)

            

            local currentJob = game.JobId

            if currentJob == "" then currentJob = "TestServer" end

            

            local finalUrl = string.format("%s/status?key=%s&user=%s&ready=%s&details=%s&jobId=%s&nocache=%d", 

                SERVER_URL, tostring(ScriptKey), Player.Name, (status == "READY" and "true" or "false"), HttpService:UrlEncode(detail), currentJob, math.random(1,100000))

            

            local resp = game:HttpGet(finalUrl)

            local data = HttpService:JSONDecode(resp)

            

            if data then

                if data.target then

                    GlobalTargetTime = data.target

                end

                if data.serverCount then

                    lastServerCount = data.serverCount

                end

                if data.maxPlayers then

                    GlobalMaxPlayers = data.maxPlayers

                end

            end

        end)

    end

end)



-- THREAD 2 : Surveiller l'heure et tirer (Ultra précis)

task.spawn(function()

    while true do

        task.wait(0.01)

        

        if GlobalTargetTime > 0 and GlobalTargetTime ~= lastTargetID then

            local remaining = GlobalTargetTime - workspace:GetServerTimeNow()

            

            if remaining > 0 and remaining < 10 and PendingCrewID then

                lastTargetID = GlobalTargetTime

                

                if setfpscap then setfpscap(120) end

                

                while remaining > 0.005 do

                    RunService.Heartbeat:Wait()

                    remaining = GlobalTargetTime - workspace:GetServerTimeNow()

                end

                

                repeat until workspace:GetServerTimeNow() >= GlobalTargetTime

                

                local args = { "Join", { CrewID = PendingCrewID } }

                task.spawn(function()

                    pcall(function()

                        CrewRemote:InvokeServer(unpack(args))

                    end)

                    print("🚀 REQ ENVOYÉE AVEC PRÉCISION MAXIMALE (ServerTime)")

                end)

                

                PendingCrewID = nil 

                

                task.wait(2)

                if setfpscap then setfpscap(30) end

            end

        end

    end

end)
