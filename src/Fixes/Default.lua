Heim = Heim or {};

function Heim.LoadFixes()
    Heim.ZOFixes();
    for _, it in pairs(Heim.fixes) do it(); end
end
