if getgenv().TDS then
    ExitApp()
end

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local GroupService = game:GetService("GroupService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Connections = {}

local TeleportCheck = false
table.insert(Connections, LocalPlayer.OnTeleport:Connect(function()
	if not TeleportCheck then
		TeleportCheck = true
		queueonteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/shxmrocks/tds/refs/heads/main/main.lua'))()")
	end
end))

table.insert(Connections, game.Close:Connect(function()
	if isfile("TDSMacros/sessionID.txt") and not TeleportCheck then
        delfile("TDSMacros/sessionID.txt")
    end
end))

local stuck = 0
while LocalPlayer:GetAttribute("Loading") or LocalPlayer:GetAttribute("Teleporting") do
    task.wait(1)
    stuck += 1

    if stuck >= 60 then
        pcall(function()
            TeleportService:Teleport(3260590327)
        end)
    end
end

table.insert(Connections, GuiService.ErrorMessageChanged:Connect(function()
    pcall(function()
        TeleportService:Teleport(3260590327)
    end)
end))

for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
	if connection["Disable"] then
		connection["Disable"](connection)
	elseif connection["Disconnect"] then
		connection["Disconnect"](connection)
	end
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local StateReplicators = ReplicatedStorage.StateReplicators

local Client = ReplicatedStorage:WaitForChild("Client")
local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local Replicators = Client:WaitForChild("Modules"):WaitForChild("Replicators")

local GameState = require(Modules:WaitForChild("GameState"))
local PlayerReplicator = require(Replicators:WaitForChild("PlayerReplicator"))

local RemoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")

-- // log menu shit

local repo = "https://raw.githubusercontent.com/shxmrocks/Obsidian/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local info = loadstring(game:HttpGet("https://raw.githubusercontent.com/shxmrocks/tds/refs/heads/main/info.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = true

local Holder, Container = Library:AddDraggableMenu("LOGS")
Holder.Visible = false

local function autosave()
	if SaveManager:GetAutoloadConfig() == "none" or SaveManager:GetAutoloadConfig() == "" then
		SaveManager:SaveAutoloadConfig("autosave")
	end
	local suc, err = SaveManager:Save("autosave")
	if suc then print("saved") else warn(err) end
end

do
    local RealBackground = Instance.new("ScrollingFrame")
    local UIListLayout_Logs = Instance.new("UIListLayout")
    local UIPadding_Logs = Instance.new("UIPadding")
    local button = Instance.new("TextButton")
    local corner = Instance.new("UICorner")

    RealBackground.Name = "LogContainer"
    RealBackground.Parent = Container
    RealBackground.BackgroundTransparency = 1
    RealBackground.Size = UDim2.new(0, 650, 0, 350)
    RealBackground.ZIndex = 11
    RealBackground.CanvasSize = UDim2.new(0, 0, 0, 0)
    RealBackground.ScrollBarThickness = 3
    RealBackground.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    RealBackground.AutomaticCanvasSize = Enum.AutomaticSize.Y

    UIListLayout_Logs.Parent = RealBackground
    UIListLayout_Logs.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_Logs.Padding = UDim.new(0, 2)

    UIPadding_Logs.Parent = RealBackground
    UIPadding_Logs.PaddingLeft = UDim.new(0, 10)
    UIPadding_Logs.PaddingTop = UDim.new(0, 5)

    local ButtonHolder = Instance.new("Frame")
    ButtonHolder.Name = "ButtonHolder"
    ButtonHolder.Parent = Container
    ButtonHolder.Size = UDim2.new(0, 650, 0, 25)
    ButtonHolder.BackgroundTransparency = 1

    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.Parent = ButtonHolder
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonLayout.Padding = UDim.new(0, 10)

    local button = Instance.new("TextButton")
    button.Name = "ClearButton"
    button.Parent = ButtonHolder
    button.Size = UDim2.new(0.5, -5, 1, 0)
    button.BackgroundColor3 = Library.Scheme.MainColor
    button.BorderSizePixel = 0
    button.ZIndex = 13
    button.TextColor3 = Library.Scheme.FontColor
    button.TextSize = 16
    button.Font = Enum.Font.Code
    button.Text = "Clear"
    button.LayoutOrder = 1

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button

    local saveButton = button:Clone()
    saveButton.Name = "SaveButton"
    saveButton.Parent = ButtonHolder
    saveButton.Text = "Save"
    saveButton.LayoutOrder = 2

    local saveCorner = corner:Clone()
    saveCorner.Parent = saveButton

    function Log(message, color)
        local LogLabel = Instance.new("TextLabel")
        LogLabel.Parent = RealBackground
        LogLabel.BackgroundTransparency = 1
        LogLabel.ZIndex = 12
        LogLabel.Size = UDim2.new(1, -10, 0, 16)
        LogLabel.Font = Enum.Font.Code
        LogLabel.Text = string.format("[%s] %s", os.date("%X"), tostring(message))
        LogLabel.TextColor3 = color or Color3.fromRGB(220, 220, 220)
        LogLabel.TextScaled = true
        LogLabel.TextXAlignment = Enum.TextXAlignment.Left
        LogLabel.RichText = true
        
        task.defer(function()
            RealBackground.CanvasPosition = Vector2.new(0, RealBackground.AbsoluteCanvasSize.Y)
        end)
    end

    function ClearLogs()
        for _, item in RealBackground:GetChildren() do
            if item:IsA("TextLabel") then 
                item:Destroy() 
            end
        end
        Library:Notify("Cleared logs")
    end

    function SaveLogs()
        local full = ""
        for _, item in RealBackground:GetChildren() do
            if item:IsA("TextLabel") then 
                full ..= item.Text .. "\n"
            end
        end
        Clipboard(full)
        Library:Notify("Copied to clipboard")
    end

    button.Activated:Connect(ClearLogs)
    saveButton.Activated:Connect(SaveLogs)

    Library:AddOutline(button)
    Library:AddOutline(saveButton)

    Library:AddToRegistry(button, {
        BackgroundColor3 = "MainColor",
        TextColor3 = "FontColor",
    })

    Library:AddToRegistry(saveButton, {
        BackgroundColor3 = "MainColor",
        TextColor3 = "FontColor",
    })
end

do
    if not isfolder("TDSMacros") then
        makefolder("TDSMacros")
    end
end

-- // dumb functions

local function checkOk(data)
    if data == true then 
        return true 
    end

    if type(data) == "table" and data.Success == true then
        return true
    end

    local success, IsInstance = pcall(function()
        return data and typeof(data) == "Instance"
    end)

    if success and IsInstance then
        return true
    end

    if type(data) == "userdata" then
        return true
    end

    return false
end

local Keybinds = {}
local BreakLoops = false

local function parseKeyCode(key: Enum.KeyCode | string): Enum.KeyCode?
    if typeof(key) == "EnumItem" then
        return key
    elseif typeof(key) == "string" then
        local success, result = pcall(function()
            return Enum.KeyCode[key]
        end)
        if success then return result end
    end
    return nil
end

local function Bind(key: Enum.KeyCode | string, callback: () -> ())
    local finalKey = parseKeyCode(key)
    if finalKey then
        Keybinds[finalKey] = callback
    else
        warn("Invalid keybind provided: " .. tostring(key))
    end
end

local function Unbind(key: Enum.KeyCode | string)
    local finalKey = parseKeyCode(key)
    if finalKey then
        Keybinds[finalKey] = nil
    end
end

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if Keybinds[input.KeyCode] then
        Keybinds[input.KeyCode]()
    end
end))

local function CreateThread(func, ...)
	local thread = coroutine.create(func)
	coroutine.resume(thread, ...)
	return thread
end

local function Clipboard(data: any)
    setclipboard(tostring(data))
end

function Sleep(delay: number)
    task.wait(math.ceil(delay) / 1000)
end

function Loop(countOrFunc: number | (() -> string?), callback: () -> ())
    if type(countOrFunc) == "function" then
        while not BreakLoops do
            local shouldBreak: string? = countOrFunc()
            if shouldBreak == "break" then 
                break 
            end
            Sleep(0)
        end
    elseif type(countOrFunc) == "number" and type(callback) == "function" then
        for i: number = 1, countOrFunc do
            local shouldBreak: string? = callback(i)
            if BreakLoops or shouldBreak == "break" then 
                break 
            end
            Sleep(0)
        end
    end
end

function ExitApp(): ()
    for _, con in Connections do
        con:Disconnect()
    end

    BreakLoops = true

    getgenv().TDS = nil
    Library:Unload()
end

--// good stuff below

local TDS =  {
    PlacedTowers = {}
}

-- // general functions

function TDS:GetMacros(): ()
    local Path = "TDSMacros"
    local blacklist = {"sessionID"}
    local SuccessList, Files = pcall(listfiles, Path)
    if not (SuccessList and typeof(Files) == "table") then
        Library:Notify(string.format("Failed to load macro list: %s", tostring(Files)))
        return {}
    end

    local FileNames = {}
    for _, FilePath in Files do
        local RawFileName = FilePath:match("(.+)%..+$")
        if not RawFileName then continue end

        local Position = RawFileName:gsub("\\", "/"):find("/[^/]*$")
        local FileName = Position and RawFileName:sub(Position + 1) or RawFileName
        if not FileName or table.find(blacklist, FileName) then continue end

        table.insert(FileNames, FileName)
    end

    return FileNames
end

function TDS:RunMacro(Name: string): ()
    if not Name or not table.find(self:GetMacros(), Name) then return end

    local suc, err = pcall(function()
        loadstring(readfile("TDSMacros/" .. Name .. ".txt"))()
    end)

    if not suc then return warn(err) end
end

function TDS:ToggleLogs(Visible: boolean): ()
    Holder.Visible = Visible
end

function TDS:GenerateSessionID(): ()
    local id = HttpService:GenerateGUID(false)
    self.SessionID = id
    
    writefile("TDSMacros/sessionID.txt", id)
end

function TDS:GetSessionID(): string
    return self.SessionID or readfile("TDSMacros/sessionID.txt")
end

function TDS:GoTo(Position: Vector3): ()
    local character = LocalPlayer.Character or nil
    character:PivotTo(CFrame.new(Position) * character:GetPivot().Rotation)
end

function TDS:GetPlayerPosition(Stacking: boolean): Vector3
    local character = LocalPlayer.Character or nil
    local floory = character:GetPivot().Position.Y - character:FindFirstChildOfClass("Humanoid").HipHeight
    return Vector3.new(character:GetPivot().Position.X, (Stacking and character:GetPivot().Position.Y or floory), character:GetPivot().Position.Z)
end

function TDS:GetMousePosition(Stacking: boolean): Vector3
    return Stacking and (Mouse.Hit.Position + Vector3.new(0, 5, 0)) or Mouse.Hit.Position
end

-- // game related functions

function TDS:PromptGroup()
    return GroupService:PromptJoinAsync(4914494)
end

function TDS:GetGameStatus(): string
    if workspace:FindFirstChild("Type").Value == "Game" then
        return "Game"
    elseif workspace:FindFirstChild("Type").Value == "Lobby" then
        return "Lobby"
    end
end

function TDS:GetMatchStatus(): string
    if self:GetGameStatus() ~= "Game" then
        return
    end

    if GameState.Intermission then
        return "Intermission"
    elseif not GameState.GameStarted then
        return "Not Started"
    elseif GameState.GameStarted and not GameState.GameOver then
        return "In Progress"
    elseif (GameState.GameOver and GameState.Health <= 0) then
        return "Dead"
    elseif (GameState.GameOver and GameState.Health > 0) then
        return "Triumph"
    end
end

function TDS:GetLoadout(Player: Player?)
    local targetPlayer = Player or LocalPlayer
    return PlayerReplicator.GetEntityFromPlayer(targetPlayer).EquippedTowers
end

function TDS:EquipTower(Name: string)
    local done = false
    repeat
        local ok = pcall(function()
            RemoteEvent:FireServer("Inventory", "Equip", "Tower", Name)
            Sleep(100)
        end)
        if ok then done = true else Sleep() end
    until done

    Log("Equipped " .. Name)

    return true
end

function TDS:UnequipTower(Name: string)
    local done = false
    repeat
        local ok = pcall(function()
            RemoteEvent:FireServer("Inventory", "Unequip", "Tower", Name)
            Sleep(100)
        end)
        if ok then done = true else Sleep() end
    until done

    Log("Unequipped " .. Name)

    return true
end

function TDS:SetLoadout(...)
    local Loadout = {...}

    for _, tower in self:GetLoadout() do
        local done = false
        repeat
            local ok = pcall(function()
                RemoteEvent:FireServer("Inventory", "Unequip", "Tower", tower)
                Sleep(100)
            end)
            if ok then done = true else Sleep() end
        until done
    end

    Log("Cleared loadout")

    Sleep(500)

    for _, tower in Loadout do
        local done = false
        repeat
            local ok = pcall(function()
                RemoteEvent:FireServer("Inventory", "Equip", "Tower", tower)
                Sleep(100)
            end)
            if ok then done = true else Sleep() end
        until done
    end

    Log("Set loadout: " .. table.concat(Loadout, ", "))

    return true
end

function TDS:GetCurrentWave(): number
    if self:GetGameStatus() ~= "Game" then
        return
    end

    return GameState.Wave
end

function TDS:GetCurrentCash(Player: Player?): number
    if self:GetGameStatus() ~= "Game" then
        return
    end

    local targetPlayer = Player or LocalPlayer
    return PlayerReplicator.GetEntityFromPlayer(targetPlayer).Cash
end

function TDS:GetWaveTimer(): number
    if self:GetGameStatus() ~= "Game" then
        return
    end

    return ReplicatedStorage.State.Timer.Time.Value
end

function TDS:CreateMatch(Difficulty: string)
    local res = nil

    repeat
        local ok, result = pcall(function()
            local payload

            if Difficulty == "PizzaParty" then
                payload = {
                    mode = "halloween",
                    count = 1
                }
            elseif Difficulty == "Hardcore" then
                payload = {
                    mode = "hardcore",
                    difficulty = "Easy",
                    count = 1
                }
            elseif Difficulty == "Voidcore" then
                payload = {
                    mode = "hardcore",
                    difficulty = "Hard",
                    count = 1
                }
            elseif Difficulty == "PollutedWasteland" then
                payload = {
                    mode = "polluted",
                    count = 1
                }
            elseif Difficulty == "Badlands" then
                payload = {
                    mode = "badlands",
                    count = 1
                }
            elseif Difficulty == "Trial" then
                self:TeleportToLobby()
                return true
            else
                payload = {
                    difficulty = Difficulty,
                    mode = "survival",
                    count = 1
                }
            end

            return RemoteFunction:InvokeServer("Multiplayer", "v2:start", payload)
        end)

        if ok and checkOk(result) then
            success = true
            res = result
        else
            Sleep(500)
        end
    until success

    return res
end

function TDS:TeleportToLobby()
    return TeleportService:Teleport(3260590327)
end

function TDS:IsMapAvailable(Name: string): boolean
    if self:GetMatchStatus() ~= "Intermission" then
        return
    end

    local found = false
    for _, d in workspace:GetDescendants() do
        if d:IsA("SurfaceGui") and d.Name == "MapDisplay" then
            local t = d:FindFirstChild("Title")
            if t and t.Text == Name then
                found = true
                break
            end
        end
    end

    return found
end

function TDS:ReadyUp(): ()
    if self:GetMatchStatus() ~= "Intermission" then
        return
    end

    RemoteEvent:FireServer("LobbyVoting", "Ready")
end

function TDS:VetoMaps(): ()
    if self:GetMatchStatus() ~= "Intermission" then
        return
    end

    RemoteEvent:FireServer("LobbyVoting", "Veto")
end

function TDS:VoteMap(Name: string): ()
    if self:GetMatchStatus() ~= "Intermission" then
        return
    end

    RemoteEvent:FireServer("LobbyVoting", "Vote", Name, Vector3.new(0, 0, 0))
end

function TDS:StartGame(): ()
    if self:GetMatchStatus() ~= "Not Started" then
        return
    end

    local Replicator = StateReplicators.VoteReplicator
    local Enabled = Replicator:GetAttribute("Enabled")
    local Title = Replicator:GetAttribute("Title")
    local VoteCount = Replicator:GetAttribute("VoteCount")
    local MaxVotes = Replicator:GetAttribute("MaxVotes")

    if Enabled and Title == "Ready?" and VoteCount < MaxVotes then
        RemoteFunction:InvokeServer("Voting", "Skip")
    end
end

function TDS:SkipWave(): ()
    if self:GetMatchStatus() ~= "In Progress" then
        return
    end

    local Replicator = StateReplicators.VoteReplicator
    local Enabled = Replicator:GetAttribute("Enabled")
    local Title = Replicator:GetAttribute("Title")
    local VoteCount = Replicator:GetAttribute("VoteCount")
    local MaxVotes = Replicator:GetAttribute("MaxVotes")

    if Enabled and Title == "Skip Wave?" and VoteCount < MaxVotes then
        RemoteFunction:InvokeServer("Voting", "Skip")
    end
end

function TDS:RestartGame(): ()
    if self:GetMatchStatus() ~= "Dead" then
        return
    end

    RemoteFunction:InvokeServer("Voting", "Skip")
end

local Tower = {}
Tower.__index = Tower

function Tower.new(instance, replicator, manager)
    local self = setmetatable({}, Tower)
    
    self.Instance = instance
    self.Replicator = replicator
    self.TDS = manager
    
    return self
end

function TDS:PlaceTower(Name: string, Pos: Vector3, ...): Instance
    if self:GetGameStatus() ~= "Game" then
        return
    end

    local args = {...}
    local newTower = nil
    local ok, res = pcall(function()
        return RemoteFunction:InvokeServer("Troops", "Place", {
            Rotation = CFrame.new(),
            Position = Pos
        }, Name, unpack(args))
    end)

    if ok and checkOk(res) and typeof(res) == "Instance" then
        newTower = res
        Log("Placed " .. Name)
    else
        return Log(res, Color3.new(1, 1, 0))
    end

    local tower = Tower.new(newTower, newTower.TowerReplicator, self)
    table.insert(self.PlacedTowers, tower)
    
    return tower
end

function Tower:Upgrade(PathId: number): boolean
    local ok, res, msg = pcall(function()
        return RemoteFunction:InvokeServer("Troops", "Upgrade", "Set", {
            Troop = self.Instance,
            Path = PathId or 1
        })
    end)

    if ok and checkOk(res) then 
        Log(string.format("Successfully upgraded %s at index #%s", self.Replicator:GetAttribute("Name"), table.find(self.TDS.PlacedTowers, self)), Color3.new(0, 1, 0))
        return true
    else
        return Log(msg, Color3.new(1, 1, 0))
    end
end

function Tower:Sell()
    local ok, res = pcall(function()
        return RemoteFunction:InvokeServer("Troops", "Sell", { Troop = self.Instance })
    end)

    if ok and checkOk(res) then
        for index, placedTower in ipairs(self.TDS.PlacedTowers) do
            if placedTower == self then
                Log(string.format("Successfully sold %s at index #%s", self.Replicator:GetAttribute("Name"), index), Color3.new(0, 1, 0))
                table.remove(self.TDS.PlacedTowers, index)
                break
            end
        end
        return true
    else
        return Log(string.format("Failed to sell %s at index #%s", self.Replicator:GetAttribute("Name"), table.find(self.TDS.PlacedTowers, self)), Color3.new(1, 0, 0))
    end
end

function Tower:GetPosition()
    return self.Replicator:GetAttribute("Position")
end

-- deprecated
function TDS:UpgradeAllTowers()
    if self:GetGameStatus() ~= "Game" then 
        return 
    end
    
    for index, towerObject in ipairs(self.PlacedTowers) do
        if towerObject.Instance and towerObject.Instance.Parent then
            CreateThread(function()
                towerObject:Upgrade()
            end)

            Sleep(50)
        end
    end
end

function TDS:SellAllTowers()
    if self:GetGameStatus() ~= "Game" then
        return
    end

    for i = #self.PlacedTowers, 1, -1 do
        CreateThread(function()
            local tower = self.PlacedTowers[i]
            tower:Sell()
        end)

        Sleep(50)
    end
end

-- // create librarhy shit

local Window = Library:CreateWindow({
	Title = "macro slop",
    Footer = "version: " .. info.version,
    Icon = 13340047973,
	Center = true,
	AutoShow = false,
	Resizable = true,
	EnableSidebarResize = true,
	ShowCustomCursor = false,
	UnlockMouseWhileOpen = true,
    NotifySide = "Right"
})

local Tabs = {
	Macro = Window:AddTab("Macro", "bot"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local LoadGroupbox = Tabs.Macro:AddLeftGroupbox("Load")
local RecorderGroupbox = Tabs.Macro:AddRightGroupbox("Recorder")
local DiscordGroupbox = Tabs.Macro:AddLeftGroupbox("Discord")
local OtherGroupbox = Tabs.Macro:AddRightGroupbox("Other")

-- have a way to stop it
LoadGroupbox:AddToggle("MacroActive", {
	Text = "Enable Macro",
	Default = false,
    Callback = function(Value)
        if Value then
            task.wait(1) -- idk find a better way to wait for the option to load
            TDS:RunMacro(Options.MacroList.Value)
        end
    end
})

LoadGroupbox:AddDropdown("MacroList", { Text = "Macros", Values = TDS:GetMacros(), AllowNull = true })

LoadGroupbox:AddButton("Refresh list", function()
    Options.MacroList:SetValue(TDS:GetMacros())
    Options.MacroList:SetValue(nil)
end)

-- add smth to prevent duplicate names later
RecorderGroupbox:AddInput("MacroName", {
	Default = nil,
	Numeric = false,
	Finished = false,
	ClearTextOnFocus = true,
		
	Text = "Macro Name",
	Placeholder = "",
})

local begin = RecorderGroupbox:AddButton("Begin Recording", function() print("Begin recording") end)
local pause = RecorderGroupbox:AddButton("Pause Recording", function() print("Pause recording") end)
local stop = RecorderGroupbox:AddButton("Stop Recording", function() print("Stop recording") end)

stop:SetDisabled(true)
pause:SetDisabled(true)

DiscordGroupbox:AddToggle("LogDiscord", {
	Text = "Log to Discord Webhook",
    Tooltip = "logs only session stats and important stufff",
	Default = false,
})
DiscordGroupbox:AddToggle("Ping", {
	Text = "Ping",
	Tooltip = "will ping @everyone ",
	Default = false,
})
DiscordGroupbox:AddInput("WebhookURL", {
	Default = "",
	Numeric = false,
	Finished = false,
	ClearTextOnFocus = true,
		
	Text = "Webhook URL",
	Placeholder = "https://discord.com/api/webhooks/",
})

OtherGroupbox:AddToggle("ToggleLogs", {
	Text = "Toggle Logs",
	Default = false,
    Callback = function(Value)
        TDS:ToggleLogs(Value)

        if Value then
            ClearLogs()
            Log("Session " .. TDS:GetSessionID())
        end
    end
})

if not isfile("TDSMacros/sessionID.txt") then
    TDS:GenerateSessionID()
end

Library:Notify("Press right shift to toggle the UI")

--[[local Watermark = Library:AddDraggableLabel("watermark...")
Watermark:SetVisible(false)

Watermark:SetText(("No Macro Active | %s"):format(
	game.Players.LocalPlayer.Name
));]]

Library:OnUnload(function()
	autosave()
	Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

Library.KeybindFrame.Visible = false;

--MenuGroup:AddToggle("Watermark", { Default = false, Text = "Watermark", Callback = function(value) Watermark:SetVisible(value) end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = Library.ShowCustomCursor, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddDropdown("NotifySide", {Values = { "Left", "Right" }, Default = 2, Text = "Notification Side", Callback = function(value) Library:SetNotifySide(value) end})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})

MenuGroup:AddSlider("UICornerSlider", {
	Text = "Corner Radius",
	Default = Library.CornerRadius,
	Min = 0,
	Max = 20,
	Rounding = 0,
	Callback = function(value)
		Window:SetCornerRadius(value)
	end
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function() ExitApp() end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("nullscapesample")
--SaveManager:SetFolder()

--SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

-- // stguff

local globalFunctions = {
    ["Bind"] = Bind,
    ["Unbind"] = Unbind,
    ["CreateThread"] = CreateThread,
    ["Clipboard"] = Clipboard,
    ["Sleep"] = Sleep,
    ["Loop"] = Loop,
    ["ExitApp"] = ExitApp
}

for name, func in globalFunctions do
    getgenv()[name] = func
end

getgenv().TDS = TDS

return TDS
