
%Compute features describing single gaps
%In a MOVING scenarios

function [navi_examples, gap_flags]= single_gap_description_MOVING...
                              (gap_rectangles_bl,target_center, gap_flags,start_pos,...
                              hand_width, N_features,table_diag,row_heights,interaction_flag,obj_rectangle)
                                                

                          
%adjusting gap_flags using information from interaction_flag
%for 2-rows 8-gaps structure
%gap_flags should be zero if interaction_flag is 1
if interaction_flag(1)==1
    gap_flags(1:4) = [0;0;0;0];
end
if interaction_flag(2)==1
    gap_flags(5:8) = [0;0;0;0];
end

%number of gab rectangles
N_gabs = size(gap_rectangles_bl,1);

%centers of gab rectangles
%gab rectangles are given in MATLAB format: x,y (bottom left),w,h
%from bottom-left to center format
gab_cent_format = to_rectangles_cent_format(gap_rectangles_bl);
gab_centers = gab_cent_format(:,1:2);
           
%gap diagonal as a measure of size
gap_diagonals = (gap_rectangles_bl(:,3).^2 + gap_rectangles_bl(:,4).^2).^ 0.5;

%TO which row each gab belongs?
N_rows = length(row_heights);
gab_center_heights = gab_centers(:,2);
gab_row_ids = zeros(N_gabs,1);
for ii = 1 : N_rows
    ids = abs(gab_center_heights-row_heights(ii))<=1e-5;
    gab_row_ids(ids,1)=ii;
end

%centers of selected gabs
% selected_gab_centers = gab_centers(logical(gap_flags),:);


%iterate over all gabs
%Initialize: N features + 1 output
navi_examples = zeros(N_gabs, N_features+1); 

%location of the end effector (HAND) fixed at start_pos
pos_end_ef = start_pos;

%line from start to target
% start_target_line = [start_pos; target_center];


for ii = 1 : N_gabs
    
%     % location of the end effector (HAND) depends on which row the gab exists
%     if gab_row_ids(ii)==1
%         %before first row, end effector is at the starting location
%         pos_end_ef = start_pos;
%     else
%         %before second row, end effector is at the selected gap/object in first row
%         %based on the interaction decision
%         if interaction_flag(1)==0
%             pos_end_ef_Y = row_heights(gab_row_ids(ii)-1);
%             pos_end_ef_X = selected_gab_centers(gab_row_ids(ii)-1);
%         else
%             pos_end_ef_X = obj_rectangle(1);
%             pos_end_ef_Y = obj_rectangle(2);
%         end
%         pos_end_ef = [pos_end_ef_X  pos_end_ef_Y];
%     end
    
    
    %NORMALIZED distance between gap and end effector
    dist_start = ((sum((gab_centers(ii,:)-pos_end_ef).^2))^0.5)/table_diag;
    %dist_start = (sum((gab_centers(ii,:)-start_pos).^2))^0.5/table_diag;
     
    %distance between gap and target centers
    dist_target = ((sum((gab_centers(ii,:)-target_center).^2))^0.5)/table_diag;
    
    %Ratio of size (width) of gap to size of end effector
    size_difference = (gap_diagonals(ii,:))/table_diag; %- hand_width
        
    %computing orientation of a straight line from gap to starting  atan2(Y,X)
    dx_start = gab_centers(ii,1)-pos_end_ef(1); 
    dy_start = gab_centers(ii,2)-pos_end_ef(2);
    theta_start = atan2(dy_start,dx_start);
    
%     computing orientation of a straight line from gap to target  atan2(Y,X)
    dx_target = gab_centers(ii,1) - target_center(1);
    dy_target = gab_centers(ii,2) - target_center(2);
    theta_goal = atan2(dy_target,dx_target);
    
%     intersection of normal from gap cent to start-target line
%     intersec_pnt = perpendicular_to_line(start_target_line,gab_centers(ii,:));
%     perp_dist = (sum((intersec_pnt - gab_centers(ii,:)).^2))^0.5;
    
    %feature vector
    gap_features = [  dist_start dist_target  size_difference theta_start theta_goal]; %theta_start theta_goal  gaps_overlap(ii)
%     gap_features = [dist_start+dist_target    gap_diagonals(ii,:)]/table_diag; %perp_dist
    
    %navigation example
    navi_examples(ii,:) = [gap_features gap_flags(ii)];
    
end


