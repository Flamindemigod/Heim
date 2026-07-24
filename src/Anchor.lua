Heim = Heim or {};
local Anchor = ZO_Object:Subclass();

local function AnchorFactory(pool) return ZO_Object.New(Anchor) end

local function AnchorReset(anchor)
    -- IsAlive shouldnt really be required as i should only be accessing it via a reference.
    -- This is more of a failsafe incase someone copies it and ends up with a dangling anchor that is no longer in use
    self.isAlive = false;
end

local pool = ZO_ObjectPool:New(AnchorFactory)

function Anchor:New(...)
    object, _ = pool:AcquireObject();
    object:Initialize(...);
    return object;
end

function Anchor:Initialize(posOnSelf, target, posOnTarget, offsetX, offsetY,
                           constrain)
    self.__type = "HeimAnchor";
    self.isAlive = true;
    if (target == GuiRoot or target == nil) then
        target = {control = GuiRoot};
    end
    if (type(target) == "userdata") then target = {control = target}; end
    assert(type(target) == "table",
           "target should be either `GuiRoot` or a table. " ..
               string.format("Got %s", type(target)));
    self.posOnSelf = posOnSelf or TOPLEFT;
    self.target = target;
    self.posOnTarget = posOnTarget or self.PosOnSelf;
    self.offsetX = offsetX or 0;
    self.offsetY = offsetY or 0;
    self.constrain = constrain or ANCHOR_CONSTRAINS_XY;
end

function Anchor:IsValid()
    return self.isAlive == true and self.target.control ~= nil;
end

function Anchor:AddToControl(control, clearAnchor)
    if (self:IsValid() ~= true) then return nil; end
    if (clearAnchor) then control:ClearAnchors(); end
    control:SetAnchor(ZO_Eval(self.posOnSelf), self.target.control,
                      ZO_Eval(self.posOnTarget), ZO_Eval(self.offsetX),
                      ZO_Eval(self.offsetY), ZO_Eval(self.constrain));
end

function Anchor:AsZOAnchor()
    if (self:IsValid() ~= true) then return nil; end
    return ZO_Anchor:New(ZO_Eval(self.posOnSelf), self.target.control,
                         ZO_Eval(self.posOnTarget), ZO_Eval(self.offsetX),
                         ZO_Eval(self.offsetY), ZO_Eval(self.constrain));
end

Heim.ANCHOR = Anchor;
Heim.ANCHOR_RESET = function() pool:ReleaseAllObjects() end;
