-- Cache frequently used native functions for performance
local PlayerPedId = PlayerPedId
local GetEntitySpeed = GetEntitySpeed
local GetVehicleCurrentRpm = GetVehicleCurrentRpm
local GetVehicleClass = GetVehicleClass
local GetVehicleNumberOfWheels = GetVehicleNumberOfWheels
local GetVehicleWheelSpeed = GetVehicleWheelSpeed
local GetControlNormal = GetControlNormal
local GetVehiclePedIsIn = GetVehiclePedIsIn
local SetVehicleWheelBrakePressure = SetVehicleWheelBrakePressure
local SetVehicleSteeringScale = SetVehicleSteeringScale
local DisableControlAction = DisableControlAction
local SetControlNormal = SetControlNormal
local math_abs = math.abs

-- System state
local state = {
    absActive = false,
    tcsActive = false,
    classSettings = {} -- Store per-class settings
}

-- Initialize class settings
local function initializeClassSettings()
    for class, settings in pairs(Config.ClassSettings) do
        state.classSettings[class] = {
            absEnabled = settings.absEnabled,
            tcsEnabled = settings.tcsEnabled
        }
    end
end

-- Get system state for current vehicle
local function getSystemState(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)
    local classSettings = state.classSettings[vehicleClass]
    
    if classSettings then
        return classSettings.absEnabled, classSettings.tcsEnabled
    end
    
    return Config.ABS.enabled, Config.TCS.enabled
end

-- Helper function to get spin threshold based on vehicle class
local function getSpinThreshold(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)
    
    if vehicleClass == Config.VehicleClasses.sports or vehicleClass == Config.VehicleClasses.super then
        return Config.TCS.spinThresholds.sports
    elseif vehicleClass == Config.VehicleClasses.offroad then
        return Config.TCS.spinThresholds.offroad
    end
    
    return Config.TCS.spinThresholds.default
end

-- Check if TCS should run for this vehicle class
local function isTCSAllowedForVehicle(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)
    local disabledClasses = Config.TCS.disabledVehicleClasses

    return not (disabledClasses and disabledClasses[vehicleClass])
end

-- ABS System
local function applyABS(vehicle)
    local absEnabled = getSystemState(vehicle)
    if not absEnabled then return false end
    
    local wheelCount = GetVehicleNumberOfWheels(vehicle)
    if wheelCount < 2 then return false end
    
    local speed = GetEntitySpeed(vehicle)
    local brakePressure = GetControlNormal(0, 72) -- Brake control
    
    if speed > Config.ABS.minSpeed and brakePressure > Config.ABS.brakePressureThreshold then
        local isABSActive = false
        
        for i = 0, wheelCount - 1 do
            local wheelSpeed = GetVehicleWheelSpeed(vehicle, i)
            if wheelSpeed < (speed * Config.ABS.wheelLockThreshold) and brakePressure > 0.8 then
                isABSActive = true
                SetVehicleWheelBrakePressure(vehicle, i, brakePressure * Config.ABS.brakePressureReduction)
                
                -- Improve steering during ABS activation
                if i < 2 then
                    local steeringAngle = GetVehicleSteeringAngle(vehicle)
                    SetVehicleSteeringScale(vehicle, 1.0 + (math_abs(steeringAngle) * 0.01))
                end
            end
        end
        
        state.absActive = isABSActive
        return isABSActive
    else
        state.absActive = false
        return false
    end
end

-- Traction Control System
local function applyTCS(vehicle)
    local _, tcsEnabled = getSystemState(vehicle)
    if not tcsEnabled then return false end
    if not isTCSAllowedForVehicle(vehicle) then
        state.tcsActive = false
        return false
    end
    
    local wheelCount = GetVehicleNumberOfWheels(vehicle)
    if wheelCount < 2 then return false end
    
    local speed = GetEntitySpeed(vehicle)
    local accelPressure = GetControlNormal(0, 71) -- Throttle control
    local rpm = GetVehicleCurrentRpm(vehicle)
    
    if accelPressure > Config.TCS.accelThreshold and rpm > Config.TCS.minRPM then
        local isTCSActive = false
        local spinThreshold = getSpinThreshold(vehicle)
        
        for i = 0, wheelCount - 1 do
            local wheelSpeed = GetVehicleWheelSpeed(vehicle, i)
            
            if wheelSpeed > (speed * spinThreshold) and accelPressure > 0.7 then
                isTCSActive = true
                
                -- Reduce throttle input
                DisableControlAction(0, 71, true)
                SetControlNormal(0, 71, accelPressure * Config.TCS.accelReduction)
                
                -- Apply brake to spinning wheel
                SetVehicleWheelBrakePressure(vehicle, i, Config.TCS.brakePressure)
                break
            end
        end
        
        state.tcsActive = isTCSActive
        return isTCSActive
    else
        state.tcsActive = false
        return false
    end
end

-- Toggle system for current vehicle class
local function toggleSystemForClass(system)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle == 0 then return end
    if system == 'tcs' and not isTCSAllowedForVehicle(vehicle) then return end
    
    local vehicleClass = GetVehicleClass(vehicle)
    if not state.classSettings[vehicleClass] then
        state.classSettings[vehicleClass] = {
            absEnabled = Config.ABS.enabled,
            tcsEnabled = Config.TCS.enabled
        }
    end
    
    if system == 'abs' then
        state.classSettings[vehicleClass].absEnabled = not state.classSettings[vehicleClass].absEnabled
        return state.classSettings[vehicleClass].absEnabled
    else
        state.classSettings[vehicleClass].tcsEnabled = not state.classSettings[vehicleClass].tcsEnabled
        return state.classSettings[vehicleClass].tcsEnabled
    end
end

-- Notification Helper Function
local function ShowNotification(title, message, messageType)
    if Config.NotificationSystem == 'ox' then
        exports.ox_lib:notify({
            title = title,
            description = message,
            type = messageType or 'inform' -- Default to 'inform' if no type is provided
        })
    elseif Config.NotificationSystem == 'ok' then
        local okokMessageType = 'neutral' -- Default okokNotify message type
        if messageType == 'success' then okokMessageType = 'success' end
        if messageType == 'error' then okokMessageType = 'error' end
        exports['okokNotify']:Alert(title, message, 5000, okokMessageType)
    else -- Default to qb (QBCore/QBox)
        local qbMessageType = 'primary' -- Default QBCore message type
        if messageType == 'success' then qbMessageType = 'success' end
        if messageType == 'error' then qbMessageType = 'error' end
        -- QBCore:Notify typically takes one main message string and an optional type
        TriggerEvent('QBCore:Notify', title .. ': ' .. message, qbMessageType)
    end
end

-- Main loop
CreateThread(function()
    initializeClassSettings()
    
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            sleep = 0 -- No sleep while in vehicle
            applyABS(vehicle)
            applyTCS(vehicle)
        end
        
        Wait(sleep)
    end
end)

-- Commands to toggle systems
RegisterCommand('abs', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle == 0 then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then return end

    local enabled = toggleSystemForClass('abs')
    local vehicleClass = GetVehicleClass(vehicle)
    local vehicleType = vehicleClass == Config.VehicleClasses.emergency and 'Emergency Vehicle' or 'Vehicle'
    ShowNotification(vehicleType .. ' ABS', (enabled and 'Enabled' or 'Disabled'), enabled and 'success' or 'error')
end, false)

RegisterCommand('tcs', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle == 0 then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then return end
    if not isTCSAllowedForVehicle(vehicle) then return end
    
    local enabled = toggleSystemForClass('tcs')
    local vehicleClass = GetVehicleClass(vehicle)
    local vehicleType = vehicleClass == Config.VehicleClasses.emergency and 'Emergency Vehicle' or 'Vehicle'
    ShowNotification(vehicleType .. ' Traction Control', (enabled and 'Enabled' or 'Disabled'), enabled and 'success' or 'error')
end, false)

-- Chat suggestions
TriggerEvent('chat:addSuggestion', '/abs', 'Toggle Anti-lock Braking System on/off')
TriggerEvent('chat:addSuggestion', '/tcs', 'Toggle Traction Control System on/off')

-- Key mapping for TCS only
RegisterKeyMapping('tcs', 'Toggle Traction Control', 'keyboard', 'LSHIFT') 