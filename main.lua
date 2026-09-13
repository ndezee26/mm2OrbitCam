local M = {}
M.info = { name = "Orbit Cam", author = "", context = {"game"} }

local orbitCam = nil
local previousCam = nil
local orbiting = false
local sensitivity = 0.01
local wheelSensitivity = 0.5

local toggleKey = DIK_O  -- 'O' key for (Orbit Cam) -- change to whatever you want

local function ensureOrbitCam(car)  -- function to create our own orbitCam from camPolarCS
    if orbitCam then return orbitCam end
    orbitCam = camPolarCS()
    orbitCam:Init(car, "LuaOrbitCam")
    orbitCam.Distance = 6.0
    orbitCam.Incline = 0.2
    orbitCam.Azimuth = 0.0
    return orbitCam
end

local function enterOrbit(view, cam)
    if orbiting then return end
    orbiting = true
    previousCam = view.CurrentCamera	--save the previous camera to revert to
    view:SetCam(cam)	--change the players current CamView to our orbitCam
    cam.AzimuthLock = true	--prevent overides to cam azimuth
end

local function exitOrbit(view, cam)
    if not orbiting then return end
    orbiting = false
    cam.AzimuthLock = false
    if previousCam then view:SetCam(previousCam) end
end

local function onUpdate()
    local car = Player.Car
    if not car then return end
    local view = Player.CamView
    if not view then return end

    local cam = ensureOrbitCam(car)	--create orbitCam

    if ioMouse.GetButtonDown(1) then
        enterOrbit(view, cam)
    elseif ioMouse.GetButtonUp(1) then
        exitOrbit(view, cam)
    end

    if ioKeyboard.GetKeyDown(toggleKey) then
        if orbiting then
            exitOrbit(view, cam)
        else
            enterOrbit(view, cam)
        end
    end

    if orbiting then
        cam.Azimuth = cam.Azimuth - ioMouse.dX * sensitivity
        cam.Incline = math.max(-1.2, math.min(1.2, cam.Incline + ioMouse.dY * sensitivity))
        cam.Distance = math.max(2.0, cam.Distance - ioMouse.dZ * wheelSensitivity)
    end
end

M.onUpdate = onUpdate
return M