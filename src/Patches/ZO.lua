Heim = Heim or {};
Heim.patches = Heim.patches or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local function defaultConf()
    return {
        enable = false,
        position = ZO_Anchor:New(TOP, GuiRoot, TOP, 0, 58),
        size = {h = ZO_COMPASS_FRAME_HEIGHT_GAMEPAD, w = nil}
    };
end

function Heim.ZOPatches()
    local function ZOCompassDefaultConfig()
    end
    local compass = Heim.config.ZOCompass;
    function COMPASS_FRAME:ApplyStyle()
        compass = Heim.config.ZOCompass.enable and Heim.config.ZOCompass or
                      defaultConf();
        Heim.config.ZOCompass.control = self.control;
        ApplyTemplateToControl(self.control,
                               ZO_GetPlatformTemplate("ZO_CompassFrame"))
        self.control:ClearAnchors();
        compass.position:AddToControl(self.control);
        self.control:SetHeight(compass.size.h)
        local gamepadMode = IsInGamepadPreferredMode()
        local center = self.control:GetNamedChild("Center")
        center:GetNamedChild("TopMungeOverlay"):SetHidden(gamepadMode)
        center:GetNamedChild("BottomMungeOverlay"):SetHidden(gamepadMode)

        if gamepadMode then
            if self.bossBarReady and self.bossBarActive then
                local frame = self.control
                frame:SetHeight(compass.size.h - 1)
                frame:GetNamedChild("Left"):SetHeight(compass.size.h - 1)
                frame:GetNamedChild("Right"):SetHeight(compass.size.h - 1)
            end
        end
    end

    function COMPASS_FRAME:UpdateWidth()
        local MIN_WIDTH = 400
        local MAX_WIDTH = 800
        if (compass.size.w ~= nil) then
            self.control:SetWidth(compass.size.w);
        else
            local screenWidth = GuiRoot:GetWidth()
            self.control:SetWidth(zo_clamp(screenWidth * .35, MIN_WIDTH,
                                           MAX_WIDTH))
        end
    end
end

local function init()
    COMPASS_FRAME:ApplyStyle();
    COMPASS_FRAME:UpdateWidth();
end
table.insert(Heim.inits, init);
table.insert(Heim.defaults, function () Heim.config.ZOCompass = defaultConf() end);
