
% TRAINING CASE ONLY

function [neighbor_space_features, hand_to_obj_dir, objects_moving_dir,target_to_obj_dir] =...
    moving_object_direction(objects_cent_format,pick_push_info,...
    scaling_factor,subject_id,trial_name,trials_base_dir,...
    approaching_dir,interaction_flag,scene_objects_names,virtual_objects)


% transform objects table into a numeric array excluding the name of the object
objects_bl_format =to_matlab_rectangles(objects_cent_format);

%Traget rectangle
target_rect = objects_bl_format(1,:);

%After getting target information, exclude the traget entry
objects_bl_format(1,:) = [];
scene_objects_names(1,:) = [];
N_objects = size(objects_bl_format,1);

%which objects were moved?
moved_object_names = unique(pick_push_info(:,4));

object_moving_flag = zeros(N_objects,1);
for ii=1:size(moved_object_names,1)
    object_moving_flag(strcmp(scene_objects_names , table2cell(moved_object_names(ii,1))))=1;
end

%compute the amount of free space around the moved objects
moved_object_ids = find(object_moving_flag);
N_moved_objects = length(moved_object_ids);


%excluding target
neighbor_space_features = zeros(N_moved_objects , 8);
neighbor_rect = zeros( 8 , 4 ,N_moved_objects );
moved_object_rect= zeros(N_moved_objects , 4);
direction_required_flag = 1;
all_occluding_objects = [objects_bl_format;virtual_objects];

for ii = 1 : N_moved_objects
    
    moved_object_rect(ii,:) = objects_bl_format(moved_object_ids(ii),:);
    
    [neighbor_space, neighbor_rect(:,:,ii),neighbor_names] = ...
        compute_neighbor_space (moved_object_rect(ii,:) , ...
        all_occluding_objects, scaling_factor, direction_required_flag);
    
    neighbor_space_features(ii,:) = neighbor_space';
end


%interaction_flags    size(approaching_dir)
%[0 0]             4 start,gap,gap,target
%[0 1]   [1 0]     5 start,approach,move, gap (or gap approach,move),target
%[1 1]             6 start,approach,move,approach,move,target

if sum(interaction_flag)==2
    hand_to_obj_dir(1,:) = approaching_dir(2,:);
    hand_to_obj_dir(2,:) = approaching_dir(4,:);
else
    if interaction_flag(1)==1
        hand_to_obj_dir(1,:) = approaching_dir(2,:);
    elseif interaction_flag(2)==1
        hand_to_obj_dir(1,:) = approaching_dir(3,:);
    end 
end

%find the groundtruth of the direction of moving the object, 
%the hand_to_object direction and target_to_object direction
objects_moving_dir = strings([N_moved_objects , 1]);
% hand_to_obj_dir = strings([length(moved_object_ids)-1 , 1]);
target_to_obj_dir  = strings([N_moved_objects , 1]);

for ii = 1 : N_moved_objects
    
    %object dimensions
    object_x = moved_object_rect(ii,1);
    object_y = moved_object_rect(ii,2);
    object_w = moved_object_rect(ii,3);
    object_h = moved_object_rect(ii,4);
   
    %direction from object to target
    obj_target_segment = [object_x object_y;target_rect(1) target_rect(2)];
        target_to_obj_dir(ii)= line_orientation_discrete(obj_target_segment);
        
    %read the interaction data for this moved object
    object_name = char(scene_objects_names(moved_object_ids(ii)));
%     interaction_table = readtable(fullfile([trials_base_dir '/P' num2str(subject_id)],...
%         [  '/S001/new_structure/' trial_name '/movement/' object_name  '_movement_' trial_name '.csv']));
    
    interaction_table = readtable(fullfile([trials_base_dir '/ICRA' sprintf('%02d',subject_id)],...
        [  '/S001/new_structure/' trial_name '/movement/' object_name  '_movement_' trial_name '.csv']));
    
    %timestamp, x and z information
    time_space_interaction = table2array(interaction_table(:,[1 2 4]));
    
    final_x = time_space_interaction(end,2);
    final_y = time_space_interaction(end,3);
    final_rect = [final_x-object_w/2  final_y-object_h/2  object_w  object_h];
    
    %moving direction is the neighboring direction having max. overlap
    %after moving
    objects_moving_dir(ii,:) = find_moving_direction(neighbor_rect(:,:,ii),final_rect,neighbor_names);  
    
end


end


