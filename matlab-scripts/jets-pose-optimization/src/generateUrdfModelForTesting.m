function createdModelName = generateUrdfModelForTesting(TurbinesData,Model)

    % GENERATEURDFMODELFORTESTING creates a urdf model that contains only
    %                             the selected turbines starting from the full
    %                             urdf model (with all turbines).
    %
    % FORMAT:  createdModelName = generateUrdfModelForTesting(TurbinesData,Model)
    %
    % INPUTS:  - TurbinesData: structure containing the turbines data;
    %
    %                          REQUIRED FIELDS:
    %
    %                          - turbineList: [cell array of strings];
    %
    %          - Model: model-specific configuration parameters;
    %                  
    %                   REQUIRED FIELDS: 
    %
    %                   - modelPath: [string];
    %                   - modelName: [string];
    %    
    % OUTPUTS: - createdModelName: string containing the new model name.
    %
    % Author : Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Nov 2018

    %% ------------Initialization----------------

    % Parse the turbines list in order to select the turbines that are NOT in
    % the list during the current test
    fullTurbinesList = {'chest_l_jet_turbine','chest_r_jet_turbine','l_arm_jet_turbine','r_arm_jet_turbine','l_leg_jet_turbine','r_leg_jet_turbine', ...
                        'chest_l_jet_turbine_prime','chest_r_jet_turbine_prime','l_arm_jet_turbine_prime','r_arm_jet_turbine_prime','l_leg_jet_turbine_prime','r_leg_jet_turbine_prime'};

    for k = 1:length(TurbinesData.turbineList)
    
        for i = 1:length(fullTurbinesList)
        
            if strcmp(TurbinesData.turbineList{k}, fullTurbinesList{i})
            
                fullTurbinesList{i} = '';
            end
        end
    end

    % create a new list of turbines that contains only the turbines to be
    % removed from the model
    fullTurbinesListUpdated = {};

    for i = 1:length(fullTurbinesList)
    
        if ~isempty(fullTurbinesList{i})
        
            fullTurbinesListUpdated = {fullTurbinesListUpdated{1:end}, fullTurbinesList{i}};
        end
    end

    % open the full model
    fid = fopen([Model.modelPath,Model.modelName], 'rt');

    % scan the entire file
    cell_urdf = textscan(fid, '%s', 'delimiter', '\n');

    % search for the turbines to comment out
    for k = 1:length(fullTurbinesListUpdated)
    
        index_start_commenting_out = find(strcmp(cell_urdf{1}, ['<link name="',fullTurbinesListUpdated{k},'">']), 1, 'first');

        % the index where to finish commenting out the lines is the end of the turbine joint
        % definition, that is 5 lines below the turbine joint declaration.
        % This info at the moment is HARD-CODED
        index_end_commenting_out = find(strcmp(cell_urdf{1}, ['<joint name="',fullTurbinesListUpdated{k},'_joint" type="fixed">']), 1, 'first');

        % debug the search results
        if isempty(index_end_commenting_out) || isempty(index_start_commenting_out)
    
            error('[generateUrdfModelForTesting]: unable to find the turbine in the model.')
        end

        if index_end_commenting_out <= index_start_commenting_out

            error('[generateUrdfModelForTesting]: the line to which stop commenting cannot be before the line the comment start.')
        end
    
        if strcmp(cell_urdf{1}{index_end_commenting_out+5}, '</joint>')
    
            % modify the cell array in order to comment out the link and joint
            % associated to the k-th turbine
            cell_urdf{1}{index_start_commenting_out} = ['<!--', cell_urdf{1}{index_start_commenting_out}];
            cell_urdf{1}{index_end_commenting_out+5} = [cell_urdf{1}{index_end_commenting_out+5}, '-->'];
        else
            error('[generateUrdfModelForTesting]: unexpected end line for commenting out the turbine. The expected end line is ''</joint>''.')
        end

    end

    % close the full model
    fclose(fid);

    % write the cell_urdf into a new urdf file that will be used in the optimization
    createdModelName = 'modelReducedTurbines.urdf';
    
    fid2 = fopen([Model.modelPath, createdModelName], 'w');

    for i = 1:numel(cell_urdf{1})

        fprintf(fid2,'%s\n', cell_urdf{1}{i});
    end
    
    disp(['[generateUrdfModelForTesting]: created model ',createdModelName])
    fclose(fid2);
end
