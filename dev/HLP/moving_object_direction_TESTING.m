

%this is the Testing (not training) version

function [neighbor_space_features, hand_to_obj_dir , target_to_obj_dir] =...
    moving_object_direction_TESTING(objects_cent_format,...
    selected_object_cent_format, hand_position, scaling_factor,...
    virtual_objects, target_rect_cent_format)


% transform rectangles into bottom-left MATLAB format 
objects_bl_rectangles = to_matlab_rectangles(objects_cent_format);
moved_objects = to_matlab_rectangles(selected_object_cent_format);
target_rect_bl_format = to_matlab_rectangles(target_rect_cent_format);


%neighbor_space_features of the given objects
N_objects = size(moved_objects, 1);
neighbor_space_features = zeros(N_objects , 8);

hand_to_obj_dir = strings([N_objects , 1]);
target_to_obj_dir  = strings([N_objects , 1]);

%Target should be included here as an occluding object to avoid moving an
%object in a direction blocking the target
all_occluding_objects = [target_rect_bl_format; objects_bl_rectangles; virtual_objects];
%a flag tells the function that features should be returned for each direction
direction_return_flag = 1;

%iterate on all moved objects need to estimate their moving direction
for ii = 1 : N_objects
    
    [neighbor_space, ~,~] = compute_neighbor_space...
        (moved_objects(ii,:) , all_occluding_objects, scaling_factor,...
        direction_return_flag);
    
    neighbor_space_features(ii,:) = neighbor_space';
    
    %direction from hand to object
    hand_trajectory_segment = [hand_position(1) hand_position(2);moved_objects(ii,1) moved_objects(ii,2)];
    hand_to_obj_dir(ii) = line_orientation_discrete(hand_trajectory_segment);
    
    %direction from object to target
    obj_target_segment = [moved_objects(ii,1) moved_objects(ii,2);target_rect_bl_format(1) target_rect_bl_format(2)];
    target_to_obj_dir(ii)= line_orientation_discrete(obj_target_segment);
end



















