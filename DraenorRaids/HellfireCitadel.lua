--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...

------------------------------------------------------
---- Hellfire Citadel Bosses
------------------------------------------------------
core.HellfireCitadel = {}
core.HellfireCitadel.Events = CreateFrame("Frame")

------------------------------------------------------
---- Iron Reaver
------------------------------------------------------
local hellfireGuardianKilled = 0

------------------------------------------------------
---- Hellfire High Council
------------------------------------------------------
local timerStarted = false
local unitsKilled = 0

------------------------------------------------------
---- Shadow-Lord Iskar
------------------------------------------------------
local eyeOfAnzuPlayer = nil
local firstPickup = false

------------------------------------------------------
---- Socrethar the Eternal
------------------------------------------------------
local hauntingSoulsKilled = 0

------------------------------------------------------
---- Archimonde
------------------------------------------------------
local doomfireSpawned = false

function core.HellfireCitadel:IronReaver()
	if core.type == "SPELL_INSTAKILL" and core.destID == "94985" and hellfireGuardianKilled < 10 then
		hellfireGuardianKilled = hellfireGuardianKilled + 1
		core:sendMessage(core:getAchievement() .. " Hellfire Guardians Killed (" .. hellfireGuardianKilled .. "/10)")
	end

	if hellfireGuardianKilled == 10 then
		core:getAchievementSuccess()		
	end
end

function core.HellfireCitadel:HellfireHighCouncil()
	if core.type == "UNIT_DIED" and (core.destID == "92142" or core.destID == "92146" or core.destID == "92144") then
		unitsKilled = unitsKilled + 1
		if timerStarted == false then
			core:sendMessage(core:getAchievement() .. " Timer Started! 10 seconds remaining to kill bosses")
			timerStarted = true
			C_Timer.After(10, function()
				if unitsKilled ~= 3 and core.inCombat == true then
					core:getAchievementFailedWithMessageAfter("(" .. unitsKilled .. "/3) Killed in time")						
				end
			end)
		end
	end
end

function core.HellfireCitadel:Kormrok()
	--If player gets hit by one of the abilities and has not already been hit then fail the achievement for the player
	if core.type == "SPELL_AURA_APPLIED" and (core.spellId == 185521 or core.spellId == 185519 or core.spellId == 180270) then
		core:getAchievementFailedPersonal()
	end
end

function core.HellfireCitadel:Gorefiend()
	if core.type == "UNIT_DIED" and core.destID == "93145" then
		core:getAchievementSuccess()			
	end
end

function core.HellfireCitadel:ShadowLordIskar()
	if core.type == "SPELL_AURA_REMOVED" and core.spellId == 179202 and core.achievementsFailed[1] == false then
		eyeOfAnzuPlayer = nil
	end

	--If player has had the Eye of Anzu for more than 5 seconds then fail the achievement
	if core.type == "SPELL_AURA_APPLIED" and core.spellId == 179202 and core.achievementsFailed[1] == false then
		eyeOfAnzuPlayer = core.destName
		firstPickup = true
		C_Timer.After(5, function()
			if eyeOfAnzuPlayer == core.destName then
				core:getAchievementFailedWithMessageAfter("by " .. core.destName)			
			end
		end)				
	end

	if firstPickup == false then
		if core.groupSize > 1 then
			for i = 1, core.groupSize do
				local unit = nil
				if core.chatType == "PARTY" then
					if i < core.groupSize then
						unit = "party" .. i
					else
						unit = "player"
					end
				elseif core.chatType == "RAID" then
					unit = "raid" .. i
				end

				if UnitBuff(unit, GetSpellInfo(179202)) then
					eyeOfAnzuPlayer = core.destName
					firstPickup = true
					C_Timer.After(5, function()
						if eyeOfAnzuPlayer == core.destName then
							core:getAchievementFailedWithMessageAfter("by " .. core.destName)			
						end
					end)						
				end
			end
		else
			if UnitBuff("Player", GetSpellInfo(179202)) then
				eyeOfAnzuPlayer = core.destName
				firstPickup = true
				C_Timer.After(5, function()
					if eyeOfAnzuPlayer == core.destName then
						core:getAchievementFailedWithMessageAfter("by " .. core.destName)		
					end
				end)						
			end			
		end
	end
end

function core.HellfireCitadel:FelLordZakuun()
	if core.type == "SPELL_AURA_APPLIED" and core.spellId == 179428 then	
		C_Timer.After(6, function()
			if core.inCombat == true then
				core:getAchievementFailedWithMessageAfter("by " .. core.destName)
			end
		end)		
	end
end

function core.HellfireCitadel:Xhulhorac()
	if core.type == "SPELL_AURA_APPLIED" and core.spellId == 185656 then
		core:getAchievementFailedWithMessageAfter("by " .. core.destName)
	end
end

function core.HellfireCitadel:SocretharTheEternal()
	if core.type == "UNIT_DIED" and core.destID == "91938" and core.achievementsCompleted[1] == false then
		hauntingSoulsKilled = hauntingSoulsKilled + 1
		core:sendMessageDelay("Haunting Souls Killed: (" .. hauntingSoulsKilled .. "/20)",hauntingSoulsKilled,5)	
		if timerStarted == false then
			timerStarted = true
			core:sendMessage("Timer Started! 10 seconds remaining")
			C_Timer.After(10, function()
				if hauntingSoulsKilled < 20 and core.inCombat == true then
					core:sendMessage(GetAchievementLink(core.achievementIDs[1]) .. " FAILED! (" .. hauntingSoulsKilled .. "/20) Killed in time.")
					hauntingSoulsKilled = 0
					timerStarted = false
				elseif hauntingSoulsKilled >= 20 then
					core:getAchievementSuccess()
				end
			end)
		end
	end
end

function core.HellfireCitadel:TyrantVelhari()
	if core.type == "UNIT_DIED" and core.destID == "90270" then
		core:getAchievementFailed()	
	end
end

function core.HellfireCitadel:Mannoroth()
	if core.type == "SPELL_DAMAGE" and core.spellId == 182077 and core.destID == "91241" and core.overkill > 0 then
		core:getAchievementSuccess()			
	end
end

function core.HellfireCitadel:Archimonde()
	if core.type == "SPELL_SUMMON" and core.destID == "92208" then
		doomfireSpawned = true
		core:getAchievementSuccess()

		--Cancel the timer if started
		if timer ~= nil then
			core:sendMessage(core:getAchievement() .. " Timer paused. Doomfire has spawned")
			timer:Cancel()
			timerStarted = false
		end
	end

	if core.destID == "92208" and core.overkill > 0 then
		--Cancel the timer if has already started
		if timerStarted == false then
			timerStarted = true
			core:sendMessage(core:getAchievement() .. " Timer Started 120 seconds to kill boss. (Timer will restart if another Doomfire spawns)")
			timer = C_Timer.NewTimer(120, function()
				--If boss health is above 40% then wait for another Doomfire to spawn
				if core:getHealthPercent("boss1") > 40 then
					core:sendMessage(core:getAchievement() .. " FAILED!. Wait for another Doomfire to spawn before taking boss below 40% health")
				else
					core:getAchievementFailed()
				end 
			end)
		end
	end

	--If boss health is below 40% and no Doomfire has spawned then fail the achievement
	if core:getHealthPercent("boss1") < 40 and doomfireSpawned == false then
		core:getAchievementFailed()
	end
end

function core.HellfireCitadel:ClearVariables()
	------------------------------------------------------
	---- Iron Reaver
	------------------------------------------------------
	hellfireGuardianKilled = 0

	------------------------------------------------------
	---- Hellfire High Council
	------------------------------------------------------
	timerStarted = false
	unitsKilled = 0	

	------------------------------------------------------
	---- Shadow-Lord Iskar
	------------------------------------------------------
	eyeOfAnzuPlayer = nil
	firstPickup = false

	------------------------------------------------------
	---- Socrethar the Eternal
	------------------------------------------------------
	hauntingSoulsKilled = 0

	------------------------------------------------------
	---- Archimonde
	------------------------------------------------------
	doomfireSpawned = false
	if timer ~= nil then
        timer:Cancel()
    end
end

function core.HellfireCitadel:InstanceCleanup()
    core.HellfireCitadel.Events:UnregisterEvent("UNIT_HEALTH")
    core.HellfireCitadel.Events:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
end

function core.HellfireCitadel:InitialSetup()
	core.HellfireCitadel.Events:RegisterEvent("UNIT_HEALTH")
	core.HellfireCitadel.Events:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end

core.HellfireCitadel.Events:SetScript("OnEvent", function(self, event, ...)
    return self[event] and self[event](self, event, ...)
end)

function core.HellfireCitadel.Events:UNIT_HEALTH(self, unitID)
	if core.Instances.WarlordsOfDraenor.Raids.HellfireCitadel.boss1.enabled == true then
		local unitType, _, _, _, _, destID, spawn_uid_dest = strsplit("-", UnitGUID(unitID));
		if destID == "90018" then
			--If health is less than 90% then fail the achievement
			if core:getHealthPercent(unitID) < 90 then
				core:getAchievementFailed()			
			end
		end
	end
end

function core.HellfireCitadel.Events:CHAT_MSG_MONSTER_YELL(self, message, sender)
	if message == "GHHAAAaaa!!!" then
		core:getAchievementFailed()				
	end
end