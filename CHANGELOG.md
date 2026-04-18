# Changelog

All notable changes to this project will be documented in this file.

## v1.1.0 - 2026-04-13

### Changed
- Added a configurable TCS disabled vehicle-class list in `Config.TCS.disabledVehicleClasses`.
- TCS is now disabled by default for cycles, boats, helicopters, planes, and trains.
- Replaced the hardcoded helicopter-only TCS block with a reusable config-based class check in `client/main.lua`.
