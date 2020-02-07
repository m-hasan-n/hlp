
function mov_dir = find_moving_direction(neighbor_rect,final_rect,neighbor_names)

wh_rect_overlap = retcangles_overlap_wh(neighbor_rect , final_rect);
[~ , id] = max(wh_rect_overlap);
mov_dir = neighbor_names(id,:);

% %Forward cases Y = +
% if diff_y >= delta_y
%     
%     %Forward          Y = + , X = 0
%     if abs(diff_x) <= zeros_xy
%         mov_dir = 'FF';
%         %Forward-Right    Y = + , X = +
%     elseif diff_x >= delta_x
%         mov_dir = 'FR';
%         %Forward-Left    Y = + , X = -
%     elseif (-diff_x) >= delta_x
%         mov_dir = 'FL';
%     end
%     
%     
%     % Backward Cases Y = -
% elseif (-diff_y) >= delta_y
%     %Backward     Y = - , X = 0
%     if abs(diff_x) <= zeros_xy
%         mov_dir = 'BB';
%         
%         %Back Right   Y = - , X = +
%     elseif diff_x >= delta_x
%         mov_dir = 'BR';
%         
%         %Back Left    Y = - , X = -
%     elseif (-diff_x) >= delta_x
%         mov_dir = 'BL';
%     end
%     
%     %Right and Left  Y = 0
% else %abs(diff_y)<= zeros_xy
%     
%     %Right           Y = 0 , X = +
%     if diff_x >= delta_x
%         mov_dir = 'RR';
%         %Left           Y = 0 , X = -
%     elseif (-diff_x) >= delta_x
%         mov_dir = 'LL';
%     end
%     
% end