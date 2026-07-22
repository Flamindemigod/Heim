Heim = Heim or {};
Heim.patches = Heim.patches or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local function defaultConfCompass()
    return {
        enable = false,
        position = Heim.ANCHOR:New(TOP, GuiRoot, TOP, 0, 58),
        size = {
            h = ZO_COMPASS_FRAME_HEIGHT_GAMEPAD,
            w = function()
                local MIN_WIDTH = 400
                local MAX_WIDTH = 800
                local screenWidth = GuiRoot:GetWidth()
                return zo_clamp(screenWidth * .35, MIN_WIDTH, MAX_WIDTH)
            end
        }
    };
end

local function defaultConfHousingHud()
    return {
        enable = false,
        position = Heim.ANCHOR:New(TOPLEFT, ZO_PromotionalEventTracker_TL,
                                   BOTTOMLEFT)
    };
end

function Heim.ZOPatches()
    local compass = Heim.config.ZOCompass;
    function COMPASS_FRAME:ApplyStyle()
        compass = Heim.IsEnabled(Heim.config.ZOCompass) and
                      Heim.config.ZOCompass or defaultConfCompass();
        local frameHeight = ZO_Eval(compass.size.h);
        Heim.config.ZOCompass.control = self.control;
        ApplyTemplateToControl(self.control,
                               ZO_GetPlatformTemplate("ZO_CompassFrame"))
        compass.position:AddToControl(self.control, true);
        self.control:SetHeight(frameHeight)
        local gamepadMode = IsInGamepadPreferredMode()
        local center = self.control:GetNamedChild("Center")
        center:GetNamedChild("TopMungeOverlay"):SetHidden(gamepadMode)
        center:GetNamedChild("BottomMungeOverlay"):SetHidden(gamepadMode)

        if gamepadMode then
            if self.bossBarReady and self.bossBarActive then
                local frame = self.control
                frame:SetHeight(frameHeight - 1)
                frame:GetNamedChild("Left"):SetHeight(frameHeight - 1)
                frame:GetNamedChild("Right"):SetHeight(frameHeight - 1)
            end
        end
    end

    function COMPASS_FRAME:UpdateWidth()
        compass = Heim.IsEnabled(Heim.config.ZOCompass) and
                      Heim.config.ZOCompass or defaultConfCompass();
        self.control:SetWidth(ZO_Eval(compass.size.w));
    end
    local housingHud = Heim.config.ZOHousingHud;
    function ZO_HouseInformationTracker:InitializeStyles()
        housingHud = Heim.IsEnabled(Heim.config.ZOHousingHud) and
                         Heim.config.ZOHousingHud or defaultConfHousingHud();
        local style = {
            CONTAINER_PRIMARY_ANCHOR = ZO_Anchor:New(TOPLEFT),
            CONTAINER_SECONDARY_ANCHOR = ZO_Anchor:New(TOPRIGHT),

            FONT_HEADER = "ZoFontGamepadBold27",
            FONT_POPULATION = "ZoFontGamepad34",
            FONT_SUBLABEL = "ZoFontGamepad34",
            FONT_TAGS = "ZoFontGamepad34",

            POPULATION_HEADERLABEL_PRIMARY_ANCHOR = ZO_Anchor:New(TOPRIGHT,
                                                                  self.headerLabel,
                                                                  BOTTOMRIGHT,
                                                                  0, 10),

            POPULATION_SUBLABEL_PRIMARY_ANCHOR = ZO_Anchor:New(TOPRIGHT,
                                                               self.subLabel,
                                                               BOTTOMRIGHT, 0, 0),

            TAGS_LABEL_PRIMARY_ANCHOR = ZO_Anchor:New(TOPRIGHT,
                                                      self.populationLabel,
                                                      BOTTOMRIGHT, 0, 0),

            TEXT_HORIZONTAL_ALIGNMENT = TEXT_ALIGN_RIGHT,

            TOP_LEVEL_PRIMARY_ANCHOR = housingHud.position:AsZOAnchor(),
            TOP_LEVEL_SECONDARY_ANCHOR = Heim.IsEnabled(Heim.config.ZOHousingHud) and
                nil or
                ZO_Anchor:New(RIGHT, GuiRoot, RIGHT, -15, 0, ANCHOR_CONSTRAINS_X)
        };
        self.styles = {keyboard = style, gamepad = style}

        ZO_HUDTracker_Base.InitializeStyles(self)
    end
end

local function init()
    HeimUtils.RunWhenTrue(function()
        return Heim.config.ZOCompass.position:IsValid()
    end, function()
        COMPASS_FRAME:ApplyStyle();
        COMPASS_FRAME:UpdateWidth();
    end)
    HeimUtils.RunWhenTrue(function()
        return Heim.config.ZOHousingHud.position:IsValid()
    end, function() HOUSE_INFORMATION_TRACKER:InitializeStyles() end)
end
table.insert(Heim.inits, init);
table.insert(Heim.defaults,
             function() Heim.config.ZOCompass = defaultConfCompass() end);
