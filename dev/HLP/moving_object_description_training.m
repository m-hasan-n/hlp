

function [object_features,neighbor_space_features,target_overlap, object_moving_flag] = ...
    moving_object_description_training(scene_objects_arr,pick_push_info, N_object_feat,...
    scaling_factor,  start_pos,row_heights,interaction_flag,selected_gap,...
    table_diag, scene_objects_names,virtual_objects,hand_width)


%object rectangles in Matlab rectangles format
%x,y of bottom left and w,h
scene_object_rectangles = to_matlab_rectangles(scene_objects_arr);

%Target info
target_center = [scene_objects_arr(1,1) scene_objects_arr(1,2)];
%start and end points of target in x-direction
S_target = scene_object_rectangles(1,1);
E_target = S_target+scene_object_rectangles(1,3);

%after getting target information, exclude target from these arrays
scene_objects_arr(1,:) = [];
scene_object_rectangles(1,:) = [];
scene_objects_names(1,:) = [];

%TO which row each object belongs?
object_centers = scene_objects_arr(:,1:2);
N_objects = size(object_centers,1);
N_rows = length(row_heights);
obj_center_heights = object_centers(:,2);
obj_row_ids = zeros(N_objects,1);
for ii = 1 : N_rows
    ids = abs(obj_center_heights-row_heights(ii))<=1e-5;
    obj_row_ids(ids,1)=ii;
end

%which objects were actually moved?
moved_object_names = unique(pick_push_info(:,4));   
object_moving_flag = zeros(N_objects,1);
for ii=1:size(moved_object_names,1)
    object_moving_flag(strcmp(scene_objects_names , table2cell(moved_object_names(ii,1))))=1;
end


%centers of selected objects excluding the traget
% selected_obj_centers = object_centers(logical(object_moving_flag),:);

%NORMALIZED object diagonals
object_diagonals = (scene_objects_arr(:,3).^2 + scene_objects_arr(:,4).^2).^0.5;

% location of the end effector (HAND) FIXED at start_pos
pos_end_ef = start_pos;


%line from start to target
% start_target_line = [start_pos; target_center];


%Iterate on scene objects but exclude target
object_features = zeros(N_objects , N_object_feat);
for ii = 1:N_objects
    
%     % location of the end effector (HAND) depends on which row the gab exists
%     if obj_row_ids(ii)==1
%         %before first row, end effector is at the starting location
%         pos_end_ef = start_pos;
%     else
%         %before second row, end effector is at the selected gap/object 
%         %in first row based on the interaction decision there 
%         if interaction_flag(1)==1
%             %hand was at an object center
%             pos_end_ef = selected_obj_centers(1,:);
%         else
%             %hand was at a gap center
%             gap_first_row = selected_gap;
%             %gaps are given in MATLAB rectangle format so center is calculated
%             pos_end_ef_X = gap_first_row(1) + gap_first_row(3)/2;
%             pos_end_ef_Y = gap_first_row(2) + gap_first_row(4)/2;
%             pos_end_ef = [pos_end_ef_X  pos_end_ef_Y];
%         end
%         
%     end
    
    %NORMALIZED distance between object and starting point centers
    dist_hand = ((sum((object_centers(ii,:)-pos_end_ef).^2))^0.5)/table_diag;
%     dist_start = (sum((scene_objects_arr(ii,1:2)-start_pos).^2))^0.5;
    
    
    %NORMALIZED distance between object and target centers
    dist_target = ((sum((object_centers(ii,:)-target_center).^2))^0.5)/table_diag;
    
    %difference in width from end effector
%     width_diff_ef = scene_objects_arr(ii,3)- hand_width;
    
    %NORMALIZED object diagonal
    obj_diag = (object_diagonals(ii,:) )/table_diag; %- hand_width
    
%     %computing orientation of a straight line from hand to object atan2(Y,X)
    dx_start = object_centers(ii,1)-pos_end_ef(1); 
    dy_start = object_centers(ii,2)-pos_end_ef(2);
    theta_start = atan2(dy_start,dx_start);
%     
%     %computing orientation of a straight line from object to target
    dx_target = object_centers(ii,1) - target_center(1) ;
    dy_target = object_centers(ii,2) - target_center(2);
    theta_target = atan2(dy_target,dx_target);
    
%      %intersection of normal from gap cent to start-target line
%     intersec_pnt = perpendicular_to_line(start_target_line,object_centers(ii,:));
%     perp_dist = (sum((intersec_pnt - object_centers(ii,:)).^2))^0.5;
    
    %feature vector
    object_features(ii,:) = [dist_hand dist_target obj_diag  theta_start theta_target]; % theta_start theta_goal  width_diff_ef theta_start+theta_goal theta_start theta_goal  gaps_overlap(ii)
%     object_features(ii,:) = [dist_hand+dist_target obj_diag  ]/table_diag; %perp_dist
end

%compute the amount of free space around objects "NORMALIZED" 
direction_required_flag = 0;
neighbor_space_features = zeros(N_objects , 1);
neighbor_rect = zeros( 8 , 4 ,N_objects );
all_occluding_objects = [scene_object_rectangles;virtual_objects];

for ii = 1 : length(scene_object_rectangles)
    [neighbor_free_space, neighbor_rect(:,:,ii),~] = compute_neighbor_space...
        (scene_object_rectangles(ii,:) , all_occluding_objects,...
        scaling_factor,direction_required_flag);
    neighbor_space_features(ii,:) = neighbor_free_space;
end

%horizonal overlap with target NORMALIZED by table diagonal
target_overlap = zeros(N_objects,1);
for ii = 1 : N_objects
    S_object = scene_object_rectangles(ii,1);
    E_object = S_object + scene_object_rectangles(ii,3);
    target_overlap(ii,:) = (lines_overlap(S_object,E_object,S_target,E_target))/table_diag;
end
