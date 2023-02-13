function [decreaseMaxFootVerticalForce, increaseMinFootVerticalForce, activateEqConstrTorqueControl] = verticalForcesControl(joyButtons)

    % ONLY WHEN THE ROBOT IS IN CONTACT WITH THE GROUND:
    %
    % L1 = increase the vertical forces (decrease the thrust forces);
    % R1 = increase the vertical forces (decrease the thrust forces);
    % A  = activate feet equality constraints after landing (torque control)
    %
    activateEqConstrTorqueControl = joyButtons(1);
    increaseMinFootVerticalForce  = joyButtons(5);
    decreaseMaxFootVerticalForce  = joyButtons(6);
end