
%Hyperparameters of all strucured-scenes experimets

function  shared_params = experiments_shared_params()

%% set random seed for reproducibility
shared_params.my_random_seed = 1;

%% Dataset initial and final trails to load and segment
shared_params.initial_trial = 10;
shared_params.final_trial = 100;

%% arm configuration regression parameters
shared_params.N_config_angles = 2;
shared_params.N_max_config_trial = 6;

%% number of features for each classifier
shared_params.N_gaps = 8;
shared_params.N_gap_features = 5;
shared_params.N_obj_scene = 6;
shared_params.N_object_features = 5;

%% initial non_practice trial
shared_params.ini_trial = 10;
shared_params.final_structured_trial = 99;

%% scaling factor to extend space around objects to compute free space 
shared_params.scaling_factor = 1.5;

%% when finding area intersection by sampling use this resolution to compute
%the number of lines used to sample the required area
shared_params.area_scan_resolution = 10;
shared_params.raster_scan_resolution = 0.01;

%% subject ids and cross vlaidation number of folds
shared_params.subjects_train_ratio = 0.8;
shared_params.num_train_combinations = 5; %like cross validation but on subjects 
shared_params.all_subject_ids = 1 : 26; 
shared_params.exclude_subject_ids = [5 10]; %exclude these IDs for problems with data collection

shared_params.valid_subject_ids = setdiff(...
    shared_params.all_subject_ids,shared_params.exclude_subject_ids);

shared_params.N_subjects = length(shared_params.valid_subject_ids);

shared_params.variable_subject_training_size = 3:4:23;

%% max number of trials
shared_params.N_trials = 100;

%% Tolerance threshold for considerable object motion
shared_params.pos_change_tol = 1e-3;
%% Options for training the decision classifiers
shared_params.calssif_options.balancing_flag = 1;
shared_params.calssif_options.nfold = 5;
shared_params.calssif_options.train_ratio = 0.8;

%'SVM_LINEAR' , 'SVM_GAUSS', 'LDA'
shared_params.calssif_options.classifier_type = 'SVM_GAUSS'; 
shared_params.calssif_options.adjust_type = 'INC';

end