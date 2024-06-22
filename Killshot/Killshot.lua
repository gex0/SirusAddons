local version = "v1.16 (09-10-2010)";

-- Access help with '/kshot'

local killingstreak = 0;
loaded = 0;

local frame = CreateFrame("FRAME");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGOUT");

function frame:OnEvent(event)
	if (event == "ADDON_LOADED") then
		if (loaded == 0) then
			loaded = 1;
			if (savevar == 1) then
				kshot:Print("Killshot preferences are loaded. "); 
				if (soundpackvar == nil) then
					soundpackvar =  1;
					kshot:Print("Loaded soundpackvar = nil, changed it to [1]");
				end
				if (resetonzonechangevar == nil) then
					resetonzonechangevar = "yes";
					kshot:Print("Loaded resetonzonechangevar = nil, changed it to [yes]");
				end
				if (ksmsg == nil) then
					ksmsg = "pwned";
					kshot:Print("Loaded ksmsg = nil, changed it to [pwned]");
				end
				if (soundon == nil) then
					soundon = "yes";
					kshot:Print("Loaded soundon = nil, changed it to [yes]");
				end
				if (texton == nil) then
					texton = "yes";
					kshot:Print("Loaded texton = nil, changed it to [yes]");
				end
				if (emoteon == nil) then
					emoteon = "yes";
					kshot:Print("Loaded emoteon = nil, changed it to [yes]");
				end
				if (maxkillingstreak == nil) then
					maxkillingstreak = 0;
					kshot:Print("Loaded maxkillingstreak = nil, changed it to [0]");
				end
				if (totalkillingstreak == nil) then
					totalkillingstreak = 0;
					kshot:Print("Loaded totalkillingstreak = nil, changed it to [0]");
				end
				if (killingstreaktimes == nil) then
					killingstreaktimes = 0;
					kshot:Print("Loaded killingstreaktimes = nil, changed it to [0]");
				end
			else
				kshot:ResetAll();
			end
		end
	end
end

frame:SetScript("OnEvent", frame.OnEvent);


local options = { 
    type='group',
    args = {
	    reset = {
            type = 'execute',
            name = 'Reset Killshot streak',
            desc = 'Reset Killshot streak',
            func = "ResetKillshotStreak"
        },
		zone = {
            type = 'execute',
            name = 'Switch reset streak on zone change on/off',
            desc = 'Switch reset streak on zone change on/off',
            func = "ResetOnZoneChange"
        },
		soundpack = {
            type = 'execute',
            name = 'Switch between soundpacks',
            desc = 'Switch between soundpacks',
            func = "SoundPackChange"
        },
        checkguild = {
            type = 'execute',
            name = 'Check Guild versions',
            desc = 'Check Guild versions',
            func = "CheckGuildVersions"
        },
        checkbg = {
            type = 'execute',
            name = 'Check Battlegroup Versions',
            desc = 'Check BG Versions',
            func = "CheckBGVersions"
        },
        checkraid = {
            type = 'execute',
            name = 'Check Raid Versions',
            desc = 'Check Raid Versions',
            func = "CheckRaidVersions"
        },
        msg = {
            type = 'text',
            name = 'Killshot Message',
            desc = 'Killshot Message',
            usage = "<message>",
            get = "getMessage",
            set = "setMessage"
        },
		sound = {
            type = 'execute',
            name = 'Disable / Enable Sounds',
            desc = 'Disable / Enable Sounds',
            func = "SoundChange"
        },
		text = {
            type = 'execute',
            name = 'Disable / Enable Text',
            desc = 'Disable / Enable Text',
            func = "TextChange"
        },
		emote = {
            type = 'execute',
            name = 'Disable / Enable the Emote',
            desc = 'Disable / Enable the Emote',
            func = "EmoteChange"
        },
		resetall = {
            type = 'execute',
            name = 'Reset everything to the default',
            desc = 'Reset everything to the default',
            func = "ResetAll"
        },
		streak = {
            type = 'execute',
            name = 'Shows your current streak number',
            desc = 'Shows your current streak number',
            func = "EchoStreak"
        },
		streakmax = {
            type = 'execute',
            name = 'Shows your highest streak',
            desc = 'Shows your highest streak',
            func = "EchoMaxStreak"
        },
		streakavg = {
            type = 'execute',
            name = 'Shows your average streak',
            desc = 'Shows your average streak',
            func = "EchoAverageStreak"
        },
		streakdeleteall = {
            type = 'execute',
            name = 'Deletes all streak information (also your highest streak)',
            desc = 'Deletes all streak information (also your highest streak)',
            func = "ResetStreakInfo"
        }
    }
};

kshot = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0", "AceDB-2.0");
kshot:RegisterChatCommand({"/ks"}, options);
kshot:RegisterChatCommand({"/kshot"}, options);
kshot:RegisterChatCommand({"/killshot"}, options);
kshot:RegisterDB("kshotDB", "kshotDBPC");
kshot:RegisterDefaults("profile", {
		soundpath = "Interface\\AddOns\\Killshot\\sounds\\"
	} 
);

function kshot:OnEnable()
    self:RegisterEvent("kshot_SoundEvent", "SoundEventHandler");
    self:RegisterEvent("PLAYER_DEAD", "PlayerDeathHandler");
    self:RegisterEvent("CHAT_MSG_ADDON", "AddonMessageHandler");
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatLogEventHandler");
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ZoneChangedHandler");
end

function kshot:SoundEventHandler(sound)
    if not (PlaySoundFile(sound)) then
        self:ScheduleEvent("kshot_SoundEvent", 0.2, sound);
    end
end

function kshot:ZoneChangedHandler()
    if (resetonzonechangevar == "yes") then 
		kshot:Print("Killshot streaks reset on zone change. Typ /kshot zone to prevent this the next time."); 
		killingstreak = 0;
	end
end

function kshot:AddonMessageHandler(prefix, text, type, target)
    if not (target == UnitName("player")) then
        if (prefix == "kshot_txt") then
            kshot:Print(text);
        elseif (prefix == "kshot_ScrollingTextEvent") then
            kshot:ScrollText(text, false);
        elseif (prefix == "kshot_KillSoundEvent") then
            kshot:kshot_SoundPack(kshot:GetKillshotSound(tonumber(text)));
        elseif (prefix == "kshot_BGVersionCheckRequest") then
            kshot:kshot_SendVersionResponse(text, "BATTLEGROUND");
        elseif (prefix == "kshot_RaidVersionCheckRequest") then
            kshot:kshot_SendVersionResponse(text, "RAID");
        elseif (prefix == "kshot_GuildVersionCheckRequest") then
            kshot:kshot_SendVersionResponse(text, "GUILD");
        elseif (prefix == "kshot_VersionCheckResponse") then
            local nameLength = string.len(UnitName("player"));
            if (UnitName("player") == string.sub(text, 0, nameLength)) then
                local startIndex = nameLength + 2;
                kshot:Print(string.sub(text, startIndex));
            else
                kshot:Print("didn't match: " .. text);
            end
        end
    end
end

function kshot:CombatLogEventHandler(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags)
    if (not UnitIsPVP("Player")) then return; end;
    if (event == nil) then return; end;
    if (event == "PARTY_KILL") then
        if (sourceFlags == nil) then return; end;
        if (destName == nil) then return; end;
        if (destFlags == nil) then return; end;
        if (bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then
            if (bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER) then
               kshot:kshot_Killshot(UnitName("player"), destName);
            elseif (bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PET) == COMBATLOG_OBJECT_TYPE_PET) then
                if (bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER) then
                    if (not bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then
                        kshot:kshot_Killshot(UnitName("player"), "an enemy pet, " .. destName);
                    end
                end
            end
        end
    end
end


function kshot:EchoStreak()
	kshot:ScrollText("Your current streak is: " .. killingstreak, true);
end

function kshot:EchoMaxStreak()
	kshot:ScrollText("Your highest streak is: " .. maxkillingstreak, true);
end

function kshot:EchoAverageStreak()
	avg = totalkillingstreak/killingstreaktimes;
	if(totalkillingstreak == 0) then
		avg = 0;
	end
	kshot:ScrollText("Your average streak is: " .. avg, true);
	kshot:Print("Amount of killingstreaks: " .. killingstreaktimes);
	kshot:Print("Total amount of killingblows: " .. totalkillingstreak);
end

function kshot:ResetStreakInfo()
	killingstreak = 0;
	maxkillingstreak = 0;
	totalkillingstreak = 0;
	killingstreaktimes = 0;
	kshot:ScrollText("Your streak info has been deleted", true);
end


function kshot:kshot_Killshot(killer, victim)
	killingstreak = killingstreak + 1;
	totalkillingstreak = totalkillingstreak + 1;
	
	if(killingstreak == 1) then
		killingstreaktimes = killingstreaktimes + 1;
	end

	if(killingstreak > maxkillingstreak) then
		maxkillingstreak = killingstreak;
		kshot:ScrollText("You have set a new record! ", true);
	end
	
	if(emoteon == "yes") then
    	SendChatMessage(ksmsg .. " " .. victim .. "! Streak of " .. killingstreak .. "!", "EMOTE");
	end
	
    kshot:ScrollText("You " .. ksmsg .. " " ..  victim .. "! Streak of " .. killingstreak .. "!", false);
	
    SendAddonMessage("kshot_ScrollingTextEvent", killer .. " " .. ksmsg .. " " ..  victim .. "! Streak of " .. killingstreak .. "!", kshot:GetMessageGroup());
    SendAddonMessage("kshot_KillSoundEvent", killingstreak, kshot:GetMessageGroup());
	
    kshot:kshot_SoundPack(kshot:GetKillshotSound(killingstreak));
end

function kshot:PlayerDeathHandler()
    if (not UnitIsPVP("Player")) then return; end;
    killingstreak = 0;
end

function kshot:GetKillshotSound(kills)
	if (soundpackvar == 1) then
		if (kills > 19) then return "sp1-14.wav"; end;
		if (kills > 15) then return "sp1-13.wav"; end;
		if (kills > 12) then return "sp1-12.wav"; end;
		if (kills > 10) then return "sp1-11.wav"; end;
		if (kills >  9) then return "sp1-10.wav"; end;
		if (kills >  8) then return "sp1-9.wav"; end;
		if (kills >  7) then return "sp1-8.wav"; end;
		if (kills >  6) then return "sp1-7.wav"; end;
		if (kills >  5) then return "sp1-6.wav"; end;
		if (kills >  4) then return "sp1-5.wav"; end;
		if (kills >  3) then return "sp1-4.wav"; end;
		if (kills >  2) then return "sp1-3.wav"; end;
		if (kills >  1) then return "sp1-2.wav"; end;
		return "sp1-1.wav";
	elseif (soundpackvar == 2) then
		if (kills > 19) then return "sp2-14.wav"; end;
		if (kills > 15) then return "sp2-13.wav"; end;
		if (kills > 12) then return "sp2-12.wav"; end;
		if (kills > 10) then return "sp2-11.wav"; end;
		if (kills >  9) then return "sp2-10.wav"; end;
		if (kills >  8) then return "sp2-9.wav"; end;
		if (kills >  7) then return "sp2-8.wav"; end;
		if (kills >  6) then return "sp2-7.wav"; end;
		if (kills >  5) then return "sp2-6.wav"; end;
		if (kills >  4) then return "sp2-5.wav"; end;
		if (kills >  3) then return "sp2-4.wav"; end;
		if (kills >  2) then return "sp2-3.wav"; end;
		if (kills >  1) then return "sp2-2.wav"; end;
		return "sp2-1.wav";
	elseif (soundpackvar == 3) then
		if (kills > 19) then return "sp3-14.wav"; end;
		if (kills > 15) then return "sp3-13.wav"; end;
		if (kills > 12) then return "sp3-12.wav"; end;
		if (kills > 10) then return "sp3-11.wav"; end;
		if (kills >  9) then return "sp3-10.wav"; end;
		if (kills >  8) then return "sp3-9.wav"; end;
		if (kills >  7) then return "sp3-8.wav"; end;
		if (kills >  6) then return "sp3-7.wav"; end;
		if (kills >  5) then return "sp3-6.wav"; end;
		if (kills >  4) then return "sp3-5.wav"; end;
		if (kills >  3) then return "sp3-4.wav"; end;
		if (kills >  2) then return "sp3-3.wav"; end;
		if (kills >  1) then return "sp3-2.wav"; end;
		return "sp3-1.wav";
	elseif (soundpackvar == 4) then
		if (kills > 19) then return "sp4-14.mp3"; end;
		if (kills > 15) then return "sp4-13.mp3"; end;
		if (kills > 12) then return "sp4-12.mp3"; end;
		if (kills > 10) then return "sp4-11.mp3"; end;
		if (kills >  9) then return "sp4-10.mp3"; end;
		if (kills >  8) then return "sp4-9.mp3"; end;
		if (kills >  7) then return "sp4-8.mp3"; end;
		if (kills >  6) then return "sp4-7.mp3"; end;
		if (kills >  5) then return "sp4-6.mp3"; end;
		if (kills >  4) then return "sp4-5.mp3"; end;
		if (kills >  3) then return "sp4-4.mp3"; end;
		if (kills >  2) then return "sp4-3.mp3"; end;
		if (kills >  1) then return "sp4-2.mp3"; end;
		return "sp4-1.mp3";
	elseif (soundpackvar == 5) then
		if (kills > 19) then return "sp5-14.mp3"; end;
		if (kills > 15) then return "sp5-13.mp3"; end;
		if (kills > 12) then return "sp5-12.mp3"; end;
		if (kills > 10) then return "sp5-11.mp3"; end;
		if (kills >  9) then return "sp5-10.mp3"; end;
		if (kills >  8) then return "sp5-9.mp3"; end;
		if (kills >  7) then return "sp5-8.mp3"; end;
		if (kills >  6) then return "sp5-7.mp3"; end;
		if (kills >  5) then return "sp5-6.mp3"; end;
		if (kills >  4) then return "sp5-5.mp3"; end;
		if (kills >  3) then return "sp5-4.mp3"; end;
		if (kills >  2) then return "sp5-3.mp3"; end;
		if (kills >  1) then return "sp5-2.mp3"; end;
		return "sp5-1.mp3";
	end
end

function kshot:ScrollText(msg, check)
	if((texton=="yes") or (check == true))then
   		if (IsAddOnLoaded("Blizzard_CombatText")) then CombatText_AddMessage(msg, CombatText_StandardSCroll, 1, 0.1, 0.1, "crit", 0);        
   		elseif (IsAddOnLoaded("SCT")) then SCT:DisplayText(msg, {r=1.0, g=0.1, b=0.1}, 1, "event", 1, 1);
    	end
    	kshot:Print(msg);
	end
end

function kshot:ResetOnZoneChange()
    if (resetonzonechangevar == "yes") then 
		resetonzonechangevar = "no";
		kshot:Print("Killshot streaks won't reset on zone change");
	else 
		resetonzonechangevar = "yes"; 
		kshot:Print("Killshot streaks will reset on zone change");
	end
end


function kshot:SoundChange()
    if (soundon == "yes") then 
		soundon = "no";
		kshot:Print("Sounds are now disabled");
	else 
		soundon = "yes"; 
		kshot:Print("Sounds are now enabled");
	end
end

function kshot:TextChange()
    if (texton == "yes") then 
		texton = "no";
		kshot:Print("Text is now disabled");
	else 
		texton = "yes"; 
		kshot:Print("Text is now enabled");
	end
end

function kshot:EmoteChange()
    if (emoteon == "yes") then 
		emoteon = "no";
		kshot:Print("The emote is now disabled");
	else 
		emoteon = "yes"; 
		kshot:Print("The emote is now enabled");
	end
end

function kshot:SoundPackChange()
    if (soundpackvar == 1) then 
		soundpackvar = 2;
		kshot:Print("Using soundpack [female] now. ");
	elseif (soundpackvar == 2) then
		soundpackvar = 3;
		kshot:Print("Using soundpack [sexy] now. ");
	elseif (soundpackvar == 3) then
		soundpackvar = 4;
		kshot:Print("Using soundpack [Healy, Ahn'Qiraj] now. ");
	elseif (soundpackvar == 4) then
        	soundpackvar = 5;
        	kshot:Print("Using soundpack [Pudge] now. ");
    	elseif (soundpackvar == 5) then
        	soundpackvar = 1;
        	kshot:Print("Using soundpack [normal] now. ");
	end
end

function kshot:ResetKillshotStreak()
    killingstreak = 0;
	kshot:Print("Your Killshot streak has been resetted.");
end

function kshot:kshot_SendVersionResponse(requester, targetGroup)
    SendAddonMessage("kshot_VersionCheckResponse", requester .. ":" .. UnitName("player") .. " is on version " .. version , targetGroup);
end

function kshot:CheckBGVersions()
    SendAddonMessage("kshot_BGVersionCheckRequest", UnitName("player"), "BATTLEGROUND");
    kshot:Print(UnitName("player") .. " is on version " .. version);
end

function kshot:CheckGuildVersions()
    SendAddonMessage("kshot_GuildVersionCheckRequest", UnitName("player"), "GUILD");
    kshot:Print(UnitName("player") .. " is on version " .. version);
end

function kshot:CheckRaidVersions()
    SendAddonMessage("kshot_RaidVersionCheckRequest", UnitName("player"), "RAID");
    kshot:Print(UnitName("player") .. " is on version " .. version);
end

function kshot:kshot_SoundPack(sound)
	if(soundon == "yes") then
    	local soundfile = self.db.profile.soundpath .. sound;
   		kshot:SoundEventHandler(soundfile);
	end
end

function kshot:getSoundPack()
    return self.db.profile.soundpack;
end

function kshot:GetMessageGroup()
    local targetGroup = "RAID";
    if (kshot:IsInBattleground() == true) then
        targetGroup = "BATTLEGROUND";
    end
    return targetGroup;
end

function kshot:IsInBattleground()
    local inBG = false;
    local zone = GetZoneText();
    if ((zone == "Warsong Gulch") or (zone == "Eye of the Storm") or (zone == "Arathi Basin") or (zone == "Alterac Valley") or (zone == "Halaa") or (zone == "Wintergrasp") or (zone == "Strand of the Ancients") or (zone == "Isle of Conquest")) then
        inBG = true;
    end
    return inBG;
end

function kshot:getMessage()
    return ksmsg;
end

function kshot:setMessage(newmsg)
    ksmsg = newmsg;
end

function kshot:ResetAll()
	resetonzonechangevar = "yes";
	soundpackvar = 1;
	savevar = 1;
	ksmsg = "pwned";
	soundon = "yes";
	texton = "yes";
	emoteon = "yes";
	killingstreak = 0;
	maxkillingstreak = 0;
	totalkillingstreak = 0;
	killingstreaktimes = 0;
	kshot:Print("Killshot detected a new user. "); 
end