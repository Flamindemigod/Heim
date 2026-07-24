-- Alternative Group Frames
-- https://www.esoui.com/downloads/info3053-AlternativeGroupFrames.html
Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.patches = Heim.patches or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local function defaultConf()
    return {
        enable = false,
        use_char_names = false,
        show_class_icons = true,
        show_level = false,
        show_no_group = false,
        alpha = {full = 1, faded = 0.4},
        position = Heim.ANCHOR:New(TOPLEFT, GuiRoot, TOPLEFT, 50, 55),
        unit_frame = {
            frames_per_column = 12,
            h = 32,
            w = 230,
            pad_x = 4,
            pad_y = 2
        }
    };
end

local function patch()
    if (ALT_GROUP_FRAMES ~= nil) then
        function ALT_GROUP_FRAMES:RefreshView(withElems)
            local CONTAINER_PAD = 5
            local conf =
                Heim.IsEnabled(Heim.config.AltGF) and Heim.config.AltGF or
                    defaultConf();
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
            conf.position:AddToControl(self.control, true);

            if withElems then
                for _, unitFrame in pairs(self.unitFrames) do
                    -- Refresh whether or not a frame is active, so that when switching between keyboard and
                    -- controller, the frames are properly resized and ready for new group members
                    unitFrame:RefreshView()
                    unitFrame:RefreshPosition()
                end
            end
        end
        ZO_PreHook(ALT_GROUP_FRAMES, "RefreshData", function()
            local conf =
                Heim.IsEnabled(Heim.config.AltGF) and Heim.config.AltGF or
                    defaultConf();
            Heim.config.AltGF.control = ALT_GROUP_FRAMES.control;
            ALT_GROUP_FRAMES.SETTINGS.USE_CHARACTER_NAMES = conf.use_char_names;
            ALT_GROUP_FRAMES.SETTINGS.SHOW_CLASS_ICONS = conf.show_class_icons;
            ALT_GROUP_FRAMES.SETTINGS.SHOW_LEVEL = conf.show_icons;
            ALT_GROUP_FRAMES.SETTINGS.SHOW_NOGROUP = conf.show_no_group;

            ALT_GROUP_FRAMES.SETTINGS.FULL_ALPHA_VALUE = conf.alpha.full;
            ALT_GROUP_FRAMES.SETTINGS.FADED_ALPHA_VALUE = conf.alpha.faded;

            ALT_GROUP_FRAMES.SETTINGS.FRAMES_PER_COLUMN = conf.unit_frame
                                                              .frames_per_column;

            ALT_GROUP_FRAMES.SETTINGS.UNIT_FRAME_WIDTH = conf.unit_frame.w;
            ALT_GROUP_FRAMES.SETTINGS.UNIT_FRAME_HEIGHT = conf.unit_frame.h;
            ALT_GROUP_FRAMES.SETTINGS.UNIT_FRAME_PAD_X = conf.unit_frame.pad_x;
            ALT_GROUP_FRAMES.SETTINGS.UNIT_FRAME_PAD_Y = conf.unit_frame.pad_y;
        end)
    end
end

local function init()
    if (ALT_GROUP_FRAMES ~= nil) then
        HeimUtils.RunWhenTrue(function()
            return Heim.config.AltGF.position:IsValid()
        end, function()
            ALT_GROUP_FRAMES:SetIsDirty(true)
            ALTGF_UnitFrames_OnUpdate();
        end)
    end
end

table.insert(Heim.inits, init);
table.insert(Heim.patches, patch);
table.insert(Heim.defaults, function() Heim.config.AltGF = defaultConf() end);
