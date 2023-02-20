function [feetContactIsActive, robotIsLanded, oneFootIsInContact] = feetContactActivation(wrench_l, wrench_r, Config)

    % The robot can only be in two possile states: in contact and not in
    % contact. However, it is also necessary to distinguish between the
    % initial balancing condition and balancing after landing.
    %
    persistent robotWasFlying robotLanded
    
    if isempty(robotWasFlying)
        
        robotWasFlying = 0;
    end
    if isempty(robotLanded)

        robotLanded = 0;
    end
     
    % check the vertical forces at feet. If their values are greater than a
    % threshold, the robot is in contact
    if wrench_l(3) > Config.minVerticalForces && wrench_r(3) > Config.minVerticalForces
     
        feetContactIsActive = 1;

    else
        feetContactIsActive = 0; 
        robotWasFlying      = 1;
        robotLanded         = 0;
    end
    
    % check if at least one foot is in contact
    if wrench_l(3) > Config.minVerticalForces || wrench_r(3) > Config.minVerticalForces
     
        oneFootIsInContact = 1;
    else
        oneFootIsInContact = 0; 
    end
    
    % the landed variable can become 1 only if the robot land after flying
    if robotWasFlying && feetContactIsActive
        
        robotWasFlying = 0;
        robotLanded    = 1;  
    end
    
    robotIsLanded = robotLanded;
end