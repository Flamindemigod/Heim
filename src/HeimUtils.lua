HeimUtils = {};

function HeimUtils.TODO(...) assert(false, ...); end

function HeimUtils.Iota(init)
    local __iota = init or 1;
    return function()
        local i = __iota;
        __iota = __iota + 1;
        return i;
    end
end

function HeimUtils.FragmentTblToMap(tbl)
    local copy = {};
    for _, value in pairs(tbl) do
        if (value.control ~= nil) then
            copy[HeimUtils.GetFragmentName(value)] = value;
        end
    end
    return copy;
end

function HeimUtils.MergeMaps(...)
    local dest = {};
    for _, it in ipairs({...}) do for k, v in pairs(it) do dest[k] = v; end end
    return dest;
end

function HeimUtils.GetFragmentName(fragment)
    if (fragment.control ~= nil) then return fragment.control:GetName(); end
    return nil;
end

function HeimUtils.GetAddonInfo(addonName)
    local manager = GetAddOnManager();
    for i = 1, manager:GetNumAddOns() do
        local name, title, author, desc, _, state = manager:GetAddOnInfo(i);
        if name == addonName and state == ADDON_STATE_ENABLED then
            return {
                name = name,
                title = title,
                author = author,
                description = desc
            };
        end
    end
    return nil;
end
