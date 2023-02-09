classdef Jet < handle
    %JET A class representing the SINGLE jet engine

    properties
        T; T_dot;
        K_T, K_TT, K_D, K_DD, K_TD, B_U, B_T, B_D, B_UU, c;
        dt;
    end

    methods

        function obj = Jet(coefficients, init, dt)
            %JET Construct an instance of this class
            %   Detailed explanation goes here
            obj.T = init;
            obj.T_dot = 0.0;
            obj.set_coefficients(coefficients);
            obj.dt = dt;
        end

        function set_coefficients(obj, coefficients)
            %set_coefficients Sets the coefficients of the jet model
            obj.K_T  = coefficients(1);
            obj.K_TT = coefficients(2);
            obj.K_D  = coefficients(3);
            obj.K_DD = coefficients(4);
            obj.K_TD = coefficients(5);
            obj.B_U  = coefficients(6);
            obj.B_T  = coefficients(7);
            obj.B_D  = coefficients(8);
            obj.B_UU = coefficients(9);
            obj.c    = coefficients(10);
        end

        function T = get_thrust(obj, u)
            %get_thrust returns the thrust
            obj.step(u);
            T = obj.T;
        end
        
        function T = get_thrust_from_dot_T(obj, dot_T)
            [~, y] = ode45(@(t, y) dot_T, [0 obj.dt], obj.T);
            T = y(end, :)';
            obj.T = T;
        end

    end

    methods (Access = private)

        function step(obj, u)
            %step applies the input to the jet
            f = obj.K_T * obj.T + obj.K_TT * obj.T^2 + obj.K_D * obj.T_dot + obj.K_DD * obj.T_dot^2 + obj.K_TD * obj.T * obj.T_dot + obj.c;
            g = obj.B_U + obj.B_T * obj.T + obj.B_D * obj.T_dot;
            T_ddot = f + g * (u + obj.B_UU * u^2);
            obj.T = obj.T + obj.T_dot * obj.dt + T_ddot * obj.dt^2/2;
            obj.T_dot = obj.T_dot + T_ddot * obj.dt;
        end

    end

end
