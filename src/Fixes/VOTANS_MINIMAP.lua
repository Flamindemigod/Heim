-- Votan's Minimap
-- https://www.esoui.com/downloads/info1399-VotansMinimap.html
Heim = Heim or {};

local function fix()
    if (VOTANS_MINIMAP ~= nil) then
        local ZO_WorldMap_Anchor = {ZO_WorldMap:GetAnchor(0)};
        ZO_PreHook(VOTANS_MINIMAP, "GoWorldMapMode", function()
            ZO_WorldMap_Anchor = {ZO_WorldMap:GetAnchor(0)};
        end);
        ZO_PostHook(VOTANS_MINIMAP, "GoMiniMapMode", function()
            ZO_WorldMap:ClearAnchors();
            ZO_WorldMap:SetAnchor(ZO_WorldMap_Anchor[2], ZO_WorldMap_Anchor[3],
                                  ZO_WorldMap_Anchor[4], ZO_WorldMap_Anchor[5],
                                  ZO_WorldMap_Anchor[6]);
        end);
    end
end

table.insert(Heim.fixes, fix);
