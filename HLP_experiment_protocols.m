
%% HLP_experiment_protocols
%This top function defines the required expereiment protocol 
%then calls the HLP_training and HLP_testing scripts  
%Training and Testing are performed on the organized environment structures
%available in the dataset

function HLP_experiment_protocols(first_time, training_required, training_protocol)

% Identify current folder
currentFolder = pwd;

%add paths to the required code
addpath(currentFolder)

% addpath('/home/hasan/Documents/HLC/Code/Moving')
% addpath('/home/hasan/Documents/HLC/Code/Utilities')
% addpath('/home/hasan/Documents/HLC/Code/Plotting')

%% Load the shared parameters 
shared_param = experiments_shared_params();

%% Saving training data
%doing that only once at the first time
if(first_time)
    % Saving extracted training data for all subjects to drive
    save_extracted_training_data(shared_param);
end

%% loading extracted training data for all subjects from drive to workspace
fname = fullfile(shared_param.extacted_data_dir , 'all_extracted_data');
load(fname)

% , 'navi_examples','navi_subject_ids','object_features','object_response',...
%     'object_subject_ids','neighbor_space_features','object_moving_direction',...
%     'hand_to_obj_direction','target_to_obj_direction','object_dir_subject_ids',...
%     'current_config','next_config','dist_feat','dir_feat','config_subject_ids',...
%     'all_path_examples', 'path_subject_ids'

%%    
%% Training and/or Testing
% 80% training and 20% testing with 5 subject combinations
% training_protocol = '80_20';
% train_protocol = 'num_subjects_effect';
if(training_required)
    %% Train the decision classifiers and save the trained models
    HLP_Training (training_protocol, shared_param,navi_examples,...
        navi_subject_ids,object_features,object_response,...
        object_subject_ids,neighbor_space_features,...
        object_moving_direction,hand_to_obj_direction,...
        target_to_obj_direction,object_dir_subject_ids,...
        current_config, next_config, dist_feat,...
        dir_feat,config_subject_ids,all_path_examples, path_subject_ids);
else
    %% Testing
    HLP_Testing_Reduced(shared_param , training_protocol);
end

end