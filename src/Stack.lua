Heim = Heim or {};
HeimUtils = HeimUtils or {};
Heim.Stack = {};

local Stack = ZO_HUDFadeSceneFragment:Subclass();

local STACK_MODE_IOTA = HeimUtils.Iota();

local STACK_MODE = {
    UP = STACK_MODE_IOTA(),
    DOWN = STACK_MODE_IOTA(),
    LEFT = STACK_MODE_IOTA(),
    RIGHT = STACK_MODE_IOTA()
};

function Stack:New(...) return ZO_HUDFadeSceneFragment.New(self, ...); end

function Stack:Initialize(name, mode, gap, type)
    local root = Heim.WM:CreateControl(Heim.name .. name, GuiRoot,
                                       type or CT_TOPLEVELCONTROL);
    ApplyTemplateToControl(root, "Heim_Stack")
    ZO_HUDFadeSceneFragment.Initialize(self, root);
    self.mode = mode;
    self.gap = gap or 16
end

function Stack:HasChild(control)
    for it_index = 1, self.control:GetNumChildren() do
        local it = self.control:GetChild(it_index);
        if (it == control) then return it_index end
    end
    return nil
end

function Stack:ComputeLayout()
    if (self.requiresReLayout == nil) then return; end
    self.requiresReLayout = nil;
    for it_index = 1, self.control:GetNumChildren() do
        local it = self.control:GetChild(it_index);
        it:ClearAnchors();
        local anchorTarget = self.control:GetChild(it_index - 1);
        if (anchorTarget ~= nil) then
            -- TODO: Handle all modes
            it:SetAnchor(TOPLEFT, self.control:GetChild(it_index - 1), TOPRIGHT,
                         self.gap, 0);
        else
            it:SetAnchor(TOPLEFT, self.control, TOPLEFT, 0, 0);
        end
    end
end

function Stack:OnShown()
    self:ComputeLayout();
    self:SetState(SCENE_FRAGMENT_SHOWN)
end

function Stack:OnHidden() self:SetState(SCENE_FRAGMENT_HIDDEN) end

function Stack:AppendChild(control)
    if (self:HasChild(control) == nil) then
        control:SetParent(self.control);
        control:SetHidden(false);
        if (self.requiresReLayout ~= nil) then
            zo_removeCallLater(self.requiresReLayout)
        end
        self.requiresReLayout = zo_callLater(function()
            self:ComputeLayout()
        end, 1);
    end
end

function Stack:RemoveChild(control)
    local child_index = self:HasChild(control);
    if (child_index ~= nil) then
        control:SetHidden(true);
        control:SetParent(GuiRoot);
        if (self.requiresReLayout ~= nil) then
            zo_removeCallLater(self.requiresReLayout)
        end
        self.requiresReLayout = zo_callLater(function()
            self:ComputeLayout()
        end, 1);
    end
end

Heim.STACK = Stack;
Heim.STACK_MODE = STACK_MODE;
