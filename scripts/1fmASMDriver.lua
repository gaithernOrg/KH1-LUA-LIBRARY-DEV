---@diagnostic disable: undefined-global
LUAGUI_NAME = "1fmASMDriver"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "Handles ASM On Frame and On Init functions."

local asm = require("asm.lua")

function _OnInit()
    asm._OnInit()
end

function _OnFrame()
    asm._OnFrame()
end