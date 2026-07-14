Heim = Heim or {};
Heim.EM = EVENT_MANAGER;
Heim.SM = SCENE_MANAGER;
Heim.name = "Heim";
Heim.scenes = {};

local InitId = nil;

function fragmentCopy(tbl)
  local copy = {}
  for _, value in pairs(tbl) do
    if(value.control ~= nil) then
      copy[value.control:GetName()] = value
    end
  end
  return copy
end

function GetFragementName(fragment)
    if(it.control ~= nil) then
      return it.control:GetName();
    end
    return nil;
end

function Heim.show(scene, fragment_name)
  local fragment = scene.fragmentList[fragment_name];
  if(fragment ~= nil) then
    scene.scene:AddFragment(fragment)
    return fragment.control;
  end
end

--POC
function Heim.test()
  local hud = Heim.scenes.hud;
  local control = Heim.show(hud, "ZO_PerformanceMeters");
  control:SetScale(2);
end

function Heim.init()
  if(Heim.SM ~= nil) then
    Heim.scenes.hud = { scene = Heim.SM:GetScene("hud") };
    Heim.scenes.hud.fragmentList = fragmentCopy(Heim.scenes.hud.scene.fragments)
    Heim.scenes.hud.scene:SetState("hidden");
    Heim.scenes.hud.scene.fragments = {};
    Heim.scenes.hud.scene:SetState("shown");
  end
end

function Heim.OnAddOnLoaded(event, addonName)
  if InitId then zo_removeCallLater(InitId) end
  InitId = zo_callLater(function ()
      Heim.init();
      Heim.EM:UnregisterForEvent(Heim.name, EVENT_ADD_ON_LOADED);
  end, 1000)
end

Heim.EM:RegisterForEvent(Heim.name, EVENT_ADD_ON_LOADED, Heim.OnAddOnLoaded, false);
