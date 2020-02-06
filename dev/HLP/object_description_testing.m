
function [object_features, neighbor_space_features,target_overlap ] = ...
    object_description_testing(N_object_features,...
    scaling_factor,obj_rect_cent_format,target_rect_cent_format, hand_pos,...
    table_diag,virtual_objects)

% objects_cent_format is in center-format
% object_bl_format is in bottom-left MATLAB format

%target rectangle
target_rect_bl_format = to_matlab_rectangles(target_rect_cent_format);
target_center = target_rect_cent_format(1:2);

%start and end points of target in x-direction
S_target = target_rect_bl_format(1);
E_target = S_target+target_rect_bl_format(3);

% obj_cent_format includes object rectangles without the target object
obj_rect_bl_format = to_matlab_rectangles(obj_rect_cent_format);

%object_centers after excluding target
object_centers = obj_rect_cent_format(:,1:2);

%NORMALIZED object diagonals
object_diagonals = ((obj_rect_cent_format(:,3).^2 + ...
                             obj_rect_cent_format(:,4).^2).^0.5)/table_diag;

object_bl_format = to_matlab_rectangles(obj_rect_cent_format);                         
N_objects = size(obj_rect_cent_format,1);


 %the hand is assumed to be at the given hand_pos
    pos_end_ef = hand_pos;
    
%line from start to target
% start_target_line = [pos_end_ef; target_center];


%Iterate on the given objects 
object_features = zeros(N_objects , N_object_features);
for ii = 1:N_objects
    
   
    
    %NORMALIZED distance between object and starting point centers
    dist_hand = ((sum((object_centers(ii,:)-pos_end_ef).^2))^0.5)/table_diag;
    
    %NORMALIZED distance between object and target centers
    dist_target = ((sum((object_centers(ii,:)-target_center).^2))^0.5)/table_diag;
    
    %NORMALIZED object diagonal
    %NORMALIZED object diagonal
    obj_diag = object_diagonals(ii,:);
    
%     %computing orientation of a straight line from hand to object atan2(Y,X)
    dx_start = object_centers(ii,1)-pos_end_ef(1); 
    dy_start = object_centers(ii,2)-pos_end_ef(2);
    theta_start = atan2(dy_start,dx_start);
%     
%     %computing orientation of a straight line from object to target
    dx_target = object_centers(ii,1) - target_center(1) ;
    dy_target = object_centers(ii,2) - target_center(2) ;
    theta_target = atan2(dy_target,dx_target);
    
    %intersection of normal from gap cent to start-target line
%     intersec_pnt = perpendicular_to_line(start_target_line,object_centers(ii,:));
%     perp_dist = (sum((intersec_pnt - object_centers(ii,:)).^2))^0.5;
    
    %feature vector
    object_features(ii,:) = [dist_hand dist_target obj_diag  theta_start theta_target];
%     object_features(ii,:) = [dist_hand+dist_target obj_diag  ]/table_diag; %perp_dist
    
    
    
end


%compute the amount of free space around objects NORMALIZED by area
direction_required_flag = 0;
neighbor_space_features = zeros(N_objects , 1);
neighbor_rect = zeros( 8 , 4 ,N_objects );

%When deciding which object to select, Target object should be excluded
%from the occluding objects to prevent the classifier from rejecting objects 
%near to target. This obj_bl_format doesn't include the target
all_occluding_objects = [obj_rect_bl_format; virtual_objects];

for ii = 1 : N_objects
    [neighbor_free_space, neighbor_rect(:,:,ii),~] = compute_neighbor_space...
        (object_bl_format(ii,:) , all_occluding_objects,...
        scaling_factor,direction_required_flag);
    neighbor_space_features(ii,:) = neighbor_free_space;
end

%horizonal overlap with target NORMALIZED by table diagonal
target_overlap = zeros(N_objects,1);
for ii = 1 : N_objects
    S_object = object_bl_format(ii,1);
    E_object = S_object + object_bl_format(ii,3);
    target_overlap(ii,:) = (lines_overlap(S_object,E_object,S_target,E_target))/table_diag;
end

end


