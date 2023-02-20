function [r_J1, r_J2, r_J3, r_J4, ax_J1, ax_J2, ax_J3, ax_J4] = demuxJetAxesAndArms(matrixOfJetsAxes, matrixOfJetsArms)

    % used in the flying momentum controller 
    r_J1  = matrixOfJetsArms(:,1);
    r_J2  = matrixOfJetsArms(:,2);
    r_J3  = matrixOfJetsArms(:,3);
    r_J4  = matrixOfJetsArms(:,4);
    
    ax_J1 = matrixOfJetsAxes(:,1);
    ax_J2 = matrixOfJetsAxes(:,2);
    ax_J3 = matrixOfJetsAxes(:,3);
    ax_J4 = matrixOfJetsAxes(:,4);
end