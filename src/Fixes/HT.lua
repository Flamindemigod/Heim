-- HyperTools
-- https://www.esoui.com/downloads/info3057-HyperTools.html
Heim = Heim or {};

local function fix()
    if (HT ~= nil) then
        local HT_TRACKER_FRAG = ZO_HUDFadeSceneFragment:New(HT_Trackers)
        local HT_3D_FRAG = ZO_HUDFadeSceneFragment:New(HT_3D)
        Heim.scenes.hud.fragmentList[HT.name .. "_Trackers"] = HT_TRACKER_FRAG;
        Heim.scenes.hudui.fragmentList[HT.name .. "_Trackers"] = HT_TRACKER_FRAG;
        Heim.scenes.hud.fragmentList[HT.name .. "_3D"] = HT_3D_FRAG;
        Heim.scenes.hudui.fragmentList[HT.name .. "_3D"] = HT_3D_FRAG;
    end
end

table.insert(Heim.fixes, fix);
