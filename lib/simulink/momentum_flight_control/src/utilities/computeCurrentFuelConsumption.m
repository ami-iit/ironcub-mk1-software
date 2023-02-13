function fuelConsCurr = computeCurrentFuelConsumption(thrusts, Config)

    % WARNING: this function is still preliminary! 
    %
    % 1) it assumes a linear relation between the fuel consumption and the thrust;
    % 2) it does not account for extra fuel required in the startup phase.
    % 
    % Fuel consumption model: cons = m*thrust + q
    %
    % m and q are the model parameters. The model can be estimated from
    % the JetCat data on the specific arm and chest turbines.
    
    % thrust and fuel max/idle consumption
    thr_turbineChest_max  = Config.turbines.thr_turbineChest_max;
    thr_turbineArm_max    = Config.turbines.thr_turbineArm_max;
    thr_turbineChest_idl  = Config.turbines.thr_turbineChest_idl;
    thr_turbineArm_idl    = Config.turbines.thr_turbineArm_idl;
    cons_turbineChest_max = Config.turbines.cons_turbineChest_max;
    cons_turbineArm_max   = Config.turbines.cons_turbineArm_max;
    cons_turbineChest_idl = Config.turbines.cons_turbineChest_idl;
    cons_turbineArm_idl   = Config.turbines.cons_turbineArm_idl;
    
    % get m and q for arm and chest turbines
    m_arm   = (cons_turbineArm_max - cons_turbineArm_idl)/(thr_turbineArm_max - thr_turbineArm_idl);
    m_chest = (cons_turbineChest_max - cons_turbineChest_idl)/(thr_turbineChest_max - thr_turbineChest_idl);
    q_arm   = cons_turbineArm_max - m_arm * thr_turbineArm_max;
    q_chest = cons_turbineChest_max - m_chest * thr_turbineChest_max;    
    
    % compute the fuel consumption
    cons_T1 = m_arm * thrusts(1) + q_arm;
    cons_T2 = m_arm * thrusts(2) + q_arm;
    cons_T3 = m_chest * thrusts(3) + q_chest;
    cons_T4 = m_chest * thrusts(4) + q_chest;

    % update (sum) the current fuel consumption
    fuelConsCurr = cons_T1 + cons_T2 + cons_T3 + cons_T4;
end
