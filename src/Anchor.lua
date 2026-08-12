Heim = Heim or {};
local Anchor = ZO_Object:Subclass();

local function AnchorFactory(pool) return ZO_Object.New(Anchor) end

local function AnchorReset(anchor)
    -- IsAlive shouldnt really be required as i should only be accessing it via a reference.
    -- This is more of a failsafe incase someone copies it and ends up with a dangling anchor that is no longer in use
    self.isAlive = false;
end

local pool = ZO_ObjectPool:New(AnchorFactory, AnchorReset)

function Anchor:New(...)
    object, _ = pool:AcquireObject();
    object:Initialize(...);
    return object;
end

local function validateTarget(target)
    if (target == GuiRoot or target == nil) then
        target = {control = GuiRoot};
    end
    if (type(target) == "userdata") then target = {control = target}; end
    assert(type(target) == "table",
           "target should be either `GuiRoot` or a table. " ..
               string.format("Got %s", type(target)));
    return target;
end

function Anchor:Initialize(a1, a2)
    self.__type = "HeimAnchor";
    self.isAlive = true;
    do
        local posOnSelf, target, posOnTarget, offsetX, offsetY, constrain =
            unpack(a1);
        self.posOnSelf = posOnSelf or TOPLEFT;
        self.target = validateTarget(target);
        self.posOnTarget = posOnTarget or self.posOnSelf;
        self.offsetX = offsetX or 0;
        self.offsetY = offsetY or 0;
        self.constrain = constrain or ANCHOR_CONSTRAINS_XY;
    end
    if (a2 ~= nil) then
        local posOnSelf, target, posOnTarget, offsetX, offsetY, constrain =
            unpack(a2);
        self.posOnSelf1 = posOnSelf or TOPLEFT;
        self.target1 = target ~= nil and validateTarget(target) or nil;
        self.posOnTarget1 = posOnTarget or self.PosOnSelf1;
        self.offsetX1 = offsetX or 0;
        self.offsetY1 = offsetY or 0;
        self.constrain1 = constrain or ANCHOR_CONSTRAINS_XY;
    end
end

function Anchor:IsValid()
    if (self.isAlive == false) then return false; end
    if (self.target.control == nil) then return false; end
    if (self.target1 ~= nil and self.target1.control == nil) then
        return false;
    end
    return true;
end

function Anchor:AddToControl(control, clearAnchor)
    if (self:IsValid() ~= true) then return nil; end
    if (clearAnchor) then control:ClearAnchors(); end
    control:SetAnchor(ZO_Eval(self.posOnSelf), self.target.control,
                      ZO_Eval(self.posOnTarget), ZO_Eval(self.offsetX),
                      ZO_Eval(self.offsetY), ZO_Eval(self.constrain));
    if (self.target1 ~= nil) then
        control:SetAnchor(ZO_Eval(self.posOnSelf1), self.target1.control,
                          ZO_Eval(self.posOnTarget1), ZO_Eval(self.offsetX1),
                          ZO_Eval(self.offsetY1), ZO_Eval(self.constrain1));
    end
end

function Anchor:AsZOAnchor()
    if (self:IsValid() ~= true) then return nil; end
    return ZO_Anchor:New(ZO_Eval(self.posOnSelf), self.target.control,
                         ZO_Eval(self.posOnTarget), ZO_Eval(self.offsetX),
                         ZO_Eval(self.offsetY), ZO_Eval(self.constrain));
end

function Anchor:AsZOAnchor1()
    if (self:IsValid() ~= true or self.target1 == nil) then return nil; end
    return ZO_Anchor:New(ZO_Eval(self.posOnSelf1), self.target1.control,
                         ZO_Eval(self.posOnTarget1), ZO_Eval(self.offsetX1),
                         ZO_Eval(self.offsetY1), ZO_Eval(self.constrain1));
end

Heim.ANCHOR = Anchor;
Heim.ANCHOR_RESET = function() pool:ReleaseAllObjects() end;
