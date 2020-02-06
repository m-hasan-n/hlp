
%convert from x,y center rectangle definition
%to x,y bottom-left matlab rectangle definition

function mat_rectangles = to_matlab_rectangles(cent_rectangles)

objects_X = cent_rectangles(:,1);
objects_Y = cent_rectangles(:,2);
objects_W = cent_rectangles(:,3);
objects_H = cent_rectangles(:,4);

mat_rectangles =[objects_X-objects_W/2   objects_Y-objects_H/2   objects_W  objects_H];