classdef jetDyn < matlab.System & matlab.system.mixin.Propagates
    % step_block This block takes as input the joint torques and the
    % applied external forces and evolves the state of the robot
    
    % Public, tunable properties
    properties (Nontunable)
        jets_config;
        tStep;
        idx;
    end
    
    properties (DiscreteState)
        
    end
    
    properties (Access = private)
        jet;
    end
    
    methods (Access = protected)
        
        function setupImpl(obj)
            obj.jet = Jet(obj.jets_config.coefficients(obj.idx, :), obj.jets_config.init_thrust(obj.idx), obj.tStep);
        end
        
        function [jet_intensitiy, generalized_jet_wrench] = stepImpl(obj, jet_input, basePose, jointPosition)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            [jet_intensitiy, generalized_jet_wrench] = obj.compute_jet_intensities_and_generalized_jet_wrench(jet_input, basePose, jointPosition);
        end
        
        function [jet_intensity, generalized_jet_wrench] = compute_jet_intensities_and_generalized_jet_wrench(obj, u, basePose, jointPosition)

            if obj.jets_config.use_jet_dyn
                jet_intensity = obj.jet.get_thrust(u);
            else
                jet_intensity = obj.jet.get_thrust_from_dot_T(u);
            end
            f = obj.compute_jet_force_in_wrld_frame(jet_intensity, obj.idx, basePose, jointPosition);
            generalized_jet_wrench = obj.compute_generalized_wrench([f; zeros(3,1)], obj.idx, basePose, jointPosition);
            
        end
        
        function f = compute_jet_force_in_wrld_frame(obj, t, frame, basePose, jointPosition)
            %compute_jet_force_in_world_frame returns the jet force in the
            % world frame
            switch frame
                case 1
                    H = simFunc_getWorldTransformJet1Frame(basePose,jointPosition);
                case 2
                    H = simFunc_getWorldTransformJet2Frame(basePose,jointPosition);
                case 3
                    H = simFunc_getWorldTransformJet3Frame(basePose,jointPosition);
                case 4
                    H = simFunc_getWorldTransformJet4Frame(basePose,jointPosition);
            end
            % represent the (pure) z force in the world
            f = -H(1:3, 3) * t;
        end
        
        function f = compute_generalized_wrench(obj, wrench, frame, basePose, jointPosition)
            
            switch frame
                case 1
                    J = simFunc_getFrameFreeFloatingJacobianJet1Frame(basePose,jointPosition);
                case 2
                    J = simFunc_getFrameFreeFloatingJacobianJet2Frame(basePose,jointPosition);
                case 3
                    J = simFunc_getFrameFreeFloatingJacobianJet3Frame(basePose,jointPosition);
                case 4
                    J = simFunc_getFrameFreeFloatingJacobianJet4Frame(basePose,jointPosition);
            end
            f = J' * wrench;
        end
        
        
        function resetImpl(obj)
            
        end
        
        function [out, out2] = getOutputSizeImpl(~)
            % Return size for each output port
            out = [1 1]; % jets intensities
            out2 = [29 1]; % jeneralized jet wrench
        end
        
        function [out, out2] = getOutputDataTypeImpl(~)
            % Return data type for each output port
            out = "double";
            out2 = "double";
        end
        
        function [out, out2] = isOutputComplexImpl(~)
            % Return true for each output port with complex data
            out = false;
            out2 = false;
        end
        
        function [out, out2] = isOutputFixedSizeImpl(~)
            % Return true for each output port with fixed size
            out = true;
            out2 = true;
        end
        
        function names = getSimulinkFunctionNamesImpl(~)
            names = {...
                'simFunc_getFrameFreeFloatingJacobianJet1Frame', ...
                'simFunc_getFrameFreeFloatingJacobianJet2Frame', ...
                'simFunc_getFrameFreeFloatingJacobianJet3Frame', ...
                'simFunc_getFrameFreeFloatingJacobianJet4Frame', ...
                'simFunc_getWorldTransformJet1Frame', ...
                'simFunc_getWorldTransformJet2Frame', ...
                'simFunc_getWorldTransformJet3Frame', ...
                'simFunc_getWorldTransformJet4Frame'};
        end
        
    end
    
end
