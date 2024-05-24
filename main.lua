local lunajson = require 'lunajson'
local utils    = require 'utils'

local primitive_term = function(term)
    return term.value
end

local binary_term = function(term, context)
    local lhs = evaluate(term.lhs, context)
    local rhs = evaluate(term.rhs, context)

    local hasEveryNumber = utils.hasEvery({
        lhs,
        rhs
    }, function(value)
        return utils.isNumber(value)
    end)

    local binaryOperationStrategy = {
        Add = function()
            if hasEveryNumber then
                return lhs + rhs
            end

            return tostring(lhs) .. tostring(rhs)
        end,
        Sub = function()
            if hasEveryNumber then
                return lhs - rhs
            end

            error("you can't sub non number values");
        end,
        Mul = function()
            if hasEveryNumber then
                return lhs * rhs
            end

            error("you can't mult non number values");
        end,
        Div = function()
            if hasEveryNumber then
                return lhs / rhs
            end

            error("you can't div non number values");
        end,
        Rem = function()
            if hasEveryNumber then
                return lhs % rhs
            end

            error("you can't use module operator in non number values");
        end,
        Eq = function()
            return lhs == rhs
        end,
        Neq = function()
            return lhs ~= rhs
        end,
        Lt = function()
            return lhs < rhs
        end,
        Gt = function()
            return lhs > rhs
        end,
        Lte = function()
            return lhs <= rhs
        end,
        Gte = function()
            return lhs >= rhs
        end,
        And = function()
            return lhs and rhs
        end,
        Or = function()
            return lhs or rhs
        end
    }

    return binaryOperationStrategy[term.op]()
end;

local print_term = function(term, context)
    local result = evaluate(term.value, context)
    print(result)
end

local let_term = function(term, context)
    context[term.name.text] = evaluate(term.value, context)
    return evaluate(term.next, context);
end

local var_term = function(term, context)
    local result = context[term.text]
    return result or error("variable not defined: " .. term.text)
end

local if_term = function(term, context)
    local result = evaluate(term.condition, context)
    if result then
        return evaluate(term["then"], context)
    else
        return evaluate(term.otherwise, context)
    end
end

local func_term = function(term, context)
    return {
        type = "function",
        value = term.value,
        params = term.parameters,
        scope = context
    }
end

local call_term = function(term, context)
    local callee = evaluate(term.callee, context)
    if callee and callee.type == "function" then
        local args = utils.shallowcopy(context)

        for key, value in pairs(callee.params) do
            args[value.text] = evaluate(term.arguments[key], context)
        end
        return evaluate(callee.value, args)
    end

    error("function not defined:" .. term.callee.text)
end

local terms = {
    Str = primitive_term,
    Int = primitive_term,
    Bool = primitive_term,
    Binary = binary_term,
    Print = print_term,
    Let = let_term,
    Var = var_term,
    If = if_term,
    Call = call_term,
    Function = func_term
}

function evaluate(expression, context)
    context = context or {}
    local term = terms[expression.kind]

    if term then
        return term(expression, context)
    end

    error("invalid expression: " .. expression.kind);
end

local function main()
    local timeInit = os.clock()
    local json = io.read("a")
    local file = lunajson.decode(json)
    evaluate(file.expression)
    local timeEnd = os.clock()
    print("duration: " .. timeEnd -  timeInit.. " seconds")
end

main();
