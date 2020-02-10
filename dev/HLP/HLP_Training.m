

%Human-like planning HLP
%Trainig all classifieres
function HLP_Training (trained_models_dir, train_protocol, shared_param,all_navi_examples,...
    navi_subject_ids,all_object_features,all_object_response,...
    object_subject_ids,all_neighbor_space_features,...
    all_object_moving_direction,all_hand_to_obj_direction,...
    all_target_to_obj_direction,object_dir_subject_ids,...
    all_current_config,all_next_config,all_dist_feat,...
    all_dir_feat,config_subject_ids,all_path_examples, path_subject_ids)


%control random number generation to consistently reproduce the results
rng(shared_param.my_random_seed);
                   
%options used for training by all regressors and classifiers
training_options = shared_param.calssif_options;

%which training protocol is required
if strcmp(train_protocol,'80_20')
    subjects_train_ratio = shared_param.subjects_train_ratio;
    N_subjects = shared_param.N_subjects;
    train_subject_size = round(subjects_train_ratio* N_subjects);
elseif strcmp(train_protocol,'num_subjects_effect')
    train_subject_size = shared_param.variable_subject_training_size;
end

num_size_iter = length(train_subject_size);

%iterate on different training ratios in case there are many
for ind_subj_size = 1 : num_size_iter
    
    
    %select trainig ids
    [all_subj_perms,train_perm_ids, num_train_combinations] =...
        select_training_subjects(shared_param , train_subject_size(ind_subj_size));
    
    
    %loop on all training combinations
    for ind = 1:  num_train_combinations
        
        subject_train_ids = all_subj_perms(train_perm_ids(ind),:);
        
        N_training_subjects = length(subject_train_ids);
        
        %initialize
        gap_train_ids = [];
        obj_train_ids = [];
        obj_dir_train_ids = [];
        config_train_ids = [];
        path_train_ids =[];
        
        %get the associated trainign data
        for ii = 1 : N_training_subjects
            subj_id = subject_train_ids(ii);
            idx = find (navi_subject_ids == subj_id);
            gap_train_ids = [gap_train_ids; idx];
            idx = find (object_subject_ids == subj_id);
            obj_train_ids = [obj_train_ids;idx];
            idx = find (object_dir_subject_ids == subj_id);
            obj_dir_train_ids = [obj_dir_train_ids;idx];
            idx = find (config_subject_ids == subj_id);
            config_train_ids=[config_train_ids;idx];
            idx = find (path_subject_ids == subj_id);
            path_train_ids=[path_train_ids;idx];
        end
        
        %train the binary gap classifier
        navi_examples = all_navi_examples(gap_train_ids,:);
        gaps_classifier =  train_the_classifier(navi_examples(:,1:end-1),...
            navi_examples(:,end),training_options);
        
        %svae the trained gap calssifer for this combination
        fname = fullfile(trained_models_dir,[train_protocol ...
            '_gap_classifier_' num2str(ind_subj_size) '_' num2str(ind)]);
        
        save(fname,'gaps_classifier','subject_train_ids')
        
        %train the binary object classifier
        object_features = all_object_features(obj_train_ids,:);
        object_response = all_object_response(obj_train_ids,:);
        objects_classifier = train_the_classifier(object_features,object_response,training_options);
        
        %svae the trained object calssifer for this combination
        fname = fullfile(trained_models_dir,[train_protocol...
            '_object_classifier_' num2str(ind_subj_size) '_' num2str(ind)]);
        save(fname,'objects_classifier','subject_train_ids')
        
        %train the multi-class object-direction classifier
        neighbor_space_features = all_neighbor_space_features(obj_dir_train_ids,:);
        target_to_obj_direction = all_target_to_obj_direction(obj_dir_train_ids,:);
        hand_to_obj_direction = all_hand_to_obj_direction(obj_dir_train_ids,:);
        feats_table = [array2table(neighbor_space_features) array2table(hand_to_obj_direction)...
            array2table(target_to_obj_direction)];
        
        resp_table = all_object_moving_direction(obj_dir_train_ids,:);
        
        object_direction_classifier = train_multiClass_classifier...
            (feats_table,resp_table, training_options.nfold,...
            training_options.train_ratio,training_options.balancing_flag);
        
        %save the object-direction classifier
        fname = fullfile(trained_models_dir,[train_protocol...
            '_object_direction_classifier_' num2str(ind_subj_size) '_' num2str(ind)]);
        save(fname,'object_direction_classifier', 'subject_train_ids')
        
        %configuration regression
        current_config = all_current_config(config_train_ids,:);
        dist_feat = all_dist_feat(config_train_ids,:);
        dir_feat = all_dir_feat(config_train_ids,:);
        
        data_in = [array2table(current_config) array2table(dist_feat) array2table(dir_feat)];
        data_out = all_next_config(config_train_ids,:);
        
        arm_config_regressor = my_regression(data_in,data_out,...
            training_options.nfold,training_options.train_ratio);
        
        %save the trained model of configuration regression
        fname = fullfile(trained_models_dir,[train_protocol...
            '_arm_configuration_regressor_' num2str(ind_subj_size) '_' num2str(ind)]);
        save(fname,'arm_config_regressor', 'subject_train_ids')
        
        %train the binary path classifier
        path_examples = all_path_examples(path_train_ids,:);
        path_classifier =  train_the_classifier(path_examples(:,1:end-1),...
            path_examples(:,end),training_options);
        
        %svae the trained gap calssifer for this combination
        fname = fullfile(trained_models_dir,[train_protocol...
            '_path_classifier_' num2str(ind_subj_size) '_' num2str(ind)]);
        save(fname,'path_classifier','subject_train_ids')
        
    end

end


end

function trained_classifier =  train_the_classifier(feat,resp,calssif_options)

%train binary classifier
[total_acc, pos_acc, neg_acc, object_classifiers] = train_binary_classifier...
    (feat,resp,calssif_options.balancing_flag,...
    calssif_options.adjust_type,calssif_options.nfold,...
    calssif_options.train_ratio, calssif_options.classifier_type);

%select the best object classifier using cross-validation
trained_classifier = get_best_classifier(total_acc, pos_acc, neg_acc,...
    object_classifiers);

end


function [all_subj_perms,train_perm_ids, num_train_combinations] =...
    select_training_subjects(shared_params , train_subject_size)

%find all combinations for training ids
num_train_combinations = shared_params.num_train_combinations;
% subjects_train_ratio = hyper_params.subjects_train_ratio;
% N_subjects = hyper_params.N_subjects;
% train_subject_size = round(subjects_train_ratio* N_subjects);
all_subject_ids = shared_params.valid_subject_ids;
all_subj_perms = nchoosek(all_subject_ids, train_subject_size);

%select the required number of combinations
train_perm_ids = randsample(1:size(all_subj_perms,1),num_train_combinations);
    


end



