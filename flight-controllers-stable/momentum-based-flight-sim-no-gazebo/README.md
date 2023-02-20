## Momentum-based flight controller for simulations (no Gazebo)

**This controller is maintained for the robots:**

- `iRonCub-Mk1_1`

### Available simulations:

#### Without jet dynamics
Jets dynamic model is just the numerical integration of the desired thrusts rate of changes. The controller uses the thrusts from numerical integration.

#### With jet dynamics
Jet dynamic model is designed based on experiments with the real turbines. The thrust rate of change is stabilized towards the reference values by means of a low-level jets control that sets desired throttle values.

### Current status:

**Robot:** `iRonCub-Mk1_1`

| SIMULATION TYPE | TAKE OFF | HOVERING | SLOW FLIGHT MANEUVERS | FAST FLIGHT MANEUVERS | LANDING |
|:-------:|:------:|:--------:|:--------:|:--------------------:|:--------------------:|
|Without jet dynamics | NO |  YES |  YES |  YES |  NO |
|With jet dynamics    | NO |  NO  |  NO  |  NO  |  NO |
