

function row_based_data_extraction(subject_dir,ini_trial, save_dir,...
    pos_change_tol, unstructured_strating_trial)
                
                
%constant dimensions across all trials
[~,table_obj , ~, target_obj, object_depth]= scene_geometry_info;

%load the trial_results table
trial_results = readtable(fullfile(subject_dir,'/trial_results.csv'));

%filter out the failed trials
success_trial_ids = find(strcmp(trial_results.('outcome'),'Success'));

%skip the first 9 trials used for practice
%and the last 20 trials of un-structured scenes as not for training
success_trial_ids = success_trial_ids(success_trial_ids >= ini_trial &...
    success_trial_ids<unstructured_strating_trial);

%find the time of reaching the target
% target_reaching_time = trial_results.('target_reached_time');
% target_reaching_time = target_reaching_time(success_trial_ids);

%iterate on the successful trials of this subject
% subject_dir = [subject_dir '/new_structure'];
% all_trials = dir(subject_dir);
% fin_trial = length(all_trials)-2;
% success_trial_ids = ini_trial:fin_trial;

for ii = 1 : size(success_trial_ids,1)
    
    trial_id = success_trial_ids(ii,:);
%     reach_time = target_reaching_time(ii);
    
    %path to the trial
    trial_name = ['T' sprintf('%03d',trial_id)];
    trial_path = fullfile(subject_dir,trial_name);
    
    %Hand and Elbow Trajectory path and timestamps
    hand_trajectory_info = readtable(fullfile(trial_path,['movement/HandTracker_movement_' trial_name '.csv']));
%     hand_trajectory_timestamp = table2array(hand_trajectory_info(:,1));
    hand_trajectory_xy = table2array(hand_trajectory_info(:,[2 4]));
    
    elbow_trajectory_info = readtable(fullfile(trial_path,['movement/ElbowTracker_movement_' trial_name '.csv']));
%     elbow_trajectory_timestamp = table2array(elbow_trajectory_info(:,1));
    elbow_trajectory_xy = table2array(elbow_trajectory_info(:,[2 4]));
    
    shoulder_trajectory_info = readtable(fullfile(trial_path,['movement/ShoulderTracker_movement_' trial_name '.csv']));
%     shoulder_trajectory_timestamp = table2array(shoulder_trajectory_info(:,1));
    shoulder_trajectory_xy = table2array(shoulder_trajectory_info(:,[2 4]));
    
   
    
    %start_pos needed by many functions 
    scene_layout = readtable(fullfile(trial_path,['/scene/scene_layout_' trial_name '.csv']));
    scene_layout = table2array(scene_layout(:,2:end));
    start_pos = [scene_layout(2,1) scene_layout(2,3)];
     
    %estimate neck trajectory assuming neck joint is at same depth as
    %shoulder joint i.e. the 2d projection of neck-shoulder link is always 
    %horizontal and having same length as shoulder-elbow link
    shoulder_elbow_link_length = (sum((shoulder_trajectory_xy(1,:) -elbow_trajectory_xy(1,:)).^2))^0.5;
    neck_x = shoulder_trajectory_xy(:,1)- shoulder_elbow_link_length;
    neck_y = shoulder_trajectory_xy(:,2);
    neck_trajectory_xy = [ neck_x  neck_y];
    
    
    shoulder_elbow_link = (sum( ((shoulder_trajectory_xy -elbow_trajectory_xy).^2),2)).^0.5; 
    elbow_hand_link = (sum(((elbow_trajectory_xy - hand_trajectory_xy).^2),2)).^0.5;
    mean_shoulder_elbow_length = mean(shoulder_elbow_link);
    mean_elbow_hand_length = mean(elbow_hand_link);
    
    %read the objects layout as atable with one row for each object including Target as first row
    %7 columns: object name, x, y, z, width, height, depth
    %x,y,z define the center
    scene_objects = readtable(fullfile(trial_path,['scene/grid_objects_layout_' trial_name '.csv']));
    
    
    %for organized structures only
    %confirm correct objects layout
    %if object names are not correct, skip this trial
    %this is to handle errors in VR dataset collection
    
    id_short = find(strcmp(table2cell(scene_objects(:,1)),'FailOnTouchObstacleShort'));
    id_med = find(strcmp(table2cell(scene_objects(:,1)),'FailOnTouchObstacleMed'));
    id_long = find(strcmp(table2cell(scene_objects(:,1)),'FailOnTouchObstacleLong'));
    heights = table2array(scene_objects([id_short,id_med,id_long],4));
    if any(heights~=-0.105)
        continue
    end
    
    
    %transform into a numeric array excluding the name of the object
    scene_objects_array = table2array(scene_objects(:,[2 4 5 7]));
    obj_rect_cent_format = scene_objects_array(2:end,:);
    
    %Target Reach Point
    target_rect_cent_format = scene_objects_array(1,:);
    target_obj.pos = [target_rect_cent_format(1) target_rect_cent_format(2)];
    sq_dist = sum((hand_trajectory_xy - target_obj.pos).^2,2);
    [~ , goal_reach_id] = min(sq_dist);
    
    %go_trajectory
    hand_go_trajectory = hand_trajectory_xy(1:goal_reach_id,:);
    hand_ret_trajectory = hand_trajectory_xy(goal_reach_id+1:end,:);
    
    elbow_go_trajectory = elbow_trajectory_xy(1:goal_reach_id,:);
    shoulder_go_trajectory = shoulder_trajectory_xy(1:goal_reach_id,:);
    neck_go_trajectory = neck_trajectory_xy(1:goal_reach_id,:);
    
    %compute the gabs between objects in matlab-rectangle format [X Y W H]
    %X,Y define the bottom left corner point
    %row_heights give the heights (and number) of rows in the sceneplot_single_trial(subject_dir,trial_id)
    
    [gab_rectangles , row_heights] = find_gabs_bet_objects...
        (obj_rect_cent_format,table_obj.edges,object_depth);
    
    
%         [gab_rectangles, row_heights, ~] = find_gaps_raster_scan_XY...
%             (obj_rect_cent_format, target_rect_cent_format, start_pos,...
%             table_obj.edges, scan_step);

   
    %find which gabs were selected by the subject for both go and return paths
    gabs_flag_go = which_gab_selected (hand_go_trajectory , gab_rectangles);
    gabs_flag_return = which_gab_selected (hand_ret_trajectory , gab_rectangles);
    
  
    %interaction log file
    %5 columns: start_time, end_time, dominant_object, non_dominant_object, interaction_type
    interaction_log = readtable(fullfile(trial_path,['movement/interaction_log_' trial_name '.csv']));
    interaction_type = table2cell(interaction_log(:,5));
    
    %find when picking or pushing happens
    pick_ids = find(strcmp(interaction_type,'PickedUp'));
    push_ids = find(strcmp(interaction_type,'Pushed'));
    pick_push_ids = sort([pick_ids; push_ids]);
    pick_push_info = interaction_log(pick_push_ids,:);
    id_target = strcmp(table2cell(pick_push_info(:,4)),'Target');
    target_info = pick_push_info(id_target,:);
    
    %remove Target from the interactions to check if interaction happened
    reduced_pick_push_info = pick_push_info;
    reduced_pick_push_info(id_target,:)=[];
    
    %remove duplicates from reduced_pick_push_info
    [~ , ids_unique] = unique(reduced_pick_push_info(:,4));
    reduced_pick_push_info = reduced_pick_push_info(sort(ids_unique),:);
    
   
    %find which objects were moved at each row
    moved_object_names = table2cell(reduced_pick_push_info(:,4));
    obj_ids_first = [];
    obj_ids_second = [];
    for jj=1:size(moved_object_names,1)
        if any(strcmp({'FailOnTouchObstacleShort','FailOnTouchObstacleMed','FailOnTouchObstacleLong'}, moved_object_names(jj)))
            obj_ids_first = [obj_ids_first;jj];
        end
        if any(strcmp({'FailOnTouchObstacleShort-1','FailOnTouchObstacleMed-1','FailOnTouchObstacleLong-1'}, moved_object_names(jj)))
            obj_ids_second = [obj_ids_second;jj];
        end
    end

    
    %in case of moving more than 1 objects at any row, select the first one only
    
    %if more than one object at first row
    if length(obj_ids_first) > 1
        starting_times = table2array(reduced_pick_push_info(obj_ids_first,1));
        [~ , ids_1] = min(starting_times);
        obj_ids_1 = obj_ids_first(ids_1);
    else
        obj_ids_1 = obj_ids_first;
    end
    %if more than one object at second row
    if length(obj_ids_second) > 1
        starting_times = table2array(reduced_pick_push_info(obj_ids_second,1));
        [~ , ids_2] = min(starting_times);
        obj_ids_2 = obj_ids_second(ids_2);
    else
        obj_ids_2 = obj_ids_second;
    end
    obj_ids = union(obj_ids_1 , obj_ids_2);
    reduced_pick_push_info = reduced_pick_push_info(obj_ids,:);
    
    
    
    %Row-based interaction flags are: 
    %[0 0] no interaction
    %[1 0] , [0 1] interaction at first or second row
    %[1 1] interaction at both rows
    
    %initialized with zeros for No interaction case
    interaction_flag=zeros(1,2);
    
    %With Interaction, moved objects
    moved_object_names = table2cell(reduced_pick_push_info(:,4));

    for jj=1:size(moved_object_names,1)
        if any(strcmp({'FailOnTouchObstacleShort','FailOnTouchObstacleMed','FailOnTouchObstacleLong'}, moved_object_names(jj)))
            interaction_flag(1) = 1;
        end
        if any(strcmp({'FailOnTouchObstacleShort-1','FailOnTouchObstacleMed-1','FailOnTouchObstacleLong-1'}, moved_object_names(jj)))
            interaction_flag(2) = 1;
        end
    end

    pick_push_info_for_segment = [reduced_pick_push_info;target_info];
    
    [ object_inetaction_data , keypoints_sorted] = spatio_temporal_segment...
        (trial_path,trial_name, pick_push_info_for_segment,pos_change_tol);

    %in case interaction at the two rows but less than two objects were
    %actually moved
    if length(object_inetaction_data)<3 && sum(interaction_flag)==2
        continue
    end
    %in case target was not moved
    inter_names = cell(length(object_inetaction_data),1);
    for dd = 1 : length(object_inetaction_data)
        inter_names(dd) = object_inetaction_data(dd).name;
    end
    if ~any(strcmp(inter_names,'Target'))
        continue
    end
    %in case at least one object should be moved but only target was moved
    if length(object_inetaction_data)<2 && sum(interaction_flag) > 0
        continue
    end
    
    
    %sum_link_lengths used for normalizing distance features of
    %configuration regression
    sum_link_lengths = mean_shoulder_elbow_length + mean_elbow_hand_length;
    
    %collect data of key configurations at gaps/objects
    [key_config_data, approaching_dir , obj_gap_corners,...
        distance_moved] = key_configurations...
        (hand_go_trajectory, elbow_go_trajectory, shoulder_go_trajectory,neck_go_trajectory,...
        gabs_flag_go,gab_rectangles,row_heights,interaction_flag,...
        scene_objects,object_inetaction_data,sum_link_lengths );
    
    
    %save the processed version of pick_push_info
    pick_push_info = pick_push_info_for_segment;
    
    
    

    
    %saving filename
    fname = fullfile(save_dir , trial_name);
    save(fname,'scene_objects',...
        'gab_rectangles','row_heights','gabs_flag_go','gabs_flag_return',...
        'interaction_flag','pick_push_info','hand_trajectory_info',...
        'elbow_trajectory_info','shoulder_trajectory_xy','goal_reach_id',...
        'key_config_data','approaching_dir','obj_gap_corners',...
        'distance_moved','start_pos','moved_object_names',...
        'mean_shoulder_elbow_length','mean_elbow_hand_length',...
        'neck_trajectory_xy','hand_trajectory_xy','elbow_trajectory_xy')
end










      
 