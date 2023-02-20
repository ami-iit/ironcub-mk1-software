function [AEq_combined,lbEq_combined,ubEq_combined] = combineInputBoundsAndInequalitiesQP(AEq,lbEq,ubEq,lb,ub)

   % This function is a workaround for https://github.com/robotology/wb-toolbox/issues/192
   %
   % Combines input bounds and inequalities for the QP block input.
   
   AEq_combined  = [AEq; eye(length(lb))];
   lbEq_combined = [lbEq; lb];
   ubEq_combined = [ubEq; ub];
end
