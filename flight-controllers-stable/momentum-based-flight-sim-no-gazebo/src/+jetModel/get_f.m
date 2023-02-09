function f = get_f(state, coefficients)
T    = state(1);
Tdot = state(2);

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

f = K_T*T + K_TT*T^2 + K_D*Tdot + K_DD*Tdot^2 + K_TD*T*Tdot + c;
end