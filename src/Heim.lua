Heim = Heim or {};
Heim.EM = EVENT_MANAGER;
Heim.SM = SCENE_MANAGER;
Heim.WM = WINDOW_MANAGER;
Heim.name = "Heim";
Heim.scenes = {};

function FragmentCopy(tbl)
    local copy = {}
    for _, value in pairs(tbl) do
        if (value.control ~= nil) then
            copy[value.control:GetName()] = value
        end
    end
    return copy
end

function MergeMaps(...)
    local dest = {};
    for _, it in ipairs({...}) do for k, v in pairs(it) do dest[k] = v; end end
    return dest;
end

function GetFragmentName(fragment)
    if (fragment.control ~= nil) then return fragment.control:GetName(); end
    return nil;
end

function Heim.Show(scene, fragment_name)
    local fragment = scene.fragmentList[fragment_name];
    if (fragment ~= nil) then
        scene.scene:AddFragment_(fragment)
        return fragment.control;
    end
end

function Heim.LoadUI()
    local control, control1, alt_atr;
    local hud = Heim.scenes.hud;
    local hudui = Heim.scenes.hudui;
    for _, it in pairs({hud, hudui}) do
        control = Heim.Show(it, "ZO_CompassFrame");
        control:SetDimensionConstraints(1000, 50, 1500, 50);
        control:SetWidth(1500);
        Heim.Show(it, "ZO_Death");
        Heim.Show(it, "ZO_DeathRecap");
        Heim.Show(it, "ZO_DyanmicEventsTracker_TLContainer");
        control = Heim.Show(it, "ZO_PerformanceMeters");
        control:ClearAnchors()
        control:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, -16, 16);
        Heim.Show(it, "HyperTools_Trackers");
        Heim.Show(it, "HyperTools_3D");
        control = Heim.Show(it, "ZO_ActionBar1");
        control:ClearAnchors()
        control:SetAnchor(BOTTOM, GuiRoot, Bottom, 0, -65)
        control1 = Heim.Show(it, EPT.name);
        control1:ClearAnchors();
        control1:SetAnchor(LEFT, control, RIGHT, 4 * 16, 0);
        alt_atr = Heim.Show(it, "ALTATTR_Container");
        alt_atr:ClearAnchors();
        alt_atr:SetAnchor(BOTTOM, control, TOP, 0,
                          -1 * (alt_atr:GetHeight() + 16))

        control = Heim.Show(it, "ALTGF_UnitFrames");
        control:ClearAnchors();
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 16, 16);
        control1 = Heim.Show(it, "HodorReflexes_Share_Damage");
        control1:ClearAnchors();
        control1:SetAnchor(TOPLEFT, control, TOPRIGHT, 16, 0);
        -- This is actully the horn ult share window
        control1 = Heim.Show(it, "HodorReflexes_Share_Ultimates");
        control1:ClearAnchors();
        control1:SetAnchor(TOPLEFT, control, BOTTOMLEFT, 0, 16);
        control = Heim.Show(it, "HodorReflexes_Share_Colos");
        control:ClearAnchors();
        control:SetAnchor(TOPLEFT, control1, TOPRIGHT, 16, 0);
        control = Heim.Show(it, "HodorReflexes_Share_Atronach");
        control:ClearAnchors();
        control:SetAnchor(TOPLEFT, control1, BOTTOMLEFT, 0, 16);
        control1 = Heim.Show(it, "HodorReflexes_Share_MiscUltimates");
        control1:ClearAnchors();
        control1:SetAnchor(TOPLEFT, control, TOPRIGHT, 16, 0);

        control = Heim.Show(it, "ZO_WorldMap");
        control:ClearAnchors()
        control:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -16, 16 * 8)
        control1 = Heim.Show(it, "ZO_ActivityTrackerContainer");
        control1:ClearAnchors();
        control1:SetAnchor(TOPRIGHT, control, BOTTOMRIGHT, 0, 16);
        control = Heim.Show(it, "ZO_HouseInformationTrackerTopLevelContainer");
        control:ClearAnchors();
        control:SetAnchor(TOPRIGHT, control1, BOTTOMRIGHT, 0, 16);
        Heim.Show(it, "M0RMarkersToplevel");
        Heim.Show(it, "ZO_LootHistoryControl_Gamepad");
        Heim.Show(it, "ZO_HousingHUDFragmentTopLevel");
    end
    ZO_SynergyTopLevelContainerIcon:SetScale(1.4)
    ZO_SynergyTopLevelContainerIcon:ClearAnchors()
    ZO_SynergyTopLevelContainerIcon:SetAnchor(TOP, alt_atr, TOP, 0, -8 * 16);
end

function Heim.ZosFixes()
    function ZO_Scene:AddFragment_(fragment)
        if not self:HasFragment(fragment) then
            table.insert(self.fragments, fragment)
            fragment:SetSceneManager(self.sceneManager)
            fragment:Refresh()
        end
    end

    function ZO_Scene:AddFragment(fragment)
        if (Heim.scenes[self.name] ~= nil) then
            local fragName = GetFragmentName(fragment);
            if (fragName == nil) then return nil end
            Heim.scenes[self.name].fragmentList[fragName] = fragment;
            return;
        end
        self:AddFragment_(fragment);
    end

    function ZO_Scene:RemoveFragment_(fragment)
        for i = 1, #self.fragments do
            if (self.fragments[i] == fragment) then
                table.remove(self.fragments, i)
                fragment:Refresh()
                break
            end
        end
    end

    function ZO_Scene:RemoveFragment(fragment)
        if (Heim.scenes[self.name] ~= nil) then
            local fragName = GetFragmentName(fragment);
            if (fragName == nil) then return nil end
            Heim.scenes[self.name].fragmentList[fragName] = nil;
        end
        self:RemoveFragment_(fragment);
    end
    -- Default UI Fragment. its a bit weird because it messes with a bunch of stuff in globla scope through methods and doesnt have any attributes itself;
    Heim.scenes.hud.scene:AddFragment_(HUD_FRAGMENT);
    function ACTIVITY_TRACKER:RefreshAnchors() end
    function ZO_Synergy:OnSynergyAbilityChanged()
        local hasSynergy, synergyName, iconFilename, prompt =
            GetCurrentSynergyInfo()
        if hasSynergy then
            if self.lastSynergyName ~= synergyName then
                PlaySound(SOUNDS.ABILITY_SYNERGY_READY)
                self.action:SetHidden(true);
                self.key:SetHidden(true);
                self.lastSynergyName = synergyName
            end

            self.icon:SetTexture(iconFilename)

            SHARED_INFORMATION_AREA:SetHidden(self, false)
        else
            SHARED_INFORMATION_AREA:SetHidden(self, true)
            self.lastSynergyName = nil
        end
    end
    -- TODO: Add all remaining hud and hudui ACTION_LAYER_FRAGMENT
    -- https://github.com/esoui/esoui/blob/8c7b5f9c0bf1f35ac3dc2cfd3457f47e26f55880/esoui/ingame/scenes/ingamefragments.lua#L1079
    Heim.scenes.hud.scene:AddFragment_(HOUSING_HUD_ACTION_LAYER_FRAGMENT);
    Heim.scenes.hudui.scene:AddFragment_(HOUSING_HUD_ACTION_LAYER_FRAGMENT);
end

-- Required Mostly because some addons are just stupid and use the state change to show/hide windows instead of adding it as a fragment
function Heim.SpecificAddonFixes()
    -- HyperTools
    -- https://www.esoui.com/downloads/info3057-HyperTools.html
    if (HT ~= nil) then
        local HT_TRACKER_FRAG = ZO_HUDFadeSceneFragment:New(HT_Trackers)
        local HT_3D_FRAG = ZO_HUDFadeSceneFragment:New(HT_3D)
        Heim.scenes.hud.fragmentList[HT.name .. "_Trackers"] = HT_TRACKER_FRAG;
        Heim.scenes.hudui.fragmentList[HT.name .. "_Trackers"] = HT_TRACKER_FRAG;
        Heim.scenes.hud.fragmentList[HT.name .. "_3D"] = HT_3D_FRAG;
        Heim.scenes.hudui.fragmentList[HT.name .. "_3D"] = HT_3D_FRAG;
    end
    -- Exoys Proc Set Tracker
    -- TODO: Add Link to EPT
    if (EPT ~= nil) then
        function EPT:CreateGui(setId)
            local name = tostring(setId)
            local gui = {}

            gui.win = EPT.window:CreateControl(name, GuiRoot, CT_CONTROL)
            gui.win:SetClampedToScreen(true)
            gui.win:ClearAnchors()
            gui.win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.store[setId].left,
                              self.store[setId].top)
            gui.win:SetHidden(true)
            -- PrimaryIndicator
            gui.primaryInd = {}
            gui.primaryInd.ctrl = EPT.window:CreateControl(name ..
                                                               "PrimaryControl",
                                                           gui.win, CT_CONTROL)
            gui.primaryInd.edge = EPT.window:CreateControl(
                                      name .. "PrimaryEdge",
                                      gui.primaryInd.ctrl, CT_BACKDROP)
            gui.primaryInd.back = EPT.window:CreateControl(name ..
                                                               "PrimaryBackground",
                                                           gui.primaryInd.ctrl,
                                                           CT_BACKDROP)
            gui.primaryInd.icon = EPT.window:CreateControl(
                                      name .. "PrimaryIcon",
                                      gui.primaryInd.ctrl, CT_TEXTURE)
            gui.primaryInd.label = EPT.window:CreateControl(name ..
                                                                "PrimaryIndicator",
                                                            gui.primaryInd.ctrl,
                                                            CT_LABEL)

            -- NameDisplay
            gui.nameDisplay = {}
            gui.nameDisplay.ctrl = EPT.window:CreateControl(name ..
                                                                "NameControl",
                                                            gui.win, CT_CONTROL)
            gui.nameDisplay.back = EPT.window:CreateControl(name ..
                                                                "NameBackground",
                                                            gui.nameDisplay.ctrl,
                                                            CT_BACKDROP)
            gui.nameDisplay.label = EPT.window:CreateControl(
                                        name .. "NameLabel",
                                        gui.nameDisplay.ctrl, CT_LABEL)

            EPT:SetDesign(setId, gui)

            if setId ~= "demo" then
                if EPT.procSets[setId].type == "special" then
                    gui.secondaryInd = EPT:GetSecondaryIndicator(setId, gui.win)
                    gui.tertiaryInd = EPT:GetTertiaryIndicator(setId, gui.win)
                elseif EPT.procSets[setId].type == "stackEPT" or
                    EPT.procSets[setId].type == "stacktarget" then
                    gui.secondaryInd = EPT:GetSecondaryIndicator(setId, gui.win)
                end
            end
            return gui
        end

        Heim.scenes.hud.fragmentList[EPT.name] =
            Heim.STACK:New(EPT.name, Heim.STACK_MODE.RIGHT);
        Heim.scenes.hudui.fragmentList[EPT.name] =
            Heim.scenes.hud.fragmentList[EPT.name];
        function EPT:RegisterGUI(setId)
            if not EPT.guiList[setId] then
                EPT.guiList[setId] = EPT:CreateGui(setId)
            end
            Heim.scenes.hud.fragmentList[EPT.name]:AppendChild(
                EPT.guiList[setId].win)
            Heim.scenes.hudui.fragmentList[EPT.name]:AppendChild(
                EPT.guiList[setId].win)
        end
        function EPT:UnregisterGUI(setId)
            Heim.scenes.hud.fragmentList[EPT.name]:RemoveChild(
                EPT.guiList[setId].win)
            Heim.scenes.hudui.fragmentList[EPT.name]:RemoveChild(
                EPT.guiList[setId].win)
        end

    end
    -- Votan's Minimap
    -- TODO: Add Link to Votan's Minimap
    if (VOTANS_MINIMAP ~= nil) then
        local ZO_WorldMap_Anchor = {ZO_WorldMap:GetAnchor(0)};
        ZO_PreHook(VOTANS_MINIMAP, "GoWorldMapMode", function()
            ZO_WorldMap_Anchor = {ZO_WorldMap:GetAnchor(0)};
        end)
        ZO_PostHook(VOTANS_MINIMAP, "GoMiniMapMode", function()
            ZO_WorldMap:ClearAnchors();
            ZO_WorldMap:SetAnchor(ZO_WorldMap_Anchor[2], ZO_WorldMap_Anchor[3],
                                  ZO_WorldMap_Anchor[4], ZO_WorldMap_Anchor[5],
                                  ZO_WorldMap_Anchor[6]);
        end)
    end
    -- Alternative Group Frames
    -- TODO: Add Link To  AGF
    if (ALTGF_UnitFrames_Initialize ~= nil) then
        local CONTAINER_PAD = 5
        function ALT_GROUP_FRAMES:RefreshView(withElems)
            local maxCol = zo_ceil(self.groupSize /
                                       self.SETTINGS.FRAMES_PER_COLUMN)
            local maxRow = zo_min(self.groupSize,
                                  self.SETTINGS.FRAMES_PER_COLUMN)

            local x = maxCol *
                          (self.SETTINGS.UNIT_FRAME_WIDTH +
                              self.SETTINGS.UNIT_FRAME_PAD_X)
            local y = maxRow *
                          (self.SETTINGS.UNIT_FRAME_HEIGHT +
                              self.SETTINGS.UNIT_FRAME_PAD_Y)

            self.control:SetDimensions(x + (CONTAINER_PAD * 2),
                                       y + (CONTAINER_PAD * 2))

            if withElems then
                for _, unitFrame in pairs(self.unitFrames) do
                    -- Refresh whether or not a frame is active, so that when switching between keyboard and
                    -- controller, the frames are properly resized and ready for new group members
                    unitFrame:RefreshView()
                    unitFrame:RefreshPosition()
                end
            end
        end
    end
end

function Heim.PrepScene(sceneName)
    Heim.scenes[sceneName] = {scene = Heim.SM:GetScene(sceneName)};
    Heim.scenes[sceneName].scene:UnregisterAllCallbacks("StateChange");
    Heim.scenes[sceneName].fragmentList = MergeMaps(
                                              Heim.scenes[sceneName]
                                                  .fragmentList or {},
                                              FragmentCopy(
                                                  Heim.scenes[sceneName].scene
                                                      .fragments));
    Heim.scenes[sceneName].scene.fragments = {};
end

function Heim.Init()
    if (Heim.SM ~= nil) then
        Heim.SM:Show("empty");
        Heim.PrepScene("hud");
        Heim.PrepScene("hudui");
        Heim.SM:Show("hud");
        Heim.ZosFixes();
        Heim.SpecificAddonFixes();
        zo_callLater(Heim.LoadUI, 1);
    end
end

function Heim.OnAddOnLoaded(event, addonName)
    if (addonName == Heim.name) then
        Heim.EM:RegisterForEvent(Heim.name .. "DeferredInit",
                                 EVENT_PLAYER_ACTIVATED, Heim.Init);
        Heim.EM:UnregisterForEvent(Heim.name, EVENT_ADD_ON_LOADED);
    end
end

Heim.EM:RegisterForEvent(Heim.name, EVENT_ADD_ON_LOADED, Heim.OnAddOnLoaded);
