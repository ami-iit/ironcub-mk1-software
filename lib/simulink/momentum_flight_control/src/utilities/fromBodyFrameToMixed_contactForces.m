function [mixed_f_l_sole, mixed_f_r_sole] = fromBodyFrameToMixed_contactForces(contactForces_WBD, w_R_l_sole, w_R_r_sole)

    % from body frame to mixed representation of the contact forces
    mixed_f_l_sole = blkdiag(w_R_l_sole, w_R_l_sole)*contactForces_WBD(1:6);
    mixed_f_r_sole = blkdiag(w_R_r_sole, w_R_r_sole)*contactForces_WBD(7:12);
end