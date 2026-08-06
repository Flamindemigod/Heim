Heim = Heim or {};
Heim.patches = Heim.patches or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

local function defaultConfCompass()
    return {
        enable = false,
        position = Heim.ANCHOR:New({TOP, GuiRoot, TOP, 0, 58}),
        size = {
            h = ZO_COMPASS_FRAME_HEIGHT_GAMEPAD,
            w = function()
                local MIN_WIDTH = 400
                local MAX_WIDTH = 800
                local screenWidth = GuiRoot:GetWidth()
                return zo_clamp(screenWidth * .35, MIN_WIDTH, MAX_WIDTH)
            end
        }
    };
end

local function defaultConfHousingHud()
    return {
        enable = false,
        position = Heim.ANCHOR:New({
            TOPLEFT, ZO_PromotionalEventTracker_TL, BOTTOMLEFT
        })
    };
end

local function defaultConfPerformanceMeters()
    return {
        enable = false,
        position = Heim.ANCHOR:New({BOTTOMLEFT, GuiRoot, BOTTOMLEFT, -20, 20})
    };
end

local function defaultConfChat()
    return {
        enable = false,
        position = Heim.ANCHOR:New({BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 0, -64}),
        scale = 1,
        minimize_direction = "left",
        size = {w = 16 * 42, h = 16 * 42 * (3 / 4)}
    };
end

local function defaultConfSynergy()
    return {
        enable = false,
        position = Heim.ANCHOR:New({BOTTOM, ZO_ActionBar1, TOP, 0, -64}),
        showKey = true,
        showText = true,
        scale = 1
    };
end

function Heim.ZOPatches()
    local compass = Heim.config.ZOCompass;
    function COMPASS_FRAME:ApplyStyle()
        compass = Heim.IsEnabled(Heim.config.ZOCompass) and
                      Heim.config.ZOCompass or defaultConfCompass();
        local frameHeight = ZO_Eval(compass.size.h);
        Heim.config.ZOCompass.control = self.control;
        ApplyTemplateToControl(self.control,
                               ZO_GetPlatformTemplate("ZO_CompassFrame"))
        compass.position:AddToControl(self.control, true);
        self.control:SetHeight(frameHeight)
        local gamepadMode = IsInGamepadPreferredMode()
        local center = self.control:GetNamedChild("Center")
        center:GetNamedChild("TopMungeOverlay"):SetHidden(gamepadMode)
        center:GetNamedChild("BottomMungeOverlay"):SetHidden(gamepadMode)

        if gamepadMode then
            if self.bossBarReady and self.bossBarActive then
                local frame = self.control
                frame:SetHeight(frameHeight - 1)
                frame:GetNamedChild("Left"):SetHeight(frameHeight - 1)
                frame:GetNamedChild("Right"):SetHeight(frameHeight - 1)
            end
        end
    end

    function COMPASS_FRAME:UpdateWidth()
        compass = Heim.IsEnabled(Heim.config.ZOCompass) and
                      Heim.config.ZOCompass or defaultConfCompass();
        self.control:SetWidth(ZO_Eval(compass.size.w));
    end
    local housingHud = Heim.config.ZOHousingHud;
    function ZO_HouseInformationTracker:InitializeStyles()
        housingHud = Heim.IsEnabled(Heim.config.ZOHousingHud) and
                         Heim.config.ZOHousingHud or defaultConfHousingHud();
        Heim.config.ZOHousingHud.control = self.control
        local style = {
            CONTAINER_PRIMARY_ANCHOR = ZO_Anchor:New(TOPLEFT),
            CONTAINER_SECONDARY_ANCHOR = ZO_Anchor:New(TOPRIGHT),

            FONT_HEADER = "ZoFontGamepadBold27",
            FONT_POPULATION = "ZoFontGamepad34",
            FONT_SUBLABEL = "ZoFontGamepad34",
            FONT_TAGS = "ZoFontGamepad34",

            POPULATION_HEADERLABEL_PRIMARY_ANCHOR = ZO_Anchor:New(TOPRIGHT,
                                                                  self.headerLabel,
                                                                  BOTTOMRIGHT,
                                                                  0, 10),

            POPULATION_SUBLABEL_PRIMARY_ANCHOR = ZO_Anchor:New(TOPRIGHT,
                                                               self.subLabel,
                                                               BOTTOMRIGHT, 0, 0),

            TAGS_LABEL_PRIMARY_ANCHOR = ZO_Anchor:New(TOPRIGHT,
                                                      self.populationLabel,
                                                      BOTTOMRIGHT, 0, 0),

            TEXT_HORIZONTAL_ALIGNMENT = TEXT_ALIGN_RIGHT,

            TOP_LEVEL_PRIMARY_ANCHOR = housingHud.position:AsZOAnchor(),
            TOP_LEVEL_SECONDARY_ANCHOR = Heim.IsEnabled(Heim.config.ZOHousingHud) and
                nil or
                ZO_Anchor:New(RIGHT, GuiRoot, RIGHT, -15, 0, ANCHOR_CONSTRAINS_X)
        };
        self.styles = {keyboard = style, gamepad = style}

        ZO_HUDTracker_Base.InitializeStyles(self)
    end
    do
        local function OnPlay(animation, control)
            control.container:SetMinimizingOrMaximizing(true)
            control:SetClampedToScreen(false)
        end

        local function OnStop(animation, control)
            local progress = animation:GetTimeline():GetProgress()
            local conf = Heim.IsEnabled(Heim.config.ZOChat) and
                             Heim.config.ZOChat or defaultConfChat();
            local maximized;
            if (string.lower(conf.minimize_direction) == "left") then
                maximized = animation:GetDeltaOffsetX() >= 0
            elseif (string.lower(conf.minimize_direction) == "right") then
                maximized = animation:GetDeltaOffsetX() <= 0;
            end
            control:SetClampedToScreen(maximized)
            control.container:SetMinimizingOrMaximizing(false)
        end

        local function GetOrCreateMinimizeAnimationTimeline(container)
            if not container.minimizeAnimationTimeline then
                local animationTimeline =
                    ANIMATION_MANAGER:CreateTimelineFromVirtual(
                        "ChatMinMaxAnim", container.control)
                container.minimizeAnimationTimeline = animationTimeline

                local animation = animationTimeline:GetAnimation(1)
                animation:SetHandler("OnPlay", OnPlay)
                animation:SetHandler("OnStop", OnStop)
            end

            return container.minimizeAnimationTimeline
        end
        function KEYBOARD_CHAT_SYSTEM:Minimize()
            if not self.isMinimized then
                local conf = Heim.IsEnabled(Heim.config.ZOChat) and
                                 Heim.config.ZOChat or defaultConfChat();
                for _, container in pairs(self.containers) do
                    local animationTimeline =
                        GetOrCreateMinimizeAnimationTimeline(container)
                    local minimizeDistance
                    if not animationTimeline:IsPlaying() then
                        if (string.lower(conf.minimize_direction) == "left") then
                            minimizeDistance = container.control:GetRight()
                        elseif (string.lower(conf.minimize_direction) == "right") then
                            minimizeDistance = container.control:GetLeft()
                        end
                        container.originalPosition = minimizeDistance
                    else
                        minimizeDistance = container.originalPosition
                    end

                    -- Additional margin to ensure the container is completely hidden
                    if (string.lower(conf.minimize_direction) == "left") then
                        minimizeDistance = minimizeDistance + 40
                    elseif (string.lower(conf.minimize_direction) == "right") then
                        local screenWidth = GuiRoot:GetWidth()
                        minimizeDistance =
                            -(screenWidth - minimizeDistance + 40)
                    end
                    -- Set the animation distance
                    animationTimeline:GetAnimation(1):SetTranslateDeltas(
                        -minimizeDistance, 0)

                    -- Fire the animation
                    animationTimeline:PlayFromStart()

                    -- Hide all the tabs at the top
                    for _, tab in pairs(container.tabGroup.m_Buttons) do
                        tab:SetHidden(true)
                    end

                    if container.overflowTab then
                        container.overflowTab:SetHidden(true)
                    end
                    if container.newWindowTab then
                        container.newWindowTab:SetHidden(true)
                    end
                end

                -- Move the buttons to and show the minimized bar
                PlaySound(SOUNDS.CHAT_MINIMIZED)
                self:ShowMinBar()
            end
        end

        function KEYBOARD_CHAT_SYSTEM:Maximize()
            if self.isMinimized then
                local conf = Heim.IsEnabled(Heim.config.ZOChat) and
                                 Heim.config.ZOChat or defaultConfChat();
                for _, container in pairs(self.containers) do
                    -- If Minimize() was called before chat containers were created, trying access originalPosition will error.
                    if container.originalPosition then
                        -- Calculate the distance to the original position
                        local maximizeDistance;
                        if (string.lower(conf.minimize_direction) == "left") then
                            maximizeDistance =
                                container.originalPosition -
                                    container.control:GetRight()
                        elseif (string.lower(conf.minimize_direction) == "right") then
                            maximizeDistance =
                                container.originalPosition -
                                    container.control:GetLeft()
                        end

                        -- Setup the animation and fire it
                        local animationTimeline =
                            GetOrCreateMinimizeAnimationTimeline(container)
                        animationTimeline:GetAnimation(1):SetTranslateDeltas(
                            maximizeDistance, 0)
                        animationTimeline:PlayFromStart()

                        -- Show the tabs that haven't overflowed
                        for _, tab in pairs(container.tabGroup.m_Buttons) do
                            if tab.index < container.hiddenTabStartIndex then
                                tab:SetHidden(false)
                            elseif container.overflowTab then
                                container.overflowTab:SetHidden(false)
                            end
                        end
                        if container.newWindowTab then
                            container.newWindowTab:SetHidden(false)
                        end
                        container:FadeIn()
                    end
                end

                -- Hide the minimized bar and fade in the windows
                PlaySound(SOUNDS.CHAT_MAXIMIZED)
                self:HideMinBar()

                if self.newChatFadeAnim and self.newChatFadeAnim:IsPlaying() then
                    self.newChatFadeAnim:Stop()
                    self.minBar.bgHighlight:SetAlpha(0)
                end
            end
        end
    end
    function KEYBOARD_CHAT_SYSTEM:ShowMinBar()
        -- clear the anchors
        self.mailButton:ClearAnchors()
        self.mailLabel:ClearAnchors()
        self.friendsButton:ClearAnchors()
        self.friendsLabel:ClearAnchors()
        self.notificationsButton:ClearAnchors()
        self.notificationsLabel:ClearAnchors()
        self.minBar.maxButton:ClearAnchors()
        self.agentChatButton:ClearAnchors()

        -- reset the parentage for fading purposes
        self.mailButton:SetParent(self.minBar)
        self.mailLabel:SetParent(self.minBar)
        self.friendsButton:SetParent(self.minBar)
        self.friendsLabel:SetParent(self.minBar)
        self.notificationsButton:SetParent(self.minBar)
        self.notificationsLabel:SetParent(self.minBar)
        self.agentChatButton:SetParent(self.minBar)

        -- reanchor everything
        self.mailButton:SetAnchor(TOP, nil, TOP, 0, 16)
        self.mailLabel:SetAnchor(TOP, self.mailButton, BOTTOM, 0, -8)
        self.friendsButton:SetAnchor(TOP, self.mailLabel, BOTTOM)
        self.friendsLabel:SetAnchor(TOP, self.friendsButton, BOTTOM, 0, -8)
        self.notificationsButton:SetAnchor(TOP, self.friendsLabel, BOTTOM)
        self.notificationsLabel:SetAnchor(TOP, self.notificationsButton, BOTTOM,
                                          0, -8)
        self.agentChatButton:SetAnchor(TOPLEFT, self.notificationsLabel, BOTTOM)
        self.minBar.maxButton:SetAnchor(TOPLEFT, self.agentChatButton,
                                        BOTTOMLEFT)

        -- center the labels
        self.mailLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        self.friendsLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        self.notificationsLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        -- TODO: Fix orientation of the button depending on side
        -- Gonna just hide it for now
        self.minBar.maxButton:SetHidden(true);
        self.minBar:SetHidden(false)
        self.isMinimized = true
    end
end

local function init()
    HeimUtils.RunWhenTrue(function()
        return Heim.config.ZOCompass.position:IsValid()
    end, function()
        COMPASS_FRAME:ApplyStyle();
        COMPASS_FRAME:UpdateWidth();
    end)
    HeimUtils.RunWhenTrue(function()
        return Heim.config.ZOHousingHud.position:IsValid()
    end, function() HOUSE_INFORMATION_TRACKER:InitializeStyles() end)
    HeimUtils.RunWhenTrue(function()
        return Heim.config.ZOPerformanceMeters.position:IsValid()
    end, function()
        local conf = Heim.IsEnabled(Heim.config.ZOPerformanceMeters) and
                         Heim.config.ZOPerformanceMeters or
                         defaultConfPerformanceMeters();
        PERFORMANCE_METERS.control:SetMovable(false);
        conf.position:AddToControl(PERFORMANCE_METERS.control, true);
    end)
    HeimUtils.RunWhenTrue(function()
        return Heim.config.ZOChat.position:IsValid()
    end, function()
        local conf =
            Heim.IsEnabled(Heim.config.ZOChat) and Heim.config.ZOChat or
                defaultConfChat();
        Heim.config.ZOChat.control = ZO_ChatWindow;
        conf.position:AddToControl(ZO_ChatWindow, true);
        ZO_ChatWindow:SetScale(conf.scale);
        ZO_ChatWindow:SetDimensions(conf.size.w / conf.scale,
                                    conf.size.h / conf.scale);
        local pos = conf.position
        pos.offsetX = 0;
        pos.constrain = ANCHOR_CONSTRAINS_X;
        pos:AddToControl(KEYBOARD_CHAT_SYSTEM.minBar, true);
        KEYBOARD_CHAT_SYSTEM.minBar:SetAnchor(BOTTOMRIGHT, ZO_ChatWindowBg,
                                              BOTTOMRIGHT, 0, 12,
                                              ANCHOR_CONSTRAINS_Y);
        KEYBOARD_CHAT_SYSTEM.minBar:SetDimensions(64 / conf.scale,
                                                  ZO_ChatWindowBg:GetHeight() /
                                                      conf.scale - 12);
    end)
    HeimUtils.RunWhenTrue(function()
        return Heim.config.ZOSynergy.position:IsValid() and
                   ZO_SynergyTopLevelContainer ~= nil
    end, function()
        local conf = Heim.IsEnabled(Heim.config.ZOSynergy) and
                         Heim.config.ZOSynergy or defaultConfSynergy();
        Heim.config.ZOSynergy.control = ZO_SynergyTopLevelContainer;
        conf.position:AddToControl(ZO_SynergyTopLevelContainer, true);
        ZO_SynergyTopLevelContainer:GetNamedChild("Key"):SetHidden(
            not conf.showKey)
        ZO_SynergyTopLevelContainer:GetNamedChild("Action"):SetHidden(
            not conf.showKey)
        ZO_SynergyTopLevelContainer:SetScale(conf.scale)
    end)
end
table.insert(Heim.inits, init);
table.insert(Heim.defaults, function()
    Heim.config.ZOCompass = defaultConfCompass();
    Heim.config.ZOHousingHud = defaultConfHousingHud();
    Heim.config.ZOPerformanceMeters = defaultConfPerformanceMeters();
    Heim.config.ZOChat = defaultConfChat();
    Heim.config.ZOSynergy = defaultConfSynergy();
end);
