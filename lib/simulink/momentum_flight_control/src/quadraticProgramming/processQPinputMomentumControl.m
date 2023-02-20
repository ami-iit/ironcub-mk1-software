function [H_balancing,g_balancing,ub_balancing,lb_balancing, ...
          H_flight,g_flight,ub_flight,lb_flight] = processQPinputMomentumControl(HessianMatrixQP,gVectorQP,lowerBoundQP,upperBoundQP)   
                                          
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
    H_balancing  = HessianMatrixQP;
    g_balancing  = gVectorQP;
    ub_balancing = upperBoundQP;
    lb_balancing = lowerBoundQP;
           
    % QP inputs for flight controller
    H_flight     = HessianMatrixQP([1:4, 17:end], [1:4, 17:end]);
    g_flight     = gVectorQP([1:4, 17:end]);
    ub_flight    = upperBoundQP([1:4, 17:end]);
    lb_flight    = lowerBoundQP([1:4, 17:end]);    
end
