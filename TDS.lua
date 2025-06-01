local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local remoteFunction = game.ReplicatedStorage:WaitForChild("RemoteFunction")
local remoteEvent = game.ReplicatedStorage:WaitForChild("RemoteEvent")
local player = game.Players.LocalPlayer

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Gui = LocalPlayer:WaitForChild("PlayerGui")

local Runtime = 0
local ValidWebhook

local StageFinishedEnabled

local AutoSkipEnabled
local AutoRestartEnabled
local AutoLobbyEnabled
local AutoVoteMap
local AutoStartGame

local AutoJoinSurvival
local AutoJoinSpecial
local AutoJoinHardcore
local AutoMapOverride

local selectedMapOverride
local selectedDifficulty
local selectedSpecialMode

local pizzamacroenabled

local function sendWebhook(messageType, stageNumber)
    if not ValidWebhook then return end

    local minutes = math.floor(Runtime / 60)
    local seconds = Runtime % 60
    local runtimeformatted = string.format("%d minutes %d seconds", minutes, seconds)
    local data -- declare `data` outside the if-blocks

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

    elseif messageType == "stage" then
        data = {
            embeds = {{
                title = "📢 LixHub Notification",
                description = "**Game Finished**",
                color = 5814783,
                fields = {
                    {
                        name = "👤 Player",
                        value = "||" .. player.Name .. "||",
                        inline = true
                    },
                    {
                        name = "⏱️ Runtime",
                        value = runtimeformatted,
                        inline = true
                    },
                    {
                        name = "🗺️ Macro",
                        value = "Unknown",
                        inline = true
                    },
                    {
                        name = "📈 Script Version",
                        value = "v1.0.0",
                        inline = true
                    },
                    {
                        name = "🪙 Coins",
                        value = tostring(player.Coins.Value),
                        inline = true
                    },
                    {
                        name = "💎 Gems",
                        value = tostring(player.Gems.Value),
                        inline = true
                    }
                }
            }}
        }
    else
        -- If the messageType doesn't match anything
        return
    end

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

local Window = Rayfield:CreateWindow({
   Name = "LixHub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "LixHub - Loading",
   LoadingSubtitle = "by Lixtron",
   Theme = "Abyss", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LixHub", -- Create a custom folder for your hub/game
      FileName = "config"
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
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("Main", 4483362458) -- Title, Image

local RuntimeLabel = MainTab:CreateLabel("Script Runtime: 0s", "circle-play") -- Title, Icon, Color, IgnoreTheme

local MapOverriderDropdown = MainTab:CreateDropdown({
   Name = "Map Overrider",
   Options = {"Select Option","Abandoned City","Autumn Falling","Crossroads","Forest Camp","Fungi Island","Grass Isle","Harbor","Necropolis","Portland","Rocket Arena","Sky Islands","Toyboard","Tropical Isles","U-Turn","Chess Board","Crystal Cave","Cyber City","Deserted Village","Farm Lands","Four Seasons","Iceville","Lighthaos","Marshlands","Medieval Times","Meltdown","Moon Base","Nether","Night Station","Retro Lighthouse","Ruby Escort","Simplicity","Spring Fever","Stained Temple","Sugar Rush","Tropical Industries","Winter Bridges","Wrecked Battlefield","Wrecked Battlefield II","Abyssal Trench","Candy Valley","Cataclysm","Construction Crazy","Dusty Bridges","Forgotten Docks","Glided Path","Retro Zone","Sacred Mountains","The Heights","Winter Abyss","Black Spot Exchange","Dead Ahead","Hot Spot","Infernal Abyss","Lay By","Mason Arch","Space City","Winter Stronghold"},
   CurrentOption = {"Select Option"},
   MultipleOptions = false,
   Flag = "MapOverrider", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
   selectedMapOverride = Options[1]
   end,
})

local MapOverriderToggle = MainTab:CreateToggle({
   Name = "Enable Map Overrider",
   CurrentValue = false,
   Flag = "MapOverrider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   AutoMapOverride = Value
   end,
})

local SurvivalJoinerDropdown = MainTab:CreateDropdown({
   Name = "Auto Survival Joiner",
   Options = {"Easy","Casual","Intermediate","Molten","Fallen"},
   CurrentOption = {"Easy"},
   MultipleOptions = false,
   Flag = "SurvivalDifficulty", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
      selectedDifficulty = Options[1]
   end,
})

local SurvivalJoinerToggle = MainTab:CreateToggle({
   Name = "Enable Auto Survival Joiner",
   CurrentValue = false,
   Flag = "AutoSurvival", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   AutoJoinSurvival = Value
   end,
})

local SpecialJoinerDropdown = MainTab:CreateDropdown({
   Name = "Auto Special Joiner",
   Options = {"halloween","badlands","polluted"},
   CurrentOption = {"halloween"},
   MultipleOptions = false,
   Flag = "SpecialJoiner", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Options)
   selectedSpecialMode = Options[1]
   end,
})

local SpecialJoinerToggle = MainTab:CreateToggle({
   Name = "Enable Auto Special Joiner",
   CurrentValue = false,
   Flag = "SpecialJoiner1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   AutoJoinSpecial = Value
   end,
})

local HardcoreJoinerToggle = MainTab:CreateToggle({
   Name = "Auto Hardcore Joiner",
   CurrentValue = false,
   Flag = "HardcoreJoiner1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      AutoJoinHardcore = Value
   end,
})

local StatsTab = Window:CreateTab("Stats", 4483362458) -- Title, Image

local CoinTrackerLabel = StatsTab:CreateLabel("Coins: "..LocalPlayer.Coins.Value, "circle-dollar-sign") -- Title, Icon, Color, IgnoreTheme
local GemTrackerLabel =  StatsTab:CreateLabel("Gems: "..LocalPlayer.Gems.Value, "gem") -- Title, Icon, Color, IgnoreTheme
local TimescaleTicketsTrackerLabel =  StatsTab:CreateLabel("TimescaleTickets: "..LocalPlayer.TimescaleTickets.Value, "ticket") -- Title, Icon, Color, IgnoreTheme
local ReviveTicketsTrackerLabel =  StatsTab:CreateLabel("ReviveTickets: "..LocalPlayer.ReviveTickets.Value, "ticket") -- Title, Icon, Color, IgnoreTheme
local SpinTicketsTrackerLabel =  StatsTab:CreateLabel("SpinTickets: "..LocalPlayer.SpinTickets.Value, "ticket") -- Title, Icon, Color, IgnoreTheme
local LevelTrackerLabel =  StatsTab:CreateLabel("Level: "..LocalPlayer.Level.Value, "gauge") -- Title, Icon, Color, IgnoreTheme

local GameTab = Window:CreateTab("Game", 4483362458) -- Title, Image

local AutoRestartToggle = GameTab:CreateToggle({
   Name = "Auto Restart",
   CurrentValue = false,
   Flag = "AutoRestart", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   AutoRestartEnabled = Value
   end,
})

local AutoLobbyToggle = GameTab:CreateToggle({
   Name = "Auto return to lobby",
   CurrentValue = false,
   Flag = "AutoLobby", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   AutoLobbyEnabled = Value
   end,
})

local AutoSkipToggle = GameTab:CreateToggle({
   Name = "Auto skip",
   CurrentValue = false,
   Flag = "AutoSkip", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      AutoSkipEnabled = Value
   end,
})

local AutoVoteToggle = GameTab:CreateToggle({
   Name = "Auto vote for map (select in map overrider)",
   CurrentValue = false,
   Flag = "AutoVote", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      AutoVoteMap = Value
   end,
})

local AutoStartToggle = GameTab:CreateToggle({
   Name = "Auto start game (votes ready)",
   CurrentValue = false,
   Flag = "AutoStart", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
      AutoStartGame = Value
   end,
})

local MacroTab = Window:CreateTab("Macro", 4483362458) -- Title, Image

local Toggle = MacroTab:CreateToggle({
   Name = "Enable Pizza macro",
   CurrentValue = false,
   Flag = "PizzaMacro", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   pizzamacroenabled = Value
   end,
})

local WebhookTab = Window:CreateTab("Webhook", 4483362458) -- Title, Image

WebhookLabel = WebhookTab:CreateLabel("Awaiting Webhook Input...", "cable")

Input = WebhookTab:CreateInput({
   Name = "Input Webhook",
   CurrentValue = "",
   PlaceholderText = "Input Webhook",
   RemoveTextAfterFocusLost = false,
   Flag = "Webhook",
   Callback = function(Text)
      if string.find(Text, "https://discord.com/api/webhooks/") then
         ValidWebhook = Text
         WebhookLabel:Set("✅ Webhook URL set!")
      elseif Text == "" then
         WebhookLabel:Set("Awaiting Webhook Input...")
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
         sendWebhook("test", 3)
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

local StageFinishedToggle = WebhookTab:CreateToggle({
   Name = "Stage finished",
   CurrentValue = false,
   Flag = "StageFinishedWebhook",
   Callback = function(Value)
      StageFinishedEnabled = Value
   end,
})

local TestStageWebhookButton = WebhookTab:CreateButton({
   Name = "Test stage webhook",
   Callback = function()
      if StageFinishedEnabled == true then
             sendWebhook("stage", 3)
      end
   end,  
})



local CreditsTab = Window:CreateTab("Credits", 4483362458) -- Title, Image

local credits1Label =  CreditsTab:CreateLabel("Lixtron", "star") -- Title, Icon, Color, IgnoreTheme

local credits2Label =  CreditsTab:CreateLabel("Rodzinka Aloesow", "star") -- Title, Icon, Color, IgnoreTheme

task.spawn(function()
   while true do
      task.wait(1)
      Runtime += 1
      RuntimeLabel:Set("Script Runtime: "..Runtime.."s", "circle-play") -- Title, Icon, Color, IgnoreTheme
   end
end)

task.spawn(function()
    while true do
        task.wait(1)
        local gameOverVisible = LocalPlayer.PlayerGui.ReactGameRewards.Frame.gameOver
        if gameOverVisible.Visible == false then
            if AutoSkipEnabled then
                  local args = {[1] = "Voting",[2] = "Skip"}
                  game:GetService("ReplicatedStorage").RemoteFunction:InvokeServer(unpack(args))
               end
            end
            if gameOverVisible.Visible == true then
               if AutoRestartEnabled then
                 local args = {[1] = "Voting",[2] = "Skip"}
                  game:GetService("ReplicatedStorage").RemoteFunction:InvokeServer(unpack(args))
            end
            end
            if gameOverVisible.Visible == true then
            if AutoLobbyEnabled then
                TeleportService:Teleport(3260590327, LocalPlayer)
            end
         end
    end
end)

task.spawn(function()
   while true do
      wait(1)
       local gameOverVisible = LocalPlayer.PlayerGui.ReactGameRewards.Frame.gameOver
       if gameOverVisible.Visible == true then
         sendWebhook("stage",3)
         break
       end
   end
end)

task.spawn(function()
   while true do
      wait(1)
      if workspace:FindFirstChild("Elevators") then 
      if AutoJoinHardcore == true  then
         local args = {
            [1] = "Multiplayer",
            [2] = "v2:start",
            [3] = {
               ["count"] = 1,
               ["mode"] = "hardcore"
            }
         }
         remoteFunction:InvokeServer(unpack(args))
      elseif AutoJoinSurvival == true then
         local args = {
    [1] = "Multiplayer",
    [2] = "v2:start",
    [3] = {
        ["difficulty"] = tostring(selectedDifficulty),
        ["count"] = 4,
        ["mode"] = "survival"
    }
}
         remoteFunction:InvokeServer(unpack(args))
      elseif AutoJoinSpecial == true then
local args = {
    [1] = "Multiplayer",
    [2] = "v2:start",
    [3] = {
        ["count"] = 1,
        ["mode"] = tostring(selectedSpecialMode)
    }
}
        remoteFunction:InvokeServer(unpack(args))
      end
   end
   end
end)

task.spawn(function()
   while true do
      wait(1)
      if not workspace:FindFirstChild("Elevators") and AutoMapOverride and selectedMapOverride ~= "Select Option" then 
         local args = {
        [1] = "LobbyVoting",
        [2] = "Override",
        [3] = tostring(selectedMapOverride)
    }
    remoteFunction:InvokeServer(unpack(args))
      end
   end
end)

task.spawn(function()
   while true do
      wait(1)
   if AutoStartGame and not workspace:FindFirstChild("Elevators") then 
      if AutoStartGame == true then
         local args = {
        [1] = "LobbyVoting",
        [2] = "Ready"
    }
    remoteEvent:FireServer(unpack(args))
   end
      end
   end
end)

task.spawn(function()
   while true do
        wait(1)
   if AutoVoteMap and selectedMapOverride ~= "Select Option" and not workspace:FindFirstChild("Elevators") then 
      if AutoVoteMap == true then
          local args = {
        [1] = "LobbyVoting",
        [2] = "Vote",
        [3] = tostring(selectedMapOverride),
        [4] = Vector3.new(-18.28144073486328, 4.984418869018555, 54.3515625)
    }
    remoteEvent:FireServer(unpack(args))
   end
      end
   end
end)

task.spawn(function()
    while true do
        if pizzamacroenabled and not workspace:FindFirstChild("Elevators") then
         print("enabled macro pizza!!!")

            local guiPath = player:WaitForChild("PlayerGui")
                :WaitForChild("ReactUniversalHotbar")
                :WaitForChild("Frame")
                :WaitForChild("values")
                :WaitForChild("cash")
                :WaitForChild("amount")

            local function getCash()
                local rawText = guiPath.Text or ""
                local cleaned = rawText:gsub("[^%d%-]", "")
                return tonumber(cleaned) or 0
            end

            local function waitForCash(minAmount)
                while getCash() < minAmount do
                    task.wait(1)
                end
            end

            local function safeInvoke(args, cost)
                waitForCash(cost)
                local success, err = pcall(function()
                    remoteFunction:InvokeServer(unpack(args))
                end)
                task.wait(1)
            end

            local sequence = {
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(4.668, 2.349, -37.184) }, "Shotgunner" }, cost = 300 },
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-1.643, 2.349, -36.870) }, "Shotgunner" }, cost = 300 },
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(4.487, 2.386, -34.154) }, "Shotgunner" }, cost = 300 },
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-1.185, 2.386, -33.905) }, "Shotgunner" }, cost = 300 },
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-0.616, 2.386, -30.504) }, "Shotgunner" }, cost = 300 },

                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(7.143, 2.350, -39.064) }, "Trapper" }, cost = 500 },
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(7.671, 2.386, -35.299) }, "Trapper" }, cost = 500 },
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(-4.269, 2.349, -38.972) }, "Trapper" }, cost = 500 },
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(4.907, 2.386, -31.026) }, "Trapper" }, cost = 500 },
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(7.948, 2.386, -30.539) }, "Trapper" }, cost = 500 },
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(0.052, 2.386, -27.333) }, "Trapper" }, cost = 500 },
                { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(), Position = Vector3.new(3.450, 2.386, -25.265) }, "Trapper" }, cost = 500 },
            }

            for _, step in ipairs(sequence) do
                safeInvoke(step.args, step.cost)
            end

            local towerFolder = workspace:WaitForChild("Towers")
            while true do
                local towers = towerFolder:GetChildren()
                for _, tower in ipairs(towers) do
                    local args = {
                        "Troops",
                        "Upgrade",
                        "Set",
                        {
                            Troop = tower,
                            Path = 1
                        }
                    }
                    pcall(function()
                        remoteFunction:InvokeServer(unpack(args))
                    end)
                end
                task.wait(1)
            end

            break -- Stop the outer loop, the macro has started
        end
        task.wait(1) -- Wait before checking again
    end
end)

Rayfield:LoadConfiguration()
