local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ─── Services ────────────────────────────────────────────────────────────────
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer
local username          = LocalPlayer.Name

-- ─── Helpers ─────────────────────────────────────────────────────────────────
local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(position)
    local root = getRoot()
    if root then
        root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    end
end

local function fireProximity(prompt)
    pcall(function()
        fireproximityprompt(prompt)
    end)
end

-- ─── Equip Function ──────────────────────────────────────────────────────────
local function equipSpell(name)
    if game.PlaceId == 10253248401 then
        pcall(function()
            ReplicatedStorage.RemoteEvent:FireServer("equip_mystery_spell", name)
        end)
    else
        print("[OuxiHub] Equipped:", name)
    end
end

local function makeEquipButton(tab, spellName)
    tab:AddButton({
        Title    = spellName,
        Callback = function()
            equipSpell(spellName)
            Fluent:Notify({ Title = "Equipped!", Content = spellName, Duration = 2 })
        end,
    })
end

-- ─── Window ──────────────────────────────────────────────────────────────────
local Window = Fluent:CreateWindow({
    Title       = "OuxiHub | Elemental Powers",
    SubTitle    = "v1",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 500),
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- ─── Auto Name (polls every 0.5s) ────────────────────────────────────────────
local function getCurrentToolName()
    local tool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
    if not tool and LocalPlayer.Character then
        tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
    end
    return tool and tool.Name or "OuxiHub | Elemental Powers"
end

local function updateWindowTitle(name)
    for _, gui in ipairs({ game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui") }) do
        if gui then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Name == "Title" then
                    obj.Text = name
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        updateWindowTitle(getCurrentToolName())
        task.wait(0.5)
    end
end)

-- ─── Tabs ────────────────────────────────────────────────────────────────────
local Tabs = {
    AutoCollect = Window:AddTab({ Title = "Auto Collect", Icon = "coins"          }),
    Buy         = Window:AddTab({ Title = "Buy",          Icon = "shopping-cart"  }),
    Kill        = Window:AddTab({ Title = "Kill",         Icon = "sword"          }),
    Chests      = Window:AddTab({ Title = "Chests",       Icon = "box"            }),
    Ability     = Window:AddTab({ Title = "Ability",      Icon = "star"           }),
    Sonic       = Window:AddTab({ Title = "Sonic",        Icon = "wind"           }),
    Slaps       = Window:AddTab({ Title = "Slaps",        Icon = "hand"           }),
    Boss        = Window:AddTab({ Title = "Boss",         Icon = "shield"         }),
    Lava        = Window:AddTab({ Title = "Lava",         Icon = "flame"          }),
    Bone        = Window:AddTab({ Title = "Bone",         Icon = "skull"          }),
    Darkness    = Window:AddTab({ Title = "Darkness",     Icon = "moon"           }),
    Light       = Window:AddTab({ Title = "Light",        Icon = "sun"            }),
    Nature      = Window:AddTab({ Title = "Nature",       Icon = "leaf"           }),
    Ice         = Window:AddTab({ Title = "Ice",          Icon = "snowflake"      }),
    Thunder     = Window:AddTab({ Title = "Thunder",      Icon = "zap"            }),
    Earth       = Window:AddTab({ Title = "Earth",        Icon = "mountain"       }),
    Fire        = Window:AddTab({ Title = "Fire",         Icon = "flame-2"        }),
    Technology  = Window:AddTab({ Title = "Technology",   Icon = "cpu"            }),
    Gravity     = Window:AddTab({ Title = "Gravity",      Icon = "globe"          }),
    Time        = Window:AddTab({ Title = "Time",         Icon = "clock"          }),
    Crystal     = Window:AddTab({ Title = "Crystal",      Icon = "gem"            }),
    Venom       = Window:AddTab({ Title = "Venom",        Icon = "droplet"        }),
    Devil       = Window:AddTab({ Title = "Devil",        Icon = "alert-triangle" }),
    Space       = Window:AddTab({ Title = "Space",        Icon = "telescope"      }),
    Advance     = Window:AddTab({ Title = "Advance",      Icon = "settings"       }),
}

-- ════════════════════════════════════════════════════════════════════════════
--  AUTO COLLECT TAB
-- ════════════════════════════════════════════════════════════════════════════
local collectActive = false
local collectThread = nil

Tabs.AutoCollect:AddSection("Auto Collect")

Tabs.AutoCollect:AddToggle("CollectToggle", {
    Title       = "Enable Auto Collect",
    Description = "Teleports to your Collector and collects automatically",
    Default     = false,
    Callback    = function(state)
        collectActive = state
        if state then
            collectThread = task.spawn(function()
                while collectActive do
                    pcall(function()
                        local collectPart = workspace.Tycoons[username].Auxiliary.Collector.Collect
                        teleportTo(collectPart.Position)
                        task.wait(0.3)
                        local root = getRoot()
                        if root then
                            root.CFrame = collectPart.CFrame
                        end
                    end)
                    task.wait(1)
                end
            end)
        else
            if collectThread then
                task.cancel(collectThread)
                collectThread = nil
            end
        end
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  BUY TAB
-- ════════════════════════════════════════════════════════════════════════════
local buyActive = false
local buyThread = nil

Tabs.Buy:AddSection("Auto Buy")
Tabs.Buy:AddParagraph({
    Title   = "Info",
    Content = "Automatically teleports to and buys buttons you can afford.\nChecks your Money leaderstats against each button's price.",
})

Tabs.Buy:AddToggle("BuyToggle", {
    Title       = "Enable Auto Buy",
    Description = "Buys all affordable buttons in your tycoon",
    Default     = false,
    Callback    = function(state)
        buyActive = state
        if state then
            buyThread = task.spawn(function()
                while buyActive do
                    pcall(function()
                        local money = LocalPlayer.leaderstats
                            and LocalPlayer.leaderstats.Money
                            and LocalPlayer.leaderstats.Money.Value or 0
                        local buttonsFolder = workspace.Tycoons[username].Buttons
                        for _, model in ipairs(buttonsFolder:GetChildren()) do
                            if not buyActive then break end
                            pcall(function()
                                local price = model:GetAttribute("Price")
                                if price and money >= price then
                                    local part = model:FindFirstChildWhichIsA("BasePart")
                                    if part then
                                        teleportTo(part.Position)
                                        task.wait(0.5)
                                        local root = getRoot()
                                        if root then
                                            root.CFrame = part.CFrame
                                        end
                                        task.wait(0.3)
                                    end
                                end
                            end)
                            task.wait(0.5)
                        end
                    end)
                    task.wait(2)
                end
            end)
        else
            if buyThread then
                task.cancel(buyThread)
                buyThread = nil
            end
        end
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  KILL TAB
-- ════════════════════════════════════════════════════════════════════════════
local selectedKillTargets = {}

Tabs.Kill:AddSection("Target Players")

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

local playerNames = getPlayerNames()

local KillDropdown = Tabs.Kill:AddDropdown("KillTargets", {
    Title       = "Select Players",
    Description = "Pick one or more players to kill",
    Values      = playerNames,
    Default     = {},
    Multi       = true,
})

KillDropdown:OnChanged(function(val)
    selectedKillTargets = val
end)

Tabs.Kill:AddButton({
    Title       = "Refresh Player List",
    Description = "Updates the list with current players in server",
    Callback    = function()
        local newNames = getPlayerNames()
        KillDropdown:SetValues(newNames)
        Fluent:Notify({ Title = "Refreshed", Content = "Player list updated", Duration = 2 })
    end,
})

Tabs.Kill:AddSection("Actions")

local function slapPlayer(target)
    pcall(function()
        local args = {
            target.Character,
            500,
            200,
            60,
            "Cold Slap"
        }
        ReplicatedStorage:WaitForChild("Slap"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
    end)
end

Tabs.Kill:AddButton({
    Title       = "Kill Selected",
    Description = "Kills all selected players",
    Callback    = function()
        local killed = 0
        for name, selected in pairs(selectedKillTargets) do
            if selected then
                local target = Players:FindFirstChild(name)
                if target then
                    slapPlayer(target)
                    killed = killed + 1
                end
            end
        end
        Fluent:Notify({ Title = "Kill", Content = "Slapped " .. killed .. " player(s)", Duration = 2 })
    end,
})

Tabs.Kill:AddButton({
    Title       = "Kill All",
    Description = "Kills every player in the server",
    Callback    = function()
        local killed = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                slapPlayer(p)
                killed = killed + 1
            end
        end
        Fluent:Notify({ Title = "Kill All", Content = "Slapped " .. killed .. " player(s)", Duration = 2 })
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  CHESTS TAB
-- ════════════════════════════════════════════════════════════════════════════
local chestActive   = false
local chestThread   = nil
local balloonActive = false
local balloonThread = nil

Tabs.Chests:AddSection("Auto Chest")

Tabs.Chests:AddToggle("ChestToggle", {
    Title       = "Auto Collect Chests",
    Description = "Teleports to all chests and fires their proximity prompts",
    Default     = false,
    Callback    = function(state)
        chestActive = state
        if state then
            chestThread = task.spawn(function()
                while chestActive do
                    local oldPos = getRoot() and getRoot().CFrame or CFrame.new()
                    local found = false
                    pcall(function()
                        local chestsFolder = workspace.Treasure.Chests
                        for _, chest in ipairs(chestsFolder:GetChildren()) do
                            if not chestActive then break end
                            pcall(function()
                                local prompt = chest:FindFirstChild("ProximityPrompt")
                                    or chest:FindFirstChildWhichIsA("ProximityPrompt", true)
                                local part = chest:FindFirstChildWhichIsA("BasePart") or chest
                                if prompt and part then
                                    found = true
                                    teleportTo(part.Position)
                                    task.wait(0.4)
                                    fireProximity(prompt)
                                    task.wait(0.5)
                                end
                            end)
                        end
                    end)
                    if not found then
                        local root = getRoot()
                        if root then root.CFrame = oldPos end
                        task.wait(3)
                    else
                        task.wait(1)
                    end
                end
            end)
        else
            if chestThread then
                task.cancel(chestThread)
                chestThread = nil
            end
        end
    end,
})

Tabs.Chests:AddSection("Auto Balloon Crate")

Tabs.Chests:AddToggle("BalloonToggle", {
    Title       = "Auto Balloon Crate",
    Description = "Teleports to BalloonCrates and fires their proximity prompts",
    Default     = false,
    Callback    = function(state)
        balloonActive = state
        if state then
            balloonThread = task.spawn(function()
                while balloonActive do
                    local oldPos = getRoot() and getRoot().CFrame or CFrame.new()
                    local found = false
                    pcall(function()
                        for _, crate in ipairs(workspace.BalloonCrate:GetChildren()) do
                            if not balloonActive then break end
                            pcall(function()
                                local prompt = crate:FindFirstChild("ProximityPrompt")
                                    or crate:FindFirstChildWhichIsA("ProximityPrompt", true)
                                local part = crate:FindFirstChildWhichIsA("BasePart") or crate
                                if prompt and part then
                                    found = true
                                    teleportTo(part.Position)
                                    task.wait(0.4)
                                    fireProximity(prompt)
                                    task.wait(0.5)
                                end
                            end)
                        end
                    end)
                    if not found then
                        local root = getRoot()
                        if root then root.CFrame = oldPos end
                        task.wait(3)
                    else
                        task.wait(1)
                    end
                end
            end)
        else
            if balloonThread then
                task.cancel(balloonThread)
                balloonThread = nil
            end
        end
    end,
})

-- ════════════════════════════════════════════════════════════════════════════
--  ABILITY TAB
-- ════════════════════════════════════════════════════════════════════════════
Tabs.Ability:AddSection("Abilities")
for _, spell in ipairs({
    "Air Strike","Cruel Sun","Crate Rain","Health Potion","Meteor Shower","Robux Beam","Rocket Launcher",
    "Dark Flame","Draedon's Tech","Yoru","Plasma Orbs","Red Saucer","Undead Staff","Elysian Beam",
    "Posion Serpent","Sonar","Cosmic Anvil","Bubble Flail",
}) do
    makeEquipButton(Tabs.Ability, spell)
end

-- ════════════════════════════════════════════════════════════════════════════
--  SONIC TAB
-- ════════════════════════════════════════════════════════════════════════════
Tabs.Sonic:AddSection("Rebound")
for _, spell in ipairs({ "Rebound Blast","Rebound Teleport" }) do
    makeEquipButton(Tabs.Sonic, spell)
end
Tabs.Sonic:AddSection("Sonic")
for _, spell in ipairs({ "Sonic Barrage","Sonic Blaster","Sonic Bloom","Sonic Twister","Super Sonic Wave" }) do
    makeEquipButton(Tabs.Sonic, spell)
end

-- ════════════════════════════════════════════════════════════════════════════
--  SLAPS TAB
-- ════════════════════════════════════════════════════════════════════════════
Tabs.Slaps:AddSection("Slaps")
for _, spell in ipairs({ "Cold Slap","Time Slap" }) do
    makeEquipButton(Tabs.Slaps, spell)
end

-- ════════════════════════════════════════════════════════════════════════════
--  BOSS TAB
-- ════════════════════════════════════════════════════════════════════════════
Tabs.Boss:AddSection("Boss Spells")
for _, spell in ipairs({
    "Boulder","DraedonLunge","FrostDisk","FrostSpikes","Meteors","Meteor",
    "Pumpkin","Skulls","SlimeJump","SlimeLaser","Spikes",
}) do
    makeEquipButton(Tabs.Boss, spell)
end

-- ════════════════════════════════════════════════════════════════════════════
--  ELEMENTAL TABS
-- ════════════════════════════════════════════════════════════════════════════
local elementData = {
    { tab = Tabs.Lava,       name = "Lava",       spells = {"Lava Katana","Lava Ball","Magam Fists","Lava Dash","Volcano Sentry","Magma Spikes","Nibiru"} },
    { tab = Tabs.Bone,       name = "Bone",       spells = {"Bone Scythe","Blaster","Bones Barrage","Flying Bone","Bone Surge","Twin Blasters","Judgement Blast"} },
    { tab = Tabs.Darkness,   name = "Darkness",   spells = {"Shadow Sword","Unseen Hands","Unseen Barrage","Dark Duo","Abyss","Dark Hold","Dark Arc"} },
    { tab = Tabs.Light,      name = "Light",      spells = {"Light Saber","Light Ball","Light Orbs","Blinding Light","Shooting Star","Light Speed","Light Beam"} },
    { tab = Tabs.Nature,     name = "Nature",     spells = {"Christmas Tree Sword","Plantoid","Spore Bombs","Nature's Blessing","Nuclear Spore","Pine Burst","Nature's Wrath"} },
    { tab = Tabs.Ice,        name = "Ice",        spells = {"Frost Staff","Frost Fire Ball","Ice Disk","Snow Ball","Ultracold Aura","Ice Spikes"} },
    { tab = Tabs.Thunder,    name = "Thunder",    spells = {"Thunder Staff","Bolt","Barrage","Discharge","Flying Nimbus","Lighting Strike","Storm"} },
    { tab = Tabs.Earth,      name = "Earth",      spells = {"Tectonic Hamer","Stone Throw","Rocks Barrage","Large Boulder","Burrow","Stone Henge","Earth Spikes"} },
    { tab = Tabs.Fire,       name = "Fire",       spells = {"Fire Sword","Fire Ball","Fire Fly","Fire Bomb","Comet","Combust","Fire Shower"} },
    { tab = Tabs.Technology, name = "Technology", spells = {"Hyper Sword","Phonton Blast","Twin-Photon Blash","Tesla Turret","Orbital","Tesseract","Hyper Slash"} },
    { tab = Tabs.Gravity,    name = "Gravity",    spells = {"Gravity Katana","Heavy Infliction","Tectonic Barrage","Gravity Orb","Tectonic Burst","Zero Gravity","Gravity Globe"} },
    { tab = Tabs.Time,       name = "Time",       spells = {"Time Scepter","Temporal Gate","Warp Barrage","Tempo Beam","Time Trap","Warp Bomb","Grand Clock"} },
    { tab = Tabs.Crystal,    name = "Crystal",    spells = {"Crystal Cleaver","Crystal Mine","Energy Crash","Energy Crown","Crystal Eruption","Energy Crystal","Crystal Surge"} },
    { tab = Tabs.Venom,      name = "Venom",      spells = {"Venom Blade","Poison Bullet","Acid Rain","Venom Stream","Hardened Venom","Poison Demon","Bubbling Venom"} },
    { tab = Tabs.Devil,      name = "Devil",      spells = {"Devil Sword","Evil Bullet","Fangs Barrage","Evil Flash","Demon Orb","Demon Lock","Dark Tsunami"} },
    { tab = Tabs.Space,      name = "Space",      spells = {"Space Gun","Blackhole Orb","Moon Splitter","Asteroid Belt","Meteor Jam","Cosmic Remote","Space Saucer"} },
}

for _, element in ipairs(elementData) do
    element.tab:AddSection(element.name .. " Spells")
    for _, spell in ipairs(element.spells) do
        makeEquipButton(element.tab, spell)
    end
end

-- ════════════════════════════════════════════════════════════════════════════
--  ADVANCE TAB
-- ════════════════════════════════════════════════════════════════════════════
local spamActive = false
local spamThread = nil
local spamDelay  = 1
local spamSpell  = "Lava Katana"

local allSpells = {}
for _, spell in ipairs({
    "Air Strike","Cruel Sun","Crate Rain","Health Potion","Meteor Shower","Robux Beam","Rocket Launcher",
    "Dark Flame","Draedon's Tech","Yoru","Plasma Orbs","Red Saucer","Undead Staff","Elysian Beam",
    "Posion Serpent","Sonar","Cosmic Anvil","Bubble Flail",
    "Rebound Blast","Rebound Teleport",
    "Sonic Barrage","Sonic Blaster","Sonic Bloom","Sonic Twister","Super Sonic Wave",
    "Cold Slap","Time Slap",
    "Boulder","DraedonLunge","FrostDisk","FrostSpikes","Meteors","Meteor",
    "Pumpkin","Skulls","SlimeJump","SlimeLaser","Spikes",
}) do
    table.insert(allSpells, spell)
end
for _, element in ipairs(elementData) do
    for _, spell in ipairs(element.spells) do
        table.insert(allSpells, spell)
    end
end

Tabs.Advance:AddSection("Auto Spam Equip")

local SpamDrop = Tabs.Advance:AddDropdown("SpamSpell", {
    Title       = "Spell to Spam",
    Description = "Will be auto-equipped on interval",
    Values      = allSpells,
    Default     = allSpells[1],
    Multi       = false,
})
SpamDrop:OnChanged(function(val) spamSpell = val end)

Tabs.Advance:AddSlider("SpamDelay", {
    Title    = "Interval (seconds)",
    Min      = 0.1,
    Max      = 5,
    Default  = 1,
    Rounding = 1,
    Callback = function(val) spamDelay = val end,
})

Tabs.Advance:AddToggle("SpamToggle", {
    Title    = "Enable Auto Spam",
    Default  = false,
    Callback = function(state)
        spamActive = state
        if state then
            spamThread = task.spawn(function()
                while spamActive do
                    equipSpell(spamSpell)
                    task.wait(spamDelay)
                end
            end)
        else
            if spamThread then
                task.cancel(spamThread)
                spamThread = nil
            end
        end
    end,
})

Tabs.Advance:AddSection("Credits")
Tabs.Advance:AddParagraph({
    Title   = "OuxiHub",
    Content = "Original script by Ouxi\nFluent UI port — v1\nPlace ID: 10253248401",
})

-- ─── SaveManager / InterfaceManager ──────────────────────────────────────────
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Advance)
SaveManager:BuildConfigSection(Tabs.Advance)

Window:SelectTab(1)
Fluent:Notify({ Title = "OuxiHub Loaded", Content = "Ready! Left Ctrl to minimize.", Duration = 4 })
SaveManager:LoadAutoloadConfig()
