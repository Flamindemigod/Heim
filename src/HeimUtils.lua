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

local LOG_MODE_IOTA = HeimUtils.Iota();
HeimUtils.LOG_MODE = {
    ERROR = LOG_MODE_IOTA(),
    WARN  = LOG_MODE_IOTA(),
    INFO  = LOG_MODE_IOTA(),
    DEBUG = LOG_MODE_IOTA(),
    TRACE = LOG_MODE_IOTA(),
};

function HeimUtils.Logger(moduleName, logMode)
    return {
        error = function(fmtStr, ...)
            if (logMode < HeimUtils.LOG_MODE.ERROR) then return nil; end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Error: " .. string.format(fmtStr, ...))
        end,
        warn = function(fmtStr, ...)
            if (logMode < HeimUtils.LOG_MODE.WARN) then return nil; end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Warn: " .. string.format(fmtStr, ...))
        end,
        info = function(fmtStr, ...)
            if (logMode < HeimUtils.LOG_MODE.INFO) then return nil; end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Info: " .. string.format(fmtStr, ...))
        end,
        debug = function(fmtStr, ...)
            if (logMode < HeimUtils.LOG_MODE.DEBUG) then return nil; end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Debug: " .. string.format(fmtStr, ...))
        end,
        trace = function(fmtStr, ...)
            if (logMode < HeimUtils.LOG_MODE.TRACE) then return nil; end
            CHAT_SYSTEM:AddMessage("[" .. moduleName .. "] Trace: " .. string.format(fmtStr, ...))
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
