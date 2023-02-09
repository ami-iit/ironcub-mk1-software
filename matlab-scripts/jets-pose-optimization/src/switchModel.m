function TurbinesData = switchModel(testNumber)

    % SWITCHMODEL allows to test different turbines configurations.
    %
    % FORMAT:  TurbinesData = switchModel(testNumber)
    %
    % INPUTS:  - testNumber = current test number;
    %                         
    % OUTPUTS: - TurbinesData: structure containing the turbines data.
    %
    % Author: Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Nov 2018
    
    %% ------------Initialization----------------

    % turbines limits
    TurbinesData.turbineLimits = [220, 220, 100, 100, 100, 100];
            
    switch testNumber
    
        case 1
             
            TurbinesData.turbineList   = {'chest_l_jet_turbine_prime','chest_r_jet_turbine_prime','l_arm_jet_turbine_prime','r_arm_jet_turbine_prime'};
            TurbinesData.turbineAxis   = [3; 3; 3; 3];
            TurbinesData.turbineLimits = TurbinesData.turbineLimits(1:end-2);  
        
        case 2
           
            TurbinesData.turbineList   = {'chest_l_jet_turbine','chest_r_jet_turbine','l_arm_jet_turbine_prime','r_arm_jet_turbine_prime'};
            TurbinesData.turbineAxis   = [-3; -3; 3; 3];
            TurbinesData.turbineLimits = TurbinesData.turbineLimits(1:end-2); 
        
        case 3
         
            TurbinesData.turbineList   = {'chest_l_jet_turbine_prime','chest_r_jet_turbine_prime','l_arm_jet_turbine','r_arm_jet_turbine'};
            TurbinesData.turbineAxis   = [3; 3; -3; -3];
            TurbinesData.turbineLimits = TurbinesData.turbineLimits(1:end-2); 
        
        case 4
        
            TurbinesData.turbineList   = {'chest_l_jet_turbine','chest_r_jet_turbine','l_arm_jet_turbine','r_arm_jet_turbine'};
            TurbinesData.turbineAxis   = [-3; -3; -3; -3];
            TurbinesData.turbineLimits = TurbinesData.turbineLimits(1:end-2);  
        
        case 5
                
            TurbinesData.turbineList   = {'l_leg_jet_turbine','r_leg_jet_turbine','l_arm_jet_turbine_prime','r_arm_jet_turbine_prime'};
            TurbinesData.turbineAxis   = [-3; -3; 3; 3];
            TurbinesData.turbineLimits = TurbinesData.turbineLimits(3:end); 
        
        case 6

            TurbinesData.turbineList   = {'l_leg_jet_turbine','r_leg_jet_turbine','l_arm_jet_turbine','r_arm_jet_turbine'};
            TurbinesData.turbineAxis   = [-3; -3; -3; -3];
            TurbinesData.turbineLimits = TurbinesData.turbineLimits(3:end);  
        
        case 7
               
            TurbinesData.turbineList   = {'l_leg_jet_turbine_prime','r_leg_jet_turbine_prime','l_arm_jet_turbine_prime','r_arm_jet_turbine_prime'};
            TurbinesData.turbineAxis   = [3; 3; 3; 3];
            TurbinesData.turbineLimits = TurbinesData.turbineLimits(3:end);  
        
        case 8
                
            TurbinesData.turbineList   = {'l_leg_jet_turbine_prime','r_leg_jet_turbine_prime','l_arm_jet_turbine','r_arm_jet_turbine'};
            TurbinesData.turbineAxis   = [3; 3; -3; -3];
             TurbinesData.turbineLimits = TurbinesData.turbineLimits(3:end);  
        
        case 9
               
            TurbinesData.turbineList   = {'chest_l_jet_turbine_prime','chest_r_jet_turbine_prime','l_arm_jet_turbine_prime','r_arm_jet_turbine_prime','l_leg_jet_turbine_prime','r_leg_jet_turbine_prime'};
            TurbinesData.turbineAxis   = [3; 3; 3; 3; 3; 3]; 
        
        case 10
          
            TurbinesData.turbineList   = {'chest_l_jet_turbine','chest_r_jet_turbine','l_arm_jet_turbine_prime','r_arm_jet_turbine_prime','l_leg_jet_turbine_prime','r_leg_jet_turbine_prime'};
            TurbinesData.turbineAxis   = [-3; -3; 3; 3; 3; 3]; 
        
        case 11
  
            TurbinesData.turbineList   = {'chest_l_jet_turbine','chest_r_jet_turbine','l_arm_jet_turbine','r_arm_jet_turbine','l_leg_jet_turbine_prime','r_leg_jet_turbine_prime'};
            TurbinesData.turbineAxis   = [-3; -3; -3; -3; 3; 3];
        
        case 12
        
            TurbinesData.turbineList   = {'chest_l_jet_turbine','chest_r_jet_turbine','l_arm_jet_turbine','r_arm_jet_turbine','l_leg_jet_turbine','r_leg_jet_turbine'};
            TurbinesData.turbineAxis   = [-3; -3; -3; -3; -3; -3]; 
        
        case 13
                
            TurbinesData.turbineList   = {'chest_l_jet_turbine_prime','chest_r_jet_turbine_prime','l_arm_jet_turbine','r_arm_jet_turbine','l_leg_jet_turbine','r_leg_jet_turbine'};
            TurbinesData.turbineAxis   = [3; 3; -3; -3; -3; -3];
        
        case 14
                
            TurbinesData.turbineList   = {'chest_l_jet_turbine_prime','chest_r_jet_turbine_prime','l_arm_jet_turbine_prime','r_arm_jet_turbine_prime','l_leg_jet_turbine','r_leg_jet_turbine'};
            TurbinesData.turbineAxis   = [3; 3; 3; 3; -3; -3];
        
        case 15
               
            TurbinesData.turbineList   = {'chest_l_jet_turbine','chest_r_jet_turbine','l_arm_jet_turbine_prime','r_arm_jet_turbine_prime','l_leg_jet_turbine','r_leg_jet_turbine'};
            TurbinesData.turbineAxis   = [-3; -3; 3; 3; -3; -3];
            
        case 16

            TurbinesData.turbineList   = {'chest_l_jet_turbine_prime','chest_r_jet_turbine_prime','l_arm_jet_turbine','r_arm_jet_turbine','l_leg_jet_turbine_prime','r_leg_jet_turbine_prime'};
            TurbinesData.turbineAxis   = [3; 3; -3; -3; 3; 3];
        otherwise
            
            error('[switchModel]: wrong testNumber.')
    end   
end
