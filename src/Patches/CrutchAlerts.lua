-- CrutchAlerts
-- https://esoui.com/downloads/info3137-CrutchAlerts.html
Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.patches = Heim.patches or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local function defaultConf()
    return {
        enable = false,
        bossBar = {
            enable = true,
            position = Heim.ANCHOR:New({
                TOPLEFT, GuiRoot, CENTER, 0, 0, ANCHOR_CONSTRAINS_Y
            }, {BOTTOMLEFT, ZO_ActionBar1, TOPRIGHT, 0, 0, ANCHOR_CONSTRAINS_X})
        }
    };
end

-- function patch()
--     if (CrutchAlerts ~= nil) then
--         local Crutch = CrutchAlerts
--         local BHB = Crutch.BossHealthBar
--     end
-- end

local function init()
    if (CrutchAlerts ~= nil) then
        -- Boss Bar
        HeimUtils.RunWhenTrue(function()
            return Heim.config.Crutch.bossBar.position:IsValid()
        end, function()
            local conf = Heim.config.Crutch.enable and Heim.config.Crutch or
                             defaultConf();
            Heim.config.Crutch.bossBar.control =
                CrutchAlertsBossHealthBarContainer;
            if (Heim.IsEnabled(conf.bossBar)) then
                conf.bossBar.position:AddToControl(
                    CrutchAlertsBossHealthBarContainer, true);
            end
        end)
    end
end

table.insert(Heim.inits, init);
-- table.insert(Heim.patches, patch);
table.insert(Heim.defaults, function() Heim.config.Crutch = defaultConf() end);
