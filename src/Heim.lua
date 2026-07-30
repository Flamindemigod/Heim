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
        position = Heim.ANCHOR:New({
            BOTTOMRIGHT, Heim.config.Crutch.bossBar, BOTTOMLEFT, -32, 69
        }),
        flipped = true,
        scale = 1.2,
        layout = "stacked" -- stacked | pyramid
    };
    config.Crutch = {
        enable = true,
        bossBar = {
            enable = true,
            position = Heim.ANCHOR:New({
                BOTTOM, ZO_ActionBar1, TOP, 0, -16 * 10, ANCHOR_CONSTRAINS_Y
            }, {BOTTOMLEFT, ZO_ActionBar1, TOPRIGHT, 0, 0, ANCHOR_CONSTRAINS_X})
        }
    };
    config.EPT = {
        enable = true,
        position = Heim.ANCHOR:New({
            TOPRIGHT, Heim.config.HeimAtrs, BOTTOMRIGHT, 5, -24
        }),
        stackDirection = Heim.STACK_MODE.LEFT
    };
    config.Hodor = {
        enable = true,
        dpsShare = {
            enable = true,
            position = Heim.ANCHOR:New({
                TOPLEFT, Heim.config.AltGF, TOPRIGHT, 8, 6
            })
        },
        hornShare = {
            enable = true,
            position = Heim.ANCHOR:New({
                TOPLEFT, Heim.config.AltGF, BOTTOMLEFT, 0, 8
            })
        },
        coloShare = {
            enable = true,
            position = Heim.ANCHOR:New({
                TOPLEFT, Heim.config.Hodor.hornShare, TOPRIGHT, 8, 0
            })
        },
        atroShare = {
            enable = true,
            position = Heim.ANCHOR:New({
                TOPLEFT, Heim.config.Hodor.hornShare, BOTTOMLEFT, 0, 8
            })
        },
        ultShare = {
            enable = true,
            position = Heim.ANCHOR:New({
                TOPLEFT, Heim.config.Hodor.coloShare, BOTTOMLEFT, 0, 8
            })
        },
        hornNotif = {
            enable = true,
            position = Heim.ANCHOR:New({BOTTOMLEFT, GuiRoot, TOPLEFT, 100, 0})
        },
        coloNotif = {
            enable = true,
            position = Heim.ANCHOR:New({BOTTOMLEFT, GuiRoot, TOPLEFT, 100, 0})
        }
    };
    config.Auras = {
        enable = true,
        windows = {
                {
                    position = Heim.ANCHOR:New({BOTTOM, Heim.config.HeimAtrs, TOP, 0, -8}),
                    auras = {
                    {aura = 106754, target = "boss"},
                    {aura = 2727, target = "boss"}
                },
                    stackMode = Heim.STACK_MODE.UP,
                    gap = 4,
                    auraMode = Heim.AURAS_WINDOW_MODE.PROGRESS_FLIPPED,
                    scale = 1,
                },
                {
                    position = Heim.ANCHOR:New({RIGHT, ZO_ActionBar1, LEFT, -64, 0}),
                    auras = {
                    --Generic Debuffs
                    {aura = 69143, target = "player"},
                    --DSR Debuffs
                    {aura = 174961, target = "player"},
                    --Twins Debuffs
                    {aura = 166482, target = "player"},
                    {aura = 166472, target = "player"},
                    {aura = 168525, target = "player"},
                    {aura = 168526, target = "player"},
                    {aura = 166529, target = "player"},
                    {aura = 166525, target = "player"},
                    --Reef Debuffs
                    {aura = 166638, target = "player"},
                    {aura = 174659, target = "player"},
                    --Taleria Debuffs
                    {aura = 169935, target = "player"},
                    {aura = 169938, target = "player"},
                    {aura = 169936, target = "player"}
                },
                    stackMode = Heim.STACK_MODE.LEFT,
                    gap = 4,
                    auraMode = Heim.AURAS_WINDOW_MODE.ICON,
                    scale = 1.2,
                    resize = true,
                },
                {
                    position = Heim.ANCHOR:New({BOTTOM, ZO_ActionBar1, TOPLEFT, -16, -32*4}),
                    auras = {
                    {aura = 109966, target = "player"},
                    {aura = 61747, target = "player"},
                    {aura = 93109, target = "player"},
                    {aura = 61745, target = "player"},
                },
                    stackMode = Heim.STACK_MODE.UP,
                    gap = 4,
                    auraMode = Heim.AURAS_WINDOW_MODE.PROGRESS,
                    scale = 1,
                }
        }
    };
    return config;
end

-- function Heim.LoadUI()
--     local control, control1, alt_atr;
--     local hud = Heim.scenes.hud;
--     local hudui = Heim.scenes.hudui;
--     for _, it in pairs({hud, hudui}) do
--         Heim.Show(it, "HyperTools_Trackers");
--         Heim.Show(it, "HyperTools_3D");
--
--         control1 = Heim.Show(it, "ZO_ActivityTrackerContainer");
--         control1:ClearAnchors();
--         control1:SetAnchor(TOPRIGHT, control, BOTTOMRIGHT, 0, 16);
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

