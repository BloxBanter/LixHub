local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Rangers X - optimization",
   Icon = "apple", -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Loading for Anime Rangers X",
   LoadingSubtitle = "by Lix",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LixHub", -- Create a custom folder for your hub/game
      FileName = "Anime Rangers X"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "mZJwDHt2", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "LixHub - Freemium",
      Subtitle = "Key System",
      Note = "Get key at [REDACTED]", -- Use this to tell the user how to get a key
      FileName = "LixHubSavedKey", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"1"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local ValidWebhook
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEndRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("GameEndedUI")
local CodeRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("Code")
local StartGameRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VotePlaying")
local merchantRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("Merchant")
 local PlayEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")
local challengeFolder = game:GetService("ReplicatedStorage"):WaitForChild("Gameplay"):WaitForChild("Game"):WaitForChild("Challenge")
local ServerSettings = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Settings"):WaitForChild("Setting_Event")
local PlayRoomEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")
local UnitsRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Upgrade")
local GameWorldInfo = ReplicatedStorage.Shared.Info.GameWorld
local itemsFolder = challengeFolder:WaitForChild("Items")
local AFKChamberUI = player:WaitForChild("PlayerGui"):WaitForChild("AFKChamber")
local STAGE_MODULES_FOLDER = game.ReplicatedStorage.Shared.Info.GameWorld.Levels -- Adjust path
local DISCORD_USER_ID = "942709395253522442" -- Replace with actual Discord user ID
local pendingChallengeReturn = false -- Flag to indicate we should return to lobby when game ends
local storedChallengeSerial = nil -- Store the challenge serial persistently
local selectedRawStages = {}

-- ========== Value Holders ==========
local autoJoinEnabled
local hasSentWebhook = false
local matchResult = "Unknown"
local autoStartEnabled
local autoRetryEnabled
local autoReturnEnabled
local autoNextEnabled
local autoChallengeEnabled
local autoPortalEnabled
local portalUsed = false
local isAutoJoining
local autoClaimBP
local AutoClaimQuests
local AutoClaimMilestones
local MerchantPurchaseTable = {}
local AutoPurchaseMerchant
local chapters = {"Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7", "Chapter8", "Chapter9", "Chapter10"}
local difficulties = {"Normal", "Hard", "Nightmare"}
local selectedWorld, selectedChapter, selectedDifficulty
local rangerStages = {}
local wantedRewards = {} -- Changed from single reward to array
local challengeAutoReturnEnabled
local capturedRewards = {}
local hasNewRewards = false
-- Add these variables to your existing value holders section
local autoBossAttackEnabled
local autoReturnBossTicketResetEnabled
local autoInfinityCastleEnabled
local lastBossTicketCount = 0
local lastBossTicketResetTime = 0
local pendingBossTicketReturn = false
local infinityCastleTask = nil
local currentPath = nil
local autoUpgradeEnabled
local upgradeMethod = "Left to right until max"
local unitLevelCaps = {9, 9, 9, 9, 9, 9}
local upgradeTask = nil
local UPGRADE_COOLDOWN = 1
local currentUpgradeSlot = 1  -- Track which slot we're currently upgrading
local gameRunning = false
local autoAfkTeleportEnabled
local availableStories = {}
local availableRangerStages = {}
local hasGameEnded = false
local AutoUltimateEnabled
local lastUpgradeTime = 0

local codes = { --////////////////////////////////////////////////////////////////UPDATE\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--
    "SorryRaids",
    "RAIDS",
    "BizzareUpdate2!",
    "Sorry4Delays",
    "BOSSTAKEOVER",
}

local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

--[[local function isInLobby()
    if workspace:FindFirstChild("Lobby") then
        return true
    else
        return false
    end
end--]]

local function enableLowPerformanceMode()
    Lighting.Brightness = 1
    Lighting.GlobalShadows = false
    Lighting.Technology = Enum.Technology.Compatibility
    Lighting.ShadowSoftness = 0
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if obj.Transparency < 1 then
                obj.Transparency = 1
            end
        end
    end
    local playerGui = player:WaitForChild("PlayerGui")
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") or gui:IsA("BlurEffect") then
            gui.Enabled = false
        end
    end
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or 
           obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
            obj.Enabled = false
        end
    end
    local args = {}
    args = {"Abilities VFX", false}
    ServerSettings:FireServer(unpack(args))
    args = {"Hide Cosmetic", true}
    ServerSettings:FireServer(unpack(args))
    args = {"Low Graphic Quality", true}
    ServerSettings:FireServer(unpack(args))
    args = {"HeadBar", false}
    ServerSettings:FireServer(unpack(args))
    args = {"Display Players Units", false}
    ServerSettings:FireServer(unpack(args))
    args = {"DisibleGachaChat", true}
    ServerSettings:FireServer(unpack(args))
    args = {"DisibleDamageText", true}
    ServerSettings:FireServer(unpack(args))
end
local function fetchStoryData()
    local storyData = {}
    local worldDisplayNameMap = {}
    local folder = GameWorldInfo:WaitForChild("World")
    
    for _, moduleScript in ipairs(folder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, data = pcall(function()
                return require(moduleScript)
            end)

            if success and typeof(data) == "table" then
                for key, storyTable in pairs(data) do
                    if typeof(storyTable) == "table" and storyTable.StoryAble == true then
                        if storyTable.Name and storyTable.Ani_Names then
                            table.insert(storyData, {
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
    
    return storyData, worldDisplayNameMap
end
local function fetchRangerStageData(storyData)
    local folder = GameWorldInfo:WaitForChild("Levels")
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
            local success, data = pcall(require, moduleScript)

            if success and typeof(data) == "table" then
                for seriesName, chapters in pairs(data) do
                    if typeof(chapters) == "table" then
                        for chapterKey, chapterData in pairs(chapters) do
                            if typeof(chapterData) == "table" and chapterData.Wave and string.find(chapterData.Wave, "RangerStage") then
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
local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title or "Notice",
        Content = content or "No message.",
        Duration = duration or 5,
        Image = "info",
    })
end
local function findMatchingStageAndCheckUnits(detectedRewards)
    local foundUnits = {}
    local matchedStage = nil

    local success, stageData

    for _, moduleScript in ipairs(STAGE_MODULES_FOLDER:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            success, stageData = pcall(require, moduleScript)

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
    local playerData = ReplicatedStorage:FindFirstChild("Player_Data")[player.Name]
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

    local GetData = require(ReplicatedStorage.Shared.GetData)

    for _, reward in pairs(rewardData) do
        local itemName = reward.Name
        local amount = reward.Amount and reward.Amount.Value or 1

        local isUnit = false

        pcall(function()
            if GetData.GetUnitStats(itemName) then
                isUnit = true
                table.insert(detectedUnits, itemName)
            elseif GetData.GetItemStats(itemName) then
                -- Only checking item validity, no action needed
            end
        end)

        local totalAmount = getTotalItemAmount(itemName)
        local totalText = totalAmount and string.format(" [%s total]", totalAmount) or ""

        local rewardText
        if isUnit then
            rewardText = string.format("🌟 %s x%d (UNIT!)%s", itemName, amount, totalText)
        else
            rewardText = string.format("+ %s %s%s", amount, itemName, totalText)
        end

        table.insert(rewards, rewardText)
        capturedRewards[itemName] = amount
    end

    return rewards, detectedUnits
end
local function hookRewardSystem()
    if isInLobby() then return end

    local success, err = pcall(function()
        local gameEndedRemote = ReplicatedStorage.Remote.Client.UI.GameEndedUI

        gameEndedRemote.OnClientEvent:Connect(function(eventType, data)
            if eventType == "Rewards - Items" then
                print("🎯 Intercepted reward data from game!")
                capturedRewards = {}
                hasNewRewards = true

                local rewardLines, detectedUnits = processRemoteRewards(data)

                capturedRewards.processed = rewardLines
                capturedRewards.units = detectedUnits
                capturedRewards.rawData = data

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
    local rewardsRoot = player:FindFirstChild("RewardsShow")
    if not rewardsRoot then
        return "_No rewards found_", {}
    end

    local lines = {}
    local detectedRewards = {} -- Track what rewards we found

    for _, folder in ipairs(rewardsRoot:GetChildren()) do
        if folder:IsA("Folder") then
            for _, val in ipairs(folder:GetChildren()) do
                if val:IsA("NumberValue") then
                    local itemName = val.Parent.Name
                    local amount = tostring(val.Value)
                    
                    -- Store the reward for unit checking
                    detectedRewards[itemName] = amount

                    -- Get total amount from player data
                    local totalAmount = getTotalItemAmount(itemName)
                    local totalText = totalAmount and string.format(" [%s total]", totalAmount) or ""

                    -- Display with colon for standard stuff like XP/Gold, and × for items
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
        return "_No reward values found_", {}
    end

    return table.concat(lines, "\n"), detectedRewards
end

local function sendWebhook(messageType, rewards, clearTime, matchResult)
    if not ValidWebhook then return end
    local data

    -- TEST WEBHOOK
    if messageType == "test" then
        data = {
            username = "LixHub Bot",
            embeds = {{
                title = "📢 LixHub Notification",
                description = "Test webhook sent successfully",
                color = 0x5865F2,
                footer = {
                    text = "LixHub Auto Logger"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }

    -- STAGE COMPLETION WEBHOOK
    elseif messageType == "stage" then
        local RewardsUI = player:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("InGame"):WaitForChild("Main"):WaitForChild("GameInfo")
        local RewardsFolder = player:FindFirstChild("RewardsShow")

        local stageName = RewardsUI and RewardsUI:FindFirstChild("Stage") and RewardsUI.Stage.Label.Text or "Unknown Stage"
        local gameMode = RewardsUI and RewardsUI:FindFirstChild("Gamemode") and RewardsUI.Gamemode.Label.Text or "Unknown Time"
        local isWin = matchResult == "Victory"
        local plrlevel = ReplicatedStorage.Player_Data[player.Name].Data.Level.Value or ""

        -- Build reward string and get detected rewards
        local rewardsText, detectedRewards = buildRewardsText()
        
        -- Check for units by searching through all stage modules
        local foundUnits, matchedStage = findMatchingStageAndCheckUnits(detectedRewards)
        local shouldPing = #foundUnits > 0
        local pingText = shouldPing and string.format("<@%s> 🎉 **SECRET UNIT OBTAINED!** 🎉", DISCORD_USER_ID) or ""

        local stageResult = stageName .. " (" .. gameMode .. ")" .. " - " .. matchResult
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        -- Build description with ping if unit found
        local description = stageResult
        if shouldPing then
            description = pingText .. "\n" .. stageResult
        end

        data = {
            username = "LixHub Bot",
            content = shouldPing and pingText or nil, -- This ensures the ping works
            embeds = {{
                title = shouldPing and "🌟 UNIT DROP! 🌟" or "🎯 Stage Finished!",
                description = description,
                color = shouldPing and 0xFFD700 or (isWin and 0x57F287 or 0xED4245), -- Gold for units, green for win, red for loss
                fields = {
                    {
                        name = "👤 Player",
                        value = "||" .. player.Name .. " [" .. plrlevel .. "]" .. "||",
                        inline = true
                    },
                    {
                        name = isWin and ("✅ Won in:") or ("❌ Lost after:"),
                        value = clearTime,
                        inline = true
                    },
                    {
                        name = shouldPing and "🏆 Rewards" or "🏆 Rewards",
                        value = rewardsText,
                        inline = false
                    },
                    shouldPing and {
                        name = "🌟 Units Obtained",
                        value = table.concat(foundUnits, ", "),
                        inline = false
                    } or nil,
                    {
                        name = "📈 Script Version",
                        value = "v1.1.0", -- Updated version
                        inline = true
                    }
                },
                footer = {
                    text = "discord.gg/lixhub"
                },
                timestamp = timestamp
            }}
        }

        -- Remove nil fields
        local filteredFields = {}
        for _, field in ipairs(data.embeds[1].fields) do
            if field then
                table.insert(filteredFields, field)
            end
        end
        data.embeds[1].fields = filteredFields

    else
        return -- Unrecognized message type
    end

    -- Encode & send webhook
    local payload = HttpService:JSONEncode(data)
    local requestFunc = (syn and syn.request) or (http and http.request) or request
    if requestFunc then
        local success, result = pcall(function()
            return requestFunc({
                Url = ValidWebhook,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = payload
            })
        end)
        if not success then
            warn("Webhook failed to send: " .. tostring(result))
        end
    else
        warn("No compatible HTTP request method found.")
    end
end

local function countPartsOnPath(folder, pathFolder)
    local count = 0
    local startPos = pathFolder["1"].Position
    local endPos = pathFolder["2"].Position
    local totalDist = (startPos - endPos).Magnitude
    for _, part in ipairs(folder:GetChildren()) do
        if part:IsA("BasePart") and part:FindFirstChildOfClass("Humanoid") then
            local distSum = (part.Position - startPos).Magnitude + (part.Position - endPos).Magnitude
            if distSum <= totalDist + 15 then
                count += 1
            end
        end
    end

    return count
end

local function getBestPath()
    local lowestUnits = math.huge
    local bestPath

    for i = 1, 3 do
        local pathName = "P" .. i
        local pathFolder = workspace:WaitForChild("WayPoint"):FindFirstChild(pathName)

        if pathFolder then
            local unitCount = countPartsOnPath(workspace.Agent.UnitT, pathFolder)
            local enemyCount = countPartsOnPath(workspace.Agent.EnemyT, pathFolder)

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
    if infinityCastleTask then
        task.cancel(infinityCastleTask)
    end

    infinityCastleTask = task.spawn(function()
        while autoInfinityCastleEnabled do
            local success, err = pcall(function()
                local bestPath = getBestPath()

                if bestPath and bestPath ~= currentPath then
                    notify("🚀 Switching to path: ", bestPath)
                    currentPath = bestPath

                    game:GetService("ReplicatedStorage").Remote.Server.Units.SelectWay:FireServer(bestPath)
                else
                    print("✅ Staying on current path:", currentPath or "None")
                end
            end)

            if not success then
                warn("❌ Infinity Castle error:", err)
            end

            task.wait(2.5)
        end
    end)
end

local function stopInfinityCastleLogic()
    if infinityCastleTask then
        task.cancel(infinityCastleTask)
        infinityCastleTask = nil
    end
    currentPath = nil
end

local function isWantedChallengeRewardPresent()
    for _, reward in ipairs(wantedRewards) do
        local value = itemsFolder:FindFirstChild(reward)
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
    local playerData = ReplicatedStorage.Player_Data[player.Name].Data
    if not playerData then return {} end

    local currencies = {}
    local gold = playerData:FindFirstChild("Gold")
    if gold then currencies["Gold"] = gold.Value end

    local gems = playerData:FindFirstChild("Gem")
    if gems then currencies["Gem"] = gems.Value end

    return currencies
end

local function canAffordItem(itemFolder)
    local priceValue = itemFolder:FindFirstChild("CurrencyAmount")
    local currencyTypeValue = itemFolder:FindFirstChild("CurrencyType")
    if not priceValue or not currencyTypeValue then return false end

    local playerCurrencies = getPlayerCurrency()
    return playerCurrencies[currencyTypeValue.Value] and playerCurrencies[currencyTypeValue.Value] >= priceValue.Value
end

local function purchaseItem(itemName, quantity)
    pcall(function()
        merchantRemote:FireServer(itemName, quantity or 1)
    end)
end

local function autoPurchaseItems()
    if not AutoPurchaseMerchant or not MerchantPurchaseTable or #MerchantPurchaseTable == 0 then return end

    local playerData = ReplicatedStorage.Player_Data[player.Name]
    if not playerData then return end

    local merchantFolder = playerData:FindFirstChild("Merchant")
    if not merchantFolder then return end

    for _, selectedItem in pairs(MerchantPurchaseTable) do
        local itemFolder = merchantFolder:FindFirstChild(selectedItem)
        if itemFolder and canAffordItem(itemFolder) then
            local quantityValue = itemFolder:FindFirstChild("Quantity")
            local buyAmountValue = itemFolder:FindFirstChild("BuyAmount")

            local availableQuantity = quantityValue and quantityValue.Value or 1
            local currentQuantity = buyAmountValue and buyAmountValue.Value or 0

            if currentQuantity <= 0 then
                purchaseItem(selectedItem, availableQuantity)
                notify("Auto Purchase Merchant", "Purchased: " .. availableQuantity .. "x " .. selectedItem)
                task.wait(0.5)
            end
        elseif itemFolder then
            notify("Auto Purchase Merchant", "Cannot Afford " .. selectedItem)
        end
    end
end

local function autoJoinRangerStage(stageName)
    if not isInLobby() then
        print("❌ Not in lobby, cannot join ranger stage")
        return
    end

    print("🚀 Joining ranger stage:", stageName)

    PlayRoomEvent:FireServer("Create")
    task.wait(0.3)

    PlayRoomEvent:FireServer("Change-Mode", { Mode = "Ranger Stage" })
    task.wait(0.3)

    local world = stageName:match("^(.-)_RangerStage")
    if not world then
        warn("❌ Couldn't extract world from:", stageName)
        return
    end

    PlayRoomEvent:FireServer("Change-World", { World = world })
    task.wait(0.3)

    PlayRoomEvent:FireServer("Change-Chapter", { Chapter = stageName })
    task.wait(0.3)

    PlayRoomEvent:FireServer("Submit")
    task.wait(0.3)

    PlayRoomEvent:FireServer("Start")

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

    local notifyActions = {
        ["Ranger Stage Auto Join"] = true,
        ["Challenge Auto Join"] = true,
        ["Portal Auto Join"] = true,
        ["Boss Attack Auto Join"] = true
    }

    if notifyActions[action] then
        notify("🔄 Processing: ", action)
    elseif action == "Story Auto Join" then
        notify("🔄 Processing: ", string.format("Joining %s - %s [%s]", selectedWorld or "?", selectedChapter or "?", selectedDifficulty or "?"))
    end
end

local function clearProcessingState()
    autoJoinState.isProcessing = false
    autoJoinState.currentAction = nil
end

local function getBossAttackTickets()
    local success, tickets = pcall(function()
        return ReplicatedStorage.Player_Data[player.Name].Data.BossAttackTicket.Value
    end)
    return success and tickets or 0
end

local function getBossTicketResetTime()
    local success, resetTime = pcall(function()
        return ReplicatedStorage.Player_Data[player.Name].Data.BossAttackReset.Value
    end)
    return success and resetTime or 0
end

local function autoJoinBossAttack()
    if not isInLobby() then return end
    print("🏆 [Priority 0] Attempting to join Boss Attack...")
    PlayRoomEvent:FireServer("Boss-Attack")
end

local function getInternalWorldName(displayName)
    for _, story in ipairs(availableStories) do
        if story.SeriesName == displayName then
            return story.ModuleName
        end
    end
    return nil
end

local function checkAndExecuteHighestPriority()
    if not isInLobby() or autoJoinState.isProcessing or not canPerformAction() then return end

    -- Priority 0: Boss Attack Auto Join
    if autoBossAttackEnabled then
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
    if isAutoJoining and selectedRawStages and #selectedRawStages > 0 then
        local selectedStageSet = {}
        for _, raw in ipairs(selectedRawStages) do
            selectedStageSet[raw] = true
        end

        local prioritizedStageList = {}
        for _, stage in ipairs(availableRangerStages) do
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
    if autoChallengeEnabled then
        local foundRewardOK, foundReward = isWantedChallengeRewardPresent()
        if foundRewardOK then
            setProcessingState("Challenge Auto Join")
            print("🎯 Found wanted reward '" .. foundReward .. "' → creating challenge room")
            notify("Challenge Mode", string.format("Found %s, joining challenge...", foundReward))
            PlayRoomEvent:FireServer("Create", { CreateChallengeRoom = true })
            PlayRoomEvent:FireServer("Start")
            task.delay(5, clearProcessingState)
            return
        end
    end

    -- Priority 3: Portal Auto Join
    if autoPortalEnabled and not portalUsed then
        local success, result = pcall(function()
            local inventoryFrame = player:FindFirstChild("PlayerGui").Items.Main.Base.Space:FindFirstChild("Scrolling")
            if not inventoryFrame then return nil end

            local bestPortalName, bestTier = nil, 0
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

            local portalInstance = ReplicatedStorage.Player_Data[player.Name].Items:FindFirstChild(result)
            if portalInstance then
                print("🚪 Using portal:", result)
                ReplicatedStorage.Remote.Server.Lobby.ItemUse:FireServer(portalInstance)
                notify("Portal", string.format("Using portal: %s", result))
                task.wait(1)
                print("▶️ Starting portal match...")
                ReplicatedStorage.Remote.Server.Lobby.PortalEvent:FireServer("Start")
                portalUsed = true
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
    if autoJoinEnabled and selectedWorld and selectedChapter and selectedDifficulty then
        setProcessingState("Story Auto Join")
        local internalWorldName = getInternalWorldName(selectedWorld)

        if internalWorldName then
            print("📚 [Priority 4] Joining Story:", selectedWorld, "/", selectedChapter, "/", selectedDifficulty)

            local combinedWorld = internalWorldName .. "_" .. selectedChapter:gsub(" ", "")
            local sequence = {
                { "Create" },
                { "Change-World", { World = tostring(internalWorldName) } },
                { "Change-Chapter", { Chapter = tostring(combinedWorld) } },
                { "Change-Difficulty", { Difficulty = tostring(selectedDifficulty) } },
                { "Submit" },
                { "Start" }
            }

            for _, cmd in ipairs(sequence) do
                PlayRoomEvent:FireServer(unpack(cmd))
                task.wait(0.25)
            end

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
        return challengeFolder:WaitForChild("serial_number") and challengeFolder:WaitForChild("serial_number").Value
    end)
    return success and serial or nil
end

local function getUnitNameFromSlot(slotNumber)
    local success, unitInstance = pcall(function()
        return player.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame.UnitFrame.Info.Folder.Value
    end)

    if success and unitInstance then
        return typeof(unitInstance) == "Instance" and unitInstance.Name or tostring(unitInstance)
    end
    return nil
end

local function getCurrentUpgradeLevel(unitName)
    if not unitName then return 0 end

    local success, upgradeLevel = pcall(function()
        local upgradeText = player.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].UpgradeText.Text

        if string.find(upgradeText:upper(), "MAX") then
            return "MAX"
        end

        local level = string.match(upgradeText, "Upgrade:</font>%s*(%d+)")
        return tonumber(level) or 0
    end)

    return success and upgradeLevel or 0
end

local function getUpgradeCost(unitName)
    if not unitName then return 9999 end

    local success, cost = pcall(function()
        local costText = player.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].CostText.Text
        local costValue = string.match(costText, "Cost:</font>%s*([%d,]+)")

        if costValue then
            return tonumber(costValue:gsub(",", "")) or 9999
        end
    end)

    return success and cost or 9999
end

local function getCurrentMoney()
    local success, money = pcall(function()
        return player.Yen.Value
    end)
    return success and money or 0
end

local function upgradeUnit(unitName)
    if not unitName then return false end

    local success = pcall(function()
        UnitsRemote:FireServer(player.UnitsFolder[typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)])
    end)

    if success then
        print("✅ Upgraded unit:", typeof(unitName) == "Instance" and unitName.Name or tostring(unitName))
        lastUpgradeTime = tick()
        return true
    else
        warn("❌ Failed to upgrade unit:", typeof(unitName) == "Instance" and unitName.Name or tostring(unitName))
        return false
    end
end

local function canUpgrade()
    return tick() - lastUpgradeTime >= UPGRADE_COOLDOWN
end

local function leftToRightUpgrade()
    if not canUpgrade() then return end
   -- print("🔄 Starting upgrade cycle from slot " .. currentUpgradeSlot)
    
    while autoUpgradeEnabled and gameRunning do
        local unitName = getUnitNameFromSlot(currentUpgradeSlot)
        local unitNameStr = unitName and (typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)) or "nil"
        local maxLevel = unitLevelCaps[currentUpgradeSlot] or 9
        
       -- print("🔍 Checking slot " .. currentUpgradeSlot .. " unit:", unitNameStr)

        if unitName and unitNameStr ~= "" and unitNameStr ~= "nil" then
            local currentLevel = getCurrentUpgradeLevel(unitNameStr)

            if currentLevel == "MAX" or tonumber(currentLevel) >= maxLevel then
                print("🏆 Unit " .. unitNameStr .. " reached max level, moving to next slot")
                currentUpgradeSlot = currentUpgradeSlot + 1
                
                -- If we've checked all slots, restart from slot 1
                if currentUpgradeSlot > 6 then
                    currentUpgradeSlot = 1
                   -- print("🔄 All slots checked, restarting from slot 1")
                end
            else
                -- Try to upgrade current unit - STRICT ORDER: Wait for money!
                local currentMoney = getCurrentMoney()
                local upgradeCost = getUpgradeCost(unitNameStr)
                
               -- print("📊 Unit '" .. unitNameStr .. "' - Level:", tostring(currentLevel), "Max:", maxLevel, "Cost:", upgradeCost, "Money:", currentMoney)

                if currentMoney >= upgradeCost then
                   -- print("🔧 Upgrading unit:", unitNameStr)
                    if upgradeUnit(unitNameStr) then
                        task.wait()
                    else
                      --  print("❌ Failed to upgrade, will retry")
                        task.wait()
                    end
                else
                  --  print("⏳ Waiting for money to upgrade unit:", unitNameStr, "- STAYING on this slot")
                    
                end
            end
        else
           -- print("⚠️ No valid unit in slot " .. currentUpgradeSlot .. ", moving to next")
            currentUpgradeSlot = currentUpgradeSlot + 1
            
            if currentUpgradeSlot > 6 then
                currentUpgradeSlot = 1
               -- print("🔄 All slots checked, restarting from slot 1")
            end
        end

        task.wait(0.5) 
    end
    
   -- print("🛑 Upgrade cycle ended")
end

local function startAutoUpgrade()
    if isInLobby() then return end

    if upgradeTask then
        task.cancel(upgradeTask)
    end

    upgradeTask = task.spawn(function()
        while autoUpgradeEnabled do
            if gameRunning then
                local success, errMsg = pcall(function()
                    if upgradeMethod == "Left to right until max" then
                        leftToRightUpgrade()
                    elseif upgradeMethod == "randomize" then
                        print("🔄 Randomize method not implemented yet")
                    elseif upgradeMethod == "lowest level spread upgrade" then
                        print("🔄 Lowest level spread method not implemented yet")
                    end
                end)

                if not success then
                    warn("❌ Auto upgrade error:", errMsg)
                end
            else
                print("⏳ Waiting for game to start...")
            end

            task.wait(0.5)
        end
    end)
end

local function stopAutoUpgrade()
    if upgradeTask then
        task.cancel(upgradeTask)
        upgradeTask = nil
    end
end

local function resetUpgradeOrder()
    currentUpgradeSlot = 1
    print("🔄 Reset upgrade order to slot 1")
end

local function getUnitsWithUltimates()
    local unitsWithUltimates = {}
    local success, result = pcall(function()
        local agentFolder = workspace:WaitForChild("Agent", 5)
        if not agentFolder then return end
        
        local unitFolder = agentFolder:WaitForChild("UnitT", 5)
        if not unitFolder then return end
        
        for _, part in pairs(unitFolder:GetChildren()) do
            if (part:IsA("BasePart") or part:IsA("Part")) then
                local infoFolder = part:FindFirstChild("Info")
                if infoFolder then
                    local activeAbility = infoFolder:FindFirstChild("ActiveAbility")
                    local targetObject = infoFolder:FindFirstChild("TargetObject")
                    if activeAbility and targetObject and activeAbility:IsA("StringValue") and targetObject:IsA("ObjectValue") then
                        if activeAbility.Value ~= "" and targetObject.Value then
                            table.insert(unitsWithUltimates, {
                                part = part,
                                abilityName = activeAbility.Value
                            })
                        end
                    end
                end
            end
        end
    end)
    
    if success then
        return unitsWithUltimates
    else
        warn("Error getting units with ultimates:", result)
        return {}
    end
end

local function fireUltimateForUnit(unitData)
    pcall(function()
        local args = { unitData.part }
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Ultimate"):FireServer(unpack(args))
    end)
end

local function autoUltimateLoop()
    if isInLobby() then return end
    
    while AutoUltimateEnabled do
        local unitsWithUltimates = getUnitsWithUltimates()
        
        if #unitsWithUltimates > 0 then
            for _, unitData in pairs(unitsWithUltimates) do
                if not AutoUltimateEnabled then break end
                fireUltimateForUnit(unitData)
                task.wait(0.1)
            end
        end
        
        task.wait(1)
    end
end


local function updateOverheadText()
    pcall(function()
        local head = player.Character:WaitForChild("Head", 5)
        local billboard = head and head:FindFirstChild("PlayerHeadGui")
        if billboard then
            local textLabel = billboard:FindFirstChild("PlayerName")
            if textLabel then
                textLabel.Text = "🔥 Protected By LixHub 🔥"
            end
        end
    end)
end

player.CharacterAdded:Connect(updateOverheadText)

if player.Character then
    updateOverheadText()
end

if not storedChallengeSerial then
    storedChallengeSerial = getCurrentChallengeSerial()
end

task.spawn(function()
    while true do
        task.wait(5)
        
        -- Only check if we're in a challenge and the feature is enabled
        if challengeAutoReturnEnabled and not isInLobby() then
            local currentSerial = getCurrentChallengeSerial()
            
            if currentSerial and storedChallengeSerial and currentSerial ~= storedChallengeSerial then
                --print("🔄 New Challenge Detected! Serial changed from", storedChallengeSerial, "to", currentSerial)
                notify("Challenge Update", "New challenge detected - will return to lobby when game ends")
                
                -- Set flag to return to lobby when game ends
                pendingChallengeReturn = true
                
                -- Update stored serial
                storedChallengeSerial = currentSerial
            elseif currentSerial and not storedChallengeSerial then
                -- First time detecting a serial
                storedChallengeSerial = currentSerial
                --print("🆕 First challenge serial detected:", currentSerial)
            end
        elseif isInLobby() then
            -- Reset when we're back in lobby
            pendingChallengeReturn = false
            -- Update serial for next challenge
            storedChallengeSerial = getCurrentChallengeSerial()
        end
    end
end)

-- Monitor boss ticket resets
task.spawn(function()
    while true do
        task.wait(5)
        
        if autoReturnBossTicketResetEnabled then
            local currentTickets = getBossAttackTickets()
            local currentResetTime = getBossTicketResetTime()
            
            -- Detect ticket reset (either tickets increased or reset time changed)
            if currentTickets > lastBossTicketCount or currentResetTime ~= lastBossTicketResetTime then
                if lastBossTicketCount == 0 and currentTickets > 0 then
                    print("🎫 Boss Attack tickets reset detected! Tickets:", currentTickets)
                    notify("Boss Tickets", string.format("Tickets reset! Now have %d tickets", currentTickets))
                    pendingBossTicketReturn = true
                end
            end
            
            lastBossTicketCount = currentTickets
            lastBossTicketResetTime = currentResetTime
        end
    end
end)

-- Initialize data on startup
task.spawn(function()
    print("🔄 Fetching story data...")
    availableStories = fetchStoryData()
    
    print("🔄 Fetching ranger stage data...")
    availableRangerStages = fetchRangerStageData(availableStories)
    
    print("✅ Data fetching complete!")
   -- print("📚 Found", #availableStories, "stories")
    --print("🏟️ Found", #availableRangerStages, "ranger stages")
end)

-- ========== Main Priority Loop ==========
task.spawn(function()
    while true do
        task.wait(0.5) -- Check every 0.5 seconds
        checkAndExecuteHighestPriority()
    end
end)



local LogTab = Window:CreateTab("Update Log", "scroll") -- Title, Image

local LogTabSection = LogTab:CreateSection("01/07/2025")

local LogTabDivider = LogTab:CreateDivider()

local Label = LogTab:CreateLabel("+Fixed Bugs, +Auto Ultimate [autoplay], +UI overhaul") -- Title, Icon, Color, IgnoreTheme

local LobbyTab = Window:CreateTab("Lobby", "tv") -- Title, Image

local Button = LobbyTab:CreateButton({
    Name = "Return to lobby",
    Callback = function()
        notify("Return to lobby", "Returning to lobby!")
         TeleportService:Teleport(72829404259339, player)
    end,
})

task.spawn(function()
    while true do
        task.wait(2)
        if autoAfkTeleportEnabled and isInLobby() and AFKChamberUI.Enabled == false then
            print("🚀 Teleporting to AFK world...")
           game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("AFKWorldTeleport"):FireServer()
        end
    end
end)

local MerchantSection = LobbyTab:CreateSection("Auto Merchant")

local MerchantDivider = LobbyTab:CreateDivider()

local Toggle = LobbyTab:CreateToggle({
   Name = "Auto Purchase Merchant Items",
   CurrentValue = false,
   Flag = "AutoPurchaseMerchant",
   Callback = function(Value)
       AutoPurchaseMerchant = Value
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
       MerchantPurchaseTable = Options
   end,
})

task.spawn(function()
    while true do
        if AutoPurchaseMerchant and #MerchantPurchaseTable > 0 and isInLobby() then
            autoPurchaseItems()
        end
        task.wait(1)
    end
end)

local ClaimerSection = LobbyTab:CreateSection("Auto Claimer")

local ClaimerDivider = LobbyTab:CreateDivider()

local Toggle = LobbyTab:CreateToggle({
   Name = "Auto Claim Battlepass",
   CurrentValue = false,
   Flag = "AutoClaimBattlepass",
   Callback = function(Value)
        autoClaimBP = Value
   end,
})

local Toggle = LobbyTab:CreateToggle({
   Name = "Auto Claim Quests",
   CurrentValue = false,
   Flag = "AutoClaimQuests",
   Callback = function(Value)
        AutoClaimQuests = Value
   end,
})

local Toggle = LobbyTab:CreateToggle({
   Name = "Auto Claim Level Milestones",
   CurrentValue = false,
   Flag = "AutoClaimMilestones",
   Callback = function(Value)
        AutoClaimMilestones = Value
   end,
})

task.spawn(function()
    while true do
        task.wait(3)
        if isInLobby() then
        if autoClaimBP then
        local args = {"Claim All"}
        ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events"):WaitForChild("ClaimBp"):FireServer(unpack(args))
        end
        if AutoClaimQuests then
        local args = {"ClaimAll"}
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("QuestEvent"):FireServer(unpack(args))
        end
        if AutoClaimMilestones then
        local playerlevel = ReplicatedStorage.Player_Data[player.Name].Data.Level.Value
        local args = {tonumber(playerlevel)}
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("LevelMilestone"):FireServer(unpack(args))
            end
        end
    end
end)

local OtherSection = LobbyTab:CreateSection("Other")

local OtherDivider = LobbyTab:CreateDivider()

local Button = LobbyTab:CreateButton({
    Name = "Redeem all valid codes",
    Callback = function()
        for _, code in ipairs(codes) do
            notify("Redeeming code: ", code, 2.5)
            CodeRemote:FireServer(code)
            task.wait(0.25) -- small delay so server doesn't get flooded
        end
         notify("Redeem all valid codes", "Tried to redeem all codes!")
    end,
})

Toggle = LobbyTab:CreateToggle({
    Name = "Auto AFK Teleport",
    CurrentValue = false,
    Flag = "AutoAfkTeleportToggle",
    Callback = function(Value)
        autoAfkTeleportEnabled = Value
        if autoAfkTeleportEnabled then
            print("🟢 Auto AFK teleport enabled")
        else
            print("🔴 Auto AFK teleport disabled")
        end
    end,
})

local StatsTabSection1 = LobbyTab:CreateSection("Stats")

local StatsTabDivider1 = LobbyTab:CreateDivider()



local JoinerTab = Window:CreateTab("Joiner", "plug-zap") -- Title, Image

local JoinerTabSection1 = JoinerTab:CreateSection("Story Joiner")

local JoinerTabDivider1 = JoinerTab:CreateDivider()

local AutoJoinStoryToggle = JoinerTab:CreateToggle({
   Name = "Auto Join Story",
   CurrentValue = false,
   Flag = "AutoStoryToggle",
   Callback = function(Value)
   autoJoinEnabled = Value
   if autoJoinEnabled then
       print("▶️ [Priority System] Story auto joining enabled...")
   else
       print("🛑 [Priority System] Story auto joining disabled.")
   end
   end,
})

local StageDropdown = JoinerTab:CreateDropdown({
   Name = "Story Stage",
   Options = {},
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "StoryStageSelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
    selectedWorld = Option[1]

   end,
})

    task.spawn(function()
    while #availableStories == 0 do
        task.wait(0.5)
    end
    
    local storyNames = {}
    for _, story in ipairs(availableStories) do
        table.insert(storyNames, story.SeriesName)
    end
    
    StageDropdown:Refresh(storyNames, true)
    print("✅ Story dropdown updated with", #storyNames, "options")
end)

--[[-- Update story dropdown when data is available
task.spawn(function()
    while #availableStories == 0 do
        task.wait(0.5)
    end
    
    local storyNames = {}
    for _, story in ipairs(availableStories) do
        table.insert(storyNames, story.SeriesName)
    end
    
    StageDropdown:Refresh(storyNames, true)
    print("✅ Story dropdown updated with", #storyNames, "options")
end)--]]

local ChapterDropdown = JoinerTab:CreateDropdown({
   Name = "Stage Chapter",
   Options = chapters,
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "StoryChapterSelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
     selectedChapter = Option[1]

   end,
})
local DifficultyDropdown = JoinerTab:CreateDropdown({
   Name = "Stage Difficulty",
   Options = difficulties,
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "StoryDifficultySelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
    selectedDifficulty = Option[1]

end,
})

local JoinerTabSection2 = JoinerTab:CreateSection("Challenge Joiner")

local JoinerTabDivider2 = JoinerTab:CreateDivider()

local Toggle = JoinerTab:CreateToggle({
   Name = "Challenge Joiner",
   CurrentValue = false,
   Flag = "AutoChallengeToggle",
   Callback = function(Value)
    autoChallengeEnabled = Value
    if autoChallengeEnabled then
        print("▶️ [Priority System] Challenge auto joining enabled...")
    else
        print("🛑 [Priority System] Challenge auto joining disabled.")
    end
   end,
})

local ChallengeDropdown = JoinerTab:CreateDropdown({
   Name = "Select Challenge Rewards",
   Options = {"Dr. Megga Punk","Ranger Crystal","Stats Key","Perfect Stats Key","Trait Reroll","Cursed Finger"},
   CurrentOption = {},
   MultipleOptions = true, -- Changed back to true for multiple selection
   Flag = "ChallengeRewardSelector",
   Callback = function(options)
      wantedRewards = options or {}
      if #wantedRewards > 0 then
          print("🔎 Target rewards set to:", table.concat(wantedRewards, ", "))
      else
          print("🔎 No challenge rewards selected")
      end
   end,
})

local Toggle = JoinerTab:CreateToggle({
    Name = "Return to Lobby on New Challenge",
    CurrentValue = false,
    Flag = "AutoReturnChallengeToggle",
    Callback = function(Value)
        challengeAutoReturnEnabled = Value
        if Value then
            print("🟢 Auto Return to Lobby on New Challenge ENABLED")
        else
            print("🔴 Auto Return to Lobby on New Challenge DISABLED")
        end
    end,
})


local JoinerTabSection3 = JoinerTab:CreateSection("Portal Joiner")

local JoinerTabDivider3 = JoinerTab:CreateDivider()

local Toggle = JoinerTab:CreateToggle({
   Name = "Portal Joiner",
   CurrentValue = false,
   Flag = "AutoPortalToggle",
   Callback = function(Value)
    autoPortalEnabled = Value
    if autoPortalEnabled then
        print("▶️ [Priority System] Portal auto joining enabled...")
        portalUsed = false -- Reset portal usage when enabled
    else
        print("🛑 [Priority System] Portal auto joining disabled.")
    end
   end,
})

local JoinerTabSection4 = JoinerTab:CreateSection("Ranger Stage Joiner")

local JoinerTabDivider4 = JoinerTab:CreateDivider()

local Toggle = JoinerTab:CreateToggle({
    Name = "Auto Join Ranger Stage",
    CurrentValue = false,
    Flag = "AutoRangerStageToggle",
    Callback = function(Value)
        isAutoJoining = Value
        
        if isAutoJoining then
            print("▶️ [Priority System] Ranger Stage auto joining enabled...")
            print("🔍 Selected stages:", selectedRawStages and table.concat(selectedRawStages, ", ") or "none")
            if not selectedRawStages or #selectedRawStages == 0 then
                warn("⚠️ No stages selected! Please select at least one Ranger stage.")
                return
            end
        else
            print("🛑 [Priority System] Ranger Stage auto joining disabled.")
        end
    end,
})

local RangerStageDropdown = JoinerTab:CreateDropdown({
   Name = "Select Ranger Stages To Join",
   Options = {},
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "RangerStageSelector",
   Callback = function(Options)
      selectedRawStages = {} -- Clear the array first
      
      for _, selectedDisplay in ipairs(Options) do
         for _, stage in ipairs(availableRangerStages) do
            if stage.DisplayName == selectedDisplay then
               table.insert(selectedRawStages, stage.RawName)
               break
            end
         end
      end

      if #selectedRawStages == 0 then
         print("⚠️ No Ranger stages selected")
      else
         print("✅ Selected raw stage(s):", table.concat(selectedRawStages, ", "))
      end
   end
})

-- Update ranger stage dropdown when data is available
task.spawn(function()
    while #availableRangerStages == 0 do
        task.wait(0.5)
    end
    
    local rangerDisplayNames = {}
    for _, stage in ipairs(availableRangerStages) do
        table.insert(rangerDisplayNames, stage.DisplayName)
    end
    
    RangerStageDropdown:Refresh(rangerDisplayNames, true)
    print("✅ Ranger stage dropdown updated with", #rangerDisplayNames, "options")
end)

local BossAttackSection = JoinerTab:CreateSection("Boss Attack")

local BossAttackTabDivider = JoinerTab:CreateDivider()

local Toggle = JoinerTab:CreateToggle({
   Name = "Auto join boss attack",
   CurrentValue = false,
   Flag = "AutoJoinBossAttack",
   Callback = function(Value)
       autoBossAttackEnabled = Value
       if autoBossAttackEnabled then
           print("🏆 [Priority System] Boss Attack auto joining enabled...")
           -- Initialize ticket tracking
           lastBossTicketCount = getBossAttackTickets()
           lastBossTicketResetTime = getBossTicketResetTime()
           print("🎫 Current boss attack tickets:", lastBossTicketCount)
       else
           print("🛑 [Priority System] Boss Attack auto joining disabled.")
       end
   end,
})

local Label = JoinerTab:CreateLabel("Boss Tickets: "..ReplicatedStorage.Player_Data[player.Name].Data.BossAttackTicket.Value, "ticket") -- Title, Icon, Color, IgnoreTheme

local Toggle = JoinerTab:CreateToggle({
   Name = "Return to Lobby When Boss Attack Tickets Reset",
   CurrentValue = false,
   Flag = "AutoReturnBossAttackToggle",
   Callback = function(Value)
      autoReturnBossTicketResetEnabled = Value
      if autoReturnBossTicketResetEnabled then
          print("🟢 Auto Return to Lobby on Boss Ticket Reset ENABLED")
          -- Initialize tracking when enabled
          lastBossTicketCount = getBossAttackTickets()
          lastBossTicketResetTime = getBossTicketResetTime()
      else
          print("🔴 Auto Return to Lobby on Boss Ticket Reset DISABLED")
      end
   end,
})

local InfinityCastleSection = JoinerTab:CreateSection("Infinity Castle")

local InfinityCastleDivider = JoinerTab:CreateDivider()

local Toggle = JoinerTab:CreateToggle({
   Name = "Auto Infinity Castle",
   CurrentValue = false,
   Flag = "AutoInfinityCastle",
   Callback = function(Value)
      autoInfinityCastleEnabled = Value
      
      if autoInfinityCastleEnabled then
          print("▶️ Auto Infinity Castle enabled - Starting path optimization...")
          notify("Infinity Castle", "Auto path switching enabled!")
          startInfinityCastleLogic()
      else
          print("🛑 Auto Infinity Castle disabled.")
          notify("Infinity Castle", "Auto path switching disabled!")
          stopInfinityCastleLogic()
      end
   end,
})
local Label = JoinerTab:CreateLabel("Infinity Castle Floor: ", "badge-info") -- Title, Icon, Color, IgnoreTheme

local Label = JoinerTab:CreateLabel("You need decently good units for infinity castle to win. Don't use any other auto joiners if you're enabling this and don't panic if it fails sometimes (unless your units are not good enough).", "badge-info") -- Title, Icon, Color, IgnoreTheme

local RaidTab = Window:CreateTab("Raids", "swords") -- Title, Image

local Toggle = RaidTab:CreateToggle({
   Name = "Auto Join Selected Raid(s)",
   CurrentValue = false,
   Flag = "AutoJoinRaid",
   Callback = function(Value)

   end,
})

local RaidStageDropdown = RaidTab:CreateDropdown({
   Name = "Select Raid Stages To Join",
   Options = {"1","2","3"},
   CurrentOption = {},
   MultipleOptions = true,
   Flag = "RaidStageSelector",
   Callback = function(Options)

   end,
})

local Toggle = RaidTab:CreateToggle({
   Name = "Auto Return To Lobby When Raid Cooldown Expires",
   CurrentValue = false,
   Flag = "AutoReturnRaidCD",
   Callback = function(Value)

   end,
})

local Toggle = RaidTab:CreateToggle({
   Name = "Auto Purchase Raid Shop",
   CurrentValue = false,
   Flag = "AutoPurchaseRaidShop",
   Callback = function(Value)

   end,
})

local RaidShopSelectorDropdown = RaidTab:CreateDropdown({
   Name = "Select Items To Purchase",
   Options = {"ticket","reroll","jojo-token"},
   CurrentOption = {},
   MultipleOptions = true,
   Flag = "RaidShopPurchaseSelector",
   Callback = function(Options)
     
   end,
})

local GameTab = Window:CreateTab("Game", "gamepad-2") -- Title, Image

local Toggle = GameTab:CreateToggle({
   Name = "Auto Start",
   CurrentValue = false,
   Flag = "AutoStartToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        autoStartEnabled = Value
   end,
})

task.spawn(function()
    while true do
        task.wait(1)

        if autoStartEnabled then
            local voteVisible = false

            pcall(function()
                voteVisible = player:WaitForChild("PlayerGui")
                    :WaitForChild("HUD")
                    :WaitForChild("InGame")
                    :WaitForChild("VotePlaying").Visible
            end)

            if voteVisible then
                print("✅ Vote screen is visible — sending start signal...")
                StartGameRemote:FireServer()
                task.wait(3) -- optional cooldown between fires
            end
        end
    end
end)

local Toggle = GameTab:CreateToggle({
   Name = "Auto Next",
   CurrentValue = false,
   Flag = "AutoNextToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      autoNextEnabled = Value
      if hasGameEnded and autoNextEnabled then
        game:GetService("ReplicatedStorage"):WaitForChild("Remote")
             :WaitForChild("Server")
             :WaitForChild("OnGame")
             :WaitForChild("Voting")
             :WaitForChild("VoteNext"):FireServer()
      end
   end,
})

task.spawn(function()
    while true do
        task.wait(1)
                if autoNextEnabled and hasGameEnded then
                 game:GetService("ReplicatedStorage"):WaitForChild("Remote")
             :WaitForChild("Server")
             :WaitForChild("OnGame")
             :WaitForChild("Voting")
             :WaitForChild("VoteNext"):FireServer()
        end
    end
end)

local Toggle = GameTab:CreateToggle({
   Name = "Auto Retry",
   CurrentValue = false,
   Flag = "AutoRetryToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      autoRetryEnabled = Value
   end,
})

task.spawn(function()
    while true do
        task.wait(1)
                if autoRetryEnabled then
                if hasGameEnded then
                 game:GetService("ReplicatedStorage")
                :WaitForChild("Remote")
                :WaitForChild("Server")
                :WaitForChild("OnGame")
                :WaitForChild("Voting")
                :WaitForChild("VoteRetry"):FireServer()
            end
        end
    end
end)

local Toggle = GameTab:CreateToggle({
   Name = "Auto Lobby",
   CurrentValue = false,
   Flag = "AutoLobbyToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      autoReturnEnabled = Value
      if hasGameEnded and autoReturnEnabled then
        TeleportService:Teleport(72829404259339, player)
      end
   end,
})

local PerformanceSection = GameTab:CreateSection("Performance")

local PerformanceDivider = GameTab:CreateDivider()

local Button = GameTab:CreateButton({
    Name = "Low Performance Mode (Rejoin To Disable)",
    Callback = function()
        enableLowPerformanceMode()
    end,
})

local AutoPlayTab = Window:CreateTab("AutoPlay", "joystick") -- Title, Image

local Toggle = AutoPlayTab:CreateToggle({
   Name = "Auto Upgrade",
   CurrentValue = false,
   Flag = "AutoUpgradeToggle",
   Callback = function(Value)
       autoUpgradeEnabled = Value
       if autoUpgradeEnabled then
           print("▶️ Auto Upgrade enabled")
           gameRunning = true
           resetUpgradeOrder() -- Always reset to slot 1 when enabling 
           startAutoUpgrade()
       else
           print("🛑 Auto Upgrade disabled")
           notify("Auto Upgrade", "Stopped")
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
       upgradeMethod = Options[1] or "Left to right until max"
       if autoUpgradeEnabled then
           stopAutoUpgrade()
           resetUpgradeOrder() -- Reset when changing method
           gameRunning = true
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
       unitLevelCaps[1] = Value
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
       unitLevelCaps[2] = Value
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
       unitLevelCaps[3] = Value
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
       unitLevelCaps[4] = Value
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
       unitLevelCaps[5] = Value
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
       unitLevelCaps[6] = Value
   end,
})

local Toggle = AutoPlayTab:CreateToggle({
   Name = "Auto Ultimate",
   CurrentValue = false,
   Flag = "AutoUltimate", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      AutoUltimateEnabled = Value
   end,
})

spawn(function()
   while true do
      if AutoUltimateEnabled then
         autoUltimateLoop()
      end
      wait(0.5) -- Check every 0.5 seconds if we should start
   end
end)

local WebhookTab = Window:CreateTab("Webhook", "bluetooth") -- Title, Image

local WebhookLabel = WebhookTab:CreateLabel("Awaiting Webhook Input...", "cable")

local Input = WebhookTab:CreateInput({
   Name = "Input Webhook",
   CurrentValue = "",
   PlaceholderText = "Input Webhook...",
   RemoveTextAfterFocusLost = false,
   Flag = "WebhookInput",
   Callback = function(Text)
      if string.find(Text, "https://discord.com/api/webhooks/") then
         ValidWebhook = Text
         WebhookLabel:Set("✅ Webhook URL set!")
      elseif Text == "" then
         WebhookLabel:Set("Awaiting Webhook Input...")
         ValidWebhook = nil
      else
         ValidWebhook = nil
         WebhookLabel:Set("❌ Invalid Webhook URL")
      end
   end,
})

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
local lastResultTick = 0
local stageStartTime = nil
local GameStartRemote = game.ReplicatedStorage.Remote.Replicate

-- Stage start
GameStartRemote.OnClientEvent:Connect(function(...)
	local args = {...}
	if table.find(args, "Game_Start") then
          gameRunning = true
    resetUpgradeOrder() -- Reset to slot 1 every time a new game starts
    
    if autoUpgradeEnabled then
        notify("Game Started", "Auto upgrade restarted!")
    end

        hasSentWebhook = false
        hasGameEnded = false
		stageStartTime = tick()
		print("🟢 Stage started at", stageStartTime)
	end
end)

local gameEndedUI = game.ReplicatedStorage.Remote.Client.UI.GameEndedUI

gameEndedUI.OnClientEvent:Connect(function(_, outcome)
    if typeof(outcome) == "string" then
        local l = outcome:lower()
        if l:find("defeat") then
            matchResult = "Defeat"
        elseif l:find("won") or l:find("win") then
            matchResult = "Victory"
        else
            matchResult = "Unknown"
        end
        lastResultTick = tick()
        print("🎯 Match result detected:", matchResult)
    end
end)

GameEndRemote.OnClientEvent:Connect(function()
    if hasSentWebhook == true then
        print("⏳ Webhook still on cooldown…")
        return
    end
    
    gameRunning = false
    resetUpgradeOrder()
    hasSentWebhook = true
    -- Wait a bit longer for both remote events and folder updates
    task.wait(0.25)
    
    -- Clean up UI elements
    if player.PlayerGui:FindFirstChild("GameEndedAnimationUI") then
        player.PlayerGui:FindFirstChild("GameEndedAnimationUI"):Destroy()
    end
    if player.PlayerGui:FindFirstChild("RewardsUI").Enabled == true then
        player.PlayerGui:FindFirstChild("RewardsUI").Enabled = false
    end
    if player.PlayerGui:FindFirstChild("Visual") then
        player.PlayerGui:FindFirstChild("Visual"):Destroy()
    end
    if player:FindFirstChild("SavedToTeleport") then
        player:FindFirstChild("SavedToTeleport"):Destroy()
    end
    for _, child in pairs(ReplicatedStorage.Player_Data[player.Name].RangerStage:GetChildren()) do
        child:Destroy()
    end

    local clearTimeStr = "Unknown"
    if stageStartTime then
        local dt = math.floor(tick() - stageStartTime)
        clearTimeStr = string.format("%d:%02d", dt // 60, dt % 60)
    end

    if tick() - lastResultTick > 3 then
        matchResult = "Unknown"
    end

    -- Send webhook with enhanced tracking
    sendWebhook("stage", nil, clearTimeStr, matchResult)
    notify("✅ Webhook", "Stage completed and sent to Discord (Enhanced Tracking).")

    -- Rest of your auto-action logic remains the same...
    if pendingBossTicketReturn then
        print("🎫 Boss Attack tickets are available - returning to lobby")
        notify("Boss Tickets", "Tickets available - returning to lobby")
        pendingBossTicketReturn = false
        task.delay(2, function()
            TeleportService:Teleport(72829404259339, player)
        end)
        return
    end

    if pendingChallengeReturn then
        print("🏠 Challenge changed - returning to lobby instead of retry/next")
        notify("Challenge Return", "New challenge detected - returning to lobby")
        pendingChallengeReturn = false
        task.delay(2, function()
            TeleportService:Teleport(72829404259339, player)
        end)
        return
    end

    if autoRetryEnabled then
        print("🔁 Auto-retrying stage...")
        task.delay(2, function()
            game:GetService("ReplicatedStorage")
                :WaitForChild("Remote")
                :WaitForChild("Server")
                :WaitForChild("OnGame")
                :WaitForChild("Voting")
                :WaitForChild("VoteRetry"):FireServer()
        end)
    end

    if autoReturnEnabled then
        print("🏠 Auto returning to lobby by teleporting...")
        task.delay(2, function()
            TeleportService:Teleport(72829404259339, player)
        end)
    end

    if autoNextEnabled then
        print("🏠 Auto starting next stage")
        task.delay(2, function()
             game:GetService("ReplicatedStorage"):WaitForChild("Remote")
             :WaitForChild("Server")
             :WaitForChild("OnGame")
             :WaitForChild("Voting")
             :WaitForChild("VoteNext"):FireServer()
        end)
    end
     hasGameEnded = true
end)

Rayfield:LoadConfiguration()
