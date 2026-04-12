---@diagnostic disable: undefined-global
LUAGUI_NAME = "1fmASMDriver"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "Handles ASM On Frame and On Init functions."

local code_cave_written = false

local function inject_call_to_code_cave()
    -- Injects a call to the code cave at the end of the main loop, which allows for execution of custom code.
    WriteArray(mainLoopSentinel, assemblyMainLoopCodeCaveCall)
end

local function remove_call_to_code_cave()
    -- Removes the call to the code cave at the end of the main loop, restoring vanilla code.
    WriteArray(mainLoopSentinel, assemblyMainLoopRestore)
end

local function reset_code_cave()
    WriteInt(codeCave, 0)
    local t = {}
    for i = 1, codeCaveSize do t[i] = 0x0 end
    WriteArray(codeCave + 8, t)
end

function _OnInit()
    if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
        require("VersionCheck")
        if canExecute then
            reset_code_cave()
        end
    else
        ConsolePrint("KH1 not detected, not running script")
    end
end

function _OnFrame()
    if canExecute then
        if not code_cave_written and ReadInt(codeCave) > 0 then
            code_cave_written = true
            inject_call_to_code_cave()
        elseif code_cave_written then
            code_cave_written = false
            remove_call_to_code_cave()
            reset_code_cave()
        end
    end
end