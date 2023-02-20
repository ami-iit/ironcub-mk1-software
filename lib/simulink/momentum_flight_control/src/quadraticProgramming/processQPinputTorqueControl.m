function [H_balancing,g_balancing,ub_balancing,lb_balancing,Aeq_balancing,lbEq_balancing,ubEq_balancing, ...
          H_flight,g_flight,ub_flight,lb_flight] = processQPinputTorqueControl ...
                                                       (HessianMatrixQP,gVectorQP,InequalityConstrMatrix, ...
                                                        biasVectorInequalityConstr,jointTorquesSaturation,Config)   
   
    % This function aims at defining the hessian matrix H, the gradient
    % vector g, and the constraint matrix Aeq according to the formalism 
    % of qpOASES, i.e.
    %
    %   min (1/2) transpose(u) * H * u + transpose(u) * g
    %    
    %     s.t.
    % 
    %        lbEq < AEq * u < ubEq
    %        lb   <    u    < ub  
    %
    % For further information, see
    % 
    %     http://www.coin-or.org/qpOASES/doc/3.0/manual.pdf
    %  
        
    % QP inputs for balancing controller
    H_balancing    =  HessianMatrixQP;
    g_balancing    =  gVectorQP;
    ub_balancing   =  [ 1e14 * ones(12,1);  jointTorquesSaturation];
    lb_balancing   =  [-1e14 * ones(12,1); -jointTorquesSaturation];
    Aeq_balancing  =  [InequalityConstrMatrix, zeros(size(InequalityConstrMatrix, 1), size(Config.N_DOF_MATRIX,1))];
    lbEq_balancing = -1e14 * ones(size(InequalityConstrMatrix, 1), 1); 
    ubEq_balancing =  biasVectorInequalityConstr;  
           
    % QP inputs for flight controller
    H_flight  =  HessianMatrixQP(13:end, 13:end);
    g_flight  =  gVectorQP(13:end);
    ub_flight =  jointTorquesSaturation;
    lb_flight = -jointTorquesSaturation;    
end
