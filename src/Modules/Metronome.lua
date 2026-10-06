Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.modules = Heim.modules or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local Metronome = {};
Metronome.name = "Metronome";
Metronome.__locked = false;

function Metronome.defaultConfig()
    return {
        enable = false,
        startSound = SOUNDS.DIALOG_DECLINE,
        endSound = SOUNDS.JUSTICE_PICKPOCKET_FAILED
    };
end

function Metronome.Init()
    local MIN_INDEX = 3;
    Heim.EM:RegisterForUpdate(Heim.name .. Metronome.name, 20, function()
        local conf = Heim.config.Metronome.enable and
                         Heim.config.Metronome or Metronome.defaultConfig();
        if (conf.enable ~= true) then return nil; end
        local cd, dur, _, _ = GetSlotCooldownInfo(MIN_INDEX);
        local cd2, dur2, _, _ = GetSlotCooldownInfo(MIN_INDEX + 1);
        if (cd2 > cd) or (dur2 > dur) then
            cd = cd2;
            dur = dur2;
        end
        dur = math.max(1, dur);
        if (cd ~= 0 and Metronome.__locked == false) then
            Metronome.__locked = true;
            PlaySound(conf.startSound);
            zo_callLater(function()
                PlaySound(conf.endSound);
                Metronome.__locked = false;
            end, dur);
        end
    end)
end

table.insert(Heim.inits, Metronome.Init);
table.insert(Heim.defaults,
             function() Heim.config.Metronome = Metronome.defaultConfig(); end);
