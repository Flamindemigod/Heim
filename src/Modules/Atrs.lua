Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.modules = Heim.modules or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

HeimAtrs = {};
HeimAtrs.name = string.format("%s_%s", Heim.name, "Atrs");

function HeimAtrs.defaultConf()
    return {
        enable = true,
        position = Heim.ANCHOR:New(BOTTOM, ZO_ActionBar1, TOP, 0, -32),
        flipped = false,
        scale = 1,
        layout = "stacked" -- stacked | pyramid
    };
end

local Bar = ZO_Object:Subclass();
function Bar:New(...)
    local bar = ZO_Object.New(self);
    bar:Initialize(...);
    return bar;
end

function Bar:Initialize(powerType, topLevel, reversed)
    self.res = 0
    self.maxRes = 0
    self.powerType = powerType;
    self.control = CreateControlFromVirtual(HeimAtrs.name .. powerType,
                                            topLevel, "HeimAtrBarContainer");
    self.control:SetHidden(false);
    self.attrText = GetControl(self.control, "Text")
    self.attrTextPercent = GetControl(self.control, "Percent")
    self.attrBar = GetControl(self.control, "Bar")
    self.reversed = reversed;

    ZO_StatusBar_SetGradientColor(self.attrBar,
                                  ZO_POWER_BAR_GRADIENT_COLORS[powerType])

    local powerUpdateEventHandler = ZO_MostRecentPowerUpdateHandler:New(
                                        HeimAtrs.name .. powerType,
                                        function(_, _, _, powerPool,
                                                 powerPoolMax)
            self:OnPowerUpdate(powerPool, powerPoolMax, false)
        end)
    powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_POWER_TYPE,
                                              powerType)
    powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, "player")
    self.control:RegisterForEvent(EVENT_PLAYER_ALIVE,
                                  function() self:Refresh() end)

    self:Refresh(true)
end

function Bar:Refresh(force)
    if force then self:ApplyStyle(); end

    local power, maxPower = GetUnitPower("player", self.powerType);
    self:OnPowerUpdate(power, maxPower, force)
end

function Bar:OnPowerUpdate(res, maxRes, force)
    self.res = res;
    self.maxRes = maxRes;
    ZO_StatusBar_SmoothTransition(self.attrBar, res, maxRes, force);
    self:UpdateResourceNumbers(res, maxRes);
end

function Bar:UpdateResourceNumbers(res, maxRes)
    self.attrText:SetText(ZO_AbbreviateAndLocalizeNumber(res,
                                                         NUMBER_ABBREVIATION_PRECISION_TENTHS,
                                                         false))
    self.attrTextPercent:SetText(self:FormatPercent(res, maxRes))
end

function Bar:FormatPercent(res, maxRes)
    local percent = 0
    local percentText
    if maxRes ~= 0 then percent = (res / maxRes) * 100 end
    if percent < 10 then
        percentText = ZO_CommaDelimitDecimalNumber(
                          zo_roundToNearest(percent, .1))
        percentText = ZO_FastFormatDecimalNumber(percentText)
    else
        percentText = zo_round(percent)
    end

    return percentText .. '%'
end

function Bar:ApplyStyle()
    if (self.reversed) then
        ApplyTemplateToControl(self.control:GetNamedChild("FrameLeft"),
                               ZO_GetPlatformTemplate(
                                   "ZO_PlayerAttributeFrameLeftArrow"))
        ApplyTemplateToControl(self.control:GetNamedChild("FrameRight"),
                               ZO_GetPlatformTemplate(
                                   "ZO_PlayerAttributeFrameRight"))
        ApplyTemplateToControl(self.control:GetNamedChild("FrameCenter"),
                               ZO_GetPlatformTemplate(
                                   "ZO_PlayerAttributeFrameCenter"))
        ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgLeft"),
                               ZO_GetPlatformTemplate(
                                   "ZO_PlayerAttributeBgLeftArrow"))
        ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgRight"),
                               ZO_GetPlatformTemplate(
                                   "ZO_PlayerAttributeBgRight"))
        ApplyTemplateToControl(
            self.control:GetNamedChild("BgContainerBgCenter"),
            ZO_GetPlatformTemplate("ZO_PlayerAttributeBgCenter"))
    else
        ApplyTemplateToControl(self.control:GetNamedChild("FrameLeft"),
                               ZO_GetPlatformTemplate(
                                   "ZO_PlayerAttributeFrameLeft"))
        ApplyTemplateToControl(self.control:GetNamedChild("FrameRight"),
                               ZO_GetPlatformTemplate(
                                   "ZO_PlayerAttributeFrameRightArrow"))
        ApplyTemplateToControl(self.control:GetNamedChild("FrameCenter"),
                               ZO_GetPlatformTemplate(
                                   "ZO_PlayerAttributeFrameCenter"))
        ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgLeft"),
                               ZO_GetPlatformTemplate("ZO_PlayerAttributeBgLeft"))
        ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgRight"),
                               ZO_GetPlatformTemplate(
                                   "ZO_PlayerAttributeBgRightArrow"))
        ApplyTemplateToControl(
            self.control:GetNamedChild("BgContainerBgCenter"),
            ZO_GetPlatformTemplate("ZO_PlayerAttributeBgCenter"))
    end

    ApplyTemplateToControl(self.attrBar, ZO_GetPlatformTemplate(
                               "ZO_PlayerAttributeStatusBar"))
    ApplyTemplateToControl(self.control, self.reversed and
                               "HeimAtrBar_Rev_Template" or
                               "HeimAtrBar_Template")

    local font = '$(BOLD_FONT)|' .. zo_round(self.attrBar:GetHeight() * 1 / 3) -
                     2 .. '|soft-shadow-thick'
    self.attrText:SetFont(font)
    self.attrTextPercent:SetFont(font)
end

function Bar:Show() self.control:SetHidden(false) end

function Bar:Hide() self.control:SetHidden(true) end

local HealthBar = Bar:Subclass();
function HealthBar:New(...) return Bar.New(self, ...); end

function HealthBar:Initialize(powerType, topLevel, reversed)
    Bar.Initialize(self, powerType, topLevel, reversed)
    self.curShield = 0
    self.curRes = 0
    self.curTrauma = 0

    self.shieldBar = CreateControlFromVirtual(
                         HeimAtrs.name .. powerType .. "Shield", self.attrBar,
                         "HeimAtrShieldBar")
    local SHIELD_COLOR = ZO_ColorDef:New(1, 0.49, 0.13, 0.50)
    self.shieldBar:SetColor(SHIELD_COLOR:UnpackRGBA())
    self.shieldBar:SetHeight(self.control:GetHeight())
    self:OnUpdateShield(0, true)

    self.traumaBar = CreateControlFromVirtual(
                         HeimAtrs.name .. powerType .. "Trauma", self.attrBar,
                         "HeimAtrTraumaBar")
    local TRAUMA_COLOR = ZO_ColorDef:New(0.69, 0.2, 0.9, 0.75);
    self.traumaBar:SetColor(TRAUMA_COLOR:UnpackRGBA())
    self.traumaBar:SetHeight(self.control:GetHeight())
    self:OnUpdateTrauma(0, true)

    local function onVisualPower(_, unitTag, unitAttributeVisual, statType,
                                 attributeType, powerType, oldValue, newValue,
                                 oldMaxValue, newMaxValue)
        local value = oldMaxValue == nil and oldValue or newValue
        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            self:OnUpdateShield(value, false)
        end
        if unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
            self:OnUpdateTrauma(value, false);
        end
    end

    local function onVisualPowerRemoved(_, unitTag, unitAttributeVisual,
                                        statType, attributeType, powerType,
                                        value, maxValue)
        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            self:OnUpdateShield(0, false)
        end
        if unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
            self:OnUpdateTrauma(0, false);
        end
    end

    topLevel:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, onVisualPower)
    topLevel:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,
                               REGISTER_FILTER_UNIT_TAG, "player")
    topLevel:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, onVisualPower)
    topLevel:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED,
                               REGISTER_FILTER_UNIT_TAG, "player")
    topLevel:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,
                              onVisualPowerRemoved)
    topLevel:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,
                               REGISTER_FILTER_UNIT_TAG, "player")
    self:Refresh(true);
end

function HealthBar:OnUpdateShield(shield, force)
    self.curShield = shield
    ZO_StatusBar_SmoothTransition(self.shieldBar, self.curShield, self.maxRes,
                                  force)
    self:UpdateResourceNumbers()
end

function HealthBar:OnUpdateTrauma(trauma, force)
    self.curTrauma = trauma
    ZO_StatusBar_SmoothTransition(self.traumaBar, self.curTrauma, self.maxRes,
                                  force)
    self:UpdateResourceNumbers()
end

function HealthBar:UpdateResourceNumbers()
    local str = tostring(ZO_AbbreviateAndLocalizeNumber(self.res,
                                                        NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT,
                                                        false));
    if self.curShield and self.curShield > 0 then
        str = string.format("%s [%s]", str,
                            ZO_AbbreviateAndLocalizeNumber(self.curShield,
                                                           NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT,
                                                           false));
    end
    if self.curTrauma and self.curTrauma > 0 then
        str = string.format("%s (-%s)", str,
                            ZO_AbbreviateAndLocalizeNumber(self.curTrauma,
                                                           NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT,
                                                           false));
    end
    self.attrText:SetText(str);
    self.attrTextPercent:SetText(self:FormatPercent(self.res, self.maxRes))
end

function HealthBar:ApplyStyle()
    Bar.ApplyStyle(self)
    ApplyTemplateToControl(self.shieldBar, ZO_GetPlatformTemplate(
                               "ZO_PlayerAttributeStatusBar"))
    ApplyTemplateToControl(self.traumaBar, ZO_GetPlatformTemplate(
                               "ZO_PlayerAttributeStatusBar"))
    if (self.shieldBar) then
        self.shieldBar:SetBarAlignment(
            self.reversed and BAR_ALIGNMENT_REVERSE or BAR_ALIGNMENT_NORMAL);
    end
    if (self.traumaBar) then
        self.traumaBar:SetBarAlignment(
            self.reversed and BAR_ALIGNMENT_REVERSE or BAR_ALIGNMENT_NORMAL);
    end
end

HeimAtrNoGloss = ZO_Object:Subclass()
function HeimAtrNoGloss:New() return ZO_Object.New(self) end
function HeimAtrNoGloss:SetMinMax() end
function HeimAtrNoGloss:SetValue() end

function HeimAtrs.Init()
    ZO_PlayerAttributeHealth:SetHidden(true)
    ZO_PlayerAttributeMagicka:SetHidden(true)
    ZO_PlayerAttributeStamina:SetHidden(true)
    ZO_PlayerAttributeSiegeHealth:ClearAnchors()
    ZO_PlayerAttributeWerewolf:ClearAnchors()
    ZO_PlayerAttributeMountStamina:ClearAnchors()
    local topLevel = GetControl("HeimAtr");
    local conf =
        Heim.IsEnabled(Heim.config.HeimAtrs) and Heim.config.HeimAtrs or
            HeimAtrs.defaultConf();
    Heim.config.HeimAtrs.control = topLevel;
    conf.position:AddToControl(topLevel, true);
    if (string.lower(conf.layout) == "stacked") then
        HeimAtrs.health =
            HealthBar:New(POWERTYPE_HEALTH, topLevel, conf.flipped);
        HeimAtrs.magicka = Bar:New(POWERTYPE_MAGICKA, topLevel, conf.flipped);
        HeimAtrs.stamina = Bar:New(POWERTYPE_STAMINA, topLevel, conf.flipped);
        HeimAtrs.health.control:ClearAnchors();
        HeimAtrs.health.control:SetAnchor(TOPLEFT, topLevel, TOPLEFT, 0, 0);
        HeimAtrs.magicka.control:ClearAnchors();
        HeimAtrs.magicka.control:SetAnchor(TOPLEFT, HeimAtrs.health.control,
                                           BOTTOMLEFT, 0, 12);
        HeimAtrs.stamina.control:ClearAnchors();
        HeimAtrs.stamina.control:SetAnchor(TOPLEFT, HeimAtrs.magicka.control,
                                           BOTTOMLEFT, 0, 12);
        ZO_PlayerAttributeSiegeHealth:SetAnchor(TOPRIGHT,
                                                HeimAtrs.health.control,
                                                conf.flipped and BOTTOMRIGHT or
                                                    BOTTOMLEFT, 0, 0)
        ZO_PlayerAttributeWerewolf:SetAnchor(TOPRIGHT, HeimAtrs.stamina.control,
                                             conf.flipped and BOTTOMRIGHT or
                                                 BOTTOMLEFT, 0, 0)
        ZO_PlayerAttributeMountStamina:SetAnchor(TOPRIGHT,
                                                 HeimAtrs.magicka.control,
                                                 conf.flipped and BOTTOMRIGHT or
                                                     BOTTOMLEFT, 0, 0)
    elseif (string.lower(conf.layout) == "pyramid") then
        HeimAtrs.health =
            HealthBar:New(POWERTYPE_HEALTH, topLevel, conf.flipped);
        HeimAtrs.magicka =
            Bar:New(POWERTYPE_MAGICKA, topLevel, not conf.flipped);
        HeimAtrs.stamina = Bar:New(POWERTYPE_STAMINA, topLevel, conf.flipped);
        HeimAtrs.health.control:ClearAnchors();
        HeimAtrs.health.control:SetAnchor(TOP, topLevel, TOP, 0, 0);
        HeimAtrs.magicka.control:ClearAnchors();
        HeimAtrs.magicka.control:SetAnchor(conf.flipped and TOPLEFT or TOPRIGHT,
                                           HeimAtrs.health.control, BOTTOM,
                                           conf.flipped and 8 or -8, 12);
        HeimAtrs.stamina.control:ClearAnchors();
        HeimAtrs.stamina.control:SetAnchor(conf.flipped and TOPRIGHT or TOPLEFT,
                                           HeimAtrs.health.control, BOTTOM,
                                           conf.flipped and -8 or 8, 12);
        ZO_PlayerAttributeSiegeHealth:SetAnchor(TOP, HeimAtrs.health.control,
                                                BOTTOM, 0, 0)
        ZO_PlayerAttributeWerewolf:SetAnchor(TOPRIGHT, conf.flipped and
                                                 HeimAtrs.stamina.control or
                                                 HeimAtrs.magicka.control,
                                             BOTTOMRIGHT, 0, 0)
        ZO_PlayerAttributeMountStamina:SetAnchor(TOPLEFT, conf.flipped and
                                                     HeimAtrs.magicka.control or
                                                     HeimAtrs.stamina.control,
                                                 BOTTOMLEFT, 0, 0)
    end
    HeimAtrs.frag = ZO_HUDFadeSceneFragment:New(topLevel);
    HUD_SCENE:AddFragment(HeimAtrs.frag);
    HUD_UI_SCENE:AddFragment(HeimAtrs.frag);
    SIEGE_BAR_SCENE:AddFragment(HeimAtrs.frag);
    SIEGE_BAR_UI_SCENE:AddFragment(HeimAtrs.frag);
    table.insert(ZO_NO_DEAD_FRAGMENTS, HeimAtrs.frag);
    topLevel:SetScale(conf.scale)
end

local function init()
    HeimUtils.RunWhenTrue(function()
        return Heim.config.HeimAtrs.position:IsValid()
    end, function()
        if (Heim.IsEnabled(Heim.config.HeimAtrs)) then HeimAtrs.Init() end
    end)
end

table.insert(Heim.inits, init);
table.insert(Heim.defaults,
             function() Heim.config.HeimAtrs = HeimAtrs.defaultConf(); end);
