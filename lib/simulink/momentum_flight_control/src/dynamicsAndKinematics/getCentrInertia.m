function w_I_c = getCentrInertia(M, xCoM, xBase)

    % Get the transformation matrix from the frame B[W] to the frame G[W]
    % (centroidal coordinates)
    r       = xCoM - xBase;
    X       = [eye(3),   wbc.skew(r)';
               zeros(3), eye(3)];
           
    Mbs     = M(1:6,7:end);
    Mb      = M(1:6,1:6);
    Js      = X*(Mb\Mbs);
    ndof    = size(Mbs,2);

    g_T_b   = [X,             Js;
               zeros(ndof,6), eye(ndof)];
     
    % Inverse of the transformation
    invT    = eye(ndof+6)/g_T_b;
    invTt   = eye(ndof+6)/(g_T_b');

    % Get the full mass matrix in centroidal coordinates
    M_c     = invTt*M*invT;

    % Get the centroidal inertia
    w_I_c   = M_c(4:6,4:6);
end