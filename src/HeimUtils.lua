HeimUtils = {};

function HeimUtils.TODO(...) assert(false, ...); end

function HeimUtils.Iota(init)
    local __iota = init or 1
    return function()
        local i = __iota
        __iota = __iota + 1
        return i
    end
end
