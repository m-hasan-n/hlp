

%how much free space around each object in all 8 directions
function [neighbor_space, neighbor_rect,neighbor_names ]= compute_neighbor_space ...
    (object_rect , all_occluding_objects, scaling_factor, direction_return_flag)

%rectangles are assumed to be in MATLAB format

x = object_rect(1);
y = object_rect(2);
w = object_rect(3);
h = object_rect(4);


%initialize 8 rectangles around the object 
neighbor_names = ['FF';'BB';'LL';'RR';'FR';'FL';'BR';'BL'];

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


%compute the overlap area between each neighboring rectangle and 
%the objects in the scene excluding traget
%this gives a measure of the obstructed area around each object 
overlap_with_objects = zeros(8,1);
for ii = 1 : size(neighbor_rect,1)
    %area overlap between this neigboring rectangle and scene objects
    overlap_amount = retcangles_overlap_wh(all_occluding_objects , neighbor_rect(ii,:));
    %ratio of overlap to the area of this neighboring rectangle (neighbor_rect(ii,3)*neighbor_rect(ii,4))
%     overlap_amount = overlap_amount/object_area;
    %sum over all objects in the scene
    overlap_with_objects(ii) = sum(overlap_amount);
end

%area of free space inside each neighboring rectangle
free_space_inside =  neighbor_rect(:,3).*neighbor_rect(:,4) - overlap_with_objects;
%normalized by area of each neighboring rectangle
free_space_inside = free_space_inside ./ (neighbor_rect(:,3).*neighbor_rect(:,4));

%if direction information of free space are not required in the output
%i.e. sum of free space around is needed regarfdless of specific neihborhood
if direction_return_flag==0
    % sum over all directions and normalize by the number of neighboring rectangles
    total_overlap_normalized = sum(free_space_inside)/8;
else
    total_overlap_normalized = free_space_inside; %
end

%free space is now normalized from 0 to 1 
neighbor_space = total_overlap_normalized;







