-- Votan's Minimap
-- https://www.esoui.com/downloads/info1399-VotansMinimap.html
Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.patches = Heim.patches or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local function defaultConf()
    local UIWidth, UIHeight = GuiRoot:GetDimensions()
    return {
        enable = false,
        position = Heim.ANCHOR:New({
            CENTER, GuiRoot, CENTER, (UIWidth / 2 - 304), (UIHeight / 2 - 368)
        }),
        size = {h = 304, w = 368}
    };
end

local function patch()
    if (VOTANS_MINIMAP ~= nil) then
        function VOTANS_MINIMAP:RestorePosition()
            local minimap = Heim.IsEnabled(Heim.config.VotansMinimap) and
                                Heim.config.VotansMinimap or defaultConf();
            Heim.config.VotansMinimap.control = ZO_WorldMap;
            -- Skip full update for just setting new position
            local orgZO_WorldMap_UpdateMap = ZO_WorldMap_UpdateMap
            ZO_WorldMap_UpdateMap = function() end;

            ZO_WorldMap_OnResizeStart(ZO_WorldMap)
            minimap.position:AddToControl(ZO_WorldMap, true);
            ZO_WorldMap:SetDimensions(minimap.size.w, minimap.size.h);

            ZO_WorldMap_OnResizeStop(ZO_WorldMap)
            ZO_WorldMap_UpdateMap = orgZO_WorldMap_UpdateMap
        end
    end
end

local function init()
    if (VOTANS_MINIMAP ~= nil) then
        HeimUtils.RunWhenTrue(function()
            return Heim.config.VotansMinimap.position:IsValid()
        end, function() VOTANS_MINIMAP:RestorePosition(); end)
        --XXX:Hack
        Heim.EM:RegisterForEvent(Heim.name .. VOTANS_MINIMAP.name,
                                 EVENT_PLAYER_ACTIVATED, function()
            zo_callLater(function ()
                VOTANS_MINIMAP:RestorePosition();
                ZO_WorldMapScroll:SetDimensions(ZO_WorldMapScroll:GetDimensions());
            end, 1);
        end);
    end
end

table.insert(Heim.inits, init);
table.insert(Heim.patches, patch);
table.insert(Heim.defaults,
             function() Heim.config.VotansMinimap = defaultConf() end);
