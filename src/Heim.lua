Heim = Heim or {};
Heim.EM = EVENT_MANAGER;
Heim.SM = SCENE_MANAGER;
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

-- POC
function Heim.Test()
    local control
    local hud = Heim.scenes.hud;
    local hudui = Heim.scenes.hudui;
    for _, it in pairs({hud, hudui}) do
        control = Heim.Show(it, "ZO_CompassFrame");
        control:SetDimensionConstraints(1000, 50, 2000, 50);
        control:SetWidth(2000);
        Heim.Show(it, "ZO_Death");
        Heim.Show(it, "ZO_DeathRecap");
        Heim.Show(it, "ZO_DyanmicEventsTracker_TLContainer");
        control = Heim.Show(it, "ZO_PerformanceMeters");
        control:SetScale(2);
        Heim.Show(it, "HyperTools_Trackers");
        Heim.Show(it, "HyperTools_3D");
    end
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
        function EPT:RegisterGUI(setId)
            if not EPT.guiList[setId] then
                EPT.guiList[setId] = EPT:CreateGui(setId)
            end
            Heim.scenes.hud.fragmentList[EPT.name .. setId] = EPT.guiList[setId]
                                                                  .frag;
            Heim.scenes.hudui.fragmentList[EPT.name .. setId] =
                EPT.guiList[setId].frag;
        end
        function EPT:UnregisterGUI(setId)
            Heim.scenes.hud.fragmentList[EPT.name .. setId] = nil;
            Heim.scenes.hudui.fragmentList[EPT.name .. setId] = nil;
        end
        -- TODO: Fix CMX Live Report Window
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
        function ZO_Scene:AddFragment_(fragment)
            if not self:HasFragment(fragment) then
                table.insert(self.fragments, fragment)
                fragment:SetSceneManager(self.sceneManager)
                fragment:Refresh()
            end
        end

        function ZO_Scene:AddFragment(fragment)
            if(Heim.scenes[self.name] ~= nil) then
                local fragName = GetFragmentName(fragment);
                if(fragName == nil) then return nil end;
                Heim.scenes[self.name].fragmentList[fragName] = fragment;
                return;
            end
            self:AddFragment_(fragment);
        end

        function ZO_Scene:RemoveFragment_(fragment)
            for i = 1, #self.fragments do
                if(self.fragments[i] == fragment) then
                    table.remove(self.fragments, i)
                    fragment:Refresh()
                    break
                end
            end
        end

        function ZO_Scene:RemoveFragment(fragment)
            if(Heim.scenes[self.name] ~= nil) then
                local fragName = GetFragmentName(fragment);
                if(fragName == nil) then return nil end;
                Heim.scenes[self.name].fragmentList[fragName] = nil;
            end
            self:RemoveFragment_(fragment);
        end

        Heim.SpecificAddonFixes();
    end
end

function Heim.OnAddOnLoaded(event, addonName)
    if (addonName == Heim.name) then
        Heim.EM:RegisterForEvent(Heim.name .. "DeferredInit",
                                 EVENT_PLAYER_ACTIVATED,
                                 Heim.Init);
        Heim.EM:UnregisterForEvent(Heim.name, EVENT_ADD_ON_LOADED);
    end
end

Heim.EM:RegisterForEvent(Heim.name, EVENT_ADD_ON_LOADED, Heim.OnAddOnLoaded);
