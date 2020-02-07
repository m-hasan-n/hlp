%load_save_all_data_MOVING
%loads data of successful trials for all participants
%extracts and saves the required data for further processing
%THIS SCRIPT IS FOR THE EXPERIMENTS OF MOVING OBSTACLES.

function load_save_dataset(dataset_dir,ini_trial , saving_main_dir,...
    pos_change_tol, unstructured_strating_trial,exclude_subject_ids)

close all
clc

addpath('/home/hasan/Documents/HLC/Code/Utilities')

subjects_data = dir(dataset_dir);

for ii = 1 : length(subjects_data)
    if subjects_data(ii).isdir == 1 && ~strcmp(subjects_data(ii).name,'..') && ~strcmp(subjects_data(ii).name, '.')
        
        %subject directory, name and ID
        subject_name = subjects_data(ii).name;
        subject_dir = fullfile(dataset_dir, [subject_name '/S001']);
        subject_id = str2double(subject_name(end-1:end));
        
        if ~ismember(subject_id,exclude_subject_ids)
            subject_id = sprintf('%03d',subject_id);
            %prepare the directory for saving
            saving_dir = fullfile(saving_main_dir,subject_id);
            if ~exist(saving_dir,'dir')
                mkdir(saving_dir)
            end
            
            %call function to extract and save the data
            %         extract_trial_data_MOVING(subject_dir,ini_trial, saving_dir);
            row_based_data_extraction(subject_dir,ini_trial, saving_dir,...
                pos_change_tol, unstructured_strating_trial);
        end
    end
end


