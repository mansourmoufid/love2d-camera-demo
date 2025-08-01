-- Copyright 2025, Mansour Moufid <mansourmoufid@gmail.com>

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by the
-- Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program. If not, see <https://www.gnu.org/licenses/>.

local ffi = require('ffi')
local math = require('math')
local table = table or require('table')
table.unpack = table.unpack or unpack

local love = love or require('love')

package.cpath = love.filesystem.getCRequirePath() .. ';' .. package.cpath

local al = require('al')

state = {
    debug = true,
    init = false,
    colors = {
        background = {0, 0, 0},
    },
    window = {
        flags = {
            fullscreen = false,
            highdpi = true,
            minheight = 320,
            minwidth = 320,
            msaa = 2,
            resizable = true,
            -- vsync = true,
        },
        fps = 0,
        maxfps = 30,
        title = 'Love2d Camera Preview',
    },
    permissions = {
        camera = nil,
    },
    camera = {
        device = nil,
        index = 0,
        resolution = 720,
        aspect_ratio = 4 / 3,
        width = nil,
        height = nil,
        color = nil,
        orientation = nil,
        rotate = 0,
    },
    preview = {
        width = 0,
        height = 0,
        dimensions = {0, 0},
        data = nil,
        imagedata = nil,
        image = nil,
    },
    stop = false,
    reset = false,
}

function love.load()

    love.window.setTitle(state.window.title)
    local width, height = 480, 640
    if al.platform == 'android' or al.platform == 'ios' then
        width, height = love.graphics.getDimensions()
    end
    love.window.setMode(width, height, state.window.flags)

    -- Very important step
    if al.platform == 'android' then
        al.init({
            activity = {
                class = 'org/love2d/android/GameActivity',
                field = 'activity'
            },
        })
    else
        al.init()
    end

end

function love.update(dt)

    state.window.width = love.graphics.getWidth()
    state.window.height = love.graphics.getHeight()

    -- If the user is quitting, stop and free the camera object,
    -- and set the preview image to nil.
    if state.reset then
        if state.camera.device ~= nil then
            al.camera.stop(state.camera.device)
            al.camera.free(state.camera.device)
            state.camera.device = nil
            state.camera.color = nil
            state.camera.orientation = nil
            return
        end
        if state.preview.data ~= nil then
            state.preview.data = nil
            return
        end
        if not state.stop then
            state.reset = false
        end
    end
    if state.stop then
        return
    end

    -- Open the camera device, requesting the specific device index and
    -- resolution in the state variable, and asking permission first.
    if state.camera.device == nil then
        if state.camera.index == nil then
            return
        end
        if state.permissions.camera ~= 'granted' then
            if state.permissions.camera == 'requested' then
                if al.permissions.have(al.permissions.camera) then
                    state.permissions.camera = 'granted'
                end
            else
                al.permissions.request(al.permissions.camera)
                state.permissions.camera = 'requested'
            end
            return
        end
        state.camera.device = al.camera.new(
            state.camera.index,
            state.camera.resolution * state.camera.aspect_ratio,
            state.camera.resolution
        )
        if state.camera.device == nil then
            state.camera.index = nil
            return
        else
            print('**** state.camera.device =', state.camera.device)
            print('**** state.camera.id =', al.camera.id(state.camera.device))
            al.camera.start(state.camera.device)
            love.timer.sleep(100e-3)
        end
        return
    end

    -- Get the camera properties, like width, height, and orientation.
    if state.camera.orientation == nil then
        state.camera.orientation = al.camera.orientation(state.camera.device)
        if state.camera.orientation == nil then
            state.camera.orientation = 0
        end
    end
    if state.camera.color == nil then
        state.camera.color = al.camera.color_format(state.camera.device)
        print('**** state.camera.width =', al.camera.width(state.camera.device))
        print('**** state.camera.height =', al.camera.height(state.camera.device))
        print('**** state.camera.dimensions =', table.unpack(al.camera.dimensions(state.camera.device)))
        print('**** state.camera.orientation =', state.camera.orientation)
        local w, h = table.unpack(al.camera.dimensions(state.camera.device))
        for _, x in pairs({360, 480, 720, 1080}) do
            if w * h >= x * x * state.camera.aspect_ratio then
                state.camera.resolution = x
            end
        end
        return
    end

    -- Get the orientation relative to the device orientation.
    local o = al.display.orientation()
    if al.camera.facing(state.camera.device) == 'front' then
        state.camera.rotate = (state.camera.orientation + o) % 360
    else
        state.camera.rotate = (state.camera.orientation - o) % 360
    end
    if state.camera.color == al.COLOR_FORMAT_UNKNOWN then
        local color = al.camera.color_format(state.camera.device)
        if color == al.COLOR_FORMAT_UNKNOWN then
            return
        end
        state.camera.color = color
        print('**** state.camera.color =', state.camera.color)
    end

    -- Get the preview image, which is a pointer to the image pixel data
    -- in RGBA format.
    state.preview.data = al.camera.rgba(state.camera.device)

end

-- Fit a rectangle inside a bounding box.
-- Returns the starting point and scale factor.
local function fit(rect, box)
    local a, b = table.unpack(rect)
    local c, d = table.unpack(box)
    local s = math.min(c / a, d / b)
    if s > 1.0 then
        s = 1.0
    end
    local w = s * a
    local h = s * b
    local x = (c - w) / 2.0
    local y = (d - h) / 2.0
    return {x, y, s}
end

function love.draw()

    -- Draw a blank background.
    love.graphics.setColor(state.colors.background)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        state.window.width,
        state.window.height
    )

    -- If the user is quitting, don't proceed.
    if state.reset then
        if state.preview.image ~= nil then
            state.preview.image = nil
        end
        if state.preview.imagedata ~= nil then
            state.preview.imagedata = nil
        end
    end

    -- If the camera is open
    if state.camera.device ~= nil then

        -- Create a preview image if we haven't already,
        -- and copy over the data from the camera.
        if state.preview.data ~= nil then

            local w, h = table.unpack(al.camera.dimensions(state.camera.device))

            -- Create a new ImageData object if we haven't already.
            if state.preview.imagedata == nil then
                state.preview.imagedata = love.image.newImageData(
                    w,
                    h,
                    'rgba8'
                )
                print('**** imagedata =', state.preview.imagedata)
                local size = state.preview.imagedata:getSize()
                assert(size == w * h * ffi.sizeof('uint32_t'))
            end
            local ptr = state.preview.imagedata:getFFIPointer()
            local size = state.preview.imagedata:getSize()
            ffi.copy(ptr, state.preview.data, size)

            -- Create an Image object from the above ImageData object,
            -- or overwrite with the new data if it already exists.
            if state.preview.image == nil then
                state.preview.image = love.graphics.newImage(
                    state.preview.imagedata
                )
                print('**** image =', state.preview.image)
            else
                state.preview.image:replacePixels(state.preview.imagedata)
            end

        end

        -- Draw the preview image on screen, sized to fit, and
        -- rotated according to the orientation of the device camera.
        if state.preview.image ~= nil then
            love.graphics.setColor({1, 1, 1, 1})
            local w, h = table.unpack(al.camera.dimensions(state.camera.device))
            local o = al.display.orientation()
            local portrait = o % 180 == 0
            if portrait then
                w, h = h, w
            end
            local _, _, scale = table.unpack(fit(
                {w, h},
                {state.window.width, state.window.height}
            ))
            love.graphics.draw(
                state.preview.image,
                state.window.width / 2,
                state.window.height / 2,
                state.camera.rotate * math.pi / 180,
                scale,
                scale,
                al.camera.width(state.camera.device) / 2,
                al.camera.height(state.camera.device) / 2
            )
        end

    end

end

local function stop()
    print('*** stop')
    state.reset = true
    state.stop = true
    state.camera.index = nil
end

local function quit(status)
    print('*** quit')
    love.event.quit(status or 0)
end

function love.quit()
    print('*** love.quit')
    if not state.stop then
        stop()
        return true
    end
    for i = 1, 100 do
        if state.camera.device == nil then
            break
        end
        love.timer.sleep(10e-3)
    end
    return false
end

function love.keypressed(key)
    if key == 'tab' then
    end
    -- If the escape key is pressed once, the camera stops.
    -- If it's pressed a second time, the app quits.
    if key == 'escape' then
        if state.camera.device ~= nil then
            stop()
        else
            quit()
        end
    end
end

function love.keyreleased(key)
    if key == 'escape' then
    end
end

function love.resize(w, h)
end
