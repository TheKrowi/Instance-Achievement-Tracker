--------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...

------------------------------------------------------
---- The Motherlode Bosses
------------------------------------------------------
core._1594 = {}

------------------------------------------------------
---- Mogul Razdunk
------------------------------------------------------
local playersHit = {}

function core._1594:CoinOperatedCrowdPummeler()
    if core.type == "UNIT_DIED" and core.destID == "142625" then
        core:getAchievementSuccess()
    end
end

function core._1594:MogulRazdunk()
    --Defeat Mogul Razdunk without being struck by Gatling Gun, Micro Missiles, Big Red Rocket, or a direct hit from Drill Smash in The MOTHERLODE!! on Mythic difficulty.
    --Gatling Gun 260279
    --Micro Missiles 276234
    --Drill Smash 270926
    --Big Red Rocket 270277

    if (core.type == "SPELL_AURA_APPLIED" and core.spellId == 260279) or (core.type == "SPELL_DAMAGE" and core.spellId == 276234) or (core.type == "SPELL_DAMAGE" and core.spellId == 270926) or (core.type == "SPELL_DAMAGE" and core.spellId == 270277) then
        --If someone gets hit by the ability, check if they need the achievement or not
        if core.destName ~= nil then
            local name, realm = strsplit("-", core.destName)  
            if UnitIsPlayer(name) then
                --Detect the reason the player has failed the achievement
                local reason = ""
                if core.spellId == 260279 then
                    reason = "Gatling Gun Damage"
                elseif core.spellId == 276234 then
                    reason = "Micro Missile Damage"
                elseif core.spellId == 270926 then
                    reason = "Drill Smash Direct Hit"
                elseif core.spellId == 270277 then
                    reason = "Big Red Rocket Direct Hit"
                end
                if playersHit[core.destName] == nil then
                    --Players has not been hit already
                    --Check if the player actually needs the achievement
                    if core:has_value(core.currentBosses[1].players, core.destName) then
                        --Player needs achievement but has failed it
                        core:sendMessage(core.destName .. " has failed " .. GetAchievementLink(core.achievementIDs[1]) .. "(Reason: " .. reason .. ") (Personal Achievement)")
                    end
                    playersHit[core.destName] = true
                end
            else
                print(core.destName .. " is not a player")
            end
        else
            print("core.destName is nil")
        end
    end
end

function core._1594:ClearVariables()
    ------------------------------------------------------
    ---- Mogul Razdunk
    ------------------------------------------------------
    playersHit = {}
end