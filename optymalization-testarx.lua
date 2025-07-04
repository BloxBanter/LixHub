local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
}

local Remotes = {}
do
    local RS = Services.ReplicatedStorage
    Remotes.GameEnd = RS:WaitForChild("Remote"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("GameEndedUI")
    Remotes.Code = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("Code")
    Remotes.StartGame = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VotePlaying")
    Remotes.Merchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("Merchant")
    Remotes.PlayEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")
    Remotes.SettingEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Settings"):WaitForChild("Setting_Event")
    Remotes.RetryEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VoteRetry")
    Remotes.GameEndedUI = RS:WaitForChild("Remote"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("GameEndedUI")
    Remotes.UpgradeUnit = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Upgrade")
    Remotes.NextEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VoteNext")
end

local GameObjects = {
    challengeFolder = Services.ReplicatedStorage:WaitForChild("Gameplay"):WaitForChild("Game"):WaitForChild("Challenge"),
    AFKChamberUI = Services.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AFKChamber"),
    STAGE_MODULES_FOLDER = Services.ReplicatedStorage.Shared.Info.GameWorld.Levels
}
GameObjects.itemsFolder = GameObjects.challengeFolder:WaitForChild("Items")

local Config = {
    DISCORD_USER_ID = "942709395253522442",
    chapters = {"Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7", "Chapter8", "Chapter9", "Chapter10"},
    difficulties = {"Normal", "Hard", "Nightmare"},
    UPGRADE_COOLDOWN = 0.5,
    maxRetryAttempts = 20,
    unitLevelCaps = {9, 9, 9, 9, 9, 9}
}

local State = {
    -- Flags
    pendingChallengeReturn = false,
    hasSentWebhook = false,
    portalUsed = false,
    isAutoJoining = false,
    hasNewRewards = false,
    pendingBossTicketReturn = false,
    gameRunning = false,
    hasGameEnded = false,
    retryAttempted = false,
    NextAttempted = false,
    stageStartTime = nil,
    
    -- Auto settings
    autoJoinEnabled = false,
    autoStartEnabled = false,
    autoRetryEnabled = false,
    autoReturnEnabled = false,
    autoNextEnabled = false,
    autoChallengeEnabled = false,
    autoPortalEnabled = false,
    autoClaimBP = false,
    AutoClaimQuests = false,
    AutoClaimMilestones = false,
    AutoPurchaseMerchant = false,
    challengeAutoReturnEnabled = false,
    autoBossAttackEnabled = false,
    autoReturnBossTicketResetEnabled = false,
    autoInfinityCastleEnabled = false,
    autoUpgradeEnabled = false,
    autoAfkTeleportEnabled = false,
    AutoUltimateEnabled = false,
    
    -- Values
    matchResult = "Unknown",
    storedChallengeSerial = nil,
    selectedWorld = nil,
    selectedChapter = nil,
    selectedDifficulty = nil,
    lastBossTicketCount = 0,
    lastBossTicketResetTime = 0,
    infinityCastleTask = nil,
    currentPath = nil,
    upgradeMethod = "Left to right until max",
    upgradeTask = nil,
    ultimateTask = nil,
    currentUpgradeSlot = 1,
    currentRetryAttempt = 0
}

local Data = {
    selectedRawStages = {},
    MerchantPurchaseTable = {},
    rangerStages = {},
    wantedRewards = {},
    capturedRewards = {},
    availableStories = {},
    availableRangerStages = {},
    storyData = {},
    worldDisplayNameMap = {},
    CurrentCodes = {"SorryRaids","RAIDS","BizzareUpdate2!","Sorry4Delays","BOSSTAKEOVER"},
}

local ValidWebhook

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LixHub - ARX - TEST",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by Sirius",
   ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LixHuberson", -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Keyerson", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"1"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

--//TABS\\--

local UpdateLogTab = Window:CreateTab("Update Log", "scroll")
local LobbyTab = Window:CreateTab("Lobby", "tv")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local RaidTab = Window:CreateTab("Raids", "swords")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local AutoPlayTab = Window:CreateTab("AutoPlay", "joystick")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

--//SECTIONS\\--

local UpdateLogSection = UpdateLogTab:CreateSection("01/07/2025")
local StatsSection = LobbyTab:CreateSection("Lobby")

--//DIVIDERS\\--
local UpdateLogDivider = UpdateLogTab:CreateDivider()

--//LABELS\\--
local Label1 = UpdateLogTab:CreateLabel("+Fixed Bugs, +Auto Ultimate [autoplay], +UI overhaul")

--//FUNCTIONS\\--

local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
        })
    end

local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function enableLowPerformanceMode()
        -- 1. REDUCE LIGHTING QUALITY
        Services.Lighting.Brightness = 1
        Services.Lighting.GlobalShadows = false
        Services.Lighting.Technology = Enum.Technology.Compatibility
        Services.Lighting.ShadowSoftness = 0
        Services.Lighting.EnvironmentDiffuseScale = 0
        Services.Lighting.EnvironmentSpecularScale = 0
        
        -- 2. REDUCE RENDER QUALITY
        
        -- 3. REMOVE PARTICLE EFFECTS
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
        
        -- 4. HIDE UNNECESSARY VISUAL PARTS
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                if obj.Transparency < 1 then
                    obj.Transparency = 1
                end
            end
        end
        
        -- 5. REDUCE GUI EFFECTS
        local playerGui = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") or gui:IsA("BlurEffect") then
                gui.Enabled = false
            end
        end
        
        -- 6. REMOVE LIGHTING EFFECTS
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or 
            obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = false
            end
        end
Remotes.SettingEvent:FireServer(unpack({"Abilities VFX", false}))
Remotes.SettingEvent:FireServer(unpack({"Hide Cosmetic", true}))
Remotes.SettingEvent:FireServer(unpack({"Low Graphic Quality", true}))
Remotes.SettingEvent:FireServer(unpack({"HeadBar", false}))
Remotes.SettingEvent:FireServer(unpack({"Display Players Units", false}))
Remotes.SettingEvent:FireServer(unpack({"DisibleGachaChat", true}))
Remotes.SettingEvent:FireServer(unpack({"DisibleDamageText", true}))
end

local function fetchStoryData()
    Data.storyData = {}
    local worldDisplayNameMap = {}    
    local folder = game.ReplicatedStorage.Shared.Info.GameWorld:WaitForChild("World")
        

        for _, moduleScript in ipairs(folder:GetChildren()) do
            if moduleScript:IsA("ModuleScript") then
                local success, data = pcall(function()
                    return require(moduleScript)
                end)

                if success and typeof(data) == "table" then
                    for key, storyTable in pairs(data) do
                        if typeof(storyTable) == "table" and storyTable.StoryAble == true then
                            if storyTable.Name and storyTable.Ani_Names then
                                table.insert(Data.storyData, {
                                    SeriesName = storyTable.Name,        -- Nice display name (e.g., "Voocha Village")
                                    InternalName = storyTable.Ani_Names, -- Internal name for remote (e.g., "OnePiece")
                                    ModuleName = moduleScript.Name,
                                    Key = key
                                })

                                worldDisplayNameMap[storyTable.Ani_Names] = storyTable.Name
                                --print("Found Series: " .. tostring(storyTable.Name) .. " -> " .. tostring(storyTable.Ani_Names))
                            end
                        end
                    end
                else
                    print("Error loading " .. moduleScript.Name)
                end
            end
        end
        
        return Data.storyData, Data.worldDisplayNameMap
    end

local function fetchRangerStageData(storyData)
    local folder = Services.ReplicatedStorage.Shared.Info.GameWorld:WaitForChild("Levels")

    local worldPriority = {
        ["OnePiece"] = 1,
        ["Namek"] = 2,
        ["DemonSlayer"] = 3,
        ["Naruto"] = 4,
        ["OPM"] = 5,
        ["TokyoGhoul"] = 6,
        ["JojoPart1"] = 7,
    }

    local worldDisplayNames = {}
    for _, story in ipairs(storyData) do
        worldDisplayNames[story.ModuleName] = story.SeriesName
    end

    local worldStages = {}

    for _, moduleScript in ipairs(folder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, data = pcall(function()
                return require(moduleScript)
            end)

            if success and typeof(data) == "table" then
                for seriesName, chapters in pairs(data) do
                    if typeof(chapters) == "table" then
                        for chapterKey, chapterData in pairs(chapters) do
                            if typeof(chapterData) == "table" and chapterData.Wave then
                                if string.find(chapterData.Wave, "RangerStage") then
                                    local worldName = chapterData.World or "UnknownWorld"
                                    worldStages[worldName] = worldStages[worldName] or {}
                                    local displayWorldName = worldDisplayNames[worldName] or worldName

                                    table.insert(worldStages[worldName], {
                                        Series = seriesName,
                                        Chapter = chapterKey,
                                        Wave = chapterData.Wave,
                                        LayoutOrder = chapterData.LayoutOrder or math.huge,
                                        DisplayName = displayWorldName .. " - " .. (chapterData.Wave:match("RangerStage(%d+)") or chapterData.Wave)
                                    })
                                end
                            end
                        end
                    end
                end
            else
                warn("Error loading module: " .. moduleScript.Name)
            end
        end
    end

    local worldOrder = {}
    local rangerStages = {}

    for worldName, stages in pairs(worldStages) do
        table.sort(stages, function(a, b)
            return a.LayoutOrder < b.LayoutOrder
        end)

        local priority = worldPriority[worldName] or 1e6
        table.insert(worldOrder, {World = worldName, Priority = priority, Stages = stages})
    end

    table.sort(worldOrder, function(a, b)
        return a.Priority < b.Priority
    end)

    for _, worldInfo in ipairs(worldOrder) do
        local worldName = worldInfo.World
        for _, stage in ipairs(worldInfo.Stages) do
            table.insert(rangerStages, {
                RawName = stage.Wave,
                DisplayName = stage.DisplayName,
                World = worldName,
                Series = stage.Series,
                Chapter = stage.Chapter,
                LayoutOrder = stage.LayoutOrder
            })
        end
    end

    return rangerStages
end

local function findMatchingStageAndCheckUnits(detectedRewards)
    local foundUnits = {}
    local matchedStage = nil

    for _, moduleScript in ipairs(GameObjects.STAGE_MODULES_FOLDER:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, stageData = pcall(function()
                return require(moduleScript)
            end)

            if success and stageData then
                for worldName, worldData in pairs(stageData) do
                    if type(worldData) == "table" then
                        for stageName, stage in pairs(worldData) do
                            if type(stage) == "table" and stage.Items then
                                local possibleRewards = {}
                                for _, item in ipairs(stage.Items) do
                                    possibleRewards[item.Name] = item
                                end

                                local matches, totalDetected = 0, 0
                                for rewardName, _ in pairs(detectedRewards) do
                                    if not (rewardName:lower():match("exp") or rewardName:lower():match("gold")) then
                                        totalDetected = totalDetected + 1
                                        if possibleRewards[rewardName] then
                                            matches = matches + 1
                                        end
                                    end
                                end

                                if matches > 0 and (totalDetected == 0 or matches / totalDetected >= 0.5) then
                                    matchedStage = {
                                        module = moduleScript.Name,
                                        world = worldName,
                                        stage = stageName,
                                        data = stage
                                    }

                                    for rewardName, _ in pairs(detectedRewards) do
                                        local rewardInfo = possibleRewards[rewardName]
                                        if rewardInfo and rewardInfo.Type == "Unit" then
                                            table.insert(foundUnits, rewardName)
                                        end
                                    end

                                    if #foundUnits > 0 then
                                        return foundUnits, matchedStage
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return foundUnits, matchedStage
end

local function getTotalItemAmount(itemName)
    local playerData = Services.ReplicatedStorage:FindFirstChild("Player_Data")[Services.Players.LocalPlayer.Name]
    if not playerData then return nil end

    local itemsFolder = playerData:FindFirstChild("Items")
    if not itemsFolder then return nil end

    local itemFolder = itemsFolder:FindFirstChild(itemName)
    if not itemFolder then return nil end

    local amountValue = itemFolder:FindFirstChild("Amount")
    if not amountValue then return nil end

    return tostring(amountValue.Value)
end

local function processRemoteRewards(rewardData)
    local rewards = {}
    local detectedUnits = {}

    if not rewardData or not rewardData[1] then
        return rewards, detectedUnits
    end

    for _, reward in pairs(rewardData) do
        local itemName = reward.Name
        local amount = reward.Amount and reward.Amount.Value or 1

        local GetData = Services.ReplicatedStorage.Shared.GetData
        local isUnit, isItem = false, false

        pcall(function()
            if require(GetData).GetUnitStats(itemName) then
                isUnit = true
                table.insert(detectedUnits, itemName)
            elseif require(GetData).GetItemStats(itemName) then
                isItem = true
            end
        end)

        local totalAmount = getTotalItemAmount(itemName)
        local totalText = totalAmount and string.format(" [%s total]", totalAmount) or ""

        local rewardText
        if isUnit then
            rewardText = string.format("🌟 %s x%d (UNIT!)%s", itemName, amount, totalText)
        elseif itemName:lower():match("exp") or itemName:lower():match("gold") then
            rewardText = string.format("+ %s %s%s", amount, itemName, totalText)
        else
            rewardText = string.format("+ %s %s%s", amount, itemName, totalText)
        end

        table.insert(rewards, rewardText)
        Data.capturedRewards[itemName] = amount
    end

    return rewards, detectedUnits
end


local function hookRewardSystem()
    if isInLobby() then return end
    local success, err = pcall(function()
        local gameEndedRemote = Remotes.GameEnd

        gameEndedRemote.OnClientEvent:Connect(function(eventType, data)
            if eventType == "Rewards - Items" then
                print("🎯 Intercepted reward data from game!")
                Data.capturedRewards = {}
                State.hasNewRewards = true

                local rewardLines, detectedUnits = processRemoteRewards(data)

                Data.capturedRewards.processed = rewardLines
                Data.capturedRewards.units = detectedUnits
                Data.capturedRewards.rawData = data

                print("📦 Captured Rewards:")
                for _, line in ipairs(rewardLines) do
                    print("  " .. line)
                end

                if #detectedUnits > 0 then
                    print("🌟 UNITS DETECTED: " .. table.concat(detectedUnits, ", "))
                end
            end
        end)
    end)

    if not success then
        warn("⚠️ Failed to hook reward system: " .. tostring(err))
        return false
    end

    print("✅ Successfully hooked into game reward system!")
    return true
end


local function buildRewardsText()
    if State.hasNewRewards and Data.capturedRewards.processed then
        local rewardsText = table.concat(Data.capturedRewards.processed, "\n")
        local detectedRewards = {}

        if Data.capturedRewards.rawData then
            for _, reward in pairs(Data.capturedRewards.rawData) do
                detectedRewards[reward.Name] = reward.Amount and reward.Amount.Value or 1
            end
        end

        print("📡 Using remote event reward data (more accurate!)")
        return rewardsText, detectedRewards, Data.capturedRewards.units or {}
    end

    print("📁 Falling back to folder scanning method")
    local rewardsRoot = Services.Players.LocalPlayer:FindFirstChild("RewardsShow")
    if not rewardsRoot then
        return "_No rewards found_", {}, {}
    end

    local lines = {}
    local detectedRewards = {}

    for _, folder in ipairs(rewardsRoot:GetChildren()) do
        if folder:IsA("Folder") then
            for _, val in ipairs(folder:GetChildren()) do
                if val:IsA("NumberValue") then
                    local itemName = val.Parent.Name
                    local amount = tostring(val.Value)

                    detectedRewards[itemName] = amount

                    local totalAmount = getTotalItemAmount(itemName)
                    local totalText = totalAmount and string.format(" [%s total]", totalAmount) or ""

                    if itemName:lower():match("exp") or itemName:lower():match("gold") then
                        table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
                    else
                        table.insert(lines, string.format("+ %s %s%s", amount, itemName, totalText))
                    end
                end
            end
        end
    end

    if #lines == 0 then
        return "_No reward values found_", {}, {}
    end

    return table.concat(lines, "\n"), detectedRewards, {}
end

local function sendWebhook(messageType, rewards, clearTime, matchResult)
    if not ValidWebhook then return end

    local data
    if messageType == "test" then
        data = {
            username = "LixHub Bot",
            embeds = {{
                title = "📢 LixHub Notification",
                description = "Test webhook sent successfully",
                color = 0x5865F2,
                footer = { text = "LixHub Auto Logger" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
    elseif messageType == "stage" then
        local RewardsUI = Services.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("InGame"):WaitForChild("Main"):WaitForChild("GameInfo")
        local stageName = RewardsUI and RewardsUI:FindFirstChild("Stage") and RewardsUI.Stage.Label.Text or "Unknown Stage"
        local gameMode = RewardsUI and RewardsUI:FindFirstChild("Gamemode") and RewardsUI.Gamemode.Label.Text or "Unknown Time"
        local isWin = matchResult == "Victory"
        local plrlevel = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Level.Value or ""

        local rewardsText, detectedRewards, remoteUnits = buildRewardsText()
        local foundUnits, matchedStage = findMatchingStageAndCheckUnits(detectedRewards)

        local allUnits = {}
        for _, unit in ipairs(foundUnits) do table.insert(allUnits, unit) end
        for _, unit in ipairs(remoteUnits) do if not table.find(allUnits, unit) then table.insert(allUnits, unit) end end

        local shouldPing = #allUnits > 0
        local pingText = shouldPing and string.format("<@%s> 🎉 **SECRET UNIT OBTAINED!** 🎉", Config.DISCORD_USER_ID) or ""

        local stageResult = stageName .. " (" .. gameMode .. ")" .. " - " .. matchResult
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        local description = shouldPing and (pingText .. "\n" .. stageResult) or stageResult

        data = {
            username = "LixHub Bot",
            content = shouldPing and pingText or nil,
            embeds = {{
                title = shouldPing and "🌟 UNIT DROP! 🌟" or "🎯 Stage Finished!",
                description = description,
                color = shouldPing and 0xFFD700 or (isWin and 0x57F287 or 0xED4245),
                fields = {
                    { name = "👤 Player", value = "||" .. Services.Players.LocalPlayer.Name .. " [" .. plrlevel .. "]||", inline = true },
                    { name = isWin and "✅ Won in:" or "❌ Lost after:", value = clearTime, inline = true },
                    { name = "🏆 Rewards", value = rewardsText, inline = false },
                    shouldPing and { name = "🌟 Units Obtained", value = table.concat(allUnits, ", "), inline = false } or nil,
                    { name = "📈 Script Version", value = "v1.2.0 (Enhanced)", inline = true }
                },
                footer = { text = "discord.gg/lixhub • Enhanced Tracking" },
                timestamp = timestamp
            }}
        }

        local filteredFields = {}
        for _, field in ipairs(data.embeds[1].fields) do if field then table.insert(filteredFields, field) end end
        data.embeds[1].fields = filteredFields
    else
        return
    end

    local payload = Services.HttpService:JSONEncode(data)
    local requestFunc = (syn and syn.request) or (http and http.request) or request
    if requestFunc then
        local success, result = pcall(function()
            return requestFunc({
                Url = ValidWebhook,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
        end)
        if not success then warn("Webhook failed to send: " .. tostring(result)) end
    else
        warn("No compatible HTTP request method found.")
    end
end

local function countPartsOnPath(folder, pathFolder)
    local count = 0
    for _, part in ipairs(folder:GetChildren()) do
        if part:IsA("BasePart") and part:FindFirstChildOfClass("Humanoid") then
            local distToStart = (part.Position - pathFolder["1"].Position).Magnitude
            local distToEnd = (part.Position - pathFolder["2"].Position).Magnitude
            local totalDist = (pathFolder["1"].Position - pathFolder["2"].Position).Magnitude
            if distToStart + distToEnd <= totalDist + 15 then
                count += 1
            end
        end
    end
    return count
end

local function getBestPath()
    local bestPath, lowestUnits = nil, math.huge
    for i = 1, 3 do
        local pathName = "P" .. i
        local pathFolder = Services.Workspace:WaitForChild("WayPoint"):FindFirstChild(pathName)
        if pathFolder then
            local unitCount = countPartsOnPath(Services.Workspace.Agent.UnitT, pathFolder)
            local enemyCount = countPartsOnPath(Services.Workspace.Agent.EnemyT, pathFolder)
            print("🔎 Path " .. pathName .. ": " .. unitCount .. " units, " .. enemyCount .. " enemies")
            if enemyCount > 0 and unitCount < lowestUnits then
                lowestUnits = unitCount
                bestPath = i
            end
        end
    end
    return bestPath
end

local function startInfinityCastleLogic()
    if State.infinityCastleTask then task.cancel(State.infinityCastleTask) end
    State.infinityCastleTask = task.spawn(function()
        while State.autoInfinityCastleEnabled do
            local success, error = pcall(function()
                local bestPath = getBestPath()
                if bestPath and bestPath ~= State.currentPath then
                    notify("🚀 Switching to path: ", bestPath)
                    State.currentPath = bestPath
                    Remotes.SelectWay:FireServer(bestPath)
                else
                    print("✅ Staying on current path:", State.currentPath or "None")
                end
            end)
            if not success then warn("❌ Infinity Castle error:", error) end
            task.wait(2.5)
        end
    end)
end

local function stopInfinityCastleLogic()
    if State.infinityCastleTask then
        task.cancel(State.infinityCastleTask)
        State.infinityCastleTask = nil
    end
    State.currentPath = nil
end
local function isWantedChallengeRewardPresent()
    for _, reward in ipairs(Data.wantedRewards) do
        local value = GameObjects.itemsFolder:FindFirstChild(reward)
        if value and value:IsA("BoolValue") then
            return true, reward
        end
    end
    return false, nil
end

local function getTierValue(name)
    if name:find("III") then return 3 end
    if name:find("II") then return 2 end
    if name:find("I") then return 1 end
    return 0
end

local function getPlayerCurrency()
    local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data
    if not playerData then return {} end

    local currencies = {}
    local GoldValue = playerData:FindFirstChild("Gold")
    if GoldValue then currencies["Gold"] = GoldValue.Value end
    local gemsValue = playerData:FindFirstChild("Gem")
    if gemsValue then currencies["Gem"] = gemsValue.Value end
    return currencies
end

local function canAffordItem(itemFolder)
    local priceValue = itemFolder:FindFirstChild("CurrencyAmount")
    local currencyTypeValue = itemFolder:FindFirstChild("CurrencyType")
    if not priceValue or not currencyTypeValue then return false end

    local price = priceValue.Value
    local currencyType = currencyTypeValue.Value
    local playerCurrencies = getPlayerCurrency()

    return playerCurrencies[currencyType] and playerCurrencies[currencyType] >= price
end

local function purchaseItem(itemName, quantity)
    quantity = quantity or 1
    pcall(function()
        Remotes.Merchant:FireServer(itemName, quantity)
    end)
end

local function autoPurchaseItems()
    if not State.AutoPurchaseMerchant then return end
    if not Data.MerchantPurchaseTable or #Data.MerchantPurchaseTable == 0 then return end

    local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name]
    if not playerData then return end

    local merchantFolder = playerData:FindFirstChild("Merchant")
    if not merchantFolder then return end

    for _, selectedItem in pairs(Data.MerchantPurchaseTable) do
        local itemFolder = merchantFolder:FindFirstChild(selectedItem)
        if itemFolder then
            if canAffordItem(itemFolder) then
                local quantityValue = itemFolder:FindFirstChild("Quantity")
                local currentQuantityValue = itemFolder:FindFirstChild("BuyAmount")
                local availableQuantity = quantityValue and quantityValue.Value or 1
                local currentQuantity = currentQuantityValue and currentQuantityValue.Value or 0

                if currentQuantity <= 0 then
                    purchaseItem(selectedItem, availableQuantity)
                    notify("Auto Purchase Merchant", "Purchased: " .. availableQuantity .. "x " .. selectedItem)
                    task.wait(0.5)
                end
            else
                notify("Auto Purchase Merchant", "Cannot Afford " .. selectedItem)
            end
        end
    end
end

local function autoJoinRangerStage(stageName)
    if not isInLobby() then 
        print("❌ Not in lobby, cannot join ranger stage")
        return 
    end

    print("🚀 Joining ranger stage:", stageName)

    -- 1. Create
    Remotes.PlayEvent:FireServer("Create")
    task.wait(0.3)

    -- 2. Change-Mode
    Remotes.PlayEvent:FireServer("Change-Mode", { Mode = "Ranger Stage" })
    task.wait(0.3)

    -- 3. Extract world from stage name (e.g., "Naruto_RangerStage2" → "Naruto")
    local world = stageName:match("^(.-)_RangerStage")
    if not world then
        warn("❌ Couldn't extract world from:", stageName)
        return
    end

    -- 4. Change-World
    Remotes.PlayEvent:FireServer("Change-World", { World = world })
    task.wait(0.3)

    -- 5. Change-Chapter
    Remotes.PlayEvent:FireServer("Change-Chapter", { Chapter = stageName })
    task.wait(0.3)

    -- 6. Submit
    Remotes.PlayEvent:FireServer("Submit")
    task.wait(0.3)

    -- 7. Start
    Remotes.PlayEvent:FireServer("Start")

    print("✅ Ranger stage join sequence completed for:", stageName)
end

local autoJoinState = {
    isProcessing = false,
    currentAction = nil,
    lastActionTime = 0,
    actionCooldown = 2 
}

local function canPerformAction()
    return tick() - autoJoinState.lastActionTime >= autoJoinState.actionCooldown
end

local function setProcessingState(action)
    autoJoinState.isProcessing = true
    autoJoinState.currentAction = action
    autoJoinState.lastActionTime = tick()

    if action == "Ranger Stage Auto Join" then
        notify("🔄 Processing: ", action)
    elseif action == "Challenge Auto Join" then
        notify("🔄 Processing: ", action)
    elseif action == "Portal Auto Join" then
        notify("🔄 Processing: ", action)
    elseif action == "Story Auto Join" then
        notify("🔄 Processing: ", string.format(
            "Joining %s - %s [%s]",
            State.selectedWorld or "?",
            State.selectedChapter or "?",
            State.selectedDifficulty or "?"
        ))
    elseif action == "Boss Attack Auto Join" then
        notify("🔄 Processing: ", action)
    end
end

local function clearProcessingState()
    autoJoinState.isProcessing = false
    autoJoinState.currentAction = nil
end

local function getBossAttackTickets()
    local success, tickets = pcall(function()
        return Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.BossAttackTicket.Value
    end)
    return success and tickets or 0
end

local function getBossTicketResetTime()
    local success, resetTime = pcall(function()
        return Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.BossAttackReset.Value
    end)
    return success and resetTime or 0
end

    -- Auto join boss attack function
local function autoJoinBossAttack()
    if not isInLobby() then return end
    print("🏆 [Priority 0] Attempting to join Boss Attack...")
    Remotes.PlayEvent:FireServer("Boss-Attack")
end

local function getInternalWorldName(displayName)
    for _, story in ipairs(Data.availableStories) do
        if story.SeriesName == displayName then
            return story.ModuleName
        end
    end
    return nil
end

local function checkAndExecuteHighestPriority()
    if not isInLobby() then return end
    if autoJoinState.isProcessing then return end
    if not canPerformAction() then return end

    -- Priority 0: Boss Attack Auto Join
    if State.autoBossAttackEnabled then
        local currentTickets = getBossAttackTickets()
        if currentTickets > 0 then
            setProcessingState("Boss Attack Auto Join")
            print("🏆 [Priority 0] Boss Attack tickets available:", currentTickets)
            autoJoinBossAttack()
            task.delay(5, clearProcessingState)
            return
        else
            print("🎫 [Priority 0] No boss attack tickets available, checking other priorities...")
        end
    end

    -- Priority 1: Ranger Stage Auto Join
    if State.isAutoJoining and Data.selectedRawStages and #Data.selectedRawStages > 0 then
        local selectedStageSet = {}
        for _, raw in ipairs(Data.selectedRawStages) do
            selectedStageSet[raw] = true
        end

        local prioritizedStageList = {}
        for _, stage in ipairs(Data.availableRangerStages) do
            if selectedStageSet[stage.RawName] then
                table.insert(prioritizedStageList, stage.RawName)
            end
        end

        if #prioritizedStageList > 0 then
            local stageName = prioritizedStageList[1]
            setProcessingState("Ranger Stage Auto Join")
            print("🌍 [Priority 1] Attempting to join Ranger Stage:", stageName)
            autoJoinRangerStage(stageName)
            task.delay(5, clearProcessingState)
            return
        end
    end

    -- Priority 2: Challenge Auto Join
    if State.autoChallengeEnabled then
        local foundRewardOK, foundReward = isWantedChallengeRewardPresent()
        if foundRewardOK then
            setProcessingState("Challenge Auto Join")
            print("🎯 Found wanted reward '" .. foundReward .. "' → creating challenge room")
            notify("Challenge Mode", string.format("Found %s, joining challenge...", foundReward))
            Remotes.PlayEvent:FireServer("Create", { CreateChallengeRoom = true })
            Remotes.PlayEvent:FireServer("Start")
            task.delay(5, clearProcessingState)
            return
        end
    end

    -- Priority 3: Portal Auto Join
    if State.autoPortalEnabled and not State.portalUsed then
        local success, result = pcall(function()
            local inventoryFrame = Services.Players.LocalPlayer:FindFirstChild("PlayerGui").Items.Main.Base.Space:FindFirstChild("Scrolling")
            if not inventoryFrame then return nil end
            local bestPortalName = nil
            local bestTier = 0

            for _, item in ipairs(inventoryFrame:GetChildren()) do
                if item.Name:lower():find("portal") then
                    local tier = getTierValue(item.Name)
                    if tier > bestTier then
                        bestTier = tier
                        bestPortalName = item.Name
                    end
                end
            end
            return bestPortalName
        end)

        if success and result then
            setProcessingState("Portal Auto Join")
            print("📦 [Priority 3] Found portal:", result)

            local portalInstance = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items:FindFirstChild(result)
            if portalInstance then
                print("🚪 Using portal:", result)
                Services.ReplicatedStorage.Remote.Server.Lobby.ItemUse:FireServer(portalInstance)
                notify("Portal", string.format("Using portal: %s", result))

                task.wait(1)

                print("▶️ Starting portal match...")
                Services.ReplicatedStorage.Remote.Server.Lobby.PortalEvent:FireServer("Start")
                State.portalUsed = true

                task.delay(5, clearProcessingState)
                return
            else
                print("⚠️ Portal instance not found in player data:", result)
                notify("❌ Portal", string.format("Instance not found: %s", result))
                clearProcessingState()
            end
        end
    end

    -- Priority 4: Story Auto Join
    if State.autoJoinEnabled and State.selectedWorld and State.selectedChapter and State.selectedDifficulty then
        setProcessingState("Story Auto Join")

        local internalWorldName = getInternalWorldName(State.selectedWorld)
        if internalWorldName then
            print("📚 [Priority 4] Joining Story:", State.selectedWorld, "/", State.selectedChapter, "/", State.selectedDifficulty)

            local combinedWorld = internalWorldName .. "_" .. State.selectedChapter:gsub(" ", "")

            local function sendPlayRoomEvent(action, data)
                Remotes.PlayEvent:FireServer(action, data)
                task.wait(0.25)
            end

            sendPlayRoomEvent("Create")
            sendPlayRoomEvent("Change-World", { World = tostring(internalWorldName) })
            sendPlayRoomEvent("Change-Chapter", { Chapter = tostring(combinedWorld) })
            sendPlayRoomEvent("Change-Difficulty", { Difficulty = tostring(State.selectedDifficulty) })
            sendPlayRoomEvent("Submit")
            sendPlayRoomEvent("Start")

            task.delay(10, clearProcessingState)
            return
        else
            warn("[Story Auto Join] Invalid selection.")
            notify("⚠️ Story Join", "Selected World/Chapter/Difficulty is invalid.")
            clearProcessingState()
        end
    end
end


local function getCurrentChallengeSerial()
    local success, serial = pcall(function()
        return challengeFolder:FindFirstChild("serial_number") and challengeFolder.serial_number.Value
    end)
    return success and serial or nil
end

if not State.storedChallengeSerial then
    State.storedChallengeSerial = getCurrentChallengeSerial()
end

local function getUnitNameFromSlot(slotNumber)
    local success, unitInstance = pcall(function()
        return Services.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame.UnitFrame.Info.Folder.Value
end)

    if success and unitInstance then
        return typeof(unitInstance) == "Instance" and unitInstance.Name or tostring(unitInstance)
    end

    return nil
end

local function getCurrentUpgradeLevel(unitName)
    if not unitName then return 0 end

    local success, upgradeLevel = pcall(function()
        local upgradeText = Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].UpgradeText.Text

        if string.find(upgradeText:upper(), "MAX") then
            return "MAX"
        end

        local level = string.match(upgradeText, "Upgrade:</font>%s*(%d+)")
        return tonumber(level) or 0
    end)

    if success then
        return upgradeLevel
    else
        print("❌ Failed to get upgrade level for:", unitName)
        return 0
    end
end

local function getUpgradeCost(unitName)
    if not unitName then return 9999 end

    local success, cost = pcall(function()
        local costText = Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].CostText.Text
        local costValue = string.match(costText, "Cost:</font>%s*([%d,]+)")
        if costValue then
            costValue = costValue:gsub(",", "")
            return tonumber(costValue) or 9999
        end
    end)

    return success and cost or 9999
end

local function getCurrentMoney()
    local success, money = pcall(function()
        return Services.Players.LocalPlayer.Yen.Value
    end)

    return (success and money) or 0
end

local function upgradeUnit(unitName)
    if not unitName then return false end

    local unitNameStr = typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)

    local success = pcall(function()
        local args = { Services.Players.LocalPlayer.UnitsFolder:WaitForChild(unitNameStr) }
        Remotes.UpgradeUnit:FireServer(unpack(args))
    end)

    if success then
        print("✅ Upgraded unit:", unitNameStr)
        return true
    else
        warn("❌ Failed to upgrade unit:", unitNameStr)
        return false
    end
end

local function leftToRightUpgrade()
    while State.autoUpgradeEnabled and State.gameRunning do
        local unitName = getUnitNameFromSlot(State.currentUpgradeSlot)
        local unitNameStr = unitName and (typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)) or "nil"
        local maxLevel = Config.unitLevelCaps[tonumber(State.currentUpgradeSlot)] or 9

        if unitName and unitNameStr ~= "" and unitNameStr ~= "nil" then
            local currentLevel = getCurrentUpgradeLevel(unitNameStr)

            if currentLevel == "MAX" or tonumber(currentLevel) >= maxLevel then
                print("🏆 Unit " .. unitNameStr .. " reached max level, moving to next slot")
                State.currentUpgradeSlot = State.currentUpgradeSlot + 1
                if State.currentUpgradeSlot > 6 then
                    State.currentUpgradeSlot = 1
                end
            else
                local currentMoney = getCurrentMoney()
                local upgradeCost = getUpgradeCost(unitNameStr)

                if currentMoney >= upgradeCost then
                    if upgradeUnit(unitNameStr) then
                        task.wait(UPGRADE_COOLDOWN)
                    else
                        warn("❌ Failed to upgrade, will retry")
                        task.wait(1)
                    end
                end
            end
        else
            print("⚠️ No valid unit in slot " .. State.currentUpgradeSlot .. ", moving to next")
            State.currentUpgradeSlot = State.currentUpgradeSlot + 1
            if State.currentUpgradeSlot > 6 then
                State.currentUpgradeSlot = 1
            end
        end

        task.wait(0.5)
    end

    print("🛑 Upgrade cycle ended")
end

local function startAutoUpgrade()
    if isInLobby() then
        print("⚠️ Cannot start auto-upgrade while in lobby.")
        return
    end

    if State.upgradeTask then
        task.cancel(State.upgradeTask)
        State.upgradeTask = nil
    end

    State.upgradeTask = task.spawn(function()
        while State.autoUpgradeEnabled do
            if State.gameRunning then
                local success, err = pcall(function()
                    if State.upgradeMethod == "Left to right until max" then
                        leftToRightUpgrade()
                    elseif State.upgradeMethod == "randomize" then
                        print("🔄 Randomize method not implemented yet")
                    elseif State.upgradeMethod == "lowest level spread upgrade" then
                        print("🔄 Lowest level spread method not implemented yet")
                    end
                end)

                if not success then
                    warn("❌ Auto upgrade error:", err)
                end
            else
                print("⏳ Waiting for game to start...")
            end

            task.wait(1)
        end
    end)
end

local function stopAutoUpgrade()
    if State.upgradeTask then
        task.cancel(State.upgradeTask)
        State.upgradeTask = nil
    end
end

local function resetUpgradeOrder()
    State.currentUpgradeSlot = 1
    print("🔄 Reset upgrade order to slot 1")
end

local function getUnitsWithUltimates()
    local unitsWithUltimates = {}

    local success, result = pcall(function()
        local agentFolder = workspace:WaitForChild("Agent", 5)
        if not agentFolder then return {} end

        local unitFolder = agentFolder:WaitForChild("UnitT", 5)
        if not unitFolder then return {} end

        for _, part in pairs(unitFolder:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("Part") then
                local infoFolder = part:FindFirstChild("Info")
                if infoFolder then
                    local activeAbility = infoFolder:FindFirstChild("ActiveAbility")
                    local targetObject = infoFolder:FindFirstChild("TargetObject")

                    if activeAbility and activeAbility:IsA("StringValue") and targetObject and targetObject:IsA("ObjectValue") then
                        if activeAbility.Value ~= "" and targetObject.Value ~= nil then
                            table.insert(unitsWithUltimates, {
                                part = part,
                                abilityName = activeAbility.Value
                            })
                        end
                    end
                end
            end
        end

        return unitsWithUltimates
    end)

    if success then
        return result
    else
        warn("❌ Error getting units with ultimates:", result)
        return {}
    end
end

local function fireUltimateForUnit(unitData)
    local success = pcall(function()
        local args = { unitData.part }
        ReplicatedStorage.Remote.Server.Units.Ultimate:FireServer(unpack(args))
    end)

    if not success then
        warn("❌ Failed to fire ultimate for unit:", unitData.part.Name)
    end
end

local function autoUltimateLoop()
    if isInLobby() then return end

    while State.AutoUltimateEnabled do
        local unitsWithUltimates = getUnitsWithUltimates()

        if #unitsWithUltimates > 0 then
            for _, unitData in pairs(unitsWithUltimates) do
                if not State.AutoUltimateEnabled then break end
                fireUltimateForUnit(unitData)
                task.wait(0.1) -- Prevent server spam
            end
        end

        task.wait(1) -- Check again after 1 second
    end

    print("🛑 Auto Ultimate loop stopped")
end

local function startAutoUltimate()
    if isInLobby() then
        print("⚠️ Cannot start auto ultimate while in lobby.")
        return
    end

    if State.ultimateTask then
        task.cancel(State.ultimateTask)
        State.ultimateTask = nil
    end

    State.ultimateTask = task.spawn(function()
        local success, err = pcall(function()
            autoUltimateLoop()
        end)

        if not success then
            warn("❌ Auto Ultimate loop error:", err)
        end
    end)
end

local function stopAutoUltimate()
    if State.ultimateTask then
        task.cancel(State.ultimateTask)
        State.ultimateTask = nil
        print("🛑 Auto Ultimate task cancelled")
    end
end

local function updateOverheadText()
        local success, err = pcall(function()
            local head = Services.Players.LocalPlayer.Character:WaitForChild("Head", 5)
            local billboard = head:FindFirstChild("PlayerHeadGui")

            if billboard then
                local textLabel = billboard:FindFirstChild("PlayerName")
                if textLabel then
                    textLabel.Text = "🔥 Protected By LixHub 🔥" -- Your custom overhead text
                end
            end
        end)
end

local function startRetryLoop()
    if State.retryAttempted then return end
    State.retryAttempted = true

    task.spawn(function()
        while State.retryAttempted and State.autoRetryEnabled do
            Remotes.RetryEvent:FireServer()
            task.wait(2) -- Retry interval (can adjust)
        end
    end)
end

local function stopRetryLoop()
    State.retryAttempted = false
end

local function startNextLoop()
    if State.NextAttempted then return end
    State.NextAttempted = true

    task.spawn(function()
        while State.NextAttempted and State.autoNextEnabled do
            Remotes.NextEvent:FireServer()
            task.wait(2) -- Retry interval (can adjust)
        end
    end)
end

local function stopNextLoop()
    State.NextAttempted = false
end

--//\\--

    task.spawn(function()
        print("🔄 Fetching story data...")
        Data.availableStories = fetchStoryData()
        
        print("🔄 Fetching ranger stage data...")
        Data.availableRangerStages = fetchRangerStageData(Data.availableStories)
        
        print("✅ Data fetching complete!")
    end)

    task.spawn(function()
        while true do
            task.wait(0.5) -- Check every 0.5 seconds
            checkAndExecuteHighestPriority()
        end
    end)

    Services.Players.LocalPlayer.CharacterAdded:Connect(updateOverheadText)
    if Services.Players.LocalPlayer.Character then
        updateOverheadText()
    end
    task.spawn(function()
        while true do
            task.wait(5)
            if State.challengeAutoReturnEnabled and not isInLobby() then
                local currentSerial = getCurrentChallengeSerial()
                
                if currentSerial and State.storedChallengeSerial and currentSerial ~= State.storedChallengeSerial then
                    notify("Challenge Update", "New challenge detected - will return to lobby when game ends")
                    State.pendingChallengeReturn = true
                    State.storedChallengeSerial = currentSerial
                elseif currentSerial and not State.storedChallengeSerial then
                    State.storedChallengeSerial = currentSerial
                end
            elseif isInLobby() then
                State.pendingChallengeReturn = false
                State.storedChallengeSerial = getCurrentChallengeSerial()
            end
        end
    end)
    task.spawn(function()
        while true do
            task.wait(5)
            if State.autoReturnBossTicketResetEnabled then
                local currentTickets = getBossAttackTickets()
                local currentResetTime = getBossTicketResetTime()
                if currentTickets > State.lastBossTicketCount or currentResetTime ~= State.lastBossTicketResetTime then
                    if State.lastBossTicketCount == 0 and currentTickets > 0 then
                        print("🎫 Boss Attack tickets reset detected! Tickets:", currentTickets)
                        notify("Boss Tickets", string.format("Tickets reset! Now have %d tickets", currentTickets))
                        State.pendingBossTicketReturn = true
                    end
                end
                
                State.lastBossTicketCount = currentTickets
                State.lastBossTicketResetTime = currentResetTime
            end
        end
    end)

        task.spawn(function()
        while true do
            task.wait(2)
            if State.autoAfkTeleportEnabled and isInLobby() and GameObjects.AFKChamberUI.Enabled == false then
                print("🚀 Teleporting to AFK world...")
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("AFKWorldTeleport"):FireServer()
            end
        end
    end)

    task.spawn(function()
        while true do
            if State.AutoPurchaseMerchant and #Data.MerchantPurchaseTable > 0 and isInLobby() then
                autoPurchaseItems()
            end
            task.wait(1)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(3)
            if isInLobby() then
            if State.autoClaimBP then
            ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events"):WaitForChild("ClaimBp"):FireServer("Claim All")
            end
            if State.AutoClaimQuests then
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("QuestEvent"):FireServer("ClaimAll")
            end
            if State.AutoClaimMilestones then
            local playerlevel = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Level.Value
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("LevelMilestone"):FireServer(tonumber(playerlevel))
                end
            end
        end
    end)

    

--//BUTTONS\\--

local Button = LobbyTab:CreateButton({
        Name = "Return to lobby",
        Callback = function()
            notify("Return to lobby", "Returning to lobby!")
            Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
        end,
    })

local Button = LobbyTab:CreateButton({
        Name = "Redeem all valid codes",
        Callback = function()
            for _, code in ipairs(Data.CurrentCodes) do
                notify("Redeeming code: ", code, 2.5)
                Remotes.Code:FireServer(code)
                task.wait(0.25) -- small delay so server doesn't get flooded
            end
            notify("Redeem all valid codes", "Tried to redeem all codes!")
        end,
    })

local Button = GameTab:CreateButton({
        Name = "Low Performance Mode (Rejoin To Disable)",
        Callback = function()
            enableLowPerformanceMode()
        end,
    })

    local Label5 = WebhookTab:CreateLabel("Awaiting Webhook Input...", "cable")

 local TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test webhook",
    Callback = function()
        if ValidWebhook then
            sendWebhook("test")
            notify("Webhook Sent","Test message sent successfully!")
        else
            notify("Unable to send webhook.","Please check your webhook URL.")
        end
    end,
    })

--//TOGGLES\\--

local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Purchase Merchant Items",
    CurrentValue = false,
    Flag = "AutoPurchaseMerchant",
    Callback = function(Value)
        State.AutoPurchaseMerchant = Value
    end,
    })

     local MerchantSelectorDropdown = LobbyTab:CreateDropdown({
    Name = "Select Items To Purchase",
    Options = {"Dr. Megga Punk","Cursed Finger","Perfect Stats Key","Stats Key","Trait Reroll","Ranger Crystal"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "MerchantPurchaseSelector",
    Callback = function(Options)
        print("Selected items for auto purchase:", table.concat(Options, ", "))
        Data.MerchantPurchaseTable = Options
    end,
    })

    local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Claim Battlepass",
    CurrentValue = false,
    Flag = "AutoClaimBattlepass",
    Callback = function(Value)
        State.autoClaimBP = Value
    end,
    })

    local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Claim Quests",
    CurrentValue = false,
    Flag = "AutoClaimQuests",
    Callback = function(Value)
        State.AutoClaimQuests = Value
    end,
    })

    local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Claim Level Milestones",
    CurrentValue = false,
    Flag = "AutoClaimMilestones",
    Callback = function(Value)
        State.AutoClaimMilestones = Value
    end,
    })

    Toggle = LobbyTab:CreateToggle({
        Name = "Auto AFK Teleport",
        CurrentValue = false,
        Flag = "AutoAfkTeleportToggle",
        Callback = function(Value)
            State.autoAfkTeleportEnabled = Value
        end,
    })

    local JoinerSection = JoinerTab:CreateSection("Story Joiner")

      local AutoJoinStoryToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Story",
    CurrentValue = false,
    Flag = "AutoStoryToggle",
    Callback = function(Value)
        State.autoJoinEnabled = Value
    end,
    })

      local StageDropdown = JoinerTab:CreateDropdown({
    Name = "Story Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryStageSelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        State.selectedWorld = Option[1]  
    end,
    })

    local ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Stage Chapter",
    Options = Config.chapters,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryChapterSelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        State.selectedChapter = Option[1]

    end,
    })
    local DifficultyDropdown = JoinerTab:CreateDropdown({
    Name = "Stage Difficulty",
    Options = Config.difficulties,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryDifficultySelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        State.selectedDifficulty = Option[1]

    end,
    })

    task.spawn(function()
        while #Data.availableStories == 0 do
            task.wait(0.5)
        end
        
        local storyNames = {}
        for _, story in ipairs(Data.availableStories) do
            table.insert(storyNames, story.SeriesName)
        end
        
        StageDropdown:Refresh(storyNames)
        print("✅ Story dropdown updated with", #storyNames, "options")
    end)

    local JoinerSection2 = JoinerTab:CreateSection("Challenge Joiner")

        local Toggle = JoinerTab:CreateToggle({
    Name = "Challenge Joiner",
    CurrentValue = false,
    Flag = "AutoChallengeToggle",
    Callback = function(Value)
        State.autoChallengeEnabled = Value
    end,
    })

 local ChallengeDropdown = JoinerTab:CreateDropdown({
    Name = "Select Challenge Rewards",
    Options = {"Dr. Megga Punk","Ranger Crystal","Stats Key","Perfect Stats Key","Trait Reroll","Cursed Finger"},
    CurrentOption = {},
    MultipleOptions = true, -- Changed back to true for multiple selection
    Flag = "ChallengeRewardSelector",
    Callback = function(options)
        Data.wantedRewards = options or {}
        if #Data.wantedRewards > 0 then
            print("🔎 Target rewards set to:", table.concat(Data.wantedRewards, ", "))
        end
    end,
    })

    local Toggle = JoinerTab:CreateToggle({
        Name = "Return to Lobby on New Challenge",
        CurrentValue = false,
        Flag = "AutoReturnChallengeToggle",
        Callback = function(Value)
            State.challengeAutoReturnEnabled = Value
        end,
    })

    local JoinerSection3 = JoinerTab:CreateSection("Portal Joiner")

     local Toggle = JoinerTab:CreateToggle({
    Name = "Portal Joiner",
    CurrentValue = false,
    Flag = "AutoPortalToggle",
    Callback = function(Value)
        State.autoPortalEnabled = Value
         if autoPortalEnabled then
            State.portalUsed = false
         end
    end,
    })

    local JoinerSection4 = JoinerTab:CreateSection("Ranger Stage Joiner")

        local Toggle = JoinerTab:CreateToggle({
        Name = "Auto Join Ranger Stage",
        CurrentValue = false,
        Flag = "AutoRangerStageToggle",
        Callback = function(Value)
            State.isAutoJoining = Value
        end,
    })

    local RangerStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Ranger Stages To Join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RangerStageSelector",
    Callback = function(Options)
        Data.selectedRawStages = {} -- Clear the array first
        
        for _, selectedDisplay in ipairs(Options) do
            for _, stage in ipairs(Data.availableRangerStages) do
                if stage.DisplayName == selectedDisplay then
                table.insert(Data.selectedRawStages, stage.RawName)
                break
                end
            end
        end
    end,
})

task.spawn(function()
        while #Data.availableRangerStages == 0 do
            task.wait(0.5)
        end
        
        local rangerDisplayNames = {}
        for _, stage in ipairs(Data.availableRangerStages) do
            table.insert(rangerDisplayNames, stage.DisplayName)
        end
        
        RangerStageDropdown:Refresh(rangerDisplayNames)
        print("✅ Ranger stage dropdown updated with", #rangerDisplayNames, "options")
    end)

    local JoinerSection5 = JoinerTab:CreateSection("Boss Attack")

    local Label2 = JoinerTab:CreateLabel("Boss Tickets: "..Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.BossAttackTicket.Value, "ticket")

        local Toggle = JoinerTab:CreateToggle({
    Name = "Auto join boss attack",
    CurrentValue = false,
    Flag = "AutoJoinBossAttack",
    Callback = function(Value)
        State.autoBossAttackEnabled = Value
        if State.autoBossAttackEnabled then
            State.lastBossTicketCount = getBossAttackTickets()
            State.lastBossTicketResetTime = getBossTicketResetTime()
            print("🎫 Current boss attack tickets:", State.lastBossTicketCount)
        end
    end,
    })

        local Toggle = JoinerTab:CreateToggle({
    Name = "Return to Lobby When Boss Attack Tickets Reset",
    CurrentValue = false,
    Flag = "AutoReturnBossAttackToggle",
    Callback = function(Value)
        State.autoReturnBossTicketResetEnabled = Value
        if State.autoReturnBossTicketResetEnabled then
            State.lastBossTicketCount = getBossAttackTickets()
            State.lastBossTicketResetTime = getBossTicketResetTime()
        end
    end,
    })

    local JoinerSection6 = JoinerTab:CreateSection("Infinity Castle")

    local Label3 = JoinerTab:CreateLabel("Infinity Castle Floor: ", "badge-info")

       local Toggle = JoinerTab:CreateToggle({
    Name = "Auto Infinity Castle",
    CurrentValue = false,
    Flag = "AutoInfinityCastle",
    Callback = function(Value)
        State.autoInfinityCastleEnabled = Value     
        if State.autoInfinityCastleEnabled then
            notify("Infinity Castle", "Auto path switching enabled!")
            startInfinityCastleLogic()
        else
            stopInfinityCastleLogic()
        end
    end,
    })

    local GameSection = GameTab:CreateSection("Game")
    local Label4 = JoinerTab:CreateLabel("You need decently good units for infinity castle to win. Don't use any other auto joiners if you're enabling this and don't panic if it fails sometimes (unless your units are not good enough).", "badge-info")

     local Toggle = GameTab:CreateToggle({
    Name = "Auto Start",
    CurrentValue = false,
    Flag = "AutoStartToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
            State.autoStartEnabled = Value
    end,
    })

    local Toggle = GameTab:CreateToggle({
    Name = "Auto Next",
    CurrentValue = false,
    Flag = "AutoNextToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        State.autoNextEnabled = Value
        if State.hasGameEnded and State.autoNextEnabled then
            game:GetService("ReplicatedStorage"):WaitForChild("Remote")
                :WaitForChild("Server")
                :WaitForChild("OnGame")
                :WaitForChild("Voting")
                :WaitForChild("VoteNext"):FireServer()
        end
    end,
    })

    local Toggle = GameTab:CreateToggle({
    Name = "Auto Retry",
    CurrentValue = false,
    Flag = "AutoRetryToggle",
    Callback = function(Value)
        State.autoRetryEnabled = Value
        
    end,
    })

    local Toggle = GameTab:CreateToggle({
    Name = "Auto Lobby",
    CurrentValue = false,
    Flag = "AutoLobbyToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        State.autoReturnEnabled = Value
        if State.hasGameEnded and State.autoReturnEnabled then
            Services.TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
        end
    end,
    })

    local Toggle = AutoPlayTab:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = false,
    Flag = "AutoUpgradeToggle",
    Callback = function(Value)
        State.autoUpgradeEnabled = Value
        if State.autoUpgradeEnabled then
            State.gameRunning = true
            resetUpgradeOrder()
            startAutoUpgrade()
        else
            stopAutoUpgrade()
        end
    end,
    })

      local AutoUpgradeDropdown = AutoPlayTab:CreateDropdown({
    Name = "Select Upgrade Method",
    Options = {"Left to right until max"},
    CurrentOption = {"Left to right until max"},
    MultipleOptions = false,
    Flag = "UpgradeMethodSelector",
    Callback = function(Options)
        State.upgradeMethod = Options[1] or "Left to right until max"
        if State.autoUpgradeEnabled then
            stopAutoUpgrade()
            resetUpgradeOrder() -- Reset when changing method
            State.gameRunning = true
            task.wait(0.5)
            startAutoUpgrade()
        end
    end,
    })

    local Slider1 = AutoPlayTab:CreateSlider({
    Name = "Unit 1 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit1LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[1] = Value
    end,
    })

    local Slider2 = AutoPlayTab:CreateSlider({
    Name = "Unit 2 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit2LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[2] = Value
    end,
    })

    local Slider3 = AutoPlayTab:CreateSlider({
    Name = "Unit 3 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit3LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[3] = Value
    end,
    })

    local Slider4 = AutoPlayTab:CreateSlider({
    Name = "Unit 4 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit4LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[4] = Value
    end,
    })

    local Slider5 = AutoPlayTab:CreateSlider({
    Name = "Unit 5 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit5LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[5] = Value
    end,
    })

    local Slider6 = AutoPlayTab:CreateSlider({
    Name = "Unit 6 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit6LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[6] = Value
    end,
    })

    
    local Toggle = AutoPlayTab:CreateToggle({
    Name = "Auto Ultimate",
    CurrentValue = false,
    Flag = "AutoUltimate", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        State.AutoUltimateEnabled = Value
    end,
    })

    local Input = WebhookTab:CreateInput({
    Name = "Input Webhook",
    CurrentValue = "",
    PlaceholderText = "Input Webhook...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInput",
    Callback = function(Text)
        if string.find(Text, "https://discord.com/api/webhooks/") then
            ValidWebhook = Text
            Label5:Set("✅ Webhook URL set!")
        elseif Text == "" then
            Label5:Set("Awaiting Webhook Input...")
            ValidWebhook = nil
        else
            ValidWebhook = nil
            Label5:Set("❌ Invalid Webhook URL")
        end
    end,
    })

game.ReplicatedStorage.Remote.Replicate.OnClientEvent:Connect(function(...)
        local args = {...}
        if table.find(args, "Game_Start") then
            State.gameRunning = true
        resetUpgradeOrder() -- Reset to slot 1 every time a new game starts
        stopRetryLoop()
        stopNextLoop()
        

            State.retryAttempted = false
            State.NextAttempted = false
            State.hasGameEnded = false

        if State.autoUpgradeEnabled then
            notify("Game Started", "Auto upgrade restarted!")
        end

            State.hasSentWebhook = false
            State.stageStartTime = tick()
            print("🟢 Stage started at", State.stageStartTime)
        end
    end)

Remotes.GameEndedUI.OnClientEvent:Connect(function(_, outcome)
        if typeof(outcome) == "string" then
            local l = outcome:lower()
            if l:find("defeat") then
                State.matchResult = "Defeat"
            elseif l:find("won") or l:find("win") then
                State.matchResult = "Victory"
            else
                State.matchResult = "Unknown"
            end
            print("🎯 Match result detected:", State.matchResult)
        end
    end)

Remotes.GameEnd.OnClientEvent:Connect(function()
    if State.hasSentWebhook then
            print("⏳ Webhook still on cooldown…")
            return
        end
        State.hasSentWebhook = true
        State.gameRunning = false
        resetUpgradeOrder()

        task.wait(0.5)

     if Services.Players.LocalPlayer.PlayerGui:FindFirstChild("GameEndedAnimationUI") then
            Services.Players.LocalPlayer.PlayerGui:FindFirstChild("GameEndedAnimationUI"):Destroy()
        end
        if Services.Players.LocalPlayer.PlayerGui:FindFirstChild("RewardsUI").Enabled == true then
            Services.Players.LocalPlayer.PlayerGui:FindFirstChild("RewardsUI").Enabled = false
        end
        if Services.Players.LocalPlayer.PlayerGui:FindFirstChild("Visual") then
            Services.Players.LocalPlayer.PlayerGui:FindFirstChild("Visual"):Destroy()
        end
        if Services.Players.LocalPlayer:FindFirstChild("SavedToTeleport") then
            Services.Players.LocalPlayer:FindFirstChild("SavedToTeleport"):Destroy()
        end

        local clearTimeStr = "Unknown"
        if State.stageStartTime then
            local dt = math.floor(tick() - State.stageStartTime)
            clearTimeStr = string.format("%d:%02d", dt // 60, dt % 60)
        end

        sendWebhook("stage", nil, clearTimeStr, State.matchResult)

        State.actionTaken = false

        if State.pendingBossTicketReturn and not State.actionTaken then
            notify("Boss Tickets", "Tickets available - returning to lobby")
            State.pendingBossTicketReturn = false
            State.actionTaken = true
            task.delay(2, function()
                TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
            end)
            return
        end

        if State.pendingChallengeReturn and not State.actionTaken then
            notify("Challenge Return", "New challenge detected - returning to lobby")
            State.pendingChallengeReturn = false
            State.actionTaken = true
            task.delay(2, function()
                TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
            end)
            return
        end

    if State.autoRetryEnabled then
        startRetryLoop()
    end
    if State.autoNextEnabled then
        startNextLoop()
    end
    if State.autoReturnEnabled then
         task.delay(2, function()
                TeleportService:Teleport(72829404259339, Services.Players.LocalPlayer)
            end)
    end

end)

Rayfield:LoadConfiguration()
