# TM-TC (Traction Control & ABS System)

A standalone traction control and ABS system for FiveM servers, extracted and modified from the GES-VehicleHUD resource. This resource provides advanced vehicle handling features without the HUD elements.

## Version

Current version: `v1.1.0`

## Features

### ABS (Anti-lock Braking System)
- Prevents wheel lock-up during hard braking
- Adjusts brake pressure per wheel
- Improves steering control during ABS activation
- Configurable thresholds and sensitivity
- Per-vehicle class settings

### Traction Control System (TCS)
- Prevents wheel spin during acceleration
- Adjusts throttle input automatically
- Applies selective braking to spinning wheels
- Different thresholds for different vehicle classes:
  - Sports/Super cars: Higher threshold for more aggressive driving
  - Off-road vehicles: Highest threshold for better off-road performance
  - Standard vehicles: Balanced threshold for everyday driving
- Per-vehicle class settings

### Vehicle Class Support
- Works on all road vehicle types by default
- Emergency vehicles (police, ambulance, etc.) have systems disabled by default but can be toggled on
- Settings are remembered per vehicle class
- Customizable thresholds for different vehicle types
- TCS can be disabled for specific vehicle classes (for example: boats, helicopters, planes, and trains)

## Installation

1. Download the resource
2. Place it in your server's resources folder
3. Add `ensure tm-tc` to your server.cfg
4. Restart your server or start the resource

## Usage

### Commands
- `/toggleabs` - Toggle ABS system on/off for current vehicle class
- `/toggletcs` - Toggle Traction Control system on/off for current vehicle class

### Key Bindings
- `Left Shift` - Toggle Traction Control system

### Configuration
All settings can be modified in the `config.lua` file:

```lua
Config.ABS = {
    enabled = true,
    minSpeed = 2.8, -- Minimum speed for ABS to activate (in m/s)
    brakePressureThreshold = 0.5, -- Minimum brake pressure for ABS to activate
    wheelLockThreshold = 0.75, -- Wheel speed threshold for ABS activation
    brakePressureReduction = 0.7 -- How much to reduce brake pressure when ABS activates
}

Config.TCS = {
    enabled = true,
    minRPM = 0.5, -- Minimum RPM for TCS to activate
    accelThreshold = 0.5, -- Minimum acceleration for TCS to activate
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
```

## Credits

This resource is based on the ABS and Traction Control systems from:
- Original Script: [GES-VehicleHUD](https://github.com/GESUS/GES-VehicleHUD) by GESUS
- Modified and standalone version by TheMannster

## License

This resource is released under the MIT License, same as the original script.

## Support

For issues or suggestions, please contact the original author or create an issue in the repository. 

## Changelog

See `CHANGELOG.md` for full release notes.