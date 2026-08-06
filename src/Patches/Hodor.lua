-- HodorReflexes
-- https://www.esoui.com/downloads/info2311-HodorReflexes-DPSUltimateShare.html
-- XXX: I am on a very old version of hodor because i personally hate the work that the new maintainer has done.
-- So this module may or maynot work as expected.
-- Might need to check addon versions to and dispatch accordingly
Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.patches = Heim.patches or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local function defaultConf()
    return {
        enable = true,
        dpsShare = {
            enable = true,
            position = Heim.ANCHOR:New({TOPLEFT, GuiRoot, TOPLEFT, 0, 0})
        },
        hornShare = {
            enable = true,
            position = Heim.ANCHOR:New({TOPLEFT, GuiRoot, TOPLEFT, 0, 0})
        },
        coloShare = {
            enable = true,
            position = Heim.ANCHOR:New({TOPLEFT, GuiRoot, TOPLEFT, 0, 0})
        },
        atroShare = {
            enable = true,
            position = Heim.ANCHOR:New({TOPLEFT, GuiRoot, TOPLEFT, 0, 0})
        },
        ultShare = {
            enable = true,
            position = Heim.ANCHOR:New({TOPLEFT, GuiRoot, TOPLEFT, 0, 0})
        },
        hornNotif = {
            enable = true,
            position = Heim.ANCHOR:New({TOPLEFT, GuiRoot, TOPLEFT, 0, 0}),
            hidden = true
        },
        coloNotif = {
            enable = true,
            position = Heim.ANCHOR:New({TOPLEFT, GuiRoot, TOPLEFT, 0, 0}),
            hidden = true
        }
    };
end

local function patch() end
local function init()
    if (HodorReflexes ~= nil) then
        if (not Heim.config.Hodor.enable) then return nil end
        local conf = Heim.config.Hodor;
        -- DPS Share
        HeimUtils.RunWhenTrue(function()
            return Heim.config.Hodor.dpsShare.position:IsValid()
        end, function()
            Heim.config.Hodor.dpsShare.control = HodorReflexes_Share_Damage;
            conf.dpsShare.position:AddToControl(HodorReflexes_Share_Damage, true);
        end)
        -- Horn Share
        HeimUtils.RunWhenTrue(function()
            return Heim.config.Hodor.hornShare.position:IsValid()
        end, function()
            Heim.config.Hodor.hornShare.control = HodorReflexes_Share_Ultimates;
            conf.hornShare.position:AddToControl(HodorReflexes_Share_Ultimates,
                                                 true);
        end)
        -- Colo Share
        HeimUtils.RunWhenTrue(function()
            return Heim.config.Hodor.coloShare.position:IsValid()
        end, function()
            Heim.config.Hodor.coloShare.control = HodorReflexes_Share_Colos;
            conf.coloShare.position:AddToControl(HodorReflexes_Share_Colos, true);
        end)
        -- Atro Share
        HeimUtils.RunWhenTrue(function()
            return Heim.config.Hodor.atroShare.position:IsValid()
        end, function()
            Heim.config.Hodor.atroShare.control = HodorReflexes_Share_Atronach;
            conf.atroShare.position:AddToControl(HodorReflexes_Share_Atronach,
                                                 true);
        end)
        -- Ult Share
        HeimUtils.RunWhenTrue(function()
            return Heim.config.Hodor.ultShare.position:IsValid()
        end, function()
            Heim.config.Hodor.ultShare.control =
                HodorReflexes_Share_MiscUltimates;
            conf.ultShare.position:AddToControl(
                HodorReflexes_Share_MiscUltimates, true);
        end)
        -- Horn Countdown
        HeimUtils.RunWhenTrue(function()
            return Heim.config.Hodor.hornNotif.position:IsValid()
        end, function()
            Heim.config.Hodor.hornNotif.control =
                HodorReflexes_Share_HornCountdown_Label
            conf.coloNotif.position:AddToControl(
                HodorReflexes_Share_HornCountdown_Label, true);
            if (conf.hidden == true) then
                HodorReflexes_Share_HornCountdown_Label:SetColor(0, 0, 0, 0);
            end
        end)
        -- Colo Countdown
        HeimUtils.RunWhenTrue(function()
            return Heim.config.Hodor.coloNotif.position:IsValid()
        end, function()
            Heim.config.Hodor.coloNotif.control =
                HodorReflexes_Share_ColosCountdown_Label
            conf.coloNotif.position:AddToControl(
                HodorReflexes_Share_ColosCountdown_Label, true);
            if (conf.hidden == true) then
                HodorReflexes_Share_ColosCountdown_Label:SetColor(0, 0, 0, 0);
            end
        end)
    end
end

table.insert(Heim.inits, init);
table.insert(Heim.patches, patch);
table.insert(Heim.defaults, function() Heim.config.Hodor = defaultConf() end);
