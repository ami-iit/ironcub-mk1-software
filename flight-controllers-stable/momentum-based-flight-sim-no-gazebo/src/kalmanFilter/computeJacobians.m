function [A,C] = computeJacobians(x, u, coefficients)

T    = x(1);
Tdot = x(2);

K_T  = coefficients(1);
K_TT = coefficients(2);
K_D  = coefficients(3);
K_DD = coefficients(4);
K_TD = coefficients(5);
B_U  = coefficients(6);
B_T  = coefficients(7);
B_D  = coefficients(8);
B_UU = coefficients(9);
c    = coefficients(10);

A = zeros(2,2);

A(1,:) = [0, 1];
A(2,1) = K_T + 2*K_TT*T    + K_TD*Tdot + B_T*(u + B_UU*u^2);
A(2,2) = K_D + 2*K_DD*Tdot + K_TD*T    + B_D*(u + B_UU*u^2);
C = [1, 0];
end

