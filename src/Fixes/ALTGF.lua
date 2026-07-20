-- Alternative Group Frames
-- https://www.esoui.com/downloads/info3053-AlternativeGroupFrames.html
Heim = Heim or {};
local function fix()
    if (ALTGF_UnitFrames_Initialize ~= nil) then
        local CONTAINER_PAD = 5
        function ALT_GROUP_FRAMES:RefreshView(withElems)
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

            if withElems then
                for _, unitFrame in pairs(self.unitFrames) do
                    -- Refresh whether or not a frame is active, so that when switching between keyboard and
                    -- controller, the frames are properly resized and ready for new group members
                    unitFrame:RefreshView()
                    unitFrame:RefreshPosition()
                end
            end
        end
    end
end

table.insert(Heim.fixes, fix);
