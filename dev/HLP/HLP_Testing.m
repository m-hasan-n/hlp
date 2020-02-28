
%HLP_Testing
%test classifier and generates a complete plan
%similar to the latest plan_gaps_objects_interaction.m

function HLP_Testing(shared_params , trained_models_dir, segmented_data_dir,...
    experiment_protocol, plan_plot)


%number of features for each classifier
N_gap_features = shared_params.N_gap_features;
N_object_features = shared_params.N_object_features;

%options for arm collsision detection
scan_resolution = shared_params.area_scan_resolution; 
scaling_factor = shared_params. scaling_factor;

%control random number generation to consistently reproduce the results
rng(shared_params.my_random_seed);

%constant dimensions across all trials
[hand_width, table_obj , ~, target_obj, ~,virtual_objects] = ...
    scene_geometry_info;

%no of combinations used for training
num_train_combinations = shared_params.num_train_combinations;

%which training protocol is required
if strcmp(experiment_protocol,'80_20')
    subjects_train_ratio = shared_params.subjects_train_ratio;
    N_subjects = shared_params.N_subjects;
    train_subject_size = round(subjects_train_ratio* N_subjects);
elseif strcmp(experiment_protocol,'num_subj_effect')
    train_subject_size = shared_params.variable_subject_training_size;
end

num_size_iter = length(train_subject_size);


%iterate on different training ratios in case there are many
for ind_subj_size = 1 : num_size_iter
    

   
    
        
    %initialize arrays for accuracy measurement
    gt_gap_response = [];
    estim_gap_response = [];
    gt_obj_resp = [];
    estim_obj_resp = [];
    gt_arm_config = [];
    estim_arm_config = [];
    trial_decision_results = [];
    hlp_similarity_metric = [];
    planning_time = [];
    

    %iterate over all training combinations
    for ind = 1 : num_train_combinations
        
       
        %confirm that all models were trained using data of smae subjects
        %and load the trained models and the associated testing subjects
        [test_sub_ids, gaps_classifier,objects_classifier,...
            object_direction_classifier,arm_config_regressor, path_classifier]=...
            load_trained_models(trained_models_dir,ind,experiment_protocol,...
            shared_params,ind_subj_size);
        
        
        %iterate over all test subjects in this combination
        for ii = 1 : length(test_sub_ids)
            
            test_sub = test_sub_ids(ii);
            subject_name = ['sub_' sprintf('%02d',test_sub)];
            %subject_data_dir = fullfile(extracted_data_dir,['Pilot' num2str(subject_id)]);
            subject_data_dir = fullfile(segmented_data_dir,subject_name);
            trial_files = dir(subject_data_dir);
            
            %iterate over all trials
            for jj=1:length(trial_files)
                if ~strcmp(trial_files(jj).name,'..') && ~strcmp(trial_files(jj).name, '.')
                    
                    %load extracte data for this test trial
                    trial_data_id = trial_files(jj).name;
                    %trial_id_num = str2double(trial_data_id(2:4));
                    trial_path = fullfile( subject_data_dir, trial_data_id);
                    load(trial_path,'scene_objects',...
                        'gab_rectangles','row_heights','gabs_flag_go','gabs_flag_return',...
                        'interaction_flag','pick_push_info','hand_trajectory_info',...
                        'elbow_trajectory_info','shoulder_trajectory_xy','goal_reach_id',...
                        'key_config_data','approaching_dir','obj_gap_corners',...
                        'distance_moved','start_pos','moved_object_names',...
                        'mean_shoulder_elbow_length','mean_elbow_hand_length',...
                        'neck_trajectory_xy','hand_trajectory_xy','elbow_trajectory_xy')
                    
                    if (plan_plot)
                        figure
                        %plot the starting configuration
                        all_obj = table2array(scene_objects(:,[2 4 5 7]));
                        all_obj = to_matlab_rectangles(all_obj);
                        for hh = 1 : 7
                            rectangle('Position',all_obj(hh,:)*10)
                        end
                        hold on
                    end
                    
                     

                    
                    %start timer to compute the planning time
                    tic
                    
                    neck_joint =neck_trajectory_xy(1,:);
                    shoulder_joint = shoulder_trajectory_xy(1,:);
                    elbow_joint = elbow_trajectory_xy(1,:);
                    hand_joint = start_pos;
                    
                    if (plan_plot)
                        plot_arm_configuration(10*neck_joint,...
                            10*shoulder_joint,10*elbow_joint,...
                            10*hand_joint,key_config_data(1,:),'blue');
                    end

                    
                    row_gap_ids = [ones(4,1) ;2*ones(4,1)];
                    row_obj_ids = [ones(3,1) ;2*ones(3,1)];
                    starting_config = key_config_data(1,:);
                    
                    starting_arm_joints.neck = neck_joint;
                    starting_arm_joints.shoulder = shoulder_joint;
                    starting_arm_joints.elbow = elbow_joint;
                    starting_arm_joints.hand = hand_joint;
                    
                    %scene_objects table consists of target at the first row, then the objects
                    %scene_objects 7 columns: name, [x, y, z (center)], width, height, depth
                    target_rect_cent_format = table2array(scene_objects(1,[2 4 5 7]));
                    object_rect_cent_format = table2array(scene_objects(2:end,[2 4 5 7]));
                    
                    %with path classifier
                    [best_start_keypoints, best_end_keypoints,best_start_config,...
                        best_estimated_config, best_estimated_arm_joints,...
                        original_segment_responses,...
                        original_gaps_resp,original_objects_resp,...
                        best_estimated_action_type] = ...
                        row_based_path_planner(row_gap_ids, row_obj_ids,...
                        object_rect_cent_format,target_rect_cent_format,gab_rectangles,...
                        start_pos,gaps_classifier,objects_classifier,...
                        object_direction_classifier,...
                        arm_config_regressor,hand_width, N_gap_features,...
                        table_obj.diagonal,N_object_features, scaling_factor,...
                        virtual_objects, starting_config,...
                        mean_shoulder_elbow_length,mean_elbow_hand_length, path_classifier,...
                        target_obj.width, starting_arm_joints,hand_width,scan_resolution, plan_plot);
                    
                    planning_time = [planning_time; toc];
                    
                    %evaluate the classifiers
                    [hl_similarity,i_first_decision,i_first_element,i_second_decision,...
                        i_second_element, gap_flags_go,estimated_gap_flags,...
                        gt_object_flags,gt_config,estimated_config,...
                        estimated_object_flags,estimated_interaction] =...
                        hlp_classifiers_evaluation(best_start_keypoints,...
                        best_end_keypoints,best_start_config,...
                        best_estimated_config, best_estimated_arm_joints,...
                        original_segment_responses,original_gaps_resp,...
                        original_objects_resp,gabs_flag_go,interaction_flag,...
                        gab_rectangles,best_estimated_action_type,...
                        object_rect_cent_format,scene_objects,...
                        moved_object_names,key_config_data);
                    
                    gt_gap_response = [gt_gap_response;gap_flags_go];
                    estim_gap_response = [estim_gap_response;estimated_gap_flags];
                    gt_obj_resp = [gt_obj_resp;gt_object_flags];
                    estim_obj_resp = [estim_obj_resp;estimated_object_flags];
                    gt_arm_config = [gt_arm_config;gt_config];
                    estim_arm_config = [estim_arm_config;estimated_config];
                    trial_decision_results = [trial_decision_results;i_first_decision,...
                        i_first_element,i_second_decision,i_second_element];
                    hlp_similarity_metric = [hlp_similarity_metric;hl_similarity];
                    %                 gt_segments_response = [gt_segments_response;gt_interaction_matrix(:)];
                    %                 estim_segments_response = [estim_segments_response;estim_interaction_matrix(:)];
                    
                    
                end
            end
            
            
        end
        
        %evaluation and saving testing results
        gap_acc = sum(gt_gap_response==estim_gap_response)/size(gt_gap_response,1);
        obj_acc= sum(gt_obj_resp==estim_obj_resp)/size(gt_obj_resp,1);
        config_rmse = (mean((gt_arm_config - estim_arm_config).^2)).^0.5;
        trial_decision_acc = sum(trial_decision_results)/size(trial_decision_results,1);
        mean_hlp_metric = mean(hlp_similarity_metric);
        mean_planning_time = mean(planning_time);
        
        fname = fullfile(trained_models_dir,[experiment_protocol '_testing_results_' num2str(ind_subj_size) '_'  num2str(ind)]);
        save(fname,'gap_acc','obj_acc','config_rmse','trial_decision_acc',...
            'mean_hlp_metric','mean_planning_time')
    end

end




end



%loading the trained models
function [test_subject_ids, gaps_classifier,objects_classifier,...
    object_direction_classifier,arm_config_regressor, path_classifier] =...
    load_trained_models...
    (trained_models_dir,ind,train_protocol, hyper_params,ind_subj_size)


all_train_ids = [];

%load the gap classifier
fname = fullfile(trained_models_dir,[train_protocol '_gap_classifier_' num2str(ind_subj_size) '_' num2str(ind)]);
load(fname,'gaps_classifier','subject_train_ids')
all_train_ids = [all_train_ids; subject_train_ids];

%load the objects classifier
fname = fullfile(trained_models_dir,[train_protocol '_object_classifier_' num2str(ind_subj_size) '_' num2str(ind)]);
load(fname,'objects_classifier','subject_train_ids')
all_train_ids = [all_train_ids; subject_train_ids];

%load the object's direction classifier
fname = fullfile(trained_models_dir,[train_protocol '_object_direction_classifier_' num2str(ind_subj_size) '_' num2str(ind)]);
load(fname,'object_direction_classifier','subject_train_ids')
all_train_ids = [all_train_ids; subject_train_ids];

%load the arm configuration regression model
fname = fullfile(trained_models_dir,[train_protocol '_arm_configuration_regressor_' num2str(ind_subj_size) '_' num2str(ind)]);
load(fname,'arm_config_regressor','subject_train_ids')
all_train_ids = [all_train_ids; subject_train_ids];

%load the path classifier
fname = fullfile(trained_models_dir,[train_protocol '_path_classifier_' num2str(ind_subj_size) '_' num2str(ind)]);
load(fname,'path_classifier','subject_train_ids')
all_train_ids = [all_train_ids; subject_train_ids];

%confirm that all models are trained using same data of same subjects
diff_in_ids = diff(all_train_ids);
assert(sum(diff_in_ids(:))==0)

all_subject_ids = hyper_params.valid_subject_ids;
test_subject_ids = setdiff(all_subject_ids, subject_train_ids);

end













