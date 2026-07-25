-- Fancy Action Bar+
-- https://www.esoui.com/downloads/info3938-FancyActionBar.html
Heim = Heim or {};
Heim.patches = Heim.patches or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local function defaultConf()
    return {
        enable = false,
        position = Heim.ANCHOR:New(BOTTOM, GuiRoot, BOTTOM, 0, -64)
    };
end

local function patch()
    if (FancyActionBar ~= nil) then
        function FancyActionBar.MoveActionBar()
            local conf = Heim.IsEnabled(Heim.config.FAB) and Heim.config.FAB or
                             defaultConf();
            conf.position:AddToControl(ZO_ActionBar1, true);
        end
        function FancyActionBar.InitializeScreenResizeHandler() end
    end
end

local function init()
    if (FancyActionBar ~= nil) then
        HeimUtils.RunWhenTrue(function()
            return Heim.config.FAB.position:IsValid()
        end, function()
            FancyActionBar:MoveActionBar();
            Heim.EM:UnregisterForEvent("FancyActionBar_ScreenResize");
        end)
    end
end

table.insert(Heim.inits, init);
table.insert(Heim.patches, patch);
table.insert(Heim.defaults, function() Heim.config.FAB = defaultConf() end);
