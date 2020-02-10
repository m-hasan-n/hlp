%selected_gabs_flag
%identifies which gabs were selected by the human trajectory
%this will be the ground truth of the human selection
%selected_gabs_flag: 1 if selected and 0 if not
%human_trajectory: xy trajectory
%gab_rectangles: [x y w h]

function selected_gabs_flag = which_gab_selected (human_trajectory , gab_rectangles)

N_gabs = size(gab_rectangles,1);

selected_gabs_flag = zeros(N_gabs,1);

for ii = 1 : N_gabs
    xmin = gab_rectangles(ii,1);
    xmax = xmin + gab_rectangles(ii,3);
    ymin = gab_rectangles(ii,2);
    ymax = ymin + gab_rectangles(ii,4);
    
    x_passed = human_trajectory(:,1) > xmin & human_trajectory(:,1) < xmax;
    y_passed = human_trajectory(:,2) > ymin & human_trajectory(:,2) < ymax;
    xy_passed = x_passed & y_passed;
    
    selected_gabs_flag(ii) = any(xy_passed);
end
