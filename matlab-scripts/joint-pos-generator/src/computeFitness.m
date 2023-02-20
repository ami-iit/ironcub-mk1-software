function fitnessValues = computeFitness(KinDynModel, Config)

    % evaluate the feet and CoM constraints and the momentum derivative
    [constr_feet, constr_com] = computeFeetAndCoMConstraints(KinDynModel);
    LDot                      = computeMomentumDerivative(KinDynModel, Config);
    
    % generate fitness values. The fitness goes from 0 to 11. If a posture
    % and thrusts get 11, they respect all the constraints. If they get any
    % number from 1 to 10, they respect some constraints but violate
    % others. If they get 0 they do not respect any constraint.
    feet_fitness     = constr_feet < Config.Optimization.tolerance_feet;
    com_fitness      = constr_com < Config.Optimization.tolerance_com;
    momentum_fitness = abs(LDot) < Config.Optimization.tolerance_momentum;  
    fitnessValues    = [feet_fitness; com_fitness; momentum_fitness];
end
