function A = Amatrix(JetsAxes, JetsArms)

r_J1 = JetsArms(:,1);
r_J2 = JetsArms(:,2);
r_J3 = JetsArms(:,3);
r_J4 = JetsArms(:,4);

hat_t_J1 = JetsAxes(:,1);
hat_t_J2 = JetsAxes(:,2);
hat_t_J3 = JetsAxes(:,3);
hat_t_J4 = JetsAxes(:,4);

A = [hat_t_J1,                hat_t_J2,                hat_t_J3,                hat_t_J4 ; ...
     wbc.skew(r_J1)*hat_t_J1, wbc.skew(r_J2)*hat_t_J2, wbc.skew(r_J3)*hat_t_J3, wbc.skew(r_J4)*hat_t_J4];
 
end