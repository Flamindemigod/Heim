-- Exoys Proc Set Tracker
-- https://www.esoui.com/downloads/info2783-ExoYsProcSetTimer.html
Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.patches = Heim.patches or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local Stack;

local function defaultConf()
    return {
        enable = false,
        position = Heim.ANCHOR:New({CENTER, GuiRoot, CENTER, 0, 0}),
        stackDirection = Heim.STACK_MODE.RIGHT
    };
end

local function patch()
    if (EPT ~= nil) then
        local conf = Heim.IsEnabled(Heim.config.EPT) and Heim.config.EPT or
                         defaultConf();
        Stack = Heim.STACK:New(EPT.name, conf.stackDirection);
        HUD_SCENE:AddFragment(Stack);
        HUD_UI_SCENE:AddFragment(Stack);
        SIEGE_BAR_SCENE:AddFragment(Stack);
        SIEGE_BAR_UI_SCENE:AddFragment(Stack);
        function EPT:CreateGui(setId)
            local name = tostring(setId);
            local gui = {};

            gui.win = EPT.window:CreateControl(name, GuiRoot, CT_CONTROL);
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

        function EPT:RegisterGUI(setId)
            if not EPT.guiList[setId] then
                EPT.guiList[setId] = EPT:CreateGui(setId);
            end
            Stack:AppendChild(EPT.guiList[setId].win);
            Stack:AppendChild(EPT.guiList[setId].win);
        end
        function EPT:UnregisterGUI(setId)
            Stack:RemoveChild(EPT.guiList[setId].win);
            Stack:RemoveChild(EPT.guiList[setId].win);
        end

    end
end

local function init()
    if (EPT ~= nil) then
        -- Boss Bar
        HeimUtils.RunWhenTrue(function()
            return Heim.config.EPT.position:IsValid()
        end, function()
            local conf = Heim.IsEnabled(Heim.config.EPT) and Heim.config.EPT or
                             defaultConf();
            Heim.config.EPT.control = Stack.control;
            conf.position:AddToControl(Stack.control, true);
            EPT:CheckEquippedSets()
        end)
    end
end

table.insert(Heim.inits, init);
table.insert(Heim.patches, patch);
table.insert(Heim.defaults, function() Heim.config.EPT = defaultConf() end);
