local code_cave_offset = 0x0
local readied = false
local executed = false

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
    code_cave_offset = code_cave_offset + offset_add
    readied = true
end

local function inject_play_se2(sound_id)
    -- Injects code to play a sound effect using the SE2 function.
    local inject_bytes = {}
    for i, v in ipairs(assemblyPlaySE2) do inject_bytes[i] = v end
    inject_bytes[6] = sound_id & 0xFF
    inject_bytes[7] = (sound_id >> 8) & 0xFF
    WriteArray(codeCave + code_cave_offset, inject_bytes)
    prepare_asm(#inject_bytes)
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
        if readied and not executed then
            executed = true
        elseif readied and executed then
            remove_call_to_code_cave()
            readied = false
            executed = false
            code_cave_offset = 0x0
        end
    end
end

return {
    inject_play_se2 = inject_play_se2
}