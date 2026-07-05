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
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

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

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
local Holder, Container = Library:AddDraggableMenu("LOGS")
Holder.Visible = false

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
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.ZIndex = 13
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
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

    local function Clear()
        for _, item in RealBackground:GetChildren() do
            if item:IsA("TextLabel") then 
                item:Destroy() 
            end
        end
        Library:Notify("Cleared logs")
    end

    local function Save()
        local full = ""
        for _, item in RealBackground:GetChildren() do
            if item:IsA("TextLabel") then 
                full ..= item.Text .. "\n"
            end
        end
        Clipboard(full)
        Library:Notify("Copied to clipboard")
    end

    button.Activated:Connect(Clear)
    saveButton.Activated:Connect(Save)
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

local Connections = {}
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
	local thread = task.spawn(func, ...)
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

function TDS:ToggleLogs(Visible: boolean): ()
    Holder.Visible = Visible
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

function TDS:InLobby(): boolean
    if workspace:FindFirstChild("Type").Value == "Lobby" then
        return true
    end

    return false
end

function TDS:InMatch(): boolean
    if workspace:FindFirstChild("Type").Value == "Game" then
        return true
    end

    return false
end

function TDS:IsIntermission(): boolean
    if not self:InMatch() then
        return
    end

    return GameState.Intermission and true or false
end

function TDS:GameStarted(): boolean
    if not self:InMatch() then
        return
    end

    return GameState.GameStarted and true or false
end

function TDS:GameOverDied(): boolean
    if not self:InMatch() then
        return
    end

    return (GameState.GameOver and GameState.Health <= 0) and true or false
end

function TDS:HasTriumph(): boolean
    if not self:InMatch() then
        return
    end

    return (GameState.GameOver and GameState.Health >= 0) and true or false
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
    if not self:InMatch() then
        return
    end

    return GameState.Wave
end

function TDS:GetCurrentCash(Player: Player?): number
    if not self:InMatch() then
        return
    end

    local targetPlayer = Player or LocalPlayer
    return PlayerReplicator.GetEntityFromPlayer(targetPlayer).Cash
end

function TDS:GetWaveTimer(): number
    if not self:InMatch() then
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
    if not self:IsIntermission() then
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
    if not self:IsIntermission() then
        return
    end

    RemoteEvent:FireServer("LobbyVoting", "Ready")
end

function TDS:VetoMaps(): ()
    if not self:IsIntermission() then
        return
    end

    RemoteEvent:FireServer("LobbyVoting", "Veto")
end

function TDS:VoteMap(Name: string): ()
    if not self:IsIntermission() then
        return
    end

    RemoteEvent:FireServer("LobbyVoting", "Vote", Name, Vector3.new(0, 0, 0))
end

function TDS:StartGame(): ()
    if self:GameStarted() then
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
    if not self:GameStarted() then
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
    if not self:GameOverDied() then
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
    if not self:InMatch() then
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
        Log(string.format("Successfully upgraded %s at index #%s", self.Replicator:GetAttribute("Name"), self.TDS.PlacedTowers[self]), Color3.new(0, 1, 0))
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
        return Log(string.format("Could not sell %s at index #%s", self.Replicator:GetAttribute("Name"), self.TDS.PlacedTowers[self]), Color3.new(1, 0, 0))
    end
end

function Tower:GetPosition()
    return self.Replicator:GetAttribute("Position")
end

function TDS:UpgradeAllTowers()
    if not self:InMatch() then 
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
    for i = #self.PlacedTowers, 1, -1 do
        CreateThread(function()
            local tower = self.PlacedTowers[i]
            tower:Sell()
        end)

        Sleep(50)
    end
end

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
