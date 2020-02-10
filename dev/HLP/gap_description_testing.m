


function gap_features = gap_description_testing...
                              (gab_rectangles,target_center, hand_pos,...
                              hand_width, N_features,table_diag)
                          


%number of gab rectangles
N_gabs = size(gab_rectangles,1);

%centers of gab rectangles
%gab rectangles x,y (bottom left corner),w,h
%from bottom-left to center format
gab_cent_format = to_rectangles_cent_format(gab_rectangles);
gab_centers = gab_cent_format(:,1:2);
% gab_centers = [gab_rectangles(:,1)+gab_rectangles(:,3)/2 gab_rectangles(:,2)+gab_rectangles(:,4)/2];

%gap diagonal as a measure of size
gap_diagonals = (gab_rectangles(:,3).^2 + gab_rectangles(:,4).^2).^ 0.5;


%the hand is assumed to be at the given start_pos
pos_end_ef = hand_pos;
    
%line from start to target
% start_target_line = [pos_end_ef; target_center];


%iterate over given gabs 
gap_features = zeros(N_gabs, N_features); 
for ii = 1 : N_gabs
    
    %NORMALIZED distance between gap and end effector
    dist_start = ((sum((gab_centers(ii,:)-pos_end_ef).^2))^0.5)/table_diag;
    %dist_start = (sum((gab_centers(ii,:)-start_pos).^2))^0.5/table_diag;
     
    %distance between gap and target centers
    dist_target = ((sum((gab_centers(ii,:)-target_center).^2))^0.5)/table_diag;
    
    %Ratio of size (width) of gap to size of end effector
    size_ratio = (gap_diagonals(ii,:) )/table_diag; %-  hand_width
    
    %computing orientation of a straight line from hand to gap  atan2(Y,X)
    dx_start = gab_centers(ii,1)-pos_end_ef(1); 
    dy_start = gab_centers(ii,2)-pos_end_ef(2);
    theta_start = atan2(dy_start,dx_start);
    
    %computing orientation of a straight line from gap to target  atan2(Y,X)
    dx_target = gab_centers(ii,1) - target_center(1);
    dy_target = gab_centers(ii,2) - target_center(2) ;
    theta_goal = atan2(dy_target,dx_target);
    
    %intersection of normal from gap cent to start-target line
%     intersec_pnt = perpendicular_to_line(start_target_line,gab_centers(ii,:));
%     perp_dist = (sum((intersec_pnt - gab_centers(ii,:)).^2))^0.5;
    
    %feature vector
    gap_features(ii,:) = [  dist_start dist_target  size_ratio theta_start theta_goal];
                        
%     gap_features(ii,:) = [dist_start+dist_target    gap_diagonals(ii,:)]/table_diag; %perp_dist
end



end