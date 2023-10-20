function [joyButtons,joyAxes] = fromGuiToJoystick(gui_input)

    % Maps the GUI buttons to have the same format of joystick inputs. In
    % this way the GUI can substitute the joystick if absent.
    
    persistent front_pressed left_pressed back_pressed right_pressed pitch_c_pressed ...
               pitch_ac_pressed yaw_c_pressed yaw_ac_pressed takeoff_pressed land_pressed ...
               up_pressed down_pressed turbo_pressed
    
    front_pressed    = 0;
    left_pressed     = 0;
    back_pressed     = 0;
    right_pressed    = 0;
    pitch_c_pressed  = 0;
    pitch_ac_pressed = 0;
    yaw_c_pressed    = 0;
    yaw_ac_pressed   = 0;
    takeoff_pressed  = 0;
    land_pressed     = 0;
    down_pressed     = 0;
    up_pressed       = 0;
    
    if isempty(turbo_pressed)
        
        turbo_pressed = 0;
    end
    
    tol        = 0.001;
    joyAxes    = zeros(6,1);
    joyButtons = zeros(24,1);
    
    % if button pressed, set to 1
    if abs(gui_input-1) < tol
        
        up_pressed = 1;   
    end
    if abs(gui_input-2) < tol
        
        down_pressed = 1;   
    end
    if abs(gui_input-3) < tol
        
        right_pressed = 1;
    end
    if abs(gui_input-4) < tol
        
        left_pressed = -1;
    end    
    if abs(gui_input-5) < tol
        
        pitch_c_pressed = -1;
    end
    if abs(gui_input-6) < tol
        
        pitch_ac_pressed = 1;
    end
    if abs(gui_input-7) < tol
        
        yaw_c_pressed = 1;
    end
    if abs(gui_input-8) < tol
        
        yaw_ac_pressed = 1;
    end
    if abs(gui_input-9) < tol
        
        takeoff_pressed = 1;
    end
    if abs(gui_input-10) < tol
        
        land_pressed = 1;
    end
    if abs(gui_input-11) < tol
        
        front_pressed = -1;
    end
    if abs(gui_input-12) < tol
        
        back_pressed = 1;
    end
    if abs(gui_input-13) < tol
         
        turbo_pressed = 1;   
    end
    if abs(gui_input-14) < tol
         
        turbo_pressed = 0;   
    end
    
    if front_pressed
        joyAxes(2) = front_pressed;
    else
        joyAxes(2) = back_pressed;
    end
    if left_pressed
        joyAxes(1) = left_pressed;
    else
        joyAxes(1) = right_pressed;
    end
    if pitch_c_pressed
        joyAxes(6) = pitch_c_pressed;
    else
        joyAxes(6) = pitch_ac_pressed;
    end
        
    joyButtons(13) = up_pressed;
    joyButtons(4)  = land_pressed;
    joyButtons(5)  = land_pressed;  
    joyButtons(6)  = takeoff_pressed;
    joyButtons(16) = yaw_ac_pressed;
    joyButtons(15) = yaw_c_pressed;

    % turbo mode not available for joypad. Mapping to an unused slot.
    joyButtons(7)  = turbo_pressed;
    
    if down_pressed
        joyButtons(14) = down_pressed;
    else
        joyButtons(14) = land_pressed;
    end  
end
