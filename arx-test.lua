local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "LixHub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Loading for "..game.Name,
   LoadingSubtitle = "by Lix",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = "LixHub", -- Create a custom folder for your hub/game
      FileName = tostring(game.Name)
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
      Note = "coming soon...", -- Use this to tell the user how to get a key
      FileName = "LixHubSavedKey", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"1"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local ValidWebhook
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEndRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("GameEndedUI")
local CodeRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("Code")
local StartGameRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VotePlaying")
--local codeUrl = "https://raw.githubusercontent.com/BloxBanter/LixHub/refs/heads/main/arx-codelist" -- Replace this
 local PlayEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")
 local chapterContainer = player:WaitForChild("PlayerGui")
    :WaitForChild("PlayRoom")
    :WaitForChild("Main")
    :WaitForChild("GameStage")
    :WaitForChild("Main")
    :WaitForChild("Base")
    :WaitForChild("Chapter")
local selectedRawStages

-- ========== Value Holders ==========
local autoJoinEnabled 
local joiningInProgress = false
local hasSentWebhook = false
local matchResult = "Unknown"
local autoStartEnabled
local autoRetryEnabled
local autoReturnEnabled
local autoNextEnabled
local autoChallengeEnabled
local wantedReward
local autoPortalEnabled
local portalUsed = false
local isAutoJoining
local chapters = {"Chapter 1", "Chapter 2", "Chapter 3", "Chapter 4", "Chapter 5", "Chapter 6", "Chapter 7", "Chapter 8", "Chapter 9", "Chapter 10"}
local difficulties = {"Normal", "Hard", "Nightmare"}
local selectedWorld, selectedChapter, selectedDifficulty

local storyStages = {}
local rangerStages = {}

-- ========== Mapping Nice Names to Internal Remote Values ==========
local WorldMap = {
    ["Voocha Village"]   = "OnePiece",
    ["Green Planet"]     = "Namek",
    ["Demon Forest"]     = "DemonSlayer",
    ["Leaf Village"]     = "Naruto",
    ["Z City"]           = "OPM",
    ["Ghoul City"]       = "TokyoGhoul",
    ["Night Colosseum"]  = "JojoPart1"
}

local OrderedWorlds = {
    "Voocha Village",
    "Green Planet",
    "Demon Forest",
    "Leaf Village",
    "Z City",
    "Ghoul City",
    "Night Colosseum"
}

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

        -- Build reward string
        local rewardsText = ""
        if RewardsFolder then
            for _, rewardFolder in ipairs(RewardsFolder:GetChildren()) do
                local amountValue = rewardFolder:FindFirstChildWhichIsA("NumberValue")
                if amountValue then
                    rewardsText = rewardsText .. string.format("+%s %s\n", tostring(amountValue.Value), rewardFolder.Name)
                end
            end
        else
            rewardsText = "No rewards found"
        end

        local stageResult = stageName .. " (" .. gameMode .. ")" .. " - " .. matchResult
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        data = {
            username = "LixHub Bot",
            embeds = {{
                title = "🎯 Stage Completed!",
                description = stageResult,
                color = 0x00FF7F,
                fields = {
                    {
                        name = "👤 Player",
                        value = player.Name,
                        inline = true
                    },
                    {
                        name = "⏱️ Clear Time",
                        value = clearTime,
                        inline = true
                    },
                    {
                        name = "🏆 Rewards",
                        value = rewardsText,
                        inline = false
                    },
                    {
                        name = "📈 Script Version",
                        value = "v1.0.0",
                        inline = true
                    }
                },
                footer = {
                    text = "discord.gg/lixhub"
                },
                timestamp = timestamp
            }}
        }

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

-- Tier sorting helper
local function getTierValue(name)
    if name:find("III") then return 3 end
    if name:find("II") then return 2 end
    if name:find("I") then return 1 end
    return 0
end

local function buildRewardsText()
    local rewardsRoot = player:FindFirstChild("RewardsShow")
    if not rewardsRoot then
        return "_No rewards found_"
    end

    local lines = {}

    for _, folder in ipairs(rewardsRoot:GetChildren()) do
        if folder:IsA("Folder") then
            for _, val in ipairs(folder:GetChildren()) do
                if val:IsA("ValueBase") then
                    local itemName = val.Name
                    local amount = tostring(val.Value)

                    -- Display with colon for standard stuff like XP/Gold, and × for items
                    if itemName:lower():match("exp") or itemName:lower():match("gold") then
                        table.insert(lines, string.format("• %s: %s", itemName, amount))
                    else
                        table.insert(lines, string.format("• %s ×%s", itemName, amount))
                    end
                end
            end
        end
    end

    if #lines == 0 then
        return "_No reward values found_"
    end

    return table.concat(lines, "\n")
end


local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function toInternalChapter(chapterName)
    -- Converts "Chapter 1" to "OnePiece_Chapter1", etc.
    if selectedWorld and chapterName then
        return WorldMap[selectedWorld] .. "_" .. chapterName:gsub(" ", "")
    end
end

-- Function to sort worlds based on OrderedWorlds
local function sortWorldsByOrder(worlds)
    local orderMap = {}
    for index, name in ipairs(OrderedWorlds) do
        orderMap[name] = index
    end
    table.sort(worlds, function(a, b)
        local aIndex = orderMap[a] or (#OrderedWorlds + 1)
        local bIndex = orderMap[b] or (#OrderedWorlds + 1)
        return aIndex < bIndex
    end)
    return worlds
end

-- ========== Main Auto Join Logic ==========
local function tryAutoJoin()
    if not autoJoinEnabled then return end
    if not (selectedWorld and selectedChapter and selectedDifficulty) then return end
    if not isInLobby() then return end
    if joiningInProgress then return end

    joiningInProgress = true

    local internalWorld = WorldMap[selectedWorld]
    local internalChapter = toInternalChapter(selectedChapter)

    if not internalWorld or not internalChapter then
        warn("[AutoJoin] Invalid selection.")
        joiningInProgress = false
        return
    end

    local function fire(args)
        PlayEvent:FireServer(unpack(args))
        task.wait(0.25)
    end

    fire({"Create"})
    fire({"Change-World",   {World = internalWorld}})
    fire({"Change-Chapter", {Chapter = internalChapter}})
    fire({"Change-Difficulty", {Difficulty = selectedDifficulty}})
    fire({"Submit"})
    fire({"Start"})

    print(("[AutoJoin] Joined: %s / %s / %s"):format(internalWorld, internalChapter, selectedDifficulty))

    joiningInProgress = false
end

local function autoJoinRangerStage(stageName)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local PlayRoomEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")

    -- 1. Create
    PlayRoomEvent:FireServer("Create")
    task.wait(0.3)

    -- 2. Change-Mode
    PlayRoomEvent:FireServer("Change-Mode", { Mode = "Ranger Stage" })
    task.wait(0.3)

    -- 3. Extract world from stage name (e.g., "Naruto_RangerStage2" → "Naruto")
    local world = stageName:match("^(.-)_RangerStage")
    if not world then
        warn("❌ Couldn't extract world from:", stageName)
        return
    end

    -- 4. Change-World
    PlayRoomEvent:FireServer("Change-World", { World = world })
    task.wait(0.3)

    -- 5. Change-Chapter
    PlayRoomEvent:FireServer("Change-Chapter", { Chapter = stageName })
    task.wait(0.3)

    -- 6. Submit
    PlayRoomEvent:FireServer("Submit")
    task.wait(0.3)

    -- 7. Start
    PlayRoomEvent:FireServer("Start")
end


local ReverseWorldMap = {}
for fullName, shortCode in pairs(WorldMap) do
    ReverseWorldMap[shortCode] = fullName
end

-- Prepare display names only for dropdown

local displayOptions = {}
for _, stage in ipairs(rangerStages) do
    table.insert(displayOptions, stage.DisplayName)
end

local WorldOrderIndex = {}
for i, name in ipairs(OrderedWorlds) do
    WorldOrderIndex[name] = i
end

--//

-- Gather ranger stages
for _, worldFrame in ipairs(chapterContainer:GetChildren()) do
    if worldFrame:IsA("ScrollingFrame") and ReverseWorldMap[worldFrame.Name] then
        local fullWorldName = ReverseWorldMap[worldFrame.Name]
        for _, stageButton in ipairs(worldFrame:GetChildren()) do
            if stageButton:IsA("TextButton") and stageButton.Name:find("RangerStage") then
                local stageNum = tonumber(stageButton.Name:match("RangerStage(%d+)"))
                if stageNum then
                    table.insert(rangerStages, {
                        RawName = stageButton.Name,
                        DisplayName = fullWorldName .. " - " .. stageNum,
                        SortWorld = fullWorldName,
                        SortStage = stageNum
                    })
                end
            end
        end
    end
end

-- Sort alphabetically by world, then numerically by stage
table.sort(rangerStages, function(a, b)
    local worldA = WorldOrderIndex[a.SortWorld] or 999
    local worldB = WorldOrderIndex[b.SortWorld] or 999

    if worldA == worldB then
        return a.SortStage < b.SortStage
    else
        return worldA < worldB
    end
end)

-- Build display options
for _, stage in ipairs(rangerStages) do
    table.insert(displayOptions, stage.DisplayName)
end

local worlds = {}

for _, worldFrame in ipairs(chapterContainer:GetChildren()) do
    if worldFrame:IsA("ScrollingFrame") and ReverseWorldMap[worldFrame.Name] then
        local friendlyWorldName = ReverseWorldMap[worldFrame.Name]
        table.insert(worlds, friendlyWorldName)
    end
end

local LobbyTab = Window:CreateTab("Lobby", "tv") -- Title, Image

local codes = {
    "Instant Trait",
    "NewLobby",
    "JoJo Part 1",
    "HBDTanny",
}

local Button = LobbyTab:CreateButton({
    Name = "Redeem all valid codes",
    Callback = function()
        for _, code in ipairs(codes) do
            print("Redeeming code:", code)
            CodeRemote:FireServer(code)
            task.wait(0.25) -- small delay so server doesn't get flooded
        end
    end,
})

local JoinerTab = Window:CreateTab("Joiner", "plug-zap") -- Title, Image

local JoinerTabSection1 = JoinerTab:CreateSection("Story Joiner")

local JoinerTabDivider1 = JoinerTab:CreateDivider()

local AutoJoinStoryToggle = JoinerTab:CreateToggle({
   Name = "Auto Join Story",
   CurrentValue = false,
   Flag = "AutoStoryToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   autoJoinEnabled = Value
        tryAutoJoin()
   end,
})

local StageDropdown = JoinerTab:CreateDropdown({
   Name = "Story Stage",
   Options = worlds,
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "StoryStageSelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
    selectedWorld = Option[1]
        tryAutoJoin()
   end,
})
local ChapterDropdown = JoinerTab:CreateDropdown({
   Name = "Stage Chapter",
   Options = chapters,
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "StoryChapterSelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
     selectedChapter = Option[1]
        tryAutoJoin()
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
    tryAutoJoin()
end,
})

local JoinerTabSection2 = JoinerTab:CreateSection("Challenge Joiner")

local JoinerTabDivider2 = JoinerTab:CreateDivider()

local Toggle = JoinerTab:CreateToggle({
   Name = "Challenge Joiner",
   CurrentValue = false,
   Flag = "AutoChallengeToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    autoChallengeEnabled = Value
   end,
})
local ChallengeDropdown = JoinerTab:CreateDropdown({
   Name = "Select Challenge Rewards",
   Options = {"Dr. Megga Punk","Ranger Crystal","Stats Key","Perfect Stats Key","Trait Reroll","Cursed Finger"},
   CurrentOption = {},
   MultipleOptions = true,
   Flag = "ChallengeRewardSelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(option)
    wantedReward = option[1] ~= "Select" and option[1] or nil
        print("🔎 Target reward set to:", wantedReward)
   end,
})

task.spawn(function()
    while true do
        task.wait(2)
        if autoChallengeEnabled and wantedReward then
        if not isInLobby() then return end
            local ok, found = pcall(function()
                local itemList = player:WaitForChild("PlayerGui")
                    :WaitForChild("Visual")
                    :WaitForChild("Challenge_Display")
                    :WaitForChild("Background")
                    :WaitForChild("Rewards")
                    :WaitForChild("ItemsList")

                for _, btn in ipairs(itemList:GetChildren()) do
                    if btn:IsA("GuiButton") and btn.Name == wantedReward then
                        return true
                    end
                end
                return false
            end)

            if ok and found then
                print("🎯 Wanted reward present → creating challenge room")
                PlayEvent:FireServer("Create", {CreateChallengeRoom = true})
                PlayEvent:FireServer("Start")
            end
        end
    end
end)


local JoinerTabSection3 = JoinerTab:CreateSection("Portal Joiner")

local JoinerTabDivider3 = JoinerTab:CreateDivider()

local Toggle = JoinerTab:CreateToggle({
   Name = "Portal Joiner",
   CurrentValue = false,
   Flag = "AutoPortalToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
    autoPortalEnabled = Value
   end,
})

task.spawn(function()
    while true do
        task.wait(3)
        if autoPortalEnabled and not portalUsed then
             if  isInLobby() then
            local inventoryFrame = player:FindFirstChild("PlayerGui").Items.Main.Base.Space:FindFirstChild("Scrolling")
            if inventoryFrame then
                
                local bestPortalName = nil
                local bestTier = 0

                for _, item in ipairs(inventoryFrame:GetChildren()) do
                    if item.Name:lower():find("portal") then
                        local success, tier = pcall(getTierValue, item.Name)
                        if success and tier > bestTier then
                         bestTier = tier
                         bestPortalName = item.Name
                        end
                    end
                end

                if bestPortalName then
                    print("📦 Found portal:", bestPortalName)

                    local portalInstance = game:GetService("ReplicatedStorage").Player_Data[player.Name].Items:FindFirstChild(bestPortalName)

                    if portalInstance then
                        print("🚪 Using portal:", bestPortalName)
                        game:GetService("ReplicatedStorage").Remote.Server.Lobby.ItemUse:FireServer(portalInstance)
                        
                        -- Wait for portal to open
                        task.wait(1)

                        -- Start portal
                        print("▶️ Starting portal match...")
                        game:GetService("ReplicatedStorage").Remote.Server.Lobby.PortalEvent:FireServer("Start")
                        portalUsed = true -- ✅ prevent further uses
                         else
                print("⚠️ Portal instance not found in player data:", bestPortalName)
                    end
                    else
            print("ℹ️ No portals found in inventory.")
                end
            end
        end
        end
    end
end)

local JoinerTabSection4 = JoinerTab:CreateSection("Ranger Stage Joiner")

local JoinerTabDivider4 = JoinerTab:CreateDivider()

local Toggle = JoinerTab:CreateToggle({
    Name = "Auto Join Ranger Stage",
    CurrentValue = false,
    Flag = "AutoRangerStageToggle",
    Callback = function(Value)
        isAutoJoining = Value

        if isAutoJoining then
            if not selectedRawStages or #selectedRawStages == 0 then
                warn("⚠️ No stages selected! Please select at least one Ranger stage.")
                return
            end

            print("▶️ Auto joining enabled...")
            task.spawn(function()
                while isAutoJoining do
                    for _, stageName in ipairs(selectedRawStages) do
                        if not isAutoJoining then break end

                        print("🌍 Attempting to join:", stageName)
                        autoJoinRangerStage(stageName)

                        -- Wait to see if teleport occurs; if not, try the next stage after 3s
                        local startTime = tick()
                        while tick() - startTime < 3 do
                            if not isAutoJoining then break end
                            task.wait(0.1)
                        end
                    end

                    task.wait(1) -- Short loop delay before restarting
                end
                print("⏹️ Auto joining stopped.")
            end)
        else
            print("🛑 Auto joining disabled.")
        end
    end,
})

RangerStageDropdown = JoinerTab:CreateDropdown({
   Name = "Select Ranger Stages To Join",
   Options = displayOptions,
   CurrentOption = {},
   MultipleOptions = true,
   Flag = "RangerStageSelector",
   Callback = function(Options)
      selectedRawStages = {}
      for _, selectedDisplay in ipairs(Options) do
         for _, stage in ipairs(rangerStages) do
            if stage.DisplayName == selectedDisplay then
               table.insert(selectedRawStages, stage.RawName)
               break
            end
         end
      end

      if #selectedRawStages == 0 then
         warn("⚠️ No valid Ranger stages matched the selected options!")
      else
         print("✅ Selected raw stage(s):", table.concat(selectedRawStages, ", "))
      end
   end
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
   end,
})

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
   Name = "Auto Lobby",
   CurrentValue = false,
   Flag = "AutoLobbyToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      autoReturnEnabled = Value
   end,
})

local AutoPlayTab = Window:CreateTab("AutoPlay", "joystick") -- Title, Image

local Toggle = AutoPlayTab:CreateToggle({
   Name = "Auto Upgrade",
   CurrentValue = false,
   Flag = "AutoUpgradeToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   end,
})

local AutoUpgradeDropdown = AutoPlayTab:CreateDropdown({
   Name = "Select Upgrade Method",
   Options = {"Left to right until max","randomize","lowest level spread upgrade"},
   CurrentOption = {"Select"},
   MultipleOptions = false,
   Flag = "UpgradeMethodSelector", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
   end,
})

local Slider1 = AutoPlayTab:CreateSlider({
   Name = "Unit 1 Level cap",
   Range = {-2, 9},
   Increment = 1,
   Suffix = "Level",
   CurrentValue = 10,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
 
   end,
})

local Toggle = AutoPlayTab:CreateToggle({
   Name = "Auto Ultimate",
   CurrentValue = false,
   Flag = "AutoUltimateToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   end,
})

local WebhookTab = Window:CreateTab("Webhook", "bluetooth") -- Title, Image

WebhookLabel = WebhookTab:CreateLabel("Awaiting Webhook Input...", "cable")

Input = WebhookTab:CreateInput({
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
          Rayfield:Notify({
                Title = "Webhook Sent",
                Content = "Test message sent successfully!",
                Duration = 5,
                Image = 4483362458
            })
      else
          Rayfield:Notify({
                Title = "❌ Cannot send",
                Content = "invalid webhook!",
                Duration = 5,
                Image = 4483362458
            })
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
        hasSentWebhook = false
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

    hasSentWebhook = true

    -- 0.25 s to let rewards folder fill
    task.wait(0.25)

    -- ⏱️ clear‑time calculation
    local clearTimeStr = "Unknown"
    if stageStartTime then
        local dt = math.floor(tick() - stageStartTime)
        clearTimeStr = string.format("%d:%02d", dt // 60, dt % 60)
    end

    local rewardsText = buildRewardsText()

    -- Optional: if the UI never sent a result in the last 3 s, label it Unknown
    if tick() - lastResultTick > 3 then
        matchResult = "Unknown"
    end

    -- 📨 Send webhook
    sendWebhook("stage", rewardsText, clearTimeStr, matchResult)

    -- 🔁 Auto Retry
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

    -- 🔁 Auto Return
     if autoReturnEnabled then
        print("🏠 Auto returning to lobby by teleporting...")
        task.delay(2, function()
            TeleportService:Teleport(72829404259339, player)
        end)
    end

    -- 🔁 Auto Next
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
end)

Rayfield:LoadConfiguration()
