Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.modules = Heim.modules or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local Metronome = {};
Metronome.name = "Metronome";

function Metronome.defaultConfig()
    return {
        enable = false,
        position = Heim.ANCHOR:New({BOTTOM, ZO_ActionBar1, TOP, 0, -32})
    };
end

function Metronome.Init()
    local root = Heim.WM:CreateControl(Heim.name .. Metronome.name, GuiRoot,
                                       CT_TOPLEVELCONTROL);
    root:SetAnchor(TOPLEFT, GuiRoot, CENTER, -64, -8)
    root:SetAnchor(BOTTOMRIGHT, GuiRoot, CENTER, 64, 8)
    Heim.WM:CreateControlFromVirtual(Metronome.name, root, "MetronomeRhythm");

end

table.insert(Heim.inits, Metronome.Init);
table.insert(Heim.defaults,
             function() Heim.config.Metronome = Metronome.defaultConfig(); end);
