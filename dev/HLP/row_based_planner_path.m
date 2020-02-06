

%similar to function "row_based_planner"
%but adding the path classifier and excluding interaction classifier

function [best_start_keypoints, best_end_keypoints,best_start_config,...
    best_estimated_config, best_estimated_arm_joints,original_segment_responses,...
    original_gaps_resp,original_objects_resp,best_estimated_action_type] = row_based_planner_path...
    (row_gap_ids, row_obj_ids, object_rect_cent_format,target_rect_cent_format,gab_rectangles,...
    start_pos,gaps_classifier,objects_classifier,...
    object_dir_classifier,arm_config_regressor,hand_width, N_gap_features,...
    table_diagonal,N_object_features, scaling_factor, virtual_objects,...
    starting_config,shoulder_elbow_length,elbow_hand_length, path_classifier,...
    target_width,starting_arm_joints, link_region,scan_resolution)




%segments connect gaps and objects from a row to the next row
%gap and object classifiers select gaps and objects at rows
%segments connect the accepted gaps and objects
%segment calssifier evaluates each segment and accept/reject it
%this function returns the accepted segments with their scores  
hand_position = start_pos;

[original_segment_responses, segment_scores, gaps_objects_first, gaps_objects_second,...
    gaps_objects_first_flag, gaps_objects_second_flag,original_gaps_resp,original_objects_resp]=...
    segment_prediction...
    (path_classifier,gaps_classifier,...
    objects_classifier, gab_rectangles,object_rect_cent_format,...
    row_gap_ids,row_obj_ids,virtual_objects,target_rect_cent_format, hand_position,...
    hand_width, N_gap_features,table_diagonal,N_object_features,scaling_factor,...
    start_pos, target_width,link_region,scan_resolution);


%if no segment was accepted, take the best TWO segments
segment_responses = original_segment_responses;
if sum(segment_responses)== 0
    [~ , sorted_ids] = sort(segment_scores(:));
    segment_responses(sorted_ids(end-1:end))=1;
end


%connect path segments into a path
%estimate the arm configuration at each key-location
%evaluate the arm collision for each path
%select the best path based on collision detection
[best_start_keypoints, best_end_keypoints,best_start_config,...
    best_estimated_config, best_estimated_arm_joints,...
    best_estimated_action_type] = ...
    check_collision_path_segments (segment_responses,gaps_objects_first,...
    start_pos,starting_config,arm_config_regressor,shoulder_elbow_length,...
    elbow_hand_length,gaps_objects_second,starting_arm_joints, target_rect_cent_format,...
    gaps_objects_first_flag,gaps_objects_second_flag, link_region,...
    scan_resolution,object_rect_cent_format, scaling_factor, virtual_objects,...
    object_dir_classifier);



% figure
%  rectangle('Position',to_matlab_rectangles(target_rect_cent_format)*10,...
%             'LineWidth',3)
% 
% hold on
% 
% for ii = 1 : size(object_rect_cent_format,1)
%     rectangle('Position',to_matlab_rectangles(object_rect_cent_format(ii,:))*10,...
%             'LineWidth',3)
% end

% for ii = 1 : size(best_end_keypoints,1)
    
%     rectangle('Position',to_matlab_rectangles(best_end_keypoints(ii,:))*10,...
%             'LineWidth',3,'EdgeColor','r','LineStyle','--') 
    
%     neck_joint = best_estimated_arm_joints.neck(ii,:);
%     shoulder_joint = best_estimated_arm_joints.shoulder(ii,:);
%     elbow_joint = best_estimated_arm_joints.elbow(ii,:);
%     hand_joint=best_estimated_arm_joints.hand(ii,:);
    
%     plot_arm_configuration(10*neck_joint,10*shoulder_joint,10*elbow_joint,...
%                         10*hand_joint,best_estimated_config(ii,:), 'blue');    
% end




end


function [path_responses , path_scores,gaps_objects_first,gaps_objects_second,...
    gaps_objects_first_flag,gaps_objects_second_flag,original_gaps_resp,...
    original_objects_resp]=...
    segment_prediction(path_classifier,...
    gaps_classifier,objects_classifier,gab_rectangles,object_rect_cent_format,...
    row_gap_ids,row_obj_ids,virtual_objects,target_rect_cent_format, hand_position,...
    hand_width, N_gap_features,table_diagonal,N_object_features,scaling_factor,...
    start_pos, target_width,link_region,scan_resolution)

%target center
target_center = target_rect_cent_format(1:2);

%gap features descriptors
gap_features = gap_description_testing...
    (gab_rectangles,target_center, hand_position,...
    hand_width, N_gap_features,table_diagonal);

%gaps classification
[original_gaps_resp, gap_score ]= predict(gaps_classifier , gap_features);
gaps_resp = original_gaps_resp;

%object features descriptors
[object_features, neighbor_space_features, target_overlap ]= ...
    object_description_testing(N_object_features,...
    scaling_factor,object_rect_cent_format, target_rect_cent_format, hand_position,...
    table_diagonal, virtual_objects);

%object classifications
[original_objects_resp, object_score ]= predict(objects_classifier , ...
    [object_features, neighbor_space_features, target_overlap]);
objects_resp = original_objects_resp;

%Selected gaps at first row 
%if all gaps were rejected by classifier, selecet the one with max score
first_row_gaps  = gab_rectangles( row_gap_ids == 1 & gaps_resp == 1 ,:); 
if isempty(first_row_gaps)
    [~ , idx] = max(gap_score(row_gap_ids == 1,2));
    gaps_resp(idx)=1;
    first_row_gaps  = gab_rectangles( row_gap_ids == 1 & gaps_resp == 1 ,:); 
end

%gaps in center_format
first_row_gaps = to_rectangles_cent_format (first_row_gaps);

%selected objects at first row
first_row_objects  = object_rect_cent_format( row_obj_ids == 1 & objects_resp == 1,:);
if isempty(first_row_objects)
    [~ , idx] = max(object_score(row_obj_ids == 1,2));
    objects_resp(idx)=1;
    first_row_objects  = object_rect_cent_format( row_obj_ids == 1 & objects_resp == 1 ,:); 
end

%combine accepted gaps and objects at first row
gaps_objects_first = [first_row_gaps;first_row_objects];


%gaps and objects at second row
second_row_gaps  = gab_rectangles( row_gap_ids == 2 & gaps_resp == 1 ,:); 
if isempty(second_row_gaps)
    second_row_ids = find(row_gap_ids == 2);
    [~ , idx] = max(gap_score(row_gap_ids == 2,2));
    gaps_resp(second_row_ids(idx))=1;
    second_row_gaps  = gab_rectangles( row_gap_ids == 2 & gaps_resp == 1 ,:); 
end
second_row_gaps = to_rectangles_cent_format (second_row_gaps);



second_row_objects  = object_rect_cent_format( row_obj_ids == 2 & objects_resp == 1,:);
if isempty(second_row_objects)
    second_row_ids = find(row_obj_ids == 2);
    [~ , idx] = max(object_score(row_obj_ids == 2,2));
    objects_resp(second_row_ids(idx))=1;
    second_row_objects  = object_rect_cent_format( row_obj_ids == 2 & objects_resp == 1 ,:); 
end

%combine gaps and objects at second row
gaps_objects_second = [second_row_gaps;second_row_objects];
gaps_objects_second_flag = [zeros(size(second_row_gaps,1),1) ; ones(size(second_row_objects,1),1)];
gaps_objects_first_flag = [zeros(size(first_row_gaps,1),1) ; ones(size(first_row_objects,1),1)];

%path description
path_responses = zeros(size(gaps_objects_first,1),size(gaps_objects_second,1));
path_scores = zeros(size(gaps_objects_first,1),size(gaps_objects_second,1));

%occluding objects are used here to estimate the collision probability of
%each segment/path. Target is excluded from occluding objects since
%interaction with target shouldn't be a collision
%also bottom wall of the table (last entry)is removed from virtual_objects
virtual_objects(end,:)=[];
occluding_objects = [object_rect_cent_format;virtual_objects];

for ii = 1 : size(gaps_objects_first,1)
    
    path_features =  path_description(gaps_objects_first(ii,:),...
        gaps_objects_second,occluding_objects,gaps_objects_second_flag,...
        start_pos, target_center,target_width,table_diagonal,...
        gaps_objects_first_flag(ii),link_region,scan_resolution);
    
    [path_predictions, classif_scores ] = predict(path_classifier , path_features);
    path_responses(ii,:) = path_predictions';
    path_scores(ii,:) = classif_scores(:,2)';
end



end


function [best_start_keypoints, best_end_keypoints,best_start_config,...
    best_estimated_config, best_estimated_arm_joints,...
    best_estimated_action_type] = ...
    check_collision_path_segments (path_responses,gaps_objects_first,...
    start_pos,starting_config,arm_config_regressor,shoulder_elbow_length,...
    elbow_hand_length,gaps_objects_second,starting_arm_joints,target_rect_cent_format,...
    gaps_objects_first_flag,gaps_objects_second_flag,...
    link_region,scan_resolution,object_rect_cent_format, scaling_factor,...
    virtual_objects, object_dir_classifier)


%remove bottom wall of table from virtual objects
virtual_objects(end,:)=[]; 

%find the accepted path candidates (segment combinations)
[I , J] = find(path_responses);

%construct the keypoints list
[ start_lists, estimated_lists,start_flag_lists, estimated_flag_lists] =...
    paths_keypoint_lists(I,J,start_pos,...
    gaps_objects_first,object_rect_cent_format, scaling_factor, virtual_objects,...
    object_dir_classifier,gaps_objects_first_flag,gaps_objects_second,...
    gaps_objects_second_flag,target_rect_cent_format);


%all the occluding objects (without target since it is not an obstacle)
all_occluding_objects = [object_rect_cent_format;virtual_objects];

N_paths = length(I);

%find the best path in terms of collision detection
%test the collision of each path after knowing its keypoints
%and estimating the arm configurations at each keypoint
[best_start_keypoints, best_end_keypoints,best_start_config,...
    best_estimated_config, best_estimated_arm_joints,...
    best_estimated_action_type] = ...
    path_configurations_collision(start_lists, ...
    estimated_lists,start_flag_lists, estimated_flag_lists,...
    N_paths, starting_config,arm_config_regressor,shoulder_elbow_length,...
    elbow_hand_length,starting_arm_joints,all_occluding_objects,...
    link_region,scan_resolution);









end


%Construct a list of key points for each path
function [ start_lists, estimated_lists,start_flag_lists,...
    estimated_flag_lists,estimated_obj_dir_list] = ...
    paths_keypoint_lists(I,J,start_pos, gaps_objects_first,...
    object_rect_cent_format, scaling_factor, virtual_objects,...
    object_dir_classifier,gaps_objects_first_flag,gaps_objects_second,...
    gaps_objects_second_flag,target_rect_cent_format)

%iterate on all accepted segments for each path
for ii = 1 : length(I)
    
    starting_rectangles =[ [start_pos 0 0]; gaps_objects_first(I(ii),:);gaps_objects_second(J(ii),:)];
    starting_flags = [0;gaps_objects_first_flag(I(ii));gaps_objects_second_flag(J(ii))];
    
    estimated_rectangles = [gaps_objects_first(I(ii),:);gaps_objects_second(J(ii),:);target_rect_cent_format];
    estimated_flags = [gaps_objects_first_flag(I(ii));gaps_objects_second_flag(J(ii));0];
    
    
    
    pntr = 1;
    hand_position = start_pos;
    go_on = 1;
    
    while (go_on ==1)
        
        %if the estimated position is for an object
        if estimated_flags(pntr)==1
            
            selected_object = estimated_rectangles(pntr,:);
            
            %estimate object moving direction
            %object direction features
            [neighbor_space_features, hand_to_obj_direction , target_to_obj_direction] =...
                moving_object_direction_TESTING(object_rect_cent_format,selected_object ,...
                hand_position, scaling_factor, virtual_objects,target_rect_cent_format);
            
            feats_table = [array2table(neighbor_space_features)...
                array2table(hand_to_obj_direction) array2table(target_to_obj_direction)];
            
            %object direction classifier
            [dir_resp, ~ ]= predict(object_dir_classifier, feats_table);
           
            
            %move object to the estimated direction
            new_obj_rect = object_location_movement(selected_object , char(dir_resp), scaling_factor);
            
            %insert the new object location into the lists
            estimated_rectangles = [estimated_rectangles(1:pntr,:);new_obj_rect;estimated_rectangles(pntr+1:end,:)];
            starting_rectangles = [starting_rectangles(1:pntr+1,:); new_obj_rect;starting_rectangles(pntr+2:end,:)];
            
            %although the new entry is of an object but we set its flag to
            %zero so that it is not removed from occluding objects when
            %detecting the collision. Original objects locations are safe
            %to remove from occluding if they are the destination location
            %but these new location changes the environment so it is safe
            %to be included as an occlusion by setting its flag to zero.
            estimated_flags = [estimated_flags(1:pntr,:); 0 ; estimated_flags(pntr+1:end,:)];
            starting_flags = [starting_flags(1:pntr+1,:);0;starting_flags(pntr+2:end,:)];
            
            hand_position = new_obj_rect(1:2);
            pntr = pntr  + 2;
            
        else
            pntr = pntr  + 1;
            hand_position = starting_rectangles(pntr,1:2);
        end
        
        %stoping condition of the WHILE loop
        if pntr == size(estimated_rectangles,1)
            go_on = 0;
        end
    end
    
    
   start_lists{ii,1} =  starting_rectangles;
   estimated_lists{ii,1} = estimated_rectangles; 
   start_flag_lists{ii,1} =  starting_flags;
   estimated_flag_lists{ii,1} = estimated_flags;
   
end

end


%find the best path
%test the collision of each path after knowing its keypoints
%by estimating the arm configurations at each keypoint
function [best_start_keypoints, best_end_keypoints,...
    best_start_config, best_estimated_config, best_estimated_arm_joints,...
    best_estimated_action_type] = ...
    path_configurations_collision...
    (start_lists, estimated_lists,start_flag_lists, estimated_flag_lists,...
    N_paths, arm_starting_config,arm_config_regressor,shoulder_elbow_length,...
    elbow_hand_length,starting_arm_joints,all_occluding_objects,...
    link_region,scan_resolution)

% clrs = ['r','g','b','m','y'];

arm_collision_features = zeros(N_paths,1);


for ii = 1 : N_paths
    
    initial_rectangles = start_lists{ii};
    estimated_rectangles = estimated_lists{ii};
    
    initial_pos_obj_gap_flag =   start_flag_lists{ii};
    estimated_pos_obj_gap_flag = estimated_flag_lists{ii};
    
    current_config = arm_starting_config;
    current_elbow=starting_arm_joints.elbow; 
    current_shoulder = starting_arm_joints.shoulder;
    current_hand=starting_arm_joints.hand;
    current_neck = starting_arm_joints.neck;
    
    occluding_objects = all_occluding_objects;
    
    N_segments = size(initial_rectangles,1);
    starting_config = zeros(N_segments,2);
    estimated_config= zeros(N_segments,2);
    estimated_neck = zeros(N_segments,2);
    estimated_shoulder = zeros(N_segments,2);
    estimated_elbow = zeros(N_segments,2);
    estimated_hand = zeros(N_segments,2);
    
    for jj = 1 : N_segments
        
        starting_config(jj,:) = current_config;
        %estimate the next arm configuration
        [next_config, next_elbow,  next_shoulder, next_hand, next_neck ]= estimate_arm_config...
        (initial_rectangles(jj,1:2),estimated_rectangles(jj,1:2), current_config, arm_config_regressor,...
                shoulder_elbow_length,elbow_hand_length);
        
        estimated_neck(jj,:) = next_neck;
        estimated_shoulder(jj,:) = next_shoulder;
        estimated_elbow(jj,:) = next_elbow;
        estimated_hand(jj,:) = next_hand;
        estimated_config(jj,:) = next_config;   
        
        %plot
%         rectangle('Position',to_matlab_rectangles(estimated_rectangles(jj,:))*10,...
%             'LineWidth',3,'EdgeColor',clrs(ii),'LineStyle','--')
        
        if initial_pos_obj_gap_flag(jj) == 1 
            occluding_objects = remove_rectangle_from_list...
                (initial_rectangles(jj,:),occluding_objects);
        end
        if estimated_pos_obj_gap_flag(jj) == 1 
            occluding_objects = remove_rectangle_from_list...
                (estimated_rectangles(jj,:),occluding_objects);
        end
    
        if N_paths > 1
            %evaluate the collision of arm links with surrounding objects
            arm_collision = arm_collision_measure(current_config, current_elbow, current_shoulder,...
                current_hand,current_neck, next_config,next_elbow,  next_shoulder,...
                next_hand, next_neck,occluding_objects, link_region,scan_resolution);
            
            arm_collision_features(ii) = arm_collision_features(ii) + arm_collision;
        end
%         rectangle('Position',to_matlab_rectangles(estimated_rectangles(jj,:))*10,...
%             'LineWidth',3,'EdgeColor',clrs(ii),'LineStyle','--')

        %update
        current_config = next_config;
        current_elbow = next_elbow;  
        current_shoulder = next_shoulder; 
        current_hand = next_hand;
        current_neck = next_neck;
    end
    
    starting_config_lists{ii} = starting_config;
    estimated_config_lists{ii} = estimated_config;
    estimated_arm_joints(ii).neck = estimated_neck;
    estimated_arm_joints(ii).shoulder = estimated_shoulder;
    estimated_arm_joints(ii).elbow = estimated_elbow;
    estimated_arm_joints(ii).hand = estimated_hand;
    %0: gap 1: push object
    estimated_action_type{ii} = estimated_pos_obj_gap_flag;
    
end

if N_paths > 1
    [~ , path_id] = min(arm_collision_features);
    best_start_keypoints = start_lists{path_id};
    best_end_keypoints = estimated_lists{path_id};
    best_start_config = starting_config_lists{path_id};
    best_estimated_config = estimated_config_lists{path_id};
    best_estimated_arm_joints = estimated_arm_joints(path_id);
    best_estimated_action_type = estimated_action_type{path_id};
    
else
    best_start_keypoints = initial_rectangles; 
    best_end_keypoints = estimated_rectangles;
    best_start_config = starting_config;
    best_estimated_config = estimated_config;
    best_estimated_arm_joints = estimated_arm_joints(1);
    best_estimated_action_type = estimated_action_type{1};
    
end



end



