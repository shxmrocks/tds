loadstring(game:HttpGet("https://raw.githubusercontent.com/shxmrocks/tds/refs/heads/main/main.lua"))()
local TeleportCheck = false
game.Players.LocalPlayer.OnTeleport:Connect(function(State)
	if not TeleportCheck then
		TeleportCheck = true
		queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/shxmrocks/tds/refs/heads/main/test.lua'))()")
	end
end)
if game.PlaceId == 3260590327 then
	TDS:CreateMatch("Easy")
end

TDS:ToggleLogs(true)

CreateThread(function()
    Loop(function()
        TDS:ReadyUp()
		TDS:StartGame()
        TDS:SkipWave()
        TDS:RestartGame()

        if TDS:HasTriumph() then
            TDS:CreateMatch("Easy")
        end

        Sleep(100)
    end)
end)

Loop(function()
	if TDS:GameStarted() then
		return "break"
	end
end)

Sleep(1000)

local pos
Loop(function()
	local part = workspace.Map.Paths["1"]["3"]
	repeat
		pos = part.Position + Vector3.new(math.random(-4,4), 5, math.random(-4,4))
	until TDS:PlaceTower("Scout", pos)

	return "break"
end)

Loop(20, function()
    Loop(function()
		if TDS:GetCurrentCash() >= 125 then
			TDS:PlaceTower("Scout", pos)
			return "break"
		end
    end)


    Sleep(500)
end)

Loop(function ()
	TDS:UpgradeAllTowers()
	Sleep(5000)
end)
