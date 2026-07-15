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

function GetFragementName(fragment)
    if (it.control ~= nil) then return it.control:GetName(); end
    return nil;
end

function Heim.Show(scene, fragment_name)
    local fragment = scene.fragmentList[fragment_name];
    if (fragment ~= nil) then
        scene.scene:AddFragment(fragment)
        return fragment.control;
    end
end

-- POC
function Heim.Test()
    local hud = Heim.scenes.hud;
    local hudui = Heim.scenes.hudui;
    local control = Heim.Show(hud, "ZO_PerformanceMeters");
    control:SetScale(2);
    Heim.Show(hud, "HyperTools_Trackers");
    Heim.Show(hud, "HyperTools_3D");
    Heim.Show(hudui, "HyperTools_Trackers");
    Heim.Show(hudui, "HyperTools_3D");
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
end

function Heim.PrepScene(sceneName)
    Heim.scenes[sceneName] = {scene = Heim.SM:GetScene(sceneName)};
    Heim.scenes[sceneName].scene:UnregisterAllCallbacks("StateChange");
    Heim.scenes[sceneName].fragmentList = FragmentCopy(
                                              Heim.scenes[sceneName].scene
                                                  .fragments)

    Heim.scenes[sceneName].scene.fragments = {};
end

function Heim.Init()
    if (Heim.SM ~= nil) then
        Heim.SM:Show("empty");
        Heim.PrepScene("hud");
        Heim.PrepScene("hudui");
        Heim.SM:Show("hud");
        Heim.SpecificAddonFixes();
    end
end

function Heim.OnAddOnLoaded(event, addonName)
    if (addonName == Heim.name) then
        Heim.EM:RegisterForEvent(Heim.name .. "DeferredInit",
                                 EVENT_PLAYER_ACTIVATED,
                                 function() zo_callLater(Heim.Init, 2) end);
        Heim.EM:UnregisterForEvent(Heim.name, EVENT_ADD_ON_LOADED);
    end
end

Heim.EM:RegisterForEvent(Heim.name, EVENT_ADD_ON_LOADED, Heim.OnAddOnLoaded);
