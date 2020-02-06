


function rectangles_cent_format = to_rectangles_cent_format (rectangles_bl_format)

rectangles_cent_format = [rectangles_bl_format(:,1)+rectangles_bl_format(:,3)/2 ...
    rectangles_bl_format(:,2)+rectangles_bl_format(:,4)/2  rectangles_bl_format(:,3) rectangles_bl_format(:,4)];

