Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.EM = EVENT_MANAGER;
Heim.SM = SCENE_MANAGER;
Heim.WM = WINDOW_MANAGER;
Heim.name = "Heim";
Heim.config = Heim.config or {};
Heim.inits = Heim.inits or {};
function Heim.Inits() for _, it in pairs(Heim.inits) do it(); end end
Heim.defaults = Heim.defaults or {};
function Heim.BuildDefaultConfig() for _, it in pairs(Heim.defaults) do it(); end end

local DEBUG_MODE = false;
local function InitLogger()
    if (DEBUG_MODE) then
        local LOG_MODE = HeimUtils.LOG_MODE.TRACE;
        Heim.Log = HeimUtils.Logger(Heim.title, LOG_MODE);

        local function format_vaargs(...)
            local args = {...}
            for i = 1, #args do args[i] = tostring(args[i]) end
            return table.concat(args, ", ")
        end

        for name, it in pairs(Heim) do
            if (it ~= nil and type(it) == "function") then
                local wrapped = function(...)
                    Heim.Log.trace("Calling function %s.%s(%s)", "Heim", name,
                                   format_vaargs(...));
                    it(...);
                end
                Heim[name] = wrapped;
            end
        end

        for name, it in pairs(Heim.STACK) do
            if (it ~= nil and type(it) == "function") then
                local wrapped = function(...)
                    Heim.Log.trace("Calling function %s.%s(%s)", "Heim.STACK",
                                   name, format_vaargs(...));
                    it(...);
                end
                Heim.STACK[name] = wrapped;
            end
        end
    else
        local LOG_MODE = HeimUtils.LOG_MODE.WARN;
        Heim.Log = HeimUtils.Logger(Heim.title, LOG_MODE);
    end
end

function Heim.IsEnabled(config)
    if (config == nil or config.position == nil) then return false; end
    return config.enable and config.position:IsValid();
end

function Heim.LoadUI()
    local config = {};
    config.ZOCompass = {
        enable = true,
        position = Heim.ANCHOR:New({TOP, GuiRoot, TOP, 0, 16 * 4}),
        size = {w = 1024, h = 64}
    };
    config.ZOPerformanceMeters = {
        enable = true,
        position = Heim.ANCHOR:New({BOTTOMLEFT, GuiRoot, BOTTOMLEFT, -16, 16})
    };
    config.ZOChat = {
        enable = true,
        position = Heim.ANCHOR:New({
            BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -16, -16 * 8
        }),
        scale = 1.5,
        minimize_direction = "right"
    };
    config.FAB = {
        enable = true,
        position = Heim.ANCHOR:New({BOTTOM, GuiRoot, BOTTOM, 0, -16 * 4})
    };
    config.VotansMinimap = {
        enable = true,
        position = Heim.ANCHOR:New({TOPRIGHT, GuiRoot, TOPRIGHT, -16, 16 * 8})
    };
    config.ZOHousingHud = {
        enable = true,
        position = Heim.ANCHOR:New({
            TOPLEFT, Heim.config.VotansMinimap, BOTTOMLEFT, -16, 16
        })
    };
    config.AltGF = {
        enable = true,
        position = Heim.ANCHOR:New({TOPLEFT, GuiRoot, TOPLEFT, 16, 16}),
        show_no_group = true,
        unit_frame = {h = 16 * 3, w = 16 * 20}
    };
    config.HeimAtrs = {
        enable = true,
        position = Heim.ANCHOR:New({BOTTOM, ZO_ActionBar1, TOP, 0, -16}),
        flipped = true,
        scale = 1.2,
        layout = "stacked" -- stacked | pyramid
    };
    return config;
end

-- function Heim.LoadUI()
--     local control, control1, alt_atr;
--     local hud = Heim.scenes.hud;
--     local hudui = Heim.scenes.hudui;
--     for _, it in pairs({hud, hudui}) do
--         Heim.Show(it, "ZO_Death");
--         Heim.Show(it, "ZO_DeathRecap");
--         Heim.Show(it, "ZO_DyanmicEventsTracker_TLContainer");
--         Heim.Show(it, "HyperTools_Trackers");
--         Heim.Show(it, "HyperTools_3D");
--         control = Heim.Show(it, "ZO_ActionBar1");
--         control:ClearAnchors();
--         control:SetAnchor(BOTTOM, GuiRoot, Bottom, 0, -65)
--         control1 = Heim.Show(it, EPT.name);
--         control1:ClearAnchors();
--         control1:SetAnchor(LEFT, control, RIGHT, 4 * 16, 0);
--         alt_atr = Heim.Show(it, "ALTATTR_Container");
--         alt_atr:ClearAnchors();
--         alt_atr:SetAnchor(BOTTOM, control, TOP, 0,
--                           -1 * (alt_atr:GetHeight() + 16));
--
--         control1 = Heim.Show(it, "HodorReflexes_Share_Damage");
--         control1:ClearAnchors();
--         control1:SetAnchor(TOPLEFT, control, TOPRIGHT, 16, 0);
--         -- This is actully the horn ult share window
--         control1 = Heim.Show(it, "HodorReflexes_Share_Ultimates");
--         control1:ClearAnchors();
--         control1:SetAnchor(TOPLEFT, control, BOTTOMLEFT, 0, 16);
--         control = Heim.Show(it, "HodorReflexes_Share_Colos");
--         control:ClearAnchors();
--         control:SetAnchor(TOPLEFT, control1, TOPRIGHT, 16, 0);
--         control = Heim.Show(it, "HodorReflexes_Share_Atronach");
--         control:ClearAnchors();
--         control:SetAnchor(TOPLEFT, control1, BOTTOMLEFT, 0, 16);
--         control1 = Heim.Show(it, "HodorReflexes_Share_MiscUltimates");
--         control1:ClearAnchors();
--         control1:SetAnchor(TOPLEFT, control, TOPRIGHT, 16, 0);
--
--         control1 = Heim.Show(it, "ZO_ActivityTrackerContainer");
--         control1:ClearAnchors();
--         control1:SetAnchor(TOPRIGHT, control, BOTTOMRIGHT, 0, 16);
--         Heim.Show(it, "M0RMarkersToplevel");
--         Heim.Show(it, "ZO_LootHistoryControl_Gamepad");
--         Heim.Show(it, "ZO_HousingHUDFragmentTopLevel");
--     end
--     ZO_SynergyTopLevelContainerIcon:SetScale(1.4);
--     ZO_SynergyTopLevelContainerIcon:ClearAnchors();
--     ZO_SynergyTopLevelContainerIcon:SetAnchor(TOP, alt_atr, TOP, 0, -8 * 16);
-- end

function Heim.Init()
    if (Heim.SM ~= nil) then
        Heim.BuildDefaultConfig();
        Heim.config = HeimUtils.MergeMaps(true, Heim.config, Heim.LoadUI());
        Heim.LoadPatches();
        Heim.Inits();
    end
end

function Heim.OnAddOnLoaded(event, addonName)
    if (addonName == Heim.name) then
        local addonInfo = HeimUtils.GetAddonInfo(Heim.name);
        Heim.title = addonInfo.title;
        Heim.author = addonInfo.author;
        Heim.desc = addonInfo.desc;
        InitLogger();
        Heim.EM:RegisterForEvent(Heim.name .. "DeferredInit",
                                 EVENT_PLAYER_ACTIVATED, Heim.Init, true);
        Heim.EM:UnregisterForEvent(Heim.name, EVENT_ADD_ON_LOADED);
    end
end

Heim.EM:RegisterForEvent(Heim.name, EVENT_ADD_ON_LOADED, Heim.OnAddOnLoaded);

