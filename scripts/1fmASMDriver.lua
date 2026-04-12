---@diagnostic disable: undefined-global
LUAGUI_NAME = "1fmASMDriver"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "Handles ASM On Frame and On Init functions."

require("asm_globals")

local function inject_call_to_code_cave()
    -- Injects a call to the code cave at the end of the main loop, which allows for execution of custom code.
    WriteArray(mainLoopSentinel, assemblyMainLoopCodeCaveCall)
end

local function remove_call_to_code_cave()
    -- Removes the call to the code cave at the end of the main loop, restoring vanilla code.
    WriteArray(mainLoopSentinel, assemblyMainLoopRestore)
end

local function prepare_asm(offset_add)
    if not ASM_READIED then
        inject_call_to_code_cave()
    end
    ASM_CODE_CAVE_OFFSET = ASM_CODE_CAVE_OFFSET + offset_add
    ASM_READIED = true
end

local function inject_play_se2(sound_id)
    -- Injects code to play a sound effect using the SE2 function.
    local inject_bytes = {}
    for i, v in ipairs(assemblyPlaySE2) do inject_bytes[i] = v end
    inject_bytes[6] = sound_id & 0xFF
    inject_bytes[7] = (sound_id >> 8) & 0xFF
    WriteArray(codeCave + ASM_CODE_CAVE_OFFSET, inject_bytes)
    prepare_asm(#inject_bytes)
end

local function handle_injections()
    for i, func_name in ipairs(ASM_FUNCTIONS_TO_INJECT) do
        if func_name == "play_sound_effect" then
            local args = ASM_ARGUMENTS_TO_INJECT[i]
            inject_play_se2(args[1])
        end
    end
    -- Clear the tables after handling injections
    ASM_FUNCTIONS_TO_INJECT = {}
    ASM_ARGUMENTS_TO_INJECT = {}
end

function _OnInit()
    if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
        require("VersionCheck")
        if canExecute then
            remove_call_to_code_cave()
        end
    else
        ConsolePrint("KH1 not detected, not running script")
    end
end

function _OnFrame()
    if canExecute then
        if ASM_READIED and not ASM_EXECUTED then
            ASM_EXECUTED = true
        elseif ASM_READIED and ASM_EXECUTED then
            remove_call_to_code_cave()
            ASM_READIED = false
            ASM_EXECUTED = false
            ASM_CODE_CAVE_OFFSET = 0x0
        elseif not ASM_READIED and not ASM_EXECUTED and #ASM_FUNCTIONS_TO_INJECT > 0 then
            handle_injections()
        end
    end
end