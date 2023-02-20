function [xDot] = dynamics_EKF_MOMENTUM_JET_FEET_CMM_FEET(x,coeff_P100, coeff_P220,Amatrix, GI_X_LF, GI_X_RF,gravity_force,input)
    % MB_DYNAMICS Summary of this function goes here
    %   Detailed explanation goes here

    % 'inputs' vector consistes of [throttle_inputs, transformed_feet_contact_forces]'
    xDot_jet1 = iRonCubLib_v1.jetModel_get_xDot([x(1) x(5)], coeff_P100, input(1));
    xDot_jet2 = iRonCubLib_v1.jetModel_get_xDot([x(2) x(6)], coeff_P100, input(2));
    xDot_jet3 = iRonCubLib_v1.jetModel_get_xDot([x(3) x(7)], coeff_P220, input(3));
    xDot_jet4 = iRonCubLib_v1.jetModel_get_xDot([x(4) x(8)], coeff_P220, input(4));

    LDot = Amatrix * x(1:4) - gravity_force + GI_X_LF * x(15:20) + GI_X_RF * x(21:26);
    fLFDot = zeros(6,1);
    fRFDot = zeros(6,1);
    xDot = [xDot_jet1(1); xDot_jet2(1); xDot_jet3(1); xDot_jet4(1); ...
            xDot_jet1(2); xDot_jet2(2); xDot_jet3(2); xDot_jet4(2); ...
            LDot; fLFDot; fRFDot];
end
