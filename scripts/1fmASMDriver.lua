---@diagnostic disable: undefined-global
LUAGUI_NAME = "1fmASMDriver"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "Handles ASM On Frame and On Init functions."

local asm_globals = require("asm_globals")

local function inject_call_to_code_cave()
    -- Injects a call to the code cave at the end of the main loop, which allows for execution of custom code.
    WriteArray(mainLoopSentinel, assemblyMainLoopCodeCaveCall)
end

local function remove_call_to_code_cave()
    -- Removes the call to the code cave at the end of the main loop, restoring vanilla code.
    WriteArray(mainLoopSentinel, assemblyMainLoopRestore)
end

local function prepare_asm(offset_add)
    if not readied then
        inject_call_to_code_cave()
    end
    asm_globals.code_cave_offset = asm_globals.code_cave_offset + offset_add
    asm_globals.readied = true
end

local function inject_play_se2(sound_id)
    -- Injects code to play a sound effect using the SE2 function.
    local inject_bytes = {}
    for i, v in ipairs(assemblyPlaySE2) do inject_bytes[i] = v end
    inject_bytes[6] = sound_id & 0xFF
    inject_bytes[7] = (sound_id >> 8) & 0xFF
    WriteArray(codeCave + asm_globals.code_cave_offset, inject_bytes)
    prepare_asm(#inject_bytes)
end

local function handle_injections()
    for i, func_name in ipairs(asm_globals.functions_to_inject) do
        if func_name == "play_sound_effect" then
            local args = asm_globals.arguments_to_inject[i]
            inject_play_se2(args[1])
        end
    end
    -- Clear the tables after handling injections
    asm_globals.functions_to_inject = {}
    asm_globals.arguments_to_inject = {}
end

function _OnInit()
    if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
        require("VersionCheck")
    else
        ConsolePrint("KH1 not detected, not running script")
    end
end

function _OnFrame()
    if canExecute then
        if asm_globals.readied and not asm_globals.executed then
            asm_globals.executed = true
        elseif asm_globals.readied and asm_globals.executed then
            remove_call_to_code_cave()
            asm_globals.readied = false
            asm_globals.executed = false
            asm_globals.code_cave_offset = 0x0
        end
    elseif not asm_globals.readied and not asm_globals.executed and #asm_globals.functions_to_inject > 0 then
        handle_injections()
    end
end

return {
    inject_play_se2 = inject_play_se2,
    _OnInit = _OnInit,
    _OnFrame = _OnFrame
}