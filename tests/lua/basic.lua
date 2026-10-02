--   Copyright (C) 2024 PCSX-Redux authors
--
--   This program is free software; you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation; either version 2 of the License, or
--   (at your option) any later version.
--
--   This program is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details.
--
--   You should have received a copy of the GNU General Public License
--   along with this program; if not, write to the
--   Free Software Foundation, Inc.,
--   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

local lu = require 'luaunit'

TestBasic = {}

function TestBasic:test_basic()
    lu.assertEquals(1, 1)
end

function TestBasic:test_coroutine()
    local testCoroutine = coroutine.running()
    PCSX.nextTick(function()
        coroutine.resume(testCoroutine, 42)
    end)
    local r = coroutine.yield()
    lu.assertEquals(r, 42)
end

function TestBasic:test_pad_analog_override_api()
    local axes = PCSX.CONSTS.PAD.AXIS
    lu.assertEquals({ axes.RIGHT_X, axes.RIGHT_Y, axes.LEFT_X, axes.LEFT_Y }, { 0, 1, 2, 3 })

    local pad = PCSX.SIO0.slots[1].pads[1]
    for _, value in ipairs({ 0, 128, 255 }) do
        lu.assertTrue(pcall(pad.setAnalogOverride, value, value, value, value))
        lu.assertTrue(pcall(pad.setAnalogOverrideMode, true))
        lu.assertTrue(pcall(pad.setAnalogOverrideMode, false))
        lu.assertTrue(pcall(function() pad:setAnalogOverride(value, value, value, value) end))
        lu.assertTrue(pcall(function() pad:setAnalogOverrideMode(true) end))
        lu.assertTrue(pcall(function() pad:setAnalogOverrideMode(false) end))
    end

    for _, values in ipairs({
        { -1, 128, 128, 128 }, { 128, 256, 128, 128 }, { 128, 128, 0.5, 128 },
        { 128, 128, 128, "128" }, { 128, 128, 128 },
    }) do
        lu.assertFalse(pcall(pad.setAnalogOverride, table.unpack(values)))
    end
    for _, value in ipairs({ 0, 1, "true" }) do
        lu.assertFalse(pcall(pad.setAnalogOverrideMode, value))
    end
    lu.assertFalse(pcall(pad.setAnalogOverrideMode))
end
