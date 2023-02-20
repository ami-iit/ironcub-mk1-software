function isValid = verifyFitness(fitness, Config)

% divide the fitness into 4 components: COM, Feet, linear momentum,
% angular momentum
fitness_feet    = fitness(1:3);
fitness_com     = fitness(4:5);
fitness_mom_lin = fitness(6:8);
fitness_mom_ang = fitness(9:11);

% verify if some of the components in which the fitness is divided can
% reach the objective

isValid_feet    = (sum(fitness_feet)/length(fitness_feet) > 0.99);
isValid_com     = (sum(fitness_com)/length(fitness_com) > 0.99);
isValid_mom_lin = (sum(fitness_mom_lin)/length(fitness_mom_lin) > 0.99);
isValid_mom_ang = (sum(fitness_mom_ang)/length(fitness_mom_ang) > 0.99);

isValid         = 1;

if Config.POSTURE_VALID_IF_FEET_RESPECTED
    
    isValid     = isValid * isValid_feet;
end
if Config.POSTURE_VALID_IF_COM_RESPECTED
    
    isValid     = isValid * isValid_com;
end
if Config.POSTURE_VALID_IF_LIN_MOM_RESPECTED
    
    isValid     = isValid * isValid_mom_lin;
end
if Config.POSTURE_VALID_IF_ANG_MOM_RESPECTED
    
    isValid     = isValid * isValid_mom_ang;
end
end
