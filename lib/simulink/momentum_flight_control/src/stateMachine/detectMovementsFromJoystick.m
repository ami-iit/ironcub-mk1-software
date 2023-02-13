function [moveFront, moveLateral, moveUpDown, rotateRoll, rotatePitch, rotateYaw, turbo_mode, goLandingPos] = detectMovementsFromJoystick(joyAxes, joyButtons)

    % JOYSTICK MAPPING: 
    %
    % left joypad: move in front (up/down) and laterally (left/right)
    %
    % right joypad: rotate along pitch (up/down) and roll (left/right)
    %
    % arrows: move up and down (up/down) and rotate along yaw (left/right)
    %
    % button Y: reset robot roll and pitch to zero and limit CoM rate of change
    %
    threshold    = 0.5;
    moveFront    = 0;    
    moveLateral  = 0;
    moveUpDown   = 0;
    rotateRoll   = 0;
    rotatePitch  = 0;
    rotateYaw    = 0;

    % if pressed, the robot will reset roll and pitch to zero (pre-landing)
    % and it will limit the CoM rate of change to avoid impacts
    goLandingPos = joyButtons(4);
    
    % move frontal
    if abs(joyAxes(2)) > threshold
    
        moveFront   = sign(joyAxes(2));
    end
    
    % move lateral
    if abs(joyAxes(1)) > threshold
    
        moveLateral = sign(joyAxes(1));
    end
    
    % move up and down
    if abs(joyButtons(13)) > threshold
    
        moveUpDown  =  1;
        
    elseif abs(joyButtons(14)) > threshold
        
        moveUpDown  = -1;
    end
    
    % rotate (roll)
    if abs(joyAxes(3)) > threshold
    
        rotateRoll  = -sign(joyAxes(3));
    end
    
    % rotate (pitch)
    if abs(joyAxes(6)) > threshold
    
        rotatePitch = sign(joyAxes(6));
    end
    
    % rotate (yaw)
    if abs(joyButtons(15)) > threshold
        
        rotateYaw   =  1;
        
    elseif abs(joyButtons(16)) > threshold
        
        rotateYaw   = -1;
    end
    
    % turbo mode. WARNING: at the moment it is mapped in a random unused button
    turbo_mode = joyButtons(3);
end
