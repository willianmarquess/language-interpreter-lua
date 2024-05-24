local utils = {}

-- reference: http://lua-users.org/wiki/CopyTable
function utils.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function utils.isNumber(value)
    return type(value) == "number"
end

function utils.hasEvery(values, expression)
    values = values or {}
    for _, value in pairs(values) do
        if expression(value) ~= true then
            return false
        end
    end

    return true
end


return utils