Heim = Heim or {};
Heim.patches = Heim.patches or {};
Heim.inits = Heim.inits or {};
Heim.defaults = Heim.defaults or {};
Heim.config = Heim.config or {};

function Heim.BuildDefaultConfig()
    for _, it in pairs(Heim.defaults) do it(); end
end

function Heim.LoadPatches()
    Heim.ZOPatches();
    for _, it in pairs(Heim.patches) do it(); end
    Heim.ReInits();
end

function Heim.ReInits() for _, it in pairs(Heim.inits) do it(); end end
