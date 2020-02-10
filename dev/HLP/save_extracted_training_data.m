
% Saving extracted data for all subjects from drive to workspace

function save_extracted_training_data(shared_param )


%constant dimensions across all trials
[hand_width, table_obj , ~, target_obj, ~,virtual_objects] = ...
    scene_geometry_info;

%hyper parameters
subject_ids = shared_param.valid_subject_ids;
N_subjects = shared_param.N_subjects;
N_trials = shared_param.N_trials;
N_gaps = shared_param.N_gaps;
N_gap_features = shared_param.N_gap_features;
N_obj_scene = shared_param.N_obj_scene;
N_object_features = shared_param.N_object_features;
N_max_config_trial = shared_param.N_max_config_trial;
N_config_angles = shared_param.N_config_angles;
scaling_factor = shared_param.scaling_factor;
area_scan_resolution = shared_param.area_scan_resolution;



%Diectories required
curr_dir = pwd;
trials_base_dir = fullfile(curr_dir,'dataset');
segmented_data_dir = fullfile(curr_dir,'segmented-demonstrations');

%initialization for gap classifier
navi_examples = zeros(N_subjects*N_trials*N_gaps,N_gap_features+1);
navi_subject_ids = zeros(N_subjects*N_trials*N_gaps, 1);
gap_cntr = 1;

%initialization for object classifier
object_features = zeros(N_subjects*N_trials*N_obj_scene, N_object_features + 2 );
object_response = zeros(N_subjects*N_trials*N_obj_scene ,1);
object_subject_ids = zeros(N_subjects*N_trials*N_obj_scene ,1);
obj_cntr = 1;

%initialization for object-direction classifier
neighbor_space_features = zeros(N_subjects*N_trials*N_obj_scene,N_gaps);
object_moving_direction = strings(N_subjects*N_trials*N_obj_scene ,1);
hand_to_obj_direction = strings(N_subjects*N_trials*N_obj_scene ,1);
target_to_obj_direction = strings(N_subjects*N_trials*N_obj_scene ,1);
object_dir_subject_ids = zeros(N_subjects*N_trials*N_obj_scene ,1);
obj_dir_cntr = 1;

%initialization for arm configuration regression
current_config = zeros(N_subjects*N_trials*N_max_config_trial,N_config_angles);
next_config = zeros(N_subjects*N_trials*N_max_config_trial,N_config_angles);
dist_feat = zeros(N_subjects*N_trials*N_max_config_trial,N_config_angles);
dir_feat = strings(N_subjects*N_trials*N_max_config_trial,1);
config_cntr = 1;
config_subject_ids = zeros(N_subjects*N_trials*N_max_config_trial,1);

%initialize for path-training examples
all_path_examples = [];
path_subject_ids = [];

%loop on subjects for each combination
for ii = 1 : length(subject_ids)
    
    %extracted trails data
    subject_id = subject_ids(ii);
    subject_name = ['sub_' sprintf('%02d',subject_id)];
   
    subject_data_dir = fullfile(segmented_data_dir,subject_name);
    trial_files = dir(subject_data_dir);
    
    %iterate over all trials for this subject
    for jj=1:length(trial_files)
        if ~strcmp(trial_files(jj).name,'..') && ~strcmp(trial_files(jj).name, '.')
            
            % load the extracted data
            trial_data_id = trial_files(jj).name;
            trial_path = fullfile( subject_data_dir, trial_data_id);
            
            load(trial_path,'scene_objects',...
                'gab_rectangles','row_heights','gabs_flag_go','gabs_flag_return',...
                'interaction_flag','pick_push_info','hand_trajectory_info',...
                'elbow_trajectory_info','shoulder_trajectory_xy','goal_reach_id',...
                'key_config_data','approaching_dir','obj_gap_corners',...
                'distance_moved','start_pos','moved_object_names',...
                'mean_shoulder_elbow_length','mean_elbow_hand_length',...
                'neck_trajectory_xy','hand_trajectory_xy','elbow_trajectory_xy')
            
            %scene objects names, array and target center
            %scene_objects 6 columns: x, y, z (center) width, height, depth
            scene_objects_names = table2cell(scene_objects(:,1));
            scene_objects_array = table2array(scene_objects(:,[2 4 5 7]));
            
            %Target center from the given objects info
            target_center = [scene_objects_array(1,1) scene_objects_array(1,2)];
            
            %Gaps Classifier
            %confirm there is a selected gap at any or both rows
            %to train the gaps classifier
            if sum(interaction_flag) ~= 2
                
                %moved object at first row if any
                if ~isempty(moved_object_names)
                    obj_id = strcmp(table2cell(scene_objects(:,1)),moved_object_names);
                    obj_rectangle = table2array(scene_objects(obj_id,[2 4 5 7]));
                else
                    obj_rectangle=[];
                end
                
                %construct gap examples from features and responses
                %and get the adjusted gaps_flag_go
                [navi_examples(gap_cntr:gap_cntr+N_gaps-1,:), gabs_flag_go]...
                    = single_gap_description_MOVING...
                    (gab_rectangles,target_center, gabs_flag_go,start_pos,...
                    hand_width,N_gap_features,table_obj.diagonal,row_heights,...
                    interaction_flag,obj_rectangle);
                
                navi_subject_ids(gap_cntr:gap_cntr+N_gaps-1,:) =...
                    ones(N_gaps,1)*subject_id;
                
                gap_cntr = gap_cntr + N_gaps;
            end
            
            %Objects Classifiers
            %confirm there is an interaction at any or both rows
            %to train the objects classifier
            if sum(interaction_flag) ~= 0
                % Which object to move?
                
                %what is the selected gap at the first row, if any?
                selected_gap = gab_rectangles(logical(gabs_flag_go),:);
                
                %construct object examples from features and responses
                [object_feat , free_space,target_overlap, object_resp] = ...
                    moving_object_description_training(scene_objects_array,...
                    pick_push_info,N_object_features,scaling_factor,start_pos,...
                    row_heights,interaction_flag,selected_gap, ...
                    table_obj.diagonal, scene_objects_names,virtual_objects,hand_width);
                
                object_features(obj_cntr:obj_cntr + N_obj_scene-1,:) = ...
                    [object_feat free_space target_overlap];
                object_response(obj_cntr:obj_cntr + N_obj_scene-1,:) = object_resp;
                
                object_subject_ids(obj_cntr:obj_cntr + N_obj_scene-1,:) =...
                    ones(N_obj_scene,1)*subject_id;
                
                obj_cntr = obj_cntr + N_obj_scene;
                
                %Where to move object?
                trial_name = trial_data_id;
                trial_name(end-3:end)=[];
                
                %construct object-direction examples
                [feat_obj_neighbor , feat_hand_dir, resp_obj_mov_dir, target_to_obj_dir] = ...
                    moving_object_direction(scene_objects_array,pick_push_info,...
                    scaling_factor,subject_id,trial_name,trials_base_dir,...
                    approaching_dir,interaction_flag,scene_objects_names,virtual_objects);
                
                start_id = obj_dir_cntr;
                end_id = obj_dir_cntr + size(resp_obj_mov_dir,1)-1;
                
                neighbor_space_features(start_id:end_id,:) = feat_obj_neighbor;
                object_moving_direction(start_id:end_id,:) = resp_obj_mov_dir;
                hand_to_obj_direction(start_id:end_id,:) = feat_hand_dir;
                target_to_obj_direction(start_id:end_id,:) = target_to_obj_dir;
                
                object_dir_subject_ids(start_id:end_id,:) =...
                    ones(end_id-start_id+1,1)*subject_id;
                
                obj_dir_cntr = obj_dir_cntr + size(resp_obj_mov_dir,1);
                
                
            end
            
            
            %path-classifier trained using data from each trial
            path_examples = train_path_classifier(gab_rectangles, gabs_flag_go,...
                interaction_flag,pick_push_info,scene_objects_array,...
                scene_objects_names, virtual_objects, start_pos,...
                target_center,target_obj.width,table_obj.width,hand_width,area_scan_resolution);
            
            all_path_examples =[all_path_examples;path_examples];
            path_subject_ids = [path_subject_ids; ones(size(path_examples,1),1)*subject_id];
            
            %configuration-regression from each trial
            %extracted configurations from this trial
            num_key_config = size(key_config_data,1);
            current_config(config_cntr:config_cntr+num_key_config-2,:) = key_config_data(1:num_key_config-1,:);
            next_config(config_cntr:config_cntr+num_key_config-2,:) = key_config_data(2:num_key_config,:);
            
            %normalize distance feature by sum of link lengths
            sum_link_length = mean_shoulder_elbow_length+mean_elbow_hand_length;
            dist_feat(config_cntr:config_cntr+num_key_config-2,:) =...
                distance_moved(2:end,:)/sum_link_length;
            
            dir_feat(config_cntr:config_cntr+num_key_config-2,:) = approaching_dir(2:end,:);
            
            config_subject_ids(config_cntr:config_cntr+num_key_config-2,:) = ones(num_key_config-1 , 1)*subject_id;
            
            config_cntr = config_cntr + num_key_config-1;
            
        end
    end
    
end


%adjust array sizes
navi_examples(gap_cntr:end,:)=[];     
navi_subject_ids(gap_cntr:end,:)=[];

object_features(obj_cntr:end,:)=[];
object_response(obj_cntr:end,:)=[];  
object_subject_ids(obj_cntr:end,:)=[]; 

neighbor_space_features(obj_dir_cntr:end,:)=[];
object_moving_direction(obj_dir_cntr:end,:)=[];
hand_to_obj_direction(obj_dir_cntr:end,:)=[];
target_to_obj_direction(obj_dir_cntr:end,:)=[];
object_dir_subject_ids(obj_dir_cntr:end,:)=[];

current_config(config_cntr:end,:)=[];   
next_config(config_cntr:end,:)=[];
dist_feat(config_cntr:end,:)=[];     
dir_feat(config_cntr:end,:)=[];
config_subject_ids(config_cntr:end,:)=[];


%saving
fname = fullfile(segmented_data_dir , 'all_training_examples');

save(fname, 'navi_examples','navi_subject_ids','object_features','object_response',...
    'object_subject_ids','neighbor_space_features','object_moving_direction',...
    'hand_to_obj_direction','target_to_obj_direction','object_dir_subject_ids',...
    'current_config','next_config','dist_feat','dir_feat','config_subject_ids',...
    'all_path_examples', 'path_subject_ids')

end