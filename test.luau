-- wiggle wiggle wave
local lines = 23  -- number of increasing indent lines
local indent = 0  -- starting spaces

-- ascending
for i = 1, lines do
    print(string.rep(" ", indent) .. "wiggle wiggle")
    indent = indent + 1
end

-- middle plateau (repeats)
for i = 1, 3 do
    print(string.rep(" ", indent) .. "wiggle wiggle")
end

-- descending
for i = lines, 1, -1 do
    indent = indent - 1
    print(string.rep(" ", indent) .. "wiggle wiggle")
end
