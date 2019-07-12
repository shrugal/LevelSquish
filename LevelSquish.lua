local FACTOR = 2

-- Squishing utility
local t = {}
local function tbl(...)
    for i=1, select('#', ...) do
        t[i] = select(i, ...)
    end
end
local function tblWipe(t, ...)
    wipe(t)
    return ...
end
local function squish(val)
    return val and math.ceil(val / FACTOR)
end
local function unsquish(val)
    return val and val * FACTOR
end
local function squishFn(fn, i, j, k, l, m)
    return function (...)
        if not i then
            return squish(fn(...))
        else
            tbl(fn(...))
            if i then t[i] = squish(t[i]) end
            if j then t[j] = squish(t[j]) end
            if k then t[k] = squish(t[k]) end
            if l then t[l] = squish(t[l]) end
            if m then t[m] = squish(t[m]) end
            return tblWipe(t, unpack(t))
        end
    end
end
local function unsquishFn(fn)
    return function (i) return fn(squish(i)) end
end
local function squishTbl(t)
    for i,v in pairs(t) do
        t[i] = type(v) == "number" and squish(v) or v
    end
    return t
end

-- Squish constants
MIN_BONUS_HONOR_LEVEL = squish(MIN_BONUS_HONOR_LEVEL)
MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY = squish(MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY)
NPE_TUTORIAL_COMPLETE_LEVEL = squish(NPE_TUTORIAL_COMPLETE_LEVEL)
PALADINPOWERBAR_SHOW_LEVEL = squish(PALADINPOWERBAR_SHOW_LEVEL)
RAID_FINDER_SHOW_LEVEL = squish(RAID_FINDER_SHOW_LEVEL)
SCENARIOS_HIDE_ABOVE_LEVEL = squish(SCENARIOS_HIDE_ABOVE_LEVEL)
SCENARIOS_SHOW_LEVEL = squish(SCENARIOS_SHOW_LEVEL)
SHADOW_ORBS_SHOW_LEVEL = squish(SHADOW_ORBS_SHOW_LEVEL)
SHARDBAR_SHOW_LEVEL = squish(SHARDBAR_SHOW_LEVEL)
SHOW_CONQUEST_LEVEL = squish(SHOW_CONQUEST_LEVEL)
SHOW_LFD_LEVEL = squish(SHOW_LFD_LEVEL)
SHOW_MASTERY_LEVEL = squish(SHOW_MASTERY_LEVEL)
SHOW_PVP_LEVEL = squish(SHOW_PVP_LEVEL)
SHOW_PVP_TALENT_LEVEL = squish(SHOW_PVP_TALENT_LEVEL)
SHOW_SPEC_LEVEL = squish(SHOW_SPEC_LEVEL)
SHOW_TALENT_LEVEL = squish(SHOW_TALENT_LEVEL)

-- Squish tables
squishTbl(MAX_PLAYER_LEVEL_TABLE)
for i,v in pairs(SPLASH_SCREENS) do
    v.minDisplayLevel = squish(v.minDisplayLevel)
    v.minQuestLevel = squish(v.minQuestLevel)
end

-- Squish function return values
C_Map.GetMapLevels = squishFn(C_Map.GetMapLevels, 1, 2)
C_SpecializationInfo.GetPvpTalentSlotUnlockLevel = squishFn(C_SpecializationInfo.GetPvpTalentSlotUnlockLevel)
C_SpecializationInfo.GetPvpTalentUnlockLevel = squishFn(C_SpecializationInfo.GetPvpTalentUnlockLevel)
GetAuctionItemInfo = squishFn(GetAuctionItemInfo, 6)
GetEffectivePlayerMaxLevel = squishFn(GetEffectivePlayerMaxLevel)
GetItemInfo = squishFn(GetItemInfo, 5)
GetLFGDungeonInfo = squishFn(GetLFGDungeonInfo, 4, 5, 6, 7, 8)
GetMaxLevelForExpansionLevel = squishFn(GetMaxLevelForExpansionLevel)
GetMaxPlayerLevel = squishFn(GetMaxPlayerLevel)
GetRandomScenarioInfo = squishFn(GetRandomScenarioInfo, 5, 6)
GetRestrictedAccountData = squishFn(GetRestrictedAccountData, 1)
GetRFDungeonInfo = squishFn(GetRFDungeonInfo, 5, 6)
GetSpellAvailableLevel = squishFn(GetSpellAvailableLevel)
GetSpellLevelLearned = squishFn(GetSpellLevelLearned)
GetTrainerServiceInfo = squishFn(GetTrainerServiceInfo, 4)
UnitEffectiveLevel = squishFn(UnitEffectiveLevel)
UnitLevel = squishFn(UnitLevel)

-- Unsquish function parameter
IsLevelAtEffectiveMaxLevel = unsquishFn(IsLevelAtEffectiveMaxLevel)

-- Some things can only be replaced after the corresponding addon has been loaded
local f = CreateFrame("Frame")
f:SetScript("OnEvent", function (_, _, name)
    if name == "Blizzard_EncounterJournal" then
        function EncounterJournal_CheckLevelAndDisplayLootTab()
            local instanceSelect = EncounterJournal.instanceSelect;
            if(UnitLevel("player") < 50) then
                PanelTemplates_HideTab(instanceSelect, instanceSelect.LootJournalTab.id)
            else
                PanelTemplates_ShowTab(instanceSelect, instanceSelect.LootJournalTab.id)
            end
        end
    end
end)
f:RegisterEvent("ADDON_LOADED")

-- Squish required item levels in tooltips
local PATTERN_MIN_LEVEL = ITEM_MIN_LEVEL:gsub("%%d", "(%%d+)")
local PATTERN_MIN_RANGE = ITEM_LEVEL_RANGE:gsub("%%d", "(%%d+)")
GameTooltip:HookScript('OnTooltipSetItem', function(self)
    local lines = self:NumLines()
    for i=2, lines do
        local line = _G["GameTooltipTextLeft" .. i]:GetText()
        if not line then
            break
        end

        local from, to = line:match(PATTERN_MIN_RANGE)
        if from and to then
            _G["GameTooltipTextLeft" .. i]:SetText(ITEM_LEVEL_RANGE:format(squish(from), squish(to)))
            break
        end

        local lvl = line:match(PATTERN_MIN_LEVEL)
        if lvl then
            _G["GameTooltipTextLeft" .. i]:SetText(ITEM_MIN_LEVEL:format(squish(lvl)))
            break
        end
    end
end)

-- Squish player level in /who results
local PATTERN_WHO = WHO_LIST_FORMAT:gsub("%-", "%%%-"):gsub("%[", "%%%["):gsub("%]", "%%%]"):gsub("%%d", "(%%d+)"):gsub("%%s", "(.+)")
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function (_, _, txt, ...)
    local link, name, level, race, class, zone = txt:match(PATTERN_WHO)
    if link then
        return false, WHO_LIST_FORMAT:format(link, name, squish(level), race, class, zone), ...
    end
    return false
end)
