Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.EM = EVENT_MANAGER;
Heim.SM = SCENE_MANAGER;
Heim.WM = WINDOW_MANAGER;
Heim.name = "Heim";
Heim.config = Heim.config or {};

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

function Heim.Show(scene, fragment_name)
    local fragment = scene.fragmentList[fragment_name];
    if (fragment ~= nil) then
        scene.scene:AddFragment_(fragment);
        return fragment.control;
    end
end

function Heim.LoadUI()
    Heim.config.ZOCompass = {
        enable = true,
        position = ZO_Anchor:New(TOP, GuiRoot, TOP, 0, 16 * 4),
        size = {w = 1024, h = 64}
    };
    Heim.config.VotansMinimap = {
        enable = true,
        position = ZO_Anchor:New(TOPRIGHT, GuiRoot, TOPRIGHT, -16, 16 * 8),
        size = {w = 64*4, h = 64*4}
    };

end

-- function Heim.LoadUI()
--     local control, control1, alt_atr;
--     local hud = Heim.scenes.hud;
--     local hudui = Heim.scenes.hudui;
--     for _, it in pairs({hud, hudui}) do
--         control = Heim.Show(it, "ZO_CompassFrame");
--         control:SetDimensionConstraints(1000, 50, 1500, 50);
--         control:SetWidth(1500);
--         Heim.Show(it, "ZO_Death");
--         Heim.Show(it, "ZO_DeathRecap");
--         Heim.Show(it, "ZO_DyanmicEventsTracker_TLContainer");
--         control = Heim.Show(it, "ZO_PerformanceMeters");
--         control:ClearAnchors();
--         control:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, -16, 16);
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
--         control = Heim.Show(it, "ALTGF_UnitFrames");
--         control:ClearAnchors();
--         control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 16, 16);
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
--         control = Heim.Show(it, "ZO_WorldMap");
--         control:ClearAnchors();
--         control:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -16, 16 * 8)
--         control1 = Heim.Show(it, "ZO_ActivityTrackerContainer");
--         control1:ClearAnchors();
--         control1:SetAnchor(TOPRIGHT, control, BOTTOMRIGHT, 0, 16);
--         control = Heim.Show(it, "ZO_HouseInformationTrackerTopLevelContainer");
--         control:ClearAnchors();
--         control:SetAnchor(TOPRIGHT, control1, BOTTOMRIGHT, 0, 16);
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
        Heim.LoadUI();
        Heim.LoadPatches();
    end
end

function Heim.OnAddOnLoaded(event, addonName)
    if (addonName == Heim.name) then
        Heim.EM:RegisterForEvent(Heim.name .. "DeferredInit",
                                 EVENT_PLAYER_ACTIVATED, Heim.Init, true);
        Heim.EM:UnregisterForEvent(Heim.name, EVENT_ADD_ON_LOADED);
        InitLogger();
        local addonInfo = HeimUtils.GetAddonInfo(Heim.name);
        Heim.title = addonInfo.title;
        Heim.author = addonInfo.author;
        Heim.desc = addonInfo.desc;
    end
end

Heim.EM:RegisterForEvent(Heim.name, EVENT_ADD_ON_LOADED, Heim.OnAddOnLoaded);

