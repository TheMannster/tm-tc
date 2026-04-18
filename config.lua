Config = {}

-- Notification System: 'qb' for QBCore/QBox, 'ox' for ox_lib, 'ok' for okokNotify
Config.NotificationSystem = 'ok' -- Default to qb

-- ABS Settings
Config.ABS = {
    enabled = true,
    minSpeed = 2.8, -- Minimum speed for ABS to activate (in m/s)
    brakePressureThreshold = 0.5, -- Minimum brake pressure for ABS to activate
    wheelLockThreshold = 0.75, -- Wheel speed threshold for ABS activation (percentage of vehicle speed)
    brakePressureReduction = 0.7 -- How much to reduce brake pressure when ABS activates
}

-- Traction Control Settings
Config.TCS = {
    enabled = true,
    minRPM = 0.5, -- Minimum RPM for TCS to activate
    accelThreshold = 0.5, -- Minimum acceleration for TCS to activate
    -- Disable TCS for non-road vehicle classes by default
    disabledVehicleClasses = {
        [13] = true, -- Cycles
        [14] = true, -- Boats
        [15] = true, -- Helicopters
        [16] = true, -- Planes
        [21] = true  -- Trains
    },
    spinThresholds = {
        default = 1.3, -- Default spin threshold multiplier
        sports = 1.5,  -- Sports cars spin threshold
        super = 1.5,   -- Super cars spin threshold
        offroad = 1.8  -- Off-road vehicles spin threshold
    },
    accelReduction = 0.7, -- How much to reduce acceleration when TCS activates
    brakePressure = 0.3  -- Brake pressure to apply when TCS activates
}

-- Vehicle Class Settings
Config.VehicleClasses = {
    sports = 6,    -- Sports cars
    super = 7,     -- Super cars
    offroad = 9,   -- Off-road vehicles
    emergency = 18 -- Emergency vehicles
}

-- System state per vehicle class
Config.ClassSettings = {
    [18] = { -- Emergency vehicles
        absEnabled = false,
        tcsEnabled = false
    }
} 