
%measure of arm collision
%represented as sum bu collision of arm links with surrounding objects
function arm_collision_feature = arm_collision_measure(current_config, current_elbow,...
    current_shoulder,...
            current_hand,current_neck, next_config,next_elbow,  next_shoulder,...
            next_hand, next_neck, occluding_objects, link_region,scan_resolution)


flip_trig_flag = 1;
line_region_start = link_region/2;

% neck_shoulder_path      
neck_path = [current_neck;next_neck];
dd = diff(neck_path);
line_orient_neck = atan2(dd(2),dd(1));

shoulder_path = [current_shoulder;next_shoulder];
dd = diff(shoulder_path);
line_orient_shoulder = atan2(dd(2),dd(1));

line_orient = min(line_orient_neck,line_orient_shoulder);

l1 = (sum((next_neck - current_neck).^2)).^0.5;
l2 = (sum((next_shoulder - current_shoulder).^2)).^0.5;
line_region_end = link_region/2 + max(l1,l2);

neck_shoulder_path =[current_neck;current_shoulder];
% line_region_end = link_region/2 + find_region_limits (neck_path , shoulder_path);
arm_collision(1,:) = overlap_arbitrary_line_rectangle(neck_shoulder_path, line_region_start,line_region_end,...
    occluding_objects, scan_resolution,line_orient,flip_trig_flag); 


%shoulder_elbow_path
elbow_path = [current_elbow;next_elbow];
dd = diff(elbow_path);
line_orient_elbow = atan2(dd(2),dd(1));

line_orient = min(line_orient_shoulder,line_orient_elbow);


l1 = (sum((next_shoulder - current_shoulder).^2)).^0.5;
l2 = (sum((next_elbow - current_elbow).^2)).^0.5;
line_region_end = link_region/2 + max(l1,l2);
shoulder_elbow_path = [current_shoulder;current_elbow];
arm_collision(2,:) = overlap_arbitrary_line_rectangle(shoulder_elbow_path, line_region_start,line_region_end,...
    occluding_objects, scan_resolution,line_orient,flip_trig_flag);


%elbow_hand_path
hand_path = [current_hand;next_hand];
dd = diff(hand_path);
line_orient_hand = atan2(dd(2),dd(1));
line_orient = min(line_orient_elbow,line_orient_hand);

l1 = (sum((next_elbow - current_elbow).^2)).^0.5;
l2 = (sum((next_hand - current_hand).^2)).^0.5;
line_region_end = link_region/2 + max(l1,l2);
elbow_hand_path = [current_elbow;current_hand];
arm_collision(3,:) = overlap_arbitrary_line_rectangle(elbow_hand_path, line_region_start,line_region_end,...
    occluding_objects, scan_resolution,line_orient,flip_trig_flag);


arm_collision_feature = sum(arm_collision);

end



function segments_polygon = polygon_from_two_segments(two_segments_vector)

Xmin = min(two_segments_vector(:,1));
Ymin = min(two_segments_vector(:,2));
Xmax = max(two_segments_vector(:,1));
Ymax = max(two_segments_vector(:,2));

segments_polygon = [Xmin Ymin Xmax Ymax];
end



function lmax = find_region_limits (starting_segment , ending_segment)

Xi = starting_segment(1,1); Yi = starting_segment(1,2);
Xf = starting_segment(end,1); Yf = starting_segment(end,2); 
line(10*[Xi Xf] ,10*[Yi Yf] ,'Color','r');

dx = Xf-Xi;
dy = Yf-Yi;
line_orient = atan2(dy,dx);

p3 = project_point_line(starting_segment(1,:),tan(line_orient),ending_segment(1,:),-1/tan(line_orient));
p4 = project_point_line(starting_segment(1,:),tan(line_orient),ending_segment(2,:),-1/tan(line_orient));

l3 = (sum((starting_segment(1,:) - p3).^2)).^0.5;
l4 = (sum((starting_segment(1,:) - p4).^2)).^0.5;

lmax = max(l3, l4);

end


function p3 = project_point_line(p1,m1,p2,m2)

x1 = p1(1);
y1 = p1(2);
x2 = p2(1);
y2 = p2(2);

x3 = (m1*x1 - m2*x2 + y2 - y1)/(m1-m2);
y3 = m1*(x3-x1)+y1;

p3 = [x3 y3];

% plot(10*x1,10*y1,'r*','MarkerSize',15)
% plot(10*x2,10*y2,'g*','MarkerSize',15)
% plot(10*x3,10*y3,'b*','MarkerSize',15)
% line(10*[x1 x3] ,10*[y1 y3] ); %,'Color','r'
% line(10*[x2 x3] ,10*[y2 y3] );

end



%old veriosn
% arm_collision(1,:) = overlap_arbitrary_line_rectangle(neck_path, line_region_start,line_region_end,...
%     occluding_objects, scan_resolution); 
% 
% shoulder_path = [current_shoulder;next_shoulder];
% arm_collision(2,:) = overlap_arbitrary_line_rectangle(shoulder_path, line_region_start,line_region_end,...
%     occluding_objects, scan_resolution); 
% 
% arm_collision(3,:) = overlap_arbitrary_line_rectangle(elbow_path, line_region_start,line_region_end,...
%     occluding_objects, scan_resolution);
% 
% hand_path = [current_hand;next_hand];
% arm_collision(4,:) = overlap_arbitrary_line_rectangle(hand_path, line_region_start,line_region_end,...
%     occluding_objects, scan_resolution);
% 
% 
% neck_shoulder_polygon = polygon_from_two_segments([neck_path;shoulder_path]);

