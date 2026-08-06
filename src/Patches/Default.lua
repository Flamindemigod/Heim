Heim = Heim or {};
Heim.patches = Heim.patches or {};

function Heim.LoadPatches()
    Heim.ZOPatches();
    for _, it in pairs(Heim.patches) do it(); end
end

