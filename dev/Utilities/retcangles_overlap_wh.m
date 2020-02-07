

%width and height
function wh_rect_overlap = retcangles_overlap_wh(set_rectangles , input_rectangle)


%check rectangle across width
Xs_cell = input_rectangle(1);
Xe_cell = Xs_cell + input_rectangle(3);

width_rect_overlap = zeros(size(set_rectangles,1),1);

for ii = 1:size(set_rectangles,1)
    
    Xs_gap = set_rectangles(ii,1);
    Xe_gap =Xs_gap + set_rectangles(ii,3);
    
    width_rect_overlap(ii,:) = lines_overlap(Xs_cell,Xe_cell,Xs_gap,Xe_gap);
end

%check rectangles across height
Ys_cell = input_rectangle(2);
Ye_cell = Ys_cell + input_rectangle(4);

height_rect_overlap = zeros(size(set_rectangles,1),1);

for ii = 1:size(set_rectangles,1)
    
    if width_rect_overlap(ii,:) ~= 0
        Ys_gap = set_rectangles(ii,2);
        Ye_gap =Ys_gap + set_rectangles(ii,4);
        
        height_rect_overlap(ii,:) = lines_overlap(Ys_cell,Ye_cell,Ys_gap,Ye_gap);
    end
end

wh_rect_overlap = width_rect_overlap .* height_rect_overlap;