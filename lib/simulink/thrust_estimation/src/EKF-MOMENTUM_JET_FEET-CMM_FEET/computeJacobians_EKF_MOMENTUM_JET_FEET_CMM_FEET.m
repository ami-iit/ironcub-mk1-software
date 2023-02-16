function [A,C] = computeJacobians_EKF_MOMENTUM_JET_FEET_CMM_FEET(x, input_jets, Amatrix, GI_X_LF, GI_X_RF, coefficients_P100, coefficients_P220)

    K_T = zeros(4,1);
    K_TT = zeros(4,1);
    K_D = zeros(4,1);
    K_DD = zeros(4,1);
    K_TD = zeros(4,1);
    B_U = zeros(4,1);
    B_T = zeros(4,1);
    B_D = zeros(4,1);
    B_UU = zeros(4,1);
    c = zeros(4,1);

    K_T(1) = coefficients_P100(1);
    K_T(2) = K_T(1);
    K_T(3) = coefficients_P220(1);
    K_T(4) = K_T(3);

    K_TT(1) = coefficients_P100(2);
    K_TT(2) = K_TT(1);
    K_TT(3) = coefficients_P220(2);
    K_TT(4) = K_TT(3);

    K_D(1) = coefficients_P100(3);
    K_D(2) = K_D(1);
    K_D(3) = coefficients_P220(3);
    K_D(4) = K_D(3);

    K_DD(1) = coefficients_P100(4);
    K_DD(2) = K_DD(1);
    K_DD(3) = coefficients_P220(4);
    K_DD(4) = K_DD(3);

    K_TD(1) = coefficients_P100(5);
    K_TD(2) = K_TD(1);
    K_TD(3) = coefficients_P220(5);
    K_TD(4) = K_TD(3);

    B_U(1) = coefficients_P100(6);
    B_U(2) = B_U(1);
    B_U(3) = coefficients_P220(6);
    B_U(4) = B_U(3);

    B_T(1) = coefficients_P100(7);
    B_T(2) = B_T(1);
    B_T(3) = coefficients_P220(7);
    B_T(4) = B_T(3);

    B_D(1) = coefficients_P100(8);
    B_D(2) = B_D(1);
    B_D(3) = coefficients_P220(8);
    B_D(4) = B_D(3);

    B_UU(1) = coefficients_P100(9);
    B_UU(2) = B_UU(1);
    B_UU(3) = coefficients_P220(9);
    B_UU(4) = B_UU(3);

    c(1) = coefficients_P100(10);
    c(2) = c(1);
    c(3) = coefficients_P220(10);
    c(4) = c(3);

    df_dT    = zeros(4);
    df_dTdot = zeros(4);

    for i=1:4
        df_dT(i,i) = K_T(i) + 2*K_TT(i)*x(i)    + K_TD(i)*x(i+4) + B_T(i)*(input_jets(i) + B_UU(i)*input_jets(i)^2);
        df_dTdot(i,i) = K_D(i) + 2*K_DD(i)*x(i+4) + K_TD(i)*x(i)    + B_D(i)*(input_jets(i) + B_UU(i)*input_jets(i)^2);
    end

    A = [zeros(4),       eye(4),                    zeros(4,6),      zeros(4,6),      zeros(4,6) ; ...
        df_dT,              df_dTdot,               zeros(4,6),      zeros(4,6),      zeros(4,6); ...
        Amatrix,           zeros(6,4),             zeros(6),           GI_X_LF,           GI_X_RF; ...
        zeros(6,4),       zeros(6,4),             zeros(6),           zeros(6),            zeros(6); ...
        zeros(6,4),       zeros(6,4),             zeros(6),           zeros(6),         zeros(6)];

    C = [zeros(6,4), zeros(6,4), eye(6), zeros(6), zeros(6); ...
        zeros(6,4), zeros(6,4), zeros(6), eye(6), zeros(6); ...
        zeros(6,4), zeros(6,4), zeros(6), zeros(6), eye(6)];
end
