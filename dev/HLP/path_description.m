

function path_features =  path_description(current_rectangle, ...
    gap_objects_second_row, all_occluding_objects,gaps_objects_second_flag,...
    start_pos, target_center,target_width,table_diagonal, gap_object_first_flag,...
    link_region,scan_resolution)


%number of gaps and objects at second row
N_gaps_objects = size(gap_objects_second_row,1);

%distance feature
% dist_feature = abs(gap_objects_second_row(:,1:2)-current_rectangle(:,1:2))/...
%     table_diagonal;


dist_feature =  abs(gap_objects_second_row(:,1)-current_rectangle(:,1))/...
    table_diagonal;
%orientation features
% dx = gap_objects_second_row(:,1)-current_rectangle(:,1);
% dy = gap_objects_second_row(:,2)-current_rectangle(:,2);
% orient_feature = atan2(dy,dx);

% alternatice way to compute segments' orientation as the angle betrween
% each segment and the line connecting start to target
% start_target_line = [start_pos;target_center];
dy_start_target = target_center(2) - start_pos(2);
dx_start_target = target_center(1) - start_pos(1);
m_start_target = dx_start_target/dy_start_target;

orient_feature = zeros(N_gaps_objects,1);
% for ii = 1 : N_gaps_objects
%     %segment
%     line_segment = [current_rectangle(:,1:2);gap_objects_second_row(ii,1:2)];
%     %intersection between segment and start-to-target line
%     intersect_point = two_lines_intersection(start_target_line,line_segment);
%     %if parallel then no intersection
%     if isempty(intersect_point)
%         orient_feature(ii)= 0;
%     else
%         %vectors from intersection to target and destination gap/object
%         to_target = [intersect_point;target_center];
%         to_gap_object = [intersect_point;gap_objects_second_row(ii,1:2)];
%         
%         %angle between two vectors
%         orient_feature(ii)= line_angles(to_target,to_gap_object);
%     end
% end
% 
% 

for ii = 1 : N_gaps_objects
    %segment
    line_segment = [current_rectangle(:,1:2);gap_objects_second_row(ii,1:2)];
    dy = line_segment(2,2) - line_segment(1,2);
    dx = line_segment(2,1) - line_segment(1,1);
    
    m_seg = dx/dy;
    orient_feature(ii) = m_seg - m_start_target;
    
%     start_pnt = line_segment(1,:);
%     end_pnt = line_segment(2,:);
%     
%     intersect_start_pnt = perpendicular_to_line(start_target_line,start_pnt);
%     perp_dist_start = (sum((intersect_start_pnt - start_pnt).^2))^0.5;
%     
%     intersect_end_pnt = perpendicular_to_line(start_target_line,end_pnt);
%     perp_dist_end = (sum((intersect_end_pnt - end_pnt).^2))^0.5;
%     orient_feature(ii) = perp_dist_start + perp_dist_end;
end


%horizonal overlap between the dx and target center
target_segment = [target_center(1)-target_width target_center(1)+target_width];
overlap_feat = zeros(N_gaps_objects,1);
for ii = 1 : N_gaps_objects
    line_segment = [current_rectangle(1:2); gap_objects_second_row(ii,1:2)]; 
    x_segment = [min(line_segment(:,1))  max(line_segment(:,1))];
    overlap_feat(ii) = lines_overlap(x_segment(1), x_segment(2),...
        target_segment(1), target_segment(2) )/table_diagonal; 
end


%if the source is an object, exclude it from occluding objects
if gap_object_first_flag == 1
    all_occluding_objects = remove_rectangle_from_list...
        (current_rectangle,all_occluding_objects);
end
    
%iterate on all paths starting from the current position to all
%objects/gaps at the second row
%find overlap between the region around HAND path and the occluding objects
hand_path_collision = zeros(N_gaps_objects,1);
line_region_start = link_region/2;
line_region_end = link_region/2;
flip_trig = 0;

for ii = 1 : N_gaps_objects
    
    line_segment = [current_rectangle(1:2); gap_objects_second_row(ii,1:2)];
    occluding_objects = all_occluding_objects;
    %if the destination is an object, exclude it from occluding objects
    if gaps_objects_second_flag(ii) == 1 
        occluding_objects = remove_rectangle_from_list...
        (gap_objects_second_row(ii,:),occluding_objects);
    end
    dd = diff(line_segment);
    line_orient = atan2(dd(2),dd(1));
    hand_path_collision(ii,:) = overlap_arbitrary_line_rectangle...
        (line_segment, line_region_start,line_region_end ,...
        occluding_objects, scan_resolution,line_orient,flip_trig);
end


path_features = [dist_feature(:,1) orient_feature hand_path_collision overlap_feat];

end




