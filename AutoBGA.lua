-- create frame
local frame = CreateFrame("frame")
local lastTick = 0
local lastAutoJoin = 0

-- fancy print
local function ABAPrint(str, p)
	local public = p or false
	print("|cfff5deb3[AutoBGA]|r: " .. str)	
	if p then
		SendChatMessage("[AutoBGA]: " .. str, "SAY")
	end
end

-- handles AcceptBattlefieldPort for untainted Lua
local function _AcceptBattlefieldPort(index)
	_accepted = false
	local attempts = 0
	while not _accepted do
		if attempts > 420 then
			-- failed to auto-join (tainted)
			lastAutoJoin = tick -- prevent spam
			ABAPrint("Battelground ready"); --, please join ASAP to increase the chance to be leader!")
		end

		RunScript([[
		if not issecure() then return end
		--JumpOrAscendStart()
		AcceptBattlefieldPort(]] .. index .. [[, true)
		_accepted = true;]])
		
		-- done
		if _accepted then
			-- the faster we join, the more chance we be lead!
			lastAutoJoin = tick -- prevent spam
			ABAPrint("Auto joined battleground!")
			return
		end
	end
end

-- check for assist all if not already all assist
local function AutoAssistAll()
	local playername = UnitName("player")
	for i=1, 40 do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if name == playername and rank == 2 then
			CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton:Click()
			ABAPrint("Auto Assisted Everyone!", true)
		end
	end
end

local function tick()
	-- tick on 0.5s interval
	local tick = GetTime()
	if lastTick + 0.5 > tick then return end
	lastTick = tick
	
	-- get Queued info
	for i=1, 10 do
		local status = GetBattlefieldStatus(i)
		if status == "none" then
			-- Do nothing
		elseif status == "active" then
			--print(status .. " ")
			--print(CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton:GetChecked())
			if not CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton:GetChecked() then 
				AutoAssistAll()
				return
			end
		elseif status == "queued" then
			-- wait for pop
		elseif status == "confirm" then
			-- enter battleground 
			if tick > lastAutoJoin + (10*60) then
				_AcceptBattlefieldPort(i) -- TODO fix
			end
			return
		end
	end
end

-- register to frame
local function init()
	-- register tick
	frame:SetScript("OnUpdate", tick)
	
	-- register events
	frame:SetScript("OnEvent", function(self, event, ...)
		ABAPrint(event)
		StaticPopup1:Hide() -- No need to tell me!
	end);		
	frame:RegisterEvent("MACRO_ACTION_BLOCKED");
	frame:RegisterEvent("ADDON_ACTION_FORBIDDEN");
	frame:RegisterEvent("MACRO_ACTION_BLOCKED");
	frame:RegisterEvent("ADDON_ACTION_FORBIDDEN");
	
	-- say hello!
	ABAPrint("Auto Battleground Assist is Ready!")
end

C_Timer.After(2.25, init)