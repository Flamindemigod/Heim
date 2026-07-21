-- Exoys Proc Set Tracker
-- https://www.esoui.com/downloads/info2783-ExoYsProcSetTimer.html
Heim = Heim or {};

local function fix()
    if (EPT ~= nil) then
        function EPT:CreateGui(setId)
            local name = tostring(setId);
            local gui = {};

            gui.win = EPT.window:CreateControl(name, GuiRoot, CT_CONTROL);
            gui.win:SetClampedToScreen(true);
            gui.win:ClearAnchors();
            gui.win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.store[setId].left,
                              self.store[setId].top);
            gui.win:SetHidden(true);
            -- PrimaryIndicator
            gui.primaryInd = {};
            gui.primaryInd.ctrl = EPT.window:CreateControl(name ..
                                                               "PrimaryControl",
                                                           gui.win, CT_CONTROL);
            gui.primaryInd.edge = EPT.window:CreateControl(
                                      name .. "PrimaryEdge",
                                      gui.primaryInd.ctrl, CT_BACKDROP);
            gui.primaryInd.back = EPT.window:CreateControl(name ..
                                                               "PrimaryBackground",
                                                           gui.primaryInd.ctrl,
                                                           CT_BACKDROP);
            gui.primaryInd.icon = EPT.window:CreateControl(
                                      name .. "PrimaryIcon",
                                      gui.primaryInd.ctrl, CT_TEXTURE);
            gui.primaryInd.label = EPT.window:CreateControl(name ..
                                                                "PrimaryIndicator",
                                                            gui.primaryInd.ctrl,
                                                            CT_LABEL);

            -- NameDisplay
            gui.nameDisplay = {};
            gui.nameDisplay.ctrl = EPT.window:CreateControl(name ..
                                                                "NameControl",
                                                            gui.win, CT_CONTROL);
            gui.nameDisplay.back = EPT.window:CreateControl(name ..
                                                                "NameBackground",
                                                            gui.nameDisplay.ctrl,
                                                            CT_BACKDROP);
            gui.nameDisplay.label = EPT.window:CreateControl(
                                        name .. "NameLabel",
                                        gui.nameDisplay.ctrl, CT_LABEL);

            EPT:SetDesign(setId, gui);

            if setId ~= "demo" then
                if EPT.procSets[setId].type == "special" then
                    gui.secondaryInd = EPT:GetSecondaryIndicator(setId, gui.win);
                    gui.tertiaryInd = EPT:GetTertiaryIndicator(setId, gui.win);
                elseif EPT.procSets[setId].type == "stackEPT" or
                    EPT.procSets[setId].type == "stacktarget" then
                    gui.secondaryInd = EPT:GetSecondaryIndicator(setId, gui.win);
                end
            end
            return gui;
        end

        Heim.scenes.hud.fragmentList[EPT.name] =
            Heim.STACK:New(EPT.name, Heim.STACK_MODE.RIGHT);
        Heim.scenes.hudui.fragmentList[EPT.name] =
            Heim.scenes.hud.fragmentList[EPT.name];
        function EPT:RegisterGUI(setId)
            if not EPT.guiList[setId] then
                EPT.guiList[setId] = EPT:CreateGui(setId);
            end
            Heim.scenes.hud.fragmentList[EPT.name]:AppendChild(
                EPT.guiList[setId].win);
            Heim.scenes.hudui.fragmentList[EPT.name]:AppendChild(
                EPT.guiList[setId].win);
        end
        function EPT:UnregisterGUI(setId)
            Heim.scenes.hud.fragmentList[EPT.name]:RemoveChild(
                EPT.guiList[setId].win);
            Heim.scenes.hudui.fragmentList[EPT.name]:RemoveChild(
                EPT.guiList[setId].win);
        end

    end
end

table.insert(Heim.fixes, fix);
