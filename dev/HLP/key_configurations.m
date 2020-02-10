


function [key_config_data,approaching_dir , obj_gap_corners,...
    distance_moved]= key_configurations...
    (hand_go_trajectory, elbow_go_trajectory, shoulder_go_trajectory,neck_go_trajectory,...
        gabs_flag_go,gab_rectangles,row_heights,interaction_flag,...
        scene_objects,object_inetaction_data, sum_link_lengths )
    



%object rectangles
scene_object_rectangles = table2array(scene_objects(:,[2 4 5 7]));
scene_object_rectangles =to_matlab_rectangles(scene_object_rectangles);

%plotting
% clf
% for ss =1:length(scene_object_rectangles)
%     rectangle('Position',10*(scene_object_rectangles(ss,:)),'LineWidth',3)
% end
% hold on
% line(10*hand_go_trajectory(:,1) , 10*hand_go_trajectory(:,2));

%configurations at the starting location   
start_time_stamp = 1;
start_config = arm_config (hand_go_trajectory, elbow_go_trajectory, ...
    shoulder_go_trajectory,neck_go_trajectory,start_time_stamp);

%extracting information from object_inetaction_data
[target_times, object_times , selected_objects]...
    = extract_objects_info(object_inetaction_data,scene_objects);



%adjust the gap ids to suit the two rows
%Selected gap ids
selected_gaps = find(gabs_flag_go);
%If one gap at the second row is selected
if ~isempty(selected_gaps) && length(selected_gaps)< 2
    %make selected at first row = 0 and a second entry for second row 
    if selected_gaps > 4
        temp = selected_gaps;
        selected_gaps(1)=0;
        selected_gaps(2)=temp;
    end
end

%if more than 2 gaps were selected, and it Happened!!!
if length(selected_gaps) >  2 && sum(interaction_flag) < 2
    gaps_row_1 = selected_gaps(selected_gaps<5);
    gaps_row_2 = selected_gaps(selected_gaps>4);
    gaps_row_1 = gaps_row_1(1);
    gaps_row_2 = gaps_row_2(1);
    selected_gaps = [gaps_row_1; gaps_row_2];
end


%configurations at the rows
key_config_data = [];
approaching_dir = [];
obj_gap_corners = [];
distance_moved = [];


prev_loc = hand_go_trajectory(1,:);
for ii = 1 : 2
    
    %in case of no interaction
    if interaction_flag(ii)== 0
        gap = gab_rectangles(selected_gaps(ii),:);
        [gap_time_stamp , selected_corner, hand_dir] = tarjectory_intersect_gap...
            (hand_go_trajectory,gap,row_heights(1), ii);
        key_config = arm_config (hand_go_trajectory, elbow_go_trajectory,...
            shoulder_go_trajectory,neck_go_trajectory,gap_time_stamp);
        distance_moved = [distance_moved; (hand_go_trajectory(gap_time_stamp,:) - prev_loc)/sum_link_lengths];
        
        approaching_dir = [approaching_dir;hand_dir];
        key_config_data = [key_config_data;key_config];
        obj_gap_corners = [obj_gap_corners;selected_corner];
        
        
        %update the latest location of hand
        prev_loc = hand_go_trajectory(gap_time_stamp,:);
        
    %in case of interaction
    else
        %approaching the object
        obj_time_stamp = object_times(ii,1);
        obj_rectangle = selected_objects(ii,:);
        
        
        %grasping corner
         selected_corner = find_corner...
            (hand_go_trajectory , obj_time_stamp, obj_rectangle);
        
        %hand approaching direction
        if (ii==1)
            segment_start = 1;
        else
            if interaction_flag(1)== 0
                segment_start = gap_time_stamp;
            else 
                segment_start = object_times(1,2);
            end
        end
        
        %sometimes, errors from VR dataset where times are not consistent
        if segment_start > obj_time_stamp
            segment_start = obj_time_stamp - 20;
        end
        trajectory_segment = hand_go_trajectory(segment_start:obj_time_stamp,:);
        hand_approaching_dir = line_orientation_discrete(trajectory_segment);
        
        %plotting
%         plot_scale =10;
%         text(plot_scale*(obj_rectangle(1) + obj_rectangle(3)/2), plot_scale*(obj_rectangle(2) + obj_rectangle(4)/2) , hand_dir,'FontSize',15)
        
        %configuration
        key_config = arm_config (hand_go_trajectory, elbow_go_trajectory,...
            shoulder_go_trajectory,neck_go_trajectory,obj_time_stamp);
        distance_moved = [distance_moved; (hand_go_trajectory(obj_time_stamp,:) - prev_loc)/sum_link_lengths];
        
        approaching_dir = [approaching_dir;hand_approaching_dir];
        key_config_data = [key_config_data;key_config];
        obj_gap_corners = [obj_gap_corners;selected_corner];
        
        %moving the object
        obj_moving_time_stamp = object_times(ii,2);
        trajectory_segment = hand_go_trajectory(obj_time_stamp:obj_moving_time_stamp,:);
        hand_moving_dir = line_orientation_discrete(trajectory_segment);
        key_config = arm_config (hand_go_trajectory, elbow_go_trajectory,...
            shoulder_go_trajectory,neck_go_trajectory,obj_moving_time_stamp);
        distance_moved = [distance_moved; ...
            (hand_go_trajectory(obj_moving_time_stamp,:) - hand_go_trajectory(obj_time_stamp,:))/sum_link_lengths];
        
        approaching_dir = [approaching_dir;hand_moving_dir];
        key_config_data = [key_config_data;key_config];
        obj_gap_corners = [obj_gap_corners;selected_corner];
        
        %update the latest location of hand
        prev_loc = hand_go_trajectory(object_times(ii,2),:);
    end
    
    
end

%configurations at the target location
if interaction_flag(2)== 0
    target_start_segment = gap_time_stamp;
else
    target_start_segment = object_times(2,2);
end
[target_config,target_approach_dir,target_corner] = target_calculations...
    (hand_go_trajectory, elbow_go_trajectory, shoulder_go_trajectory,...
    neck_go_trajectory,target_times(1),scene_object_rectangles(1,:),target_start_segment);

distance_moved = [0 0;distance_moved; (hand_go_trajectory(end,:) - prev_loc)/sum_link_lengths];
key_config_data = [start_config;key_config_data;target_config];
approaching_dir = ['--' ; approaching_dir ; target_approach_dir];
obj_gap_corners = ['--';obj_gap_corners;  target_corner];

end


%find when hand trajectory intersects a gap compute also the gap corner 
%at intersection and direction of the hand when approaching the gap
function [time_stamp, gap_corner, hand_to_gap_dir ]= tarjectory_intersect_gap...
    (human_trajectory,gap_rectangle, first_row_height, row_id)

%gap coordinates
xmin = gap_rectangle(1);
xmax = xmin + gap_rectangle(3);
ymin = gap_rectangle(2);
ymax = ymin + gap_rectangle(4);

%overlap between line and gap
x_passed = human_trajectory(:,1) > xmin & human_trajectory(:,1) < xmax;
y_passed = human_trajectory(:,2) > ymin & human_trajectory(:,2) < ymax;
xy_passed = x_passed & y_passed;

%min point defines the required intersection
intersection_ids = find(xy_passed);
time_stamp = min(intersection_ids);    

%neighbor space around the object



%gap corners in order
corners_list= [ "BL";"BR"; "TR"; "TL"];
gap_corners = [xmin ymin;xmax ymin;xmax ymax;xmin ymax];

%neares corner to the intersection point
dist_corners = sum((gap_corners - human_trajectory(time_stamp,:)).^2,2) ;
[~ , id_min] = min(dist_corners);
gap_corner = corners_list(id_min,:);

%direction of hand when approaching the object
if (row_id==1)
    segment_start = 1;
else
    %nearest point of trajectory to first row as a starting point
    %rounding first to 2 nearest digits to avoid SHIT!
    human_trajectory = round(human_trajectory*100)/100;
    [~ , segment_start] = min(abs(human_trajectory(:,2) - first_row_height));
end

trajectory_segment = human_trajectory(segment_start:time_stamp,:);
hand_to_gap_dir = line_orientation_discrete(trajectory_segment);

%plotting
% plot_scale = 10;
% text(plot_scale*gap_corners(id_min,1),plot_scale*gap_corners(id_min,2),gap_corner,'FontSize',15)
% text(plot_scale*(xmin + gap_rectangle(3)/2), plot_scale*(ymin + gap_rectangle(4)/2) , hand_to_gap_dir,'FontSize',15)
end


%compute the joint angles at shoulder and elbow joints
function shoulder_elbow_angles = arm_config (hand_trajectory_xy, ...
    elbow_trajectory_xy, shoulder_trajectory_xy,neck_trajectory_xy, time_stamp)

%old: from neck to shoulder, shoulder to elbow and elbow to hand
%This gives: 180 - angle between the two vectors 
% neck_shoulder_line = [neck_trajectory_xy(time_stamp,1:2); shoulder_trajectory_xy(time_stamp,1:2)];
% shoulder_elbow_line = [shoulder_trajectory_xy(time_stamp,1:2);elbow_trajectory_xy(time_stamp,1:2)];
% shoulder_elbow_angles(1) = line_angles(neck_shoulder_line, shoulder_elbow_line);
% 
% elbow_hand_line = [elbow_trajectory_xy(time_stamp,1:2);hand_trajectory_xy(time_stamp,1:2)];
% shoulder_elbow_angles(2) = line_angles(shoulder_elbow_line,elbow_hand_line);

%new: shoulder as an origin so shoulder to neck and shoulder to elbow
%then, elbow as an origin so elbow to shoulder and elbow to hand
% This gives: angle between the two vectors

neck_shoulder_line = [shoulder_trajectory_xy(time_stamp,1:2); neck_trajectory_xy(time_stamp,1:2) ];
shoulder_elbow_line = [shoulder_trajectory_xy(time_stamp,1:2);elbow_trajectory_xy(time_stamp,1:2)];
shoulder_elbow_angles(1) = line_angles(neck_shoulder_line, shoulder_elbow_line);

shoulder_elbow_line = [elbow_trajectory_xy(time_stamp,1:2); shoulder_trajectory_xy(time_stamp,1:2)];
elbow_hand_line = [elbow_trajectory_xy(time_stamp,1:2);hand_trajectory_xy(time_stamp,1:2)];
shoulder_elbow_angles(2) = line_angles(shoulder_elbow_line,elbow_hand_line);


%plotting
% plot_scale = 10;
% h1 = plot(plot_scale*neck_trajectory_xy(time_stamp,1) , plot_scale*neck_trajectory_xy(time_stamp,2),'m s','LineWidth',5);
% h2 = plot(plot_scale*shoulder_trajectory_xy(time_stamp,1) , plot_scale*shoulder_trajectory_xy(time_stamp,2),'b s','LineWidth',5);
% h3 = plot(plot_scale*elbow_trajectory_xy(time_stamp,1),plot_scale*elbow_trajectory_xy(time_stamp,2),'g s','LineWidth',5);
% h4 = plot(plot_scale*hand_trajectory_xy(time_stamp,1),plot_scale*hand_trajectory_xy(time_stamp,2),'r s','LineWidth',5);
% 
% h5 = line([plot_scale*neck_trajectory_xy(time_stamp,1) plot_scale*shoulder_trajectory_xy(time_stamp,1)],[plot_scale*neck_trajectory_xy(time_stamp,2) plot_scale*shoulder_trajectory_xy(time_stamp,2)],'LineWidth',5);
% h6 = line([plot_scale*shoulder_trajectory_xy(time_stamp,1) plot_scale*elbow_trajectory_xy(time_stamp,1)],[plot_scale*shoulder_trajectory_xy(time_stamp,2) plot_scale*elbow_trajectory_xy(time_stamp,2)],'LineWidth',5);
% h7 = line([plot_scale*elbow_trajectory_xy(time_stamp,1) plot_scale*hand_trajectory_xy(time_stamp,1)],[plot_scale*elbow_trajectory_xy(time_stamp,2) plot_scale*hand_trajectory_xy(time_stamp,2)  ],'LineWidth',5);
% 
% h8 = text(plot_scale*shoulder_trajectory_xy(time_stamp,1),plot_scale*shoulder_trajectory_xy(time_stamp,2),num2str(180 - shoulder_elbow_angles(1)*180/pi),'FontSize',15);
% h9 = text(plot_scale*elbow_trajectory_xy(time_stamp,1),plot_scale*elbow_trajectory_xy(time_stamp,2),num2str(180 - shoulder_elbow_angles(2)*180/pi),'FontSize',15);
% 
% h10 = text(plot_scale*shoulder_trajectory_xy(time_stamp,1)-1,plot_scale*shoulder_trajectory_xy(time_stamp,2),num2str(new_shoulder_elbow_angles(1)*180/pi),'FontSize',15,'Color','r');
% h11 = text(plot_scale*elbow_trajectory_xy(time_stamp,1)-1,plot_scale*elbow_trajectory_xy(time_stamp,2),num2str(new_shoulder_elbow_angles(2)*180/pi),'FontSize',15,'Color','r');
% 
% 
% delete(h1); delete(h2); delete(h3); delete(h4)
%     delete(h5); delete(h6); delete(h7); delete(h8); delete(h9);     
end


%find the object's grasping corner used by human
function corner_location  = find_corner(human_trajectory , time_stamp, object_rect)


% % object_contact_point = find_object_contact (object_rect, human_trajectory, time_stamp,scaling_factor);
% object_contact_point = find_object_contact_continous (object_rect, human_trajectory, time_stamp); 

%object coordinates
xmin = object_rect(1);
xmax = xmin + object_rect(3);
ymin = object_rect(2);
ymax = ymin + object_rect(4);





%gap corners in order
corners_list= [ "BL";"BR"; "TR"; "TL"];
obj_corners = [xmin ymin;xmax ymin;xmax ymax;xmin ymax];

%neares corner to the intersection point
dist_corners = sum((obj_corners - human_trajectory(time_stamp,:)).^2,2) ;
[~ , id_min] = min(dist_corners);
corner_location = corners_list(id_min,:);

%plotting
% plot_scale = 10;
% text(plot_scale*obj_corners(id_min,1),plot_scale*obj_corners(id_min,2),corner_location,'FontSize',15)

end

%extracting information from object_inetaction_data
function [target_times, row_object_times , selected_objects] =...
    extract_objects_info(object_inetaction_data,scene_objects)

for ii = 1 : length(object_inetaction_data)
    
    %data of current object
    object_name = object_inetaction_data(ii).name;
    object_times = object_inetaction_data(ii).period;
    obj_id = find(strcmp(table2cell(scene_objects(:,1)) ,object_name ));
    
    %target
    if strcmp(object_name , 'Target')
        target_times = object_inetaction_data(ii).period;
        
    %object at the first row    
    elseif any(strcmp({'FailOnTouchObstacleShort','FailOnTouchObstacleMed',...
            'FailOnTouchObstacleLong'}, object_name))
        row_object_times(1,:) = object_times;
        selected_objects(1,:) = table2array(scene_objects(obj_id,[2 4 5 7]));
        
    %object at the second row    
    elseif any(strcmp({'FailOnTouchObstacleShort-1','FailOnTouchObstacleMed-1',...
            'FailOnTouchObstacleLong-1'}, object_name))
        row_object_times(2,:) = object_times;
        selected_objects(2,:) = table2array(scene_objects(obj_id,[2 4 5 7]));
        
    end
    
end
if ~exist('row_object_times','var')
    row_object_times = [];
    selected_objects = [];
end

end


%target configuration, grasping corner and line's aproaching direction
function [target_config,target_approach_dir,target_corner] = target_calculations...
    (hand_go_trajectory, elbow_go_trajectory, shoulder_go_trajectory,...
    neck_go_trajectory,target_time_stamp,target_rectangle,target_start_segment)

target_time_stamp = min(target_time_stamp,size(hand_go_trajectory,1));
target_config = arm_config (hand_go_trajectory, elbow_go_trajectory, shoulder_go_trajectory,neck_go_trajectory,target_time_stamp);
trajectory_segment = hand_go_trajectory(target_start_segment:target_time_stamp,:);
target_approach_dir = line_orientation_discrete(trajectory_segment);
target_corner = find_corner(hand_go_trajectory , target_time_stamp, target_rectangle);

end


function object_contact_point = find_object_contact_continous...
    (object_rect, human_trajectory, time_stamp)

%object coordinates
xmin = object_rect(1);
xmax = xmin + object_rect(3);
ymin = object_rect(2);
ymax = ymin + object_rect(4);

%bottom_edge line
bottom_edge = [xmin ymin;xmax ymin];
top_edge = [xmin ymax; xmax ymax];
right_edge = [xmax ymin;xmax ymax];
left_edge=[xmin ymin;xmin ymax];

%contact_point
contact_x = human_trajectory(time_stamp,1);
contact_y = human_trajectory(time_stamp,2);

%contact point is at bottom or top edges
if contact_x >= xmin && contact_x <= xmax
    %bottom
    if contact_y <= ymin
        obj_edge =  bottom_edge;
        idx = 1;
    else
        %top
        obj_edge = top_edge;
        idx = 2;
    end
else
    %right
    if contact_x >= xmax
        obj_edge = right_edge;
        idx = 3;
    else
        %left
        obj_edge = left_edge;
        idx = 4;
    end
    
end

%perpindicular from contact_point to the object edge
perp_intersection = perpendicular_to_line(obj_edge,[contact_x contact_y]);

%continous value of the perpindicular intersection point within the edge
dd = diff(obj_edge);
edge_length = (sum(dd.^2)).^0.5;

%if it is top or bottom
if dd(1) ~=0
    continous_value = (perp_intersection(1) - xmin)/edge_length;
else
    continous_value = (perp_intersection(2) - ymin)/edge_length;
end

object_contact_point = [0 0 0 0];
object_contact_point(idx) = continous_value;
end


function object_contact_point = find_object_contact (object_rect, human_trajectory, time_stamp, scaling_factor)




arm_segment_near_object = human_trajectory(time_stamp-10:time_stamp,:);


%rectangles are assumed to be in MATLAB format
x = object_rect(1);
y = object_rect(2);
w = object_rect(3);
h = object_rect(4);


%initialize 8 rectangles rep. space around the object 
neighbor_names = ["FF";"BB";"LL";"RR";"FR";"FL";"BR";"BL"];

neighbor_rect = zeros(8,4);

%forward
neighbor_rect(1,:) = [x y+h w scaling_factor*h];

%backward
neighbor_rect(2,:) = [x y-scaling_factor*h w scaling_factor*h];

%left
neighbor_rect(3,:) = [x-scaling_factor*w y scaling_factor*w h];

%right
neighbor_rect(4,:) = [x+w y scaling_factor*w h];

%forward-right
neighbor_rect(5,:) = [x+w y+h scaling_factor*w scaling_factor*h];

%forward-left
neighbor_rect(6,:) = [x-scaling_factor*w y+h scaling_factor*w scaling_factor*h];

%backward-right
neighbor_rect(7,:) = [x+w  y-scaling_factor*h scaling_factor*w scaling_factor*h];

%backward-left
neighbor_rect(8,:) = [x-scaling_factor*w y-scaling_factor*h scaling_factor*w scaling_factor*h];

segment_overlap = line_overlap_with_rectangles(neighbor_rect ,arm_segment_near_object);

[~ , imax] = max(segment_overlap);

object_contact_point = neighbor_names(imax);

% %compute the overlap area between each neighboring rectangle and 
% %the human hand when approached the object
% overlap_with_objects = zeros(8,1);
% for ii = 1 : size(neighbor_rect,1)
%     %area overlap between this neigboring rectangle and scene objects
%     overlap_amount = retcangles_overlap_wh(all_occluding_objects , neighbor_rect(ii,:));
%     %ratio of overlap to the area of this neighboring rectangle (neighbor_rect(ii,3)*neighbor_rect(ii,4))
% %     overlap_amount = overlap_amount/object_area;
%     %sum over all objects in the scene
%     overlap_with_objects(ii) = sum(overlap_amount);
% end

end