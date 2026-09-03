Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.modules = Heim.modules or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local Auras = {};
Auras.name = "Auras";

local WINDOW_MODE_IOTA = HeimUtils.Iota();

local AURAS_WINDOW_MODE = {
    PROGRESS = WINDOW_MODE_IOTA(),
    PROGRESS_FLIPPED = WINDOW_MODE_IOTA(),
    ICON = WINDOW_MODE_IOTA()
};

local function GetVirtualNameFromMode(mode)
    if (mode == AURAS_WINDOW_MODE.PROGRESS) then
        return "AuraProgressBar"
    elseif (mode == AURAS_WINDOW_MODE.PROGRESS_FLIPPED) then
        return "AuraProgressBarReversed"
    elseif (mode == AURAS_WINDOW_MODE.ICON) then
        return "AuraIcon"
    else
        HeimUtils.UNREACHABLE(
            "GetVirtualNameFromMode expected one of AURAS_WINDOW_MODE got `%s`",
            tostring(mode))
    end
end

local Window = Heim.STACK:Subclass();
function Window:New(...) return Heim.STACK.New(self, ...); end

function Window:Initialize(name, mode, gap, type, auraMode)
    Heim.STACK.Initialize(self, name, mode, gap, type);
    self.auraMode = auraMode;
    self.trackers = {};
    local function factory(pool)
        return ZO_ObjectPool_CreateNamedControl(name .. "Tracker",
                                                GetVirtualNameFromMode(auraMode),
                                                pool, GuiRoot);
    end
    local function reset(control)
        control:SetHidden(true);
        control:ClearAnchors();
    end
    self.pool = ZO_ObjectPool:New(factory, reset);
end

function Window:AddTracker(abilityId, unitTag)
    if (self.trackers[abilityId] ~= nil) then return nil; end
    local tracker = {};
    tracker.control = self.pool:AcquireObject();
    tracker.control:SetHidden(true);
    tracker.icon = GetControl(tracker.control, "Icon");
    if (self.auraMode == AURAS_WINDOW_MODE.PROGRESS or self.auraMode ==
        AURAS_WINDOW_MODE.PROGRESS_FLIPPED) then
        tracker.bar = GetControl(tracker.control, "Bar");
        tracker.bar:SetHeight(tracker.bar:GetHeight() - 1);
    end
    tracker.label = GetControl(tracker.control, "Text");
    -- EVENT_EFFECT_CHANGED (number eventCode, MsgEffectResult changeType, number effectSlot, string effectName, string unitTag, number beginTime, number endTime, number stackCount, string iconName, string buffType, BuffEffectType effectType, AbilityType abilityType, StatusEffectType statusEffectType, string unitName, number unitId, number abilityId, CombatUnitType sourceType)
    function tracker.func(_, changeType, _, effectName, unitTag, beginTime,
                          endTime, stackCount, iconName, buffType, effectType,
                          abilityType, statusEffectType, unitName, unitId,
                          abilityId, sourceType)
        if (changeType == EFFECT_RESULT_GAINED and unitTag == "group") then
            tracker.stackCount = (tracker.stackCount or 0) + (stackCount or 1);
        else
            tracker.stackCount = stackCount;
        end
        if (tracker.max == nil or tracker.max < endTime - beginTime) then
            tracker.max = endTime - beginTime;
        end
        tracker.icon:SetTexture(iconName);
        if (effectType == BUFF_EFFECT_TYPE_BUFF) then
            if (self.auraMode == AURAS_WINDOW_MODE.PROGRESS or self.auraMode ==
                AURAS_WINDOW_MODE.PROGRESS_FLIPPED) then
                ZO_StatusBar_SetGradientColor(tracker.bar,
                                              ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_MAGICKA])
            end
        elseif (BUFF_EFFECT_TYPE_DEBUFF) then
            if (self.auraMode == AURAS_WINDOW_MODE.PROGRESS or self.auraMode ==
                AURAS_WINDOW_MODE.PROGRESS_FLIPPED) then
                local TRAUMA_COLOR = ZO_ColorDef:New(0.69, 0.2, 0.9, 0.75);
                tracker.bar:SetColor(TRAUMA_COLOR:UnpackRGBA())
            end
        end
        if ((self.auraMode == AURAS_WINDOW_MODE.PROGRESS or self.auraMode ==
            AURAS_WINDOW_MODE.PROGRESS_FLIPPED) and tracker.max == 0) then
            local PERMA_COLOR = ZO_ColorDef:New("6b603a");
            tracker.bar:SetColor(PERMA_COLOR:UnpackRGBA())
        end
        if (changeType == EFFECT_RESULT_GAINED or changeType ==
            EFFECT_RESULT_UPDATED) then
            if (self.auraMode == AURAS_WINDOW_MODE.PROGRESS or self.auraMode ==
                AURAS_WINDOW_MODE.PROGRESS_FLIPPED) then
                if (tracker.endTime == nil or tracker.endTime < endTime) then
                    ZO_StatusBar_SmoothTransition(tracker.bar, tracker.max,
                                                  tracker.max, true)
                end
            end
            Heim.STACK.AppendChild(self, tracker.control);
            Heim.EM:RegisterForUpdate(self.name .. abilityId, 200,
                                      function(gameTimeS)
                if (self.auraMode == AURAS_WINDOW_MODE.PROGRESS or self.auraMode ==
                    AURAS_WINDOW_MODE.PROGRESS_FLIPPED) then
                    ZO_StatusBar_SmoothTransition(tracker.bar,
                                                  endTime - gameTimeS / 1000,
                                                  tracker.max)
                end
            end)
        elseif (changeType == EFFECT_RESULT_FADED) then
            if (unitTag == "group") then
                tracker.stackCount = (tracker.stackCount or 0) -
                                         (stackCount or 1);
                if (tracker.stackCount < 1) then
                    Heim.STACK.RemoveChild(self, tracker.control);
                    Heim.EM:UnregisterForUpdate(self.name .. abilityId);
                end
            else
                Heim.STACK.RemoveChild(self, tracker.control);
                Heim.EM:UnregisterForUpdate(self.name .. abilityId);
            end
        end
        tracker.endTime = endTime;
        if (self.auraMode == AURAS_WINDOW_MODE.ICON) then
            if (tracker.stackCount > 0) then
                tracker.label:SetText(string.format("(%d)", tracker.stackCount));
            end
        else
            if (tracker.stackCount > 0) then
                tracker.label:SetText(string.format("%s (%d)", effectName,
                                                    tracker.stackCount));
            else
                tracker.label:SetText(effectName);
            end

        end
    end
    tracker.control:RegisterForEvent(EVENT_EFFECT_CHANGED, tracker.func);
    tracker.control:AddFilterForEvent(EVENT_EFFECT_CHANGED,
                                      REGISTER_FILTER_UNIT_TAG_PREFIX,
                                      unitTag or "player");
    tracker.control:AddFilterForEvent(EVENT_EFFECT_CHANGED,
                                      REGISTER_FILTER_ABILITY_ID, abilityId);
    self.trackers[abilityId] = tracker;
end

function Auras.defaultConfig()
    return {
        enable = false,
        windows = {
            --     {
            --         position = Heim.ANCHOR:New({BOTTOM, ZO_ActionBar1, TOP, 0, -32}),
            --         auras = {{aura = 93109, target = "player"}},
            --         stackMode = Heim.STACK_MODE.LEFT,
            --         gap = 4,
            --         auraMode = Heim.AURAS_WINDOW_MODE.ICON,
            --         scale = 1,
            --         resize = false,
            --     }
        }
    };
end

local function InitBuffsFromNothing(window_idx)
    local buffCount = GetNumBuffs("player");
    if (buffCount > 0) then
        for jt_jter = 1, buffCount do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount,
                  iconFilename, buffType, effectType, abilityType,
                  statusEffectType, abilityId, canClickOff, castByPlayer =
                GetUnitBuffInfo("player", jt_jter);
            for ability_id, jt in pairs(Auras.windows[window_idx].trackers) do
                if (ability_id == abilityId) then
                    jt.func(nil, EFFECT_RESULT_GAINED, nil, buffName, "player",
                            timeStarted, timeEnding, stackCount, iconFilename,
                            buffType, effectType, abilityType, statusEffectType,
                            nil, nil, abilityId, nil);
                end
            end
        end
    end
end

function Auras.Init()
    Auras.windows = {};
    local conf = Heim.config.Auras.enable and Heim.config.Auras or
                     Auras.defaultConfig();
    for it_iter, it in pairs(conf.windows) do
        HeimUtils.RunWhenTrue(function() return it.position:IsValid() end,
                              function()
            Auras.windows[it_iter] = Window:New("AuraWindow" .. it_iter,
                                                it.stackMode, it.gap, nil,
                                                it.auraMode);
            it.control = Auras.windows[it_iter].control;
            it.position:AddToControl(it.control, true);
            it.control:SetResizeToFitDescendents(it.resize or false);
            for jt_jter, jt in pairs(it.auras) do
                Auras.windows[it_iter]:AddTracker(jt.aura, jt.target);
            end
            InitBuffsFromNothing(it_iter);
            HUD_SCENE:AddFragment(Auras.windows[it_iter]);
            HUD_UI_SCENE:AddFragment(Auras.windows[it_iter]);
            SIEGE_BAR_SCENE:AddFragment(Auras.windows[it_iter]);
            SIEGE_BAR_UI_SCENE:AddFragment(Auras.windows[it_iter]);
            table.insert(ZO_NO_DEAD_FRAGMENTS, Auras.windows[it_iter]);
            Auras.windows[it_iter].control:SetScale(it.scale)
        end)
    end
    Heim.EM:RegisterForEvent(Auras.name, EVENT_PLAYER_ACTIVATED, function()
        for it_iter, it in pairs(Auras.windows) do
            for jt_jter, jt in pairs(it.trackers) do
                it:RemoveChild(jt.control);
            end
            InitBuffsFromNothing(it_iter);
        end
    end)
end

Heim.AURAS = Auras;
Heim.AURAS_WINDOW_MODE = AURAS_WINDOW_MODE;
table.insert(Heim.inits, Auras.Init);
table.insert(Heim.defaults,
             function() Heim.config.Auras = Auras.defaultConfig(); end);
