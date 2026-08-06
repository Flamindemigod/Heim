HeimUtils = {};

function HeimUtils.TODO(fmt, ...)
    assert(false, string.format("TODO: " .. fmt, ...));
end
function HeimUtils.UNREACHABLE(fmt, ...)
    assert(false, string.format("UNREACHABLE: " .. fmt, ...));
end

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

local function __type(obj)
    if (type(obj) == "table" and obj.__type ~= nil) then return obj.__type; end
    return type(obj);
end
function HeimUtils.MergeMaps(deep, dest, ...)
    for _, it in ipairs({...}) do
        for k, v in pairs(it) do
            if (deep == true and __type(dest[k]) == "table" and __type(v) ==
                "table") then
                dest[k] = HeimUtils.MergeMaps(deep, dest[k], v);
            else
                dest[k] = v;
            end
        end
    end
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

local LOG_MODE_IOTA = HeimUtils.Iota();
HeimUtils.LOG_MODE = {
    ERROR = LOG_MODE_IOTA(),
    WARN = LOG_MODE_IOTA(),
    INFO = LOG_MODE_IOTA(),
    DEBUG = LOG_MODE_IOTA(),
    TRACE = LOG_MODE_IOTA()
};

function HeimUtils.Logger(moduleName, logMode)
    return {
        error = function(fmtStr, ...)
            if (logMode < HeimUtils.LOG_MODE.ERROR) then return nil; end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Error: " ..
                                       string.format(fmtStr, ...))
        end,
        warn = function(fmtStr, ...)
            if (logMode < HeimUtils.LOG_MODE.WARN) then return nil; end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Warn: " ..
                                       string.format(fmtStr, ...))
        end,
        info = function(fmtStr, ...)
            if (logMode < HeimUtils.LOG_MODE.INFO) then return nil; end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Info: " ..
                                       string.format(fmtStr, ...))
        end,
        debug = function(fmtStr, ...)
            if (logMode < HeimUtils.LOG_MODE.DEBUG) then return nil; end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Debug: " ..
                                       string.format(fmtStr, ...))
        end,
        trace = function(fmtStr, ...)
            if (logMode < HeimUtils.LOG_MODE.TRACE) then return nil; end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Trace: " ..
                                       string.format(fmtStr, ...))
        end
    }
end

-- Straight up yoinked from Buff the Group
-- https://github.com/Fostecks/BuffTheGroup
-- Repo hasnt been updated for a while
-- Bitrock(Fostecks) being Lazy
function HeimUtils.Lerp(a, b, coefficient) return a + (b - a) * coefficient end

-- Straight up yoinked from Buff the Group
-- https://github.com/Fostecks/BuffTheGroup
-- Repo hasnt been updated for a while
-- Bitrock(Fostecks) being Lazy
function HeimUtils.Clamp(i, min, max) return math.max(min, math.min(max, i)) end

function HeimUtils.GetColor(hexValue)
    local color = {};
    color.r = BitAnd(BitLShift(hexValue, 24), 0xFF);
    color.g = BitAnd(BitLShift(hexValue, 16), 0xFF);
    color.b = BitAnd(BitLShift(hexValue, 8), 0xFF);
    color.a = BitAnd(BitLShift(hexValue, 1), 0xFF);
    return color;
end

function HeimUtils.SecondsToMinSecString(inputSecs)
    local min = math.floor(inputSecs / 60)
    local secs = inputSecs % 60
    return string.format("%01d:%02d", min, secs)
end

local RunWhenTrueId = 1;
function HeimUtils.RunWhenTrue(conditional, f, timeBeween)
    local id = RunWhenTrueId;
    RunWhenTrueId = RunWhenTrueId + 1;
    local name = "HeimUtils.RunWhenTrue" .. id;
    Heim.EM:RegisterForUpdate(name, timeBetween or 50, function()
        if (ZO_Eval(conditional)) then
            f();
            Heim.EM:UnregisterForUpdate(name)
        end
    end)
end
