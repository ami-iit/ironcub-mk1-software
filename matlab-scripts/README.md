## MATLAB-SCRIPTS

### Available scripts

- `jet-pose-optimization`: selects the best jets configuration among four possible options. The criteria for choosing the configuration is to compute the condition number of the matrix that maps the control inputs (thrust derivatives and joint velocities) in the momentum acceleration equations. The configuration that guarantees the lowest condition number is chosen.

- `joint-pos-optimization`: calculates the best initial position for hovering. The criteria in this case is to minimize choose the joint positions that minimize the momentum rate of change during hovering. 

- `joint-pos-generator`: generates random joints positions subject to several constraints (symmetry, joints limits, ...).

