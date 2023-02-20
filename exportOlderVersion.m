%  Export Simulink models to a previously supported version if needed. 
%  Currently, the default version is MATLAB 2021b. 
%
clc
clear 
close all

fprintf('\niRonCub Software\n');
fprintf('\nExport models to a previous Matlab version\n');
fprintf('\nDefault version: R2021b\n');
fprintf('\nOldest supported version: R2019a\n');

fprintf('\n######################################################\n');
fprintf('\nWarning: this function exports only Simulink models.\n');
fprintf('\nIf a .m file requires a dependency that is not\n');
fprintf('\ncompatible with your installation, the library\n');
fprintf('\nmay still not work properly.\n');
fprintf('\n######################################################\n\n');

% list of all simulink mdl and slx in the project
mdlList   = dir('./**/*.mdl');
slxList   = dir('./**/*.slx');

% workaround to exclude installed models if the user installs them in build folder
mdlList_upd = [];
slxList_upd = [];

for k = 1:length(slxList)

    if ~contains( slxList(k).folder , '/build' )
        slxList_upd = [slxList_upd; slxList(k)]; %#ok<AGROW> 
    end
end
for k = 1:length(mdlList)

    if ~contains( mdlList(k).folder , '/build' )
        mdlList_upd = [mdlList_upd; mdlList(k)]; %#ok<AGROW> 
    end
end

mdlList = mdlList_upd;
slxList = slxList_upd;

% matlab version to which export all models
matlabVer = input('Specify the Matlab version to export models (format: R20XXx) ','s');

%% Verify matlab version

% latest version: R2019b
matlabVer_list     = {'R2019a','R2019b', 'R2020a', 'R2020b', 'R2021a', 'R2021b'};

% associated Simulink version
simulinkVer_number = {'9.3','10.0','10.1','10.2', '10.3', '10.4'};

% installed Simulink version
currentSimulinkVer = ver('Simulink');

%% Debug messages
matlabVer_found = 0;

for k = 1:length(matlabVer_list)
    
    if strcmp(matlabVer_list{k},matlabVer)
        
        fprintf(['\nExporting files into Matlab ',matlabVer, '...','\n\n']);
        matlabVer_found = k;
    end
end

if matlabVer_found == 0
    
    error('Version name does not correspond to any known Matlab release.');
end

if isempty(currentSimulinkVer)
    
    error('Simulink not found. Verify your Simulink version.');

elseif str2double(simulinkVer_number{matlabVer_found}) > str2double(currentSimulinkVer.Version)
    
    error('It is not possible to export models to Simulink versions higher than the one installed on your system.');
end

%% Load the Simulink models and export to previous versions
mdlVer_list = {'R2019A_MDL','R2019B_MDL', 'R2020A_MDL', 'R2020B_MDL', 'R2021A_MDL', 'R2021B_MDL'};
slxVer_list = {'R2019A_SLX','R2019B_SLX', 'R2020A_SLX', 'R2020B_SLX', 'R2021A_SLX', 'R2021B_SLX'};

for k = 1:length(slxList)

    % close all open models with the same name (if there is any)
    close_system('',0)
    close_system(slxList(k).name,0)
        
    fprintf(['\nLOADED SLX FILE: ' slxList(k).name '\n']);
    open_system([slxList(k).folder,'/',slxList(k).name],'loadonly');
        
    % save the model in a temporary copy. Then, export the copy into
    % the previous version, by overwriting the original model
    fprintf('\n saving a temporary copy of the model \n\n');
    save_system([slxList(k).folder,'/',slxList(k).name], [slxList(k).folder,'/',slxList(k).name(1:end-4),'_temp.slx']);
    close_system([slxList(k).folder,'/',slxList(k).name],0);        
    open_system([slxList(k).folder,'/',slxList(k).name(1:end-4),'_temp.slx'],'loadonly');
        
    % do not export if simulink models are already at the required version
    if str2double(simulinkVer_number{matlabVer_found}) == str2double(currentSimulinkVer.Version)
       
       fprintf('\n model is already at the required version. \n');  
    else     
       save_system([slxList(k).folder,'/',slxList(k).name(1:end-4),'_temp.slx'], [slxList(k).folder,'/',slxList(k).name], 'ExportToVersion', slxVer_list{matlabVer_found});
    end
              
    % closing the temporary model
    fprintf('\n closing the model \n');
    close_system([slxList(k).folder,'/',slxList(k).name(1:end-4),'_temp.slx']);
        
    % delete the temporary model
    delete([slxList(k).folder,'/',slxList(k).name(1:end-4),'_temp.slx'])
end

for k = 1:length(mdlList)
    
    % close all open models with the same name (if there is any)
    close_system('',0)
    close_system(mdlList(k).name,0)

    fprintf(['\nLOADED MDL FILE: ' mdlList(k).name '\n']);
    open_system([mdlList(k).folder,'/',mdlList(k).name],'loadonly');
        
    % save the model in a temporary copy. Then, export the copy into
    % the previous version, by overwriting the original model
    fprintf('\n saving a temporary copy of the model \n\n');
    save_system([mdlList(k).folder,'/',mdlList(k).name], [mdlList(k).folder,'/',mdlList(k).name(1:end-4),'_temp.mdl']);
    close_system([mdlList(k).folder,'/',mdlList(k).name],0);        
    open_system([mdlList(k).folder,'/',mdlList(k).name(1:end-4),'_temp.mdl'],'loadonly');
        
    % do not export if simulink models are already at the required version
    if str2double(simulinkVer_number{matlabVer_found}) == str2double(currentSimulinkVer.Version)
       
       fprintf('\n model is already at the required version. \n');  
    else     
       save_system([mdlList(k).folder,'/',mdlList(k).name(1:end-4),'_temp.mdl'], [mdlList(k).folder,'/',mdlList(k).name], 'ExportToVersion', mdlVer_list{matlabVer_found});
    end
              
    % closing the temporary model
    fprintf('\n closing the model \n');
    close_system([mdlList(k).folder,'/',mdlList(k).name(1:end-4),'_temp.mdl']);
        
    % delete the temporary model
    delete([mdlList(k).folder,'/',mdlList(k).name(1:end-4),'_temp.mdl'])
end

fprintf('\nDone.\n');
