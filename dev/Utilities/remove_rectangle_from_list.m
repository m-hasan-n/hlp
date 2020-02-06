

%removes a rectangle from alist of rectangles
function rectangles_list = remove_rectangle_from_list(source_obj,rectangles_list)

difx = rectangles_list - source_obj;
difx = sum(difx,2);
idx = difx==0;
rectangles_list(idx,:)=[];