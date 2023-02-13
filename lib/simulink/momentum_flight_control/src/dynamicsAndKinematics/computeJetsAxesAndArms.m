function [matrixOfJetsAxes, matrixOfJetsArms] = computeJetsAxesAndArms(w_H_J1, w_H_J2, w_H_J3, w_H_J4, posCoM, Config)

    % Assumption: consider a frame attached to each jet. Then, one of the
    % principal axis (x,y,z) of this frame is parallel to the thrust force.
    % Under the above assumption, the following mapping holds:
    %
    % x axis = +-1;
    % y axis = +-2;
    % z axis = +-3;
    %
    % the sign (positive or negative) identifies the thrust orientation
    % w.r.t. the axis to which the thrust force is parallel. 
    %
    orientations     = sign(Config.jets.axes);
    axes             = abs(Config.jets.axes);
    matrixOfJetsAxes = [orientations(1) * w_H_J1(1:3,axes(1)), orientations(2) * w_H_J2(1:3,axes(2)),...
                        orientations(3) * w_H_J3(1:3,axes(3)), orientations(4) * w_H_J4(1:3,axes(4))];
    
    % Distances between the jets locations and the CoM position
    r_J1             = w_H_J1(1:3,4) - posCoM;
    r_J2             = w_H_J2(1:3,4) - posCoM;
    r_J3             = w_H_J3(1:3,4) - posCoM;
    r_J4             = w_H_J4(1:3,4) - posCoM;               
    matrixOfJetsArms = [r_J1, r_J2, r_J3, r_J4];
end