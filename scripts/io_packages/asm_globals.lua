local code_cave_offset = 0x0
local readied = false
local executed = false
local functions_to_inject = {}
local arguments_to_inject = {}

return {
    code_cave_offset = code_cave_offset,
    readied = readied,
    executed = executed,
    functions_to_inject = functions_to_inject,
    arguments_to_inject = arguments_to_inject
}