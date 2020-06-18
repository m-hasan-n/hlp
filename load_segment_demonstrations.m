%load_segment_demonstrations
%loads data of successful trials for all participants
%extracts and saves the required data for further processing

function load_segment_demonstrations()


%Dataset directories,
curr_dir = pwd;
dataset_dir = fullfile(curr_dir,'dataset');
saving_dir = fullfile(curr_dir,'segmented-demonstrations');

%which trials to load 
shared_param = experiments_shared_params();
ini_trial = shared_param.initial_trial;
final_trial = shared_param.final_trial;

%which subject to exclude
excluded_subjects = shared_param.exclude_subject_ids;



subjects_data = dir(dataset_dir);

for ii = 1 : length(subjects_data)
    if subjects_data(ii).isdir == 1 && ~strcmp(subjects_data(ii).name,'..') && ~strcmp(subjects_data(ii).name, '.')
        
        %subject directory, name and ID
        subject_name = subjects_data(ii).name;
        subject_dir = fullfile(dataset_dir, subject_name);
        subject_id = str2double(subject_name(end-1:end));
        
        if ~ismember(subject_id,excluded_subjects)
            subject_id = ['sub_' sprintf('%02d',subject_id)] ;
            %prepare the directory for saving
            subject_saving_dir = fullfile(saving_dir,subject_id);
            if ~exist(subject_saving_dir,'dir')
                mkdir(subject_saving_dir)
            end
            
            %call function to extract and save the data
            %         extract_trial_data_MOVING(subject_dir,ini_trial, saving_dir);
            row_based_data_extraction(subject_dir,ini_trial, subject_saving_dir,...
                final_trial);
        end
    end
end


